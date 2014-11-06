load('C:\ExpyVR\Paradigms\Subjects file 7T_noMichael.mat');    % subjects filenames list
expyvr_log_dir='C:\ExpyVR\log\';

subjects_output_dir = 'F:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end);

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');


%% making word-length based PRTs and SDMs

num_subjects_to_use = 16;

for s=1:num_subjects_to_use
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    
    prt_files=getfullfiles(fullfile(ACPC_output_dir,'paradigm_domains_*.prt')); % assumes regular PRTs were already created using another script
    vtc_files=getfullfiles(fullfile(ACPC_output_dir,'*.vtc'));
    motion_sdm_files=getfullfiles(fullfile(output_dir,'*3DMC.sdm'));
    % remove rest files, if existing
    vtc_files(cellfun(@(x) ~isempty(strfind(x,'rest')), vtc_files))=[];
    motion_sdm_files(cellfun(@(x) ~isempty(strfind(x,'rest')), motion_sdm_files))=[];

    for i=1:length(prt_files)
        % find adequate xls_w_ques_fields file (created by another script)
        [~,~,curr_data_for_PRT]=xlsread([expyvr_log_dir num2str(subjects{s,2+i}) '_XLS_w_quest_fields.xls']);
        old_prt=xff(prt_files{i});
        
        condition_names={'pe','pl','ti'};
        condition_onoffsets=cell(1,3);
        condition_onoffsets_all=[];
        
        for linenum=2:size(curr_data_for_PRT,1)
            curr_wordlength=curr_data_for_PRT{linenum,11};       % wordlength is in column 11
            curr_domain=curr_data_for_PRT{linenum,2}(1:2);
            curr_trial_time=curr_data_for_PRT{linenum,1}+1;
            if ~isnan(curr_wordlength)
                % add to adequate domain condition
                if strcmp(curr_domain,'pe')
                    condition_onoffsets{1,1}=[condition_onoffsets{1,1}; curr_trial_time curr_trial_time curr_wordlength];
                elseif strcmp(curr_domain,'pl')
                    condition_onoffsets{1,2}=[condition_onoffsets{1,2}; curr_trial_time curr_trial_time curr_wordlength];
                elseif strcmp(curr_domain,'ti')
                    condition_onoffsets{1,3}=[condition_onoffsets{1,3}; curr_trial_time curr_trial_time curr_wordlength];
                end
                condition_onoffsets_all=[condition_onoffsets_all; curr_trial_time curr_trial_time curr_wordlength];
            else
                if strcmp(curr_domain,'pe')
                    condition_onoffsets{1,1}=[condition_onoffsets{1,1}; curr_trial_time curr_trial_time 0];
                elseif strcmp(curr_domain,'pl')
                    condition_onoffsets{1,2}=[condition_onoffsets{1,2}; curr_trial_time curr_trial_time 0];
                elseif strcmp(curr_domain,'ti')
                    condition_onoffsets{1,3}=[condition_onoffsets{1,3}; curr_trial_time curr_trial_time 0];
                end
            end
        end
        
        % adding mean of condition to unknown timepoints
        for q=1:3
            condition_onoffsets{q}(condition_onoffsets{q}(:,3)==0,3) = mean(condition_onoffsets{q}(condition_onoffsets{q}(:,3)>0,3));
        end
        
        % save PRT file
        prt_xff=xff('new:prt');     % new contrast structure, using NeuroElf
        prt_xff.ResolutionOfTime = 'Volumes';
        prt_xff.Experiment = ['Word length run' num2str(i)];
        prt_xff.ParametricWeights = 1;
        prt_xff.FileVersion = 3;
        prt_xff.AddCond('rest', old_prt.Cond(1).OnOffsets);  % rest condition from existing PRT
        for c=1:length(condition_names)
            prt_xff.AddCond(condition_names{c}, condition_onoffsets{c});
        end
        prt_xff.SaveAs(fullfile(ACPC_output_dir,['paradigm_wordlength_' num2str(i) '.prt']));
        
        % creating SDM file from the PRT for each run
        sdm_inc_confounds = prt_xff.CreateSDM(struct('nvol', 160, 'prtr', 2500, 'rcond', 1));
        % adding motion confound variables
        sdm_motion = xff(motion_sdm_files{i});
        sdm_inc_confounds.NrOfPredictors = sdm_inc_confounds.NrOfPredictors + sdm_motion.NrOfPredictors;
        sdm_inc_confounds.PredictorColors = [sdm_inc_confounds.PredictorColors(1:end-1,:); sdm_motion.PredictorColors; sdm_inc_confounds.PredictorColors(end,:)];
        sdm_inc_confounds.PredictorNames = [sdm_inc_confounds.PredictorNames(1:end-1) sdm_motion.PredictorNames sdm_inc_confounds.PredictorNames(end)];
        sdm_inc_confounds.SDMMatrix = [sdm_inc_confounds.SDMMatrix(:,1:end-1) sdm_motion.SDMMatrix sdm_inc_confounds.SDMMatrix(:,end)];
        sdm_inc_confounds.SaveAs(fullfile(ACPC_output_dir, [subj '_wordlength_' num2str(i) '.sdm']));
        
        prt_xff.ClearObject;
        sdm_inc_confounds.ClearObject;

%         % save PRT file for all stimuli together (with no domains)
%         prt_xff=xff('new:prt');     % new contrast structure, using NeuroElf
%         prt_xff.ResolutionOfTime = 'Volumes';
%         prt_xff.Experiment = ['Word length no domains run' num2str(i)];
%         prt_xff.ParametricWeights = 1;
%         prt_xff.FileVersion = 3;
%         prt_xff.AddCond('rest', old_prt.Cond(1).OnOffsets);  % rest condition from existing PRT
%         prt_xff.AddCond('all_stimuli', condition_onoffsets_all);
%         prt_xff.SaveAs(fullfile(ACPC_output_dir,['paradigm_wordlength_nodomains_' num2str(i) '.prt']));
        
    end
    
    
    %% creating MDMs and GLMs:
    
%     vtc_files=getfullfiles(fullfile(ACPC_output_dir,'*.vtc'));
%     motion_sdm_files=getfullfiles(fullfile(output_dir,'*3DMC.sdm'));
%     % remove rest files, if existing
%     vtc_files(cellfun(@(x) ~isempty(strfind(x,'rest')), vtc_files))=[];
%     motion_sdm_files(cellfun(@(x) ~isempty(strfind(x,'rest')), motion_sdm_files))=[];

    prt_files=getfullfiles(fullfile(ACPC_output_dir,'paradigm_wordlength_*.prt'));
    vmr_filename=getfullfiles(fullfile(ACPC_output_dir, '*_ISO_ACPC.vmr'));
    vmr = bvqx.OpenDocument(vmr_filename{1});
    
%     % create SDM for each session
%     for i=1:length(vtc_files)
%         vtc_filename = vtc_files{i}; prt_filename=prt_files{i};
%         SDM_name = fullfile(ACPC_output_dir, [subj '_wordlength_' num2str(i) '.sdm']);
%         vmr.LinkVTC(vtc_filename);
%         vmr.LinkStimulationProtocol(prt_filename);
%         % vmr.SaveVTC();  % save with link to protocol
%         
%         vmr.ClearDesignMatrix;
%         vmr.AddPredictor('pe'); vmr.SetPredictorValuesFromCondition('pe', 'pe', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pe');
%         vmr.AddPredictor('pl'); vmr.SetPredictorValuesFromCondition('pl', 'pl', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pl');
%         vmr.AddPredictor('ti'); vmr.SetPredictorValuesFromCondition('ti', 'ti', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('ti');
%         vmr.SDMContainsConstantPredictor = 0;
%         vmr.SaveSingleStudyGLMDesignMatrix(SDM_name);
%         
%         % adding motion confound variables
%         sdm_inc_confounds=xff(SDM_name);
%         sdm_motion=xff(motion_sdm_files{i});
%         sdm_inc_confounds.NrOfPredictors=sdm_inc_confounds.NrOfPredictors+sdm_motion.NrOfPredictors;
%         sdm_inc_confounds.PredictorColors=[sdm_inc_confounds.PredictorColors;sdm_motion.PredictorColors];
%         sdm_inc_confounds.PredictorNames=[sdm_inc_confounds.PredictorNames sdm_motion.PredictorNames];
%         sdm_inc_confounds.SDMMatrix=[sdm_inc_confounds.SDMMatrix sdm_motion.SDMMatrix];
%         sdm_inc_confounds.SaveAs(SDM_name);
%     end
    
    % adding sdm files to MDM - without the control run
    vmr.ClearMultiStudyGLMDefinition;
    for i=1:length(vtc_files)-1     % all runs except the last (control)
        motion_sdm = xff(motion_sdm_files{i});
        if isempty(find(motion_sdm.SDMMatrix>1.7,1))  % checking that there is no excessive motion in the run
            vtc_filename = vtc_files{i};
            SDM_name = fullfile(ACPC_output_dir, [subj '_wordlength_' num2str(i) '.sdm']);
            if isempty(strfind(vtc_filename,'highres')) % checking that it is not a high-res scan (cannot combine different resolutions in one GLM)
                vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);
            end
        end
        motion_sdm.ClearObject;
    end
%     i=length(vtc_files);        % adding the control run, even with excessive motion
%     vtc_filename = vtc_files{i};
%     SDM_name = fullfile(ACPC_output_dir, [subj '_wordlength_' num2str(i) '.sdm']);
%     vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);
    
    % creating the MDM
    MDM_name = fullfile(ACPC_output_dir, [subj '_wordlength_ACPC.mdm']);
    vmr.SaveMultiStudyGLMDefinitionFile(MDM_name);
    
    % creating GLM
    GLM_name = fullfile(ACPC_output_dir, [subj '_wordlength_ACPC.glm']);
    vmr.CorrectForSerialCorrelations = 1;
    vmr.SeparationOfStudyPredictors = 1;
    vmr.PSCTransformStudies = 1;
    vmr.ComputeMultiStudyGLM;
    vmr.SaveGLM(GLM_name);
    
    %% creating contrasts:
    mdm=xff(MDM_name);
    num_sessions=mdm.NrOfStudies;
    
    % adding contrasts - without control
    CTR_name = fullfile(ACPC_output_dir, [subj '_wordlength_ACPC.ctr']);
    ctr={}; ctr_names={};
    i=1; ctr_names{i}='wordlength person effect'; ctr{i}=[repmat([0 1 0 0 0 0],1,num_sessions)];
    i=2; ctr_names{i}='wordlength place effect'; ctr{i}=[repmat([0 0 0 1 0 0],1,num_sessions)];
    i=3; ctr_names{i}='wordlength time effect'; ctr{i}=[repmat([0 0 0 0 0 1],1,num_sessions)];
    i=4; ctr_names{i}='wordlength all domains effect'; ctr{i}=[repmat([0 1 0 1 0 1],1,num_sessions)];
    
    for i=1:length(ctr)
        ctr{i}=[ctr{i} zeros(1, num_sessions*7)];  % adding zeros for constant values and motion confounds
    end
    ctr_xff=xff('new:ctr');     % new contrast structure, using NeuroElf
    ctr_xff.NrOfContrasts = length(ctr_names);
    ctr_xff.NrOfValues = length(ctr{1});
    ctr_xff.ContrastNames = ctr_names;
    ctr_xff.ContrastValues = cell2mat(ctr');
    ctr_xff.SaveAs(CTR_name);
    
    mdm.ClearObject;
    ctr_xff.ClearObject;
    
end
