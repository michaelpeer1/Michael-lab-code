subjects_output_dir = 'e:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end);

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');

% creating new PRT files for adaptation analysis, in ACPC only
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    ACPC_output_dir=[fullfile(subjects_output_dir, subj) '\ACPC'];
    prt_files=getfullfiles(fullfile(ACPC_output_dir,'paradigm_domains_*.prt'));
    
    for i=1:length(prt_files)
        prt_filename=prt_files{i};
        current_prt=xff(prt_filename);
        old_conds=current_prt.Cond(2:4); current_prt.Cond = current_prt.Cond(1);
        for c=1:3
            for j=1:4
                current_cond=old_conds(c);
                current_cond.OnOffsets = current_cond.OnOffsets + [(j-1)*ones(6,1) (j-4)*ones(6,1)];
                current_cond.ConditionName{1} = [current_cond.ConditionName{1} '_trial' num2str(j)];
                current_prt.Cond(end+1) = current_cond;
            end
        end
        current_prt.SaveAs([prt_filename(1:end-13) 'adapt' prt_filename(end-13:end)]);
    end
end



% creating new design matrices for adaptation analyses (SDM, MDM and GLM files)
disp('Creating design matrices (.sdm and .mdm files)')
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    
    vtc_files=getfullfiles(fullfile(ACPC_output_dir,'*.vtc'));
    prt_files=getfullfiles(fullfile(ACPC_output_dir,'paradigm_adapt_domains_*.prt'));
    motion_sdm_files=getfullfiles(fullfile(output_dir,'*3DMC.sdm'));
    vmr_filename=getfullfiles(fullfile(ACPC_output_dir, '*_ISO_ACPC.vmr')); 
    vmr = bvqx.OpenDocument(vmr_filename{1});
    
    % remove rest files, if existing
    vtc_files(cellfun(@(x) ~isempty(strfind(x,'rest')), vtc_files))=[];
    motion_sdm_files(cellfun(@(x) ~isempty(strfind(x,'rest')), motion_sdm_files))=[];

    % create SDM for each session
    for i=1:length(vtc_files)
        vtc_filename = vtc_files{i}; prt_filename=prt_files{i};
        SDM_name = fullfile(ACPC_output_dir, [subj '_adapt_' num2str(i) '.sdm']);
        vmr.LinkVTC(vtc_filename);
        vmr.LinkStimulationProtocol(prt_filename);
        % vmr.SaveVTC();  % save with link to protocol
        
        vmr.ClearDesignMatrix;
        vmr.AddPredictor('pe_trial1'); vmr.SetPredictorValuesFromCondition('pe_trial1', 'pe_trial1', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pe_trial1');
        vmr.AddPredictor('pe_trial2'); vmr.SetPredictorValuesFromCondition('pe_trial2', 'pe_trial2', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pe_trial2');
        vmr.AddPredictor('pe_trial3'); vmr.SetPredictorValuesFromCondition('pe_trial3', 'pe_trial3', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pe_trial3');
        vmr.AddPredictor('pe_trial4'); vmr.SetPredictorValuesFromCondition('pe_trial4', 'pe_trial4', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pe_trial4');
        vmr.AddPredictor('pl_trial1'); vmr.SetPredictorValuesFromCondition('pl_trial1', 'pl_trial1', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pl_trial1');
        vmr.AddPredictor('pl_trial2'); vmr.SetPredictorValuesFromCondition('pl_trial2', 'pl_trial2', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pl_trial2');
        vmr.AddPredictor('pl_trial3'); vmr.SetPredictorValuesFromCondition('pl_trial3', 'pl_trial3', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pl_trial3');
        vmr.AddPredictor('pl_trial4'); vmr.SetPredictorValuesFromCondition('pl_trial4', 'pl_trial4', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('pl_trial4');
        vmr.AddPredictor('ti_trial1'); vmr.SetPredictorValuesFromCondition('ti_trial1', 'ti_trial1', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('ti_trial1');
        vmr.AddPredictor('ti_trial2'); vmr.SetPredictorValuesFromCondition('ti_trial2', 'ti_trial2', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('ti_trial2');
        vmr.AddPredictor('ti_trial3'); vmr.SetPredictorValuesFromCondition('ti_trial3', 'ti_trial3', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('ti_trial3');
        vmr.AddPredictor('ti_trial4'); vmr.SetPredictorValuesFromCondition('ti_trial4', 'ti_trial4', 1.0); vmr.ApplyHemodynamicResponseFunctionToPredictor('ti_trial4');
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
            SDM_name = fullfile(ACPC_output_dir, [subj '_adapt_' num2str(i) '.sdm']);
            if isempty(strfind(vtc_filename,'highres')) % checking that it is not a high-res scan (cannot combine different resolutions in one GLM)
                vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);
            end
        end
    end
    i=length(vtc_files);        % adding the control run, even with excessive motion
    vtc_filename = vtc_files{i};    
    SDM_name = fullfile(ACPC_output_dir, [subj '_adapt_' num2str(i) '.sdm']);
    vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);
    
    % creating the MDM
    MDM_name = fullfile(ACPC_output_dir, [subj '_adapt_ACPC.mdm']);
    vmr.SaveMultiStudyGLMDefinitionFile(MDM_name);

    % creating GLM
    GLM_name = fullfile(ACPC_output_dir, [subj '_adapt_ACPC.glm']);
    vmr.CorrectForSerialCorrelations = 1;
    vmr.SeparationOfStudyPredictors = 1;
    vmr.PSCTransformStudies = 1;
    vmr.ComputeMultiStudyGLM;
    vmr.SaveGLM(GLM_name);
end


% adding contrasts
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    mdm_file=getfullfiles(fullfile(ACPC_output_dir,'*_adapt_ACPC.mdm')); mdm=xff(mdm_file{1});
    num_sessions=mdm.NrOfStudies;
    
    % adding contrasts - without control
    CTR_name = fullfile(ACPC_output_dir, [subj '_adapt_ACPC.ctr']);
    ctr={}; ctr_names={};
    i=1; ctr_names{i}='person start vs end'; ctr{i}=[repmat([1 0 0 -1 0 0 0 0 0 0 0 0],1,num_sessions-1) zeros(1,12)];
    i=2; ctr_names{i}='person end vs start'; ctr{i}=[repmat([-1 0 0 1 0 0 0 0 0 0 0 0],1,num_sessions-1) zeros(1,12)];
    i=3; ctr_names{i}='place start vs end'; ctr{i}=[repmat([0 0 0 0 1 0 0 -1 0 0 0 0],1,num_sessions-1) zeros(1,12)];
    i=4; ctr_names{i}='place end vs start'; ctr{i}=[repmat([0 0 0 0 -1 0 0 1 0 0 0 0],1,num_sessions-1) zeros(1,12)];
    i=5; ctr_names{i}='time start vs end'; ctr{i}=[repmat([0 0 0 0 0 0 0 0 1 0 0 -1],1,num_sessions-1) zeros(1,12)];
    i=6; ctr_names{i}='time end vs start'; ctr{i}=[repmat([0 0 0 0 0 0 0 0 -1 0 0 1],1,num_sessions-1) zeros(1,12)];
    i=7; ctr_names{i}='all domains start vs end'; ctr{i}=[repmat([1 0 0 -1 1 0 0 -1 1 0 0 -1],1,num_sessions-1) zeros(1,12)];
    i=8; ctr_names{i}='all domains end vs start'; ctr{i}=[repmat([-1 0 0 1 -1 0 0 1 -1 0 0 1],1,num_sessions-1) zeros(1,12)];
    
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
