subjects_output_dir = 'F:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end);

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');


%% creating SDMs, MDMs, GLMs from existing distance PRT files
disp('Creating design matrices (.mdm files)')
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    
    vtc_files=getfullfiles(fullfile(ACPC_output_dir,'*.vtc'));
    vtc_files(cellfun(@(x) ~isempty(strfind(x,'rest')), vtc_files))=[];   % remove rest files, if existing
    vmr_filename=getfullfiles(fullfile(ACPC_output_dir, '*_ISO_ACPC.vmr')); 
    vmr = bvqx.OpenDocument(vmr_filename{1});
    
    prt_files=getfullfiles(fullfile(output_dir,'paradigm_with_distances_*.prt'));
    motion_sdm_files=getfullfiles(fullfile(output_dir,'*3DMC.sdm'));
    
    % create SDM for each session
    for i=1:length(vtc_files)
        vtc_filename = vtc_files{i}; prt_filename=prt_files{i};
        SDM_name = fullfile(ACPC_output_dir, [subj '_distances_' num2str(i) '.sdm']);
        vmr.LinkVTC(vtc_filename);
        vmr.LinkStimulationProtocol(prt_filename);
        % vmr.SaveVTC();  % save with link to protocol
        
        vmr.ClearDesignMatrix;
        preds={'pe_1', 'pe_2', 'pe_3', 'pe_4', 'pe_5', 'pe_6', 'pl_1', 'pl_2', 'pl_3', 'pl_4', 'pl_5', 'pl_6', 'ti_1', 'ti_2', 'ti_3', 'ti_4', 'ti_5', 'ti_6'};
        for q=1:length(preds)
            vmr.AddPredictor(preds{q});
            vmr.SetPredictorValuesFromCondition(preds{q}, preds{q}, 1.0);
            vmr.ApplyHemodynamicResponseFunctionToPredictor(preds{q});
        end
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
    
    % create MDM file
    vmr.ClearMultiStudyGLMDefinition;
    for i=1:length(vtc_files)-1     % all runs except the last (control)
        motion_sdm = xff(motion_sdm_files{i});
        if isempty(find(motion_sdm.SDMMatrix>1.7,1))  % checking that there is no excessive motion in the run
            vtc_filename = vtc_files{i};
            SDM_name = fullfile(ACPC_output_dir, [subj '_distances_' num2str(i) '.sdm']);
            if isempty(strfind(vtc_filename,'highres')) % checking that it is not a high-res scan (cannot combine different resolutions in one GLM)
                vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);
            end
        end
    end
    i=length(vtc_files);        % adding the control run, even with excessive motion
    vtc_filename = vtc_files{i};    
    SDM_name = fullfile(ACPC_output_dir, [subj '_distances_' num2str(i) '.sdm']);
    vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);

    MDM_name = fullfile(ACPC_output_dir, [subj '_distances_ACPC.mdm']);
    vmr.SaveMultiStudyGLMDefinitionFile(MDM_name);
    
    GLM_name = fullfile(ACPC_output_dir, [subj '_distances_ACPC.glm']);
    vmr.CorrectForSerialCorrelations = 1;
    vmr.SeparationOfStudyPredictors = 1;
    vmr.PSCTransformStudies = 1;
    vmr.ComputeMultiStudyGLM;
    vmr.SaveGLM(GLM_name);
end



%% creating contrasts
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    mdm_file=getfullfiles(fullfile(ACPC_output_dir,'*_distances_ACPC.mdm')); mdm=xff(mdm_file{1});
    num_sessions=mdm.NrOfStudies;
    
    % adding contrasts - without control
    CTR_name = fullfile(ACPC_output_dir, [subj '_distances_ACPC.ctr']);
    ctr={}; ctr_names={};
    i=1; ctr_names{i}='person close vs. far (12 vs. 56)'; ctr{i}=[repmat([1 1 0 0 -1 -1 zeros(1,12)],1,num_sessions-1) zeros(1,18)];
    i=2; ctr_names{i}='place close vs. far (12 vs. 56)'; ctr{i}=[repmat([zeros(1,6) 1 1 0 0 -1 -1 zeros(1,6)],1,num_sessions-1) zeros(1,18)];
    i=3; ctr_names{i}='time close vs. far (12 vs. 56)'; ctr{i}=[repmat([zeros(1,12) 1 1 0 0 -1 -1],1,num_sessions-1) zeros(1,18)];
    i=4; ctr_names{i}='all domains close vs. far (12 vs. 56)'; ctr{i}=[repmat([1 1 0 0 -1 -1 1 1 0 0 -1 -1 1 1 0 0 -1 -1] ,1,num_sessions-1) zeros(1,18)];
    i=5; ctr_names{i}='person and place close vs. far (12 vs. 56)'; ctr{i}=[repmat([1 1 0 0 -1 -1 1 1 0 0 -1 -1 zeros(1,6)] ,1,num_sessions-1) zeros(1,18)];
    i=6; ctr_names{i}='person and time close vs. far (12 vs. 56)'; ctr{i}=[repmat([1 1 0 0 -1 -1 zeros(1,6) 1 1 0 0 -1 -1] ,1,num_sessions-1) zeros(1,18)];
    i=7; ctr_names{i}='place and time close vs. far (12 vs. 56)'; ctr{i}=[repmat([zeros(1,6) 1 1 0 0 -1 -1 1 1 0 0 -1 -1] ,1,num_sessions-1) zeros(1,18)];
    i=8; ctr_names{i}='person close vs. far descending'; ctr{i}=[repmat([5 3 1 -1 -3 -5 zeros(1,12)],1,num_sessions-1) zeros(1,18)];
    i=9; ctr_names{i}='place close vs. far descending'; ctr{i}=[repmat([zeros(1,6) 5 3 1 -1 -3 -5 zeros(1,6)],1,num_sessions-1) zeros(1,18)];
    i=10; ctr_names{i}='time close vs. far descending'; ctr{i}=[repmat([zeros(1,12) 5 3 1 -1 -3 -5],1,num_sessions-1) zeros(1,18)];
    i=11; ctr_names{i}='person close vs. medium (12 vs. 34)'; ctr{i}=[repmat([1 1 -1 -1 0 0 zeros(1,12)],1,num_sessions-1) zeros(1,18)];
    i=12; ctr_names{i}='person medium vs. far (34 vs. 56)'; ctr{i}=[repmat([0 0 1 1 -1 -1 zeros(1,12)],1,num_sessions-1) zeros(1,18)];
    i=13; ctr_names{i}='place close vs. medium (12 vs. 34)'; ctr{i}=[repmat([zeros(1,6) 1 1 -1 -1 0 0 zeros(1,6)],1,num_sessions-1) zeros(1,18)];
    i=14; ctr_names{i}='place medium vs. far (34 vs. 56)'; ctr{i}=[repmat([zeros(1,6) 0 0 1 1 -1 -1 zeros(1,6)],1,num_sessions-1) zeros(1,18)];
    i=15; ctr_names{i}='time close vs. medium (12 vs. 34)'; ctr{i}=[repmat([zeros(1,12) 1 1 -1 -1 0 0],1,num_sessions-1) zeros(1,18)];
    i=16; ctr_names{i}='time medium vs. far (34 vs. 56)'; ctr{i}=[repmat([zeros(1,12) 0 0 1 1 -1 -1],1,num_sessions-1) zeros(1,18)];

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


%% creating contrasts for single domains only
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    mdm_file=getfullfiles(fullfile(ACPC_output_dir,'*_distances_ACPC.mdm')); mdm=xff(mdm_file{1});
    num_sessions=mdm.NrOfStudies;
    
    % adding contrasts - place
    CTR_name = fullfile(ACPC_output_dir, [subj '_distances_ACPC_place.ctr']);
    ctr={}; ctr_names={};
    i=1; ctr_names{i}='place 1'; ctr{i}=[repmat([zeros(1,6) 5 -1 -1 -1 -1 -1 zeros(1,6)],1,num_sessions-1) zeros(1,18)];
    i=2; ctr_names{i}='place 2'; ctr{i}=[repmat([zeros(1,6) -1 5 -1 -1 -1 -1 zeros(1,6)],1,num_sessions-1) zeros(1,18)];
    i=3; ctr_names{i}='place 3'; ctr{i}=[repmat([zeros(1,6) -1 -1 5 -1 -1 -1 zeros(1,6)],1,num_sessions-1) zeros(1,18)];
    i=4; ctr_names{i}='place 4'; ctr{i}=[repmat([zeros(1,6) -1 -1 -1 5 -1 -1 zeros(1,6)],1,num_sessions-1) zeros(1,18)];
    i=5; ctr_names{i}='place 5'; ctr{i}=[repmat([zeros(1,6) -1 -1 -1 -1 5 -1 zeros(1,6)],1,num_sessions-1) zeros(1,18)];
    i=6; ctr_names{i}='place 6'; ctr{i}=[repmat([zeros(1,6) -1 -1 -1 -1 -1 5 zeros(1,6)],1,num_sessions-1) zeros(1,18)];
    
    for i=1:length(ctr)
        ctr{i}=[ctr{i} zeros(1, num_sessions*7)];  % adding zeros for constant values and motion confounds 
    end
    ctr_xff=xff('new:ctr');     % new contrast structure, using NeuroElf
    ctr_xff.NrOfContrasts = length(ctr_names);
    ctr_xff.NrOfValues = length(ctr{1});
    ctr_xff.ContrastNames = ctr_names;
    ctr_xff.ContrastValues = cell2mat(ctr');
    ctr_xff.SaveAs(CTR_name);
    
    
    % adding contrasts - person
    CTR_name = fullfile(ACPC_output_dir, [subj '_distances_ACPC_person.ctr']);
    ctr={}; ctr_names={};
    i=1; ctr_names{i}='person 1'; ctr{i}=[repmat([5 -1 -1 -1 -1 -1 zeros(1,12)],1,num_sessions-1) zeros(1,18)];
    i=2; ctr_names{i}='person 2'; ctr{i}=[repmat([ -1 5 -1 -1 -1 -1 zeros(1,12)],1,num_sessions-1) zeros(1,18)];
    i=3; ctr_names{i}='person 3'; ctr{i}=[repmat([ -1 -1 5 -1 -1 -1 zeros(1,12)],1,num_sessions-1) zeros(1,18)];
    i=4; ctr_names{i}='person 4'; ctr{i}=[repmat([ -1 -1 -1 5 -1 -1 zeros(1,12)],1,num_sessions-1) zeros(1,18)];
    i=5; ctr_names{i}='person 5'; ctr{i}=[repmat([ -1 -1 -1 -1 5 -1 zeros(1,12)],1,num_sessions-1) zeros(1,18)];
    i=6; ctr_names{i}='person 6'; ctr{i}=[repmat([ -1 -1 -1 -1 -1 5 zeros(1,12)],1,num_sessions-1) zeros(1,18)];
    
    for i=1:length(ctr)
        ctr{i}=[ctr{i} zeros(1, num_sessions*7)];  % adding zeros for constant values and motion confounds 
    end
    ctr_xff=xff('new:ctr');     % new contrast structure, using NeuroElf
    ctr_xff.NrOfContrasts = length(ctr_names);
    ctr_xff.NrOfValues = length(ctr{1});
    ctr_xff.ContrastNames = ctr_names;
    ctr_xff.ContrastValues = cell2mat(ctr');
    ctr_xff.SaveAs(CTR_name);

    
    % adding contrasts - time
    CTR_name = fullfile(ACPC_output_dir, [subj '_distances_ACPC_time.ctr']);
    ctr={}; ctr_names={};
    i=1; ctr_names{i}='time 1'; ctr{i}=[repmat([zeros(1,12) 5 -1 -1 -1 -1 -1 ],1,num_sessions-1) zeros(1,18)];
    i=2; ctr_names{i}='time 2'; ctr{i}=[repmat([zeros(1,12) -1 5 -1 -1 -1 -1 ],1,num_sessions-1) zeros(1,18)];
    i=3; ctr_names{i}='time 3'; ctr{i}=[repmat([zeros(1,12) -1 -1 5 -1 -1 -1 ],1,num_sessions-1) zeros(1,18)];
    i=4; ctr_names{i}='time 4'; ctr{i}=[repmat([zeros(1,12) -1 -1 -1 5 -1 -1 ],1,num_sessions-1) zeros(1,18)];
    i=5; ctr_names{i}='time 5'; ctr{i}=[repmat([zeros(1,12) -1 -1 -1 -1 5 -1 ],1,num_sessions-1) zeros(1,18)];
    i=6; ctr_names{i}='time 6'; ctr{i}=[repmat([zeros(1,12) -1 -1 -1 -1 -1 5 ],1,num_sessions-1) zeros(1,18)];
    
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
