%% changing SMP visualization - domains contrasts (vs others and vs control)

% MANUAL STAGES:
% CREATE SMP FILES BY OPENING A MESH, PRESSING CTRL+M, AND PRESSING 'CREATE SMP'
% DO THIS AFTER LOADING THE smp, CHOOSING CONTRASTS '_vs_others /
% control_and_above_rest' (CONTRASTS 18-23)
% DO THIS FOR EACH HEMISPHERE SEPARATELY, AND SAVE AS '*_domains_LH / RH .smp'
%
% ALSO - SEPARATELY LOAD THE ICA RESULTS, CHOOSE THE RIGHT COMPONENT, AND
% SAVE AS SMP WITH NAME '*_ICA_LH / RH.smp'

subjects_output_dir = 'E:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end);

% changing colors and parameters of the domains SMP contrasts
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj); ACPC_output_dir=[output_dir '\ACPC'];
    smp_files=[getfullfiles(fullfile(output_dir,'*_domains*.smp')) getfullfiles(fullfile(ACPC_output_dir,'*_domains*.smp'))];
    
    for i=1:length(smp_files)       % there should be two SMP files for each subject - LH and RH
        smp=xff(smp_files{i});
        
        for j=1:length(smp.Map)
            smp.Map(j).ClusterSize = 5;
            smp.Map(j).SMPData(smp.Map(j).SMPData<0) =0;          % eliminating negative values
        end
        
        smp.SaveAs(smp_files{i});
        smp.ClearObject;
    end
end


%% changing SMP visualization - ICA components 

% MANUAL STAGES:
% LOAD THE ICA RESULTS, CHOOSE THE RIGHT COMPONENT
% CREATE SMP FILES BY OPENING A MESH, PRESSING CTRL+M, AND PRESSING 'CREATE SMP'
% DO THIS FOR EACH HEMISPHERE SEPARATELY, AND SAVE AS '*_ICA_LH / RH .smp'

for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj); ACPC_output_dir=[output_dir '\ACPC'];
    smp_files=[getfullfiles(fullfile(output_dir,'*_ICA*.smp')) getfullfiles(fullfile(ACPC_output_dir,'*_ICA*.smp'))];
    
    for i=1:length(smp_files)       % there should be two SMP files for each subject - LH and RH
        smp=xff(smp_files{i});
        
        % creating new maps for the positive and negative parts of the ICA component
        smp.Map(2) = smp.Map(1); smp.Map(3) = smp.Map(1);
        smp.Map(2).Name = [smp.Map(2).Name ' - Positive'];
        smp.Map(3).Name = [smp.Map(3).Name ' - Negative'];
        
        smp.Map(2).SMPData(smp.Map(2).SMPData<0) =0;          % eliminating negative values from map 1
        smp.Map(3).SMPData(smp.Map(3).SMPData>0) =0;          % eliminating positive values from map 2

        for j=2:3
            smp.Map(j).ClusterSize = 5;
            smp.Map(j).EnableClusterCheck = 1;
            smp.Map(j).UseRGBColor = 1;
            smp.Map(j).RGBLowerThreshPos = [100   0  100  ];             smp.Map(j).RGBUpperThreshPos = [255   0  255  ];
            smp.Map(j).RGBLowerThreshNeg = [100   0  100  ];             smp.Map(j).RGBUpperThreshNeg = [255   0  255  ];
            smp.Map(j).TransColorFactor = 0.8;
        end
        
        smp.SaveAs(smp_files{i});
        smp.ClearObject;
    end
end



%% changing SMP visualization - overlap contrasts 

% MANUAL STAGES:
% LOAD THE DOMAINS VMP, CHOOSE THE OVERLAP CONTRASTS
% CREATE SMP FILES BY OPENING A MESH, PRESSING CTRL+M, AND PRESSING 'CREATE SMP'
% DO THIS FOR EACH HEMISPHERE SEPARATELY, AND SAVE AS '*_overlap_LH / RH .smp'

for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj); ACPC_output_dir=[output_dir '\ACPC'];
    smp_files=[getfullfiles(fullfile(output_dir,'*_overlap*.smp')) getfullfiles(fullfile(ACPC_output_dir,'*_overlap*.smp'))];
    
    for i=1:length(smp_files)       % there should be two SMP files for each subject - LH and RH
        smp=xff(smp_files{i});
        
        for j=1:length(smp.Map)
            smp.Map(j).ClusterSize = 5;
            smp.Map(j).EnableClusterCheck = 1;
            smp.Map(j).ShowPositiveNegativeFlag = 1;
        end
        
        smp.SaveAs(smp_files{i});
        smp.ClearObject;
    end
end


%% Changing SRF colors 
for s=1:length(subject_names)
    subj=subject_names(s).name; disp(subj);
    ACPC_output_dir=[fullfile(subjects_output_dir, subj) '\ACPC'];

    srf_files = getfullfiles(fullfile(ACPC_output_dir,'*.srf'));
    for i=1:length(srf_files)
        srf=xff(srf_files{i});
        srf.ConcaveRGBA = [0.4688 0.4688 0.4688 1];
        srf.ConvexRGBA = [0.4688 0.4688 0.4688 1];
        srf.SaveAs(srf_files{i});
        srf.ClearObject;
    end
end



%% Creating inflated grey-matter meshes

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');

for s=1:length(subject_names)
    subj=subject_names(s).name; disp(subj);
    ACPC_output_dir=[fullfile(subjects_output_dir, subj) '\ACPC'];
    vmr_filename=getfullfiles(fullfile(ACPC_output_dir, '*_ISO_ACPC.vmr'));
    vmr = bvqx.OpenDocument(vmr_filename{1});
    srf_files = getfullfiles(fullfile(ACPC_output_dir,'*_GM_*H.srf'));
    
    for i=1:length(srf_files)
        vmr.LoadMesh(srf_files{i});
        curmesh=vmr.CurrentMesh;
        curmesh.InflateMesh(500,0.8,'');
%         curmesh.LinkMTC(srf_files{i});
        new_srf_name = [srf_files{i}(1:end-4) '_inflated.srf'];
        curmesh.SaveAs(new_srf_name);
        
        % changing colors of new srf
        srf=xff(new_srf_name);
        srf.ConcaveRGBA = [0.2344 0.2344 0.2344 1];
        srf.AutoLinkedMTC = srf_files{i};
        srf.SaveAs(new_srf_name);
        srf.ClearObject;
    end
end
