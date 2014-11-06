load('C:\ExpyVR\Paradigms\Subjects file 7T_noMichael.mat');    % subjects filenames list
expyvr_log_dir='C:\ExpyVR\log\';

subjects_output_dir = 'F:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end);

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');


%% making response-time based PRTs and SDMs

for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    
    prt_files=getfullfiles(fullfile(ACPC_output_dir,'paradigm_domains_*.prt')); % assumes regular PRTs were already created using another script
    
    for i=1:length(prt_files)
        % find adequate xls_w_ques_fields file (created by another script)
        [~,~,curr_data_for_PRT]=xlsread([expyvr_log_dir num2str(subjects{s,2+i}) '_XLS_w_quest_fields.xls']);
        old_prt=xff(prt_files{i});
        
        % calculate median RT for all RTs larger than 0
        % (NOTICE THAT THE MEDIAN RT IS OF ALL STIMULI IN THE RUN, AND NOT BY DOMAIN)
        all_RTs=[all_RTs; cell2mat(curr_data_for_PRT(2:end,7))];
        %         median_RT=median(all_RTs(all_RTs>0));
        quartile_RTs=quantile(all_RTs,[0.25 0.75]);
    end
    
    for i=1:length(prt_files)
        % find adequate xls_w_ques_fields file (created by another script)
        [~,~,curr_data_for_PRT]=xlsread([expyvr_log_dir num2str(subjects{s,2+i}) '_XLS_w_quest_fields.xls']);
        old_prt=xff(prt_files{i});

        condition_names={'pe_high_RT','pe_med_RT','pe_low_RT','pl_high_RT','pl_med_RT','pl_low_RT','ti_high_RT','ti_med_RT','ti_low_RT'};
        condition_onoffsets=cell(1,9);
        
        for linenum=2:size(curr_data_for_PRT,1)
            curr_RT=curr_data_for_PRT{linenum,7};
            curr_domain=curr_data_for_PRT{linenum,2}(1:2);
            curr_trial_time=curr_data_for_PRT{linenum,1}+1;
            %             if curr_RT>=median_RT
            if curr_RT>=quartile_RTs(2)
                % add to adequate condition (by domain)
                if strcmp(curr_domain,'pe')
                    condition_onoffsets{1,1}=[condition_onoffsets{1,1}; curr_trial_time curr_trial_time];
                elseif strcmp(curr_domain,'pl')
                    condition_onoffsets{1,4}=[condition_onoffsets{1,4}; curr_trial_time curr_trial_time];
                elseif strcmp(curr_domain,'ti')
                    condition_onoffsets{1,7}=[condition_onoffsets{1,7}; curr_trial_time curr_trial_time];
                end
            elseif curr_RT>quartile_RTs(1)   && curr_RT<quartile_RTs(2)
                if strcmp(curr_domain,'pe')
                    condition_onoffsets{1,2}=[condition_onoffsets{1,2}; curr_trial_time curr_trial_time];
                elseif strcmp(curr_domain,'pl')
                    condition_onoffsets{1,5}=[condition_onoffsets{1,5}; curr_trial_time curr_trial_time];
                elseif strcmp(curr_domain,'ti')
                    condition_onoffsets{1,8}=[condition_onoffsets{1,8}; curr_trial_time curr_trial_time];
                end
            %             elseif curr_RT>0   % smaller than median RT but not -1
            elseif curr_RT>0   && curr_RT<=quartile_RTs(1) % smaller than quartile RT but not -1
                % add to adequate condition (by domain)
                if strcmp(curr_domain,'pe')
                    condition_onoffsets{1,3}=[condition_onoffsets{1,3}; curr_trial_time curr_trial_time];
                elseif strcmp(curr_domain,'pl')
                    condition_onoffsets{1,6}=[condition_onoffsets{1,6}; curr_trial_time curr_trial_time];
                elseif strcmp(curr_domain,'ti')
                    condition_onoffsets{1,9}=[condition_onoffsets{1,9}; curr_trial_time curr_trial_time];
                end
            end
        end
        
        % save PRT file
        prt_xff=xff('new:prt');     % new contrast structure, using NeuroElf
        prt_xff.ResolutionOfTime = 'Volumes';
        prt_xff.Experiment = ['Response Time run' num2str(i)];
        prt_xff.ParametricWeights = 0;
        prt_xff.AddCond('rest', old_prt.Cond(1).OnOffsets);  % rest condition from existing PRT
        for c=1:length(condition_names)
            prt_xff.AddCond(condition_names{c}, condition_onoffsets{c});
        end
        prt_xff.SaveAs(fullfile(ACPC_output_dir,['paradigm_RT_' num2str(i) '.prt']));
    end
    
    
    %% creating SDMs, MDMs, GLMs:
    vtc_files=getfullfiles(fullfile(ACPC_output_dir,'*.vtc'));
    prt_files=getfullfiles(fullfile(ACPC_output_dir,'paradigm_RT_*.prt'));
    motion_sdm_files=getfullfiles(fullfile(output_dir,'*3DMC.sdm'));
    vmr_filename=getfullfiles(fullfile(ACPC_output_dir, '*_ISO_ACPC.vmr'));
    vmr = bvqx.OpenDocument(vmr_filename{1});
    % remove rest files, if existing
    vtc_files(cellfun(@(x) ~isempty(strfind(x,'rest')), vtc_files))=[];
    motion_sdm_files(cellfun(@(x) ~isempty(strfind(x,'rest')), motion_sdm_files))=[];
    
    % create SDM for each session
    for i=1:length(vtc_files)
        vtc_filename = vtc_files{i}; prt_filename=prt_files{i};
        SDM_name = fullfile(ACPC_output_dir, [subj '_RT_' num2str(i) '.sdm']);
        vmr.LinkVTC(vtc_filename);
        vmr.LinkStimulationProtocol(prt_filename);
        % vmr.SaveVTC();  % save with link to protocol
        
        vmr.ClearDesignMatrix;
        vmr.AddPredictor('pe_high_RT'); vmr.SetPredictorValuesFromCondition('pe_high_RT', 'pe_high_RT', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pe_high_RT');
        vmr.AddPredictor('pe_med_RT'); vmr.SetPredictorValuesFromCondition('pe_med_RT', 'pe_med_RT', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pe_med_RT');
        vmr.AddPredictor('pe_low_RT'); vmr.SetPredictorValuesFromCondition('pe_low_RT', 'pe_low_RT', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pe_low_RT');
        vmr.AddPredictor('pl_high_RT'); vmr.SetPredictorValuesFromCondition('pl_high_RT', 'pl_high_RT', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pl_high_RT');
        vmr.AddPredictor('pl_med_RT'); vmr.SetPredictorValuesFromCondition('pl_med_RT', 'pl_med_RT', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pl_med_RT');
        vmr.AddPredictor('pl_low_RT'); vmr.SetPredictorValuesFromCondition('pl_low_RT', 'pl_low_RT', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pl_low_RT');
        vmr.AddPredictor('ti_high_RT'); vmr.SetPredictorValuesFromCondition('ti_high_RT', 'ti_high_RT', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('ti_high_RT');
        vmr.AddPredictor('ti_med_RT'); vmr.SetPredictorValuesFromCondition('ti_med_RT', 'ti_med_RT', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('ti_med_RT');
        vmr.AddPredictor('ti_low_RT'); vmr.SetPredictorValuesFromCondition('ti_low_RT', 'ti_low_RT', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('ti_low_RT');
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
            SDM_name = fullfile(ACPC_output_dir, [subj '_RT_' num2str(i) '.sdm']);
            if isempty(strfind(vtc_filename,'highres')) % checking that it is not a high-res scan (cannot combine different resolutions in one GLM)
                vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);
            end
        end
    end
    i=length(vtc_files);        % adding the control run, even with excessive motion
    vtc_filename = vtc_files{i};
    SDM_name = fullfile(ACPC_output_dir, [subj '_RT_' num2str(i) '.sdm']);
    vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);
    
    % creating the MDM
    MDM_name = fullfile(ACPC_output_dir, [subj '_RT_ACPC.mdm']);
    vmr.SaveMultiStudyGLMDefinitionFile(MDM_name);
    
    % creating GLM
    GLM_name = fullfile(ACPC_output_dir, [subj '_RT_ACPC.glm']);
    vmr.CorrectForSerialCorrelations = 1;
    vmr.SeparationOfStudyPredictors = 1;
    vmr.PSCTransformStudies = 1;
    vmr.ComputeMultiStudyGLM;
    vmr.SaveGLM(GLM_name);
    
    %% creating contrasts:
    mdm=xff(MDM_name);
    num_sessions=mdm.NrOfStudies;
    
    % adding contrasts - without control
    CTR_name = fullfile(ACPC_output_dir, [subj '_RT_ACPC.ctr']);
    ctr={}; ctr_names={};
    i=1; ctr_names{i}='RT person hign vs low'; ctr{i}=[repmat([1 -1 0 0 0 0],1,num_sessions-1) zeros(1,6)];
    i=2; ctr_names{i}='RT person low vs high'; ctr{i}=[repmat([-1 1 0 0 0 0],1,num_sessions-1) zeros(1,6)];
    i=3; ctr_names{i}='RT place hign vs low'; ctr{i}=[repmat([0 0 1 -1 0 0],1,num_sessions-1) zeros(1,6)];
    i=4; ctr_names{i}='RT place low vs high'; ctr{i}=[repmat([0 0 -1 1 0 0],1,num_sessions-1) zeros(1,6)];
    i=5; ctr_names{i}='RT time hign vs low'; ctr{i}=[repmat([0 0 0 0 1 -1],1,num_sessions-1) zeros(1,6)];
    i=6; ctr_names{i}='RT time low vs high'; ctr{i}=[repmat([0 0 0 0 -1 1],1,num_sessions-1) zeros(1,6)];
    i=7; ctr_names{i}='RT all domains hign vs low'; ctr{i}=[repmat([1 -1 1 -1 1 -1],1,num_sessions-1) zeros(1,6)];
    i=8; ctr_names{i}='RT all domains low vs high'; ctr{i}=[repmat([-1 1 -1 1 -1 1],1,num_sessions-1) zeros(1,6)];
    
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
