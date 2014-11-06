load('C:\ExpyVR\Paradigms\Subjects file 7T.mat');    % subjects filenames list
expyvr_log_dir='C:\ExpyVR\log\';

subjects_output_dir = 'e:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end);

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');

num_subjects = 16;

%% making future-past based PRTs

for s=1:num_subjects
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    
    prt_files=getfullfiles(fullfile(ACPC_output_dir,'paradigm_domains_*.prt')); % assumes regular PRTs were already created using another script
    
    for i=1:length(prt_files)
        % find adequate xls_w_ques_fields file (created by another script)
        [~,~,curr_data_for_PRT]=xlsread([expyvr_log_dir num2str(subjects{s,2+i}) '_XLS_w_quest_fields.xls']);
        old_prt=xff(prt_files{i});
        
        condition_names={'past_past','future_future','future_past'};
        condition_onoffsets=cell(1,3);
        
        for linenum=2:size(curr_data_for_PRT,1)
            curr_pastfuture=curr_data_for_PRT{linenum,19};
            curr_trial_time=curr_data_for_PRT{linenum,1}+1;
            if strcmp(curr_pastfuture,'pp')
                condition_onoffsets{1,1}=[condition_onoffsets{1,1}; curr_trial_time curr_trial_time];
            elseif strcmp(curr_pastfuture,'ff')
                condition_onoffsets{1,2}=[condition_onoffsets{1,2}; curr_trial_time curr_trial_time];
            elseif strcmp(curr_pastfuture,'fp')
                condition_onoffsets{1,3}=[condition_onoffsets{1,3}; curr_trial_time curr_trial_time];
            end
        end
        
        % save PRT file
        prt_xff=xff('new:prt');     % new contrast structure, using NeuroElf
        prt_xff.ResolutionOfTime = 'Volumes';
        prt_xff.Experiment = ['Future-Past run' num2str(i)];
        prt_xff.ParametricWeights = 0;
        prt_xff.AddCond('rest', old_prt.Cond(1).OnOffsets);  % rest condition from existing PRT
        for c=1:length(condition_names)
            prt_xff.AddCond(condition_names{c}, condition_onoffsets{c});
        end
        prt_xff.SaveAs(fullfile(ACPC_output_dir,['paradigm_futurepast_' num2str(i) '.prt']));
    end
    
    
    %% creating SDMs, MDMs, GLMs:
    vtc_files=getfullfiles(fullfile(ACPC_output_dir,'*.vtc'));
    prt_files=getfullfiles(fullfile(ACPC_output_dir,'paradigm_futurepast_*.prt'));
    motion_sdm_files=getfullfiles(fullfile(output_dir,'*3DMC.sdm'));
    vmr_filename=getfullfiles(fullfile(ACPC_output_dir, '*_ISO_ACPC.vmr'));
    vmr = bvqx.OpenDocument(vmr_filename{1});
    % remove rest files, if existing
    vtc_files(cellfun(@(x) ~isempty(strfind(x,'rest')), vtc_files))=[];
    motion_sdm_files(cellfun(@(x) ~isempty(strfind(x,'rest')), motion_sdm_files))=[];
    
    % create SDM for each session
    for i=1:length(vtc_files)
        vtc_filename = vtc_files{i}; prt_filename=prt_files{i};
        SDM_name = fullfile(ACPC_output_dir, [subj '_futurepast_' num2str(i) '.sdm']);
        vmr.LinkVTC(vtc_filename);
        vmr.LinkStimulationProtocol(prt_filename);
        % vmr.SaveVTC();  % save with link to protocol
        
        vmr.ClearDesignMatrix;
        vmr.AddPredictor('past_past'); vmr.SetPredictorValuesFromCondition('past_past', 'past_past', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('past_past');
        vmr.AddPredictor('future_future'); vmr.SetPredictorValuesFromCondition('future_future', 'future_future', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('future_future');
        vmr.AddPredictor('future_past'); vmr.SetPredictorValuesFromCondition('future_past', 'future_past', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('future_past');
        vmr.SDMContainsConstantPredictor = 0;
        vmr.SaveSingleStudyGLMDesignMatrix(SDM_name);
        
        % adding motion confound variables
        sdm_inc_confounds=xff(SDM_name);
        sdm_motion=xff(motion_sdm_files{i});
        sdm_inc_confounds.NrOfPredictors=sdm_inc_confounds.NrOfPredictors+sdm_motion.NrOfPredictors;
        sdm_inc_confounds.PredictorColors=[sdm_inc_confounds.PredictorColors;sdm_motion.PredictorColors];
        sdm_inc_confounds.PredictorNames=[sdm_inc_confounds.PredictorNames sdm_motion.PredictorNames];
        sdm_inc_confounds.SDMMatrix=[sdm_inc_confounds.SDMMatrix sdm_motion.SDMMatrix];
        sdm_inc_confounds.SaveAs(SDM_name);
    end
    
    % adding sdm files to MDM
    vmr.ClearMultiStudyGLMDefinition;
    for i=1:length(vtc_files)-1     % all runs except the last (control)
        motion_sdm = xff(motion_sdm_files{i});
        if isempty(find(motion_sdm.SDMMatrix>1.7,1))  % checking that there is no excessive motion in the run
            vtc_filename = vtc_files{i};
            SDM_name = fullfile(ACPC_output_dir, [subj '_futurepast_' num2str(i) '.sdm']);
            if isempty(strfind(vtc_filename,'highres')) % checking that it is not a high-res scan (cannot combine different resolutions in one GLM)
                vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);
            end
        end
    end
    i=length(vtc_files);        % adding the control run, even with excessive motion
    vtc_filename = vtc_files{i};
    SDM_name = fullfile(ACPC_output_dir, [subj '_futurepast_' num2str(i) '.sdm']);
    vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);
    
    % creating the MDM
    MDM_name = fullfile(ACPC_output_dir, [subj '_futurepast_ACPC.mdm']);
    vmr.SaveMultiStudyGLMDefinitionFile(MDM_name);
    
    % creating GLM
    GLM_name = fullfile(ACPC_output_dir, [subj '_futurepast_ACPC.glm']);
    vmr.CorrectForSerialCorrelations = 1;
    vmr.SeparationOfStudyPredictors = 1;
    vmr.PSCTransformStudies = 1;
    vmr.ComputeMultiStudyGLM;
    vmr.SaveGLM(GLM_name);
    
    %% creating contrasts:
    mdm=xff(MDM_name);
    num_sessions=mdm.NrOfStudies;
    
    % adding contrasts - without control
    CTR_name = fullfile(ACPC_output_dir, [subj '_futurepast_ACPC.ctr']);
    ctr={}; ctr_names={};
    i=1; ctr_names{i}='future vs past'; ctr{i}=[repmat([-1 1 0],1,num_sessions-1) zeros(1,3)];
    i=2; ctr_names{i}='past vs future'; ctr{i}=[repmat([1 -1 0],1,num_sessions-1) zeros(1,3)];
    i=3; ctr_names{i}='past>futurepast and future'; ctr{i}=[repmat([2 -1 -1],1,num_sessions-1) zeros(1,3)];
    i=4; ctr_names{i}='future>futurepast and past'; ctr{i}=[repmat([-1 2 -1],1,num_sessions-1) zeros(1,3)];
    i=5; ctr_names{i}='past vs rest'; ctr{i}=[repmat([1 0 0],1,num_sessions-1) zeros(1,3)];
    i=6; ctr_names{i}='future vs rest'; ctr{i}=[repmat([0 1 0],1,num_sessions-1) zeros(1,3)];
    
    for i=1:length(ctr)
        ctr{i}=[ctr{i} zeros(1, num_sessions*7)];  % adding zeros for constant values and motion confounds
    end
    ctr_xff=xff('new:ctr');     % new contrast structure, using NeuroElf
    ctr_xff.NrOfContrasts = length(ctr_names);
    ctr_xff.NrOfValues = length(ctr{1});
    ctr_xff.ContrastNames = ctr_names;
    ctr_xff.ContrastValues = cell2mat(ctr');
    ctr_xff.SaveAs(CTR_name);
    
end


