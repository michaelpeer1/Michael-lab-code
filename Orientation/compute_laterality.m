subjects_output_dir = 'E:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end-6);

num_subjects_to_use = 16;   % excluding the high-res subjects

numvox_all_left=zeros(3,5,num_subjects_to_use);
numvox_all_right=zeros(3,5,num_subjects_to_use);

for s=1:num_subjects_to_use
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC\'];
    
    % reading the VOIs saved before
    pe_vois=xff([ACPC_output_dir subj '_pe_vs_control_and_rest.voi']);
    pl_vois=xff([ACPC_output_dir subj '_pl_vs_control_and_rest.voi']);
    ti_vois=xff([ACPC_output_dir subj '_ti_vs_control_and_rest.voi']);

    % reading the right and left hemispheres masks
    left_hemi=getfullfiles([ACPC_output_dir '*_GM_LH.vmr']); left_hemi = xff(left_hemi{1}); left_hemi = left_hemi.VMRData;
    right_hemi=getfullfiles([ACPC_output_dir '*_GM_RH.vmr']); right_hemi = xff(right_hemi{1}); right_hemi = right_hemi.VMRData;
    
    
    % computing sum of voxels in each domain, brain region and subject
    
    % person
    par_pe=zeros(256,256,256); pcn_pe=zeros(256,256,256); frn_pe=zeros(256,256,256); tmp_pe=zeros(256,256,256);
    for i=1:length(pe_vois.VOI)
        if strcmp(pe_vois.VOI(i).Name(1:3),'par')
            par_pe(sub2ind([256,256,256], pe_vois.VOI(i).Voxels(:,1),pe_vois.VOI(i).Voxels(:,2),pe_vois.VOI(i).Voxels(:,3))) = 1;
        elseif strcmp(pe_vois.VOI(i).Name(1:3),'pcn')
            pcn_pe(sub2ind([256,256,256], pe_vois.VOI(i).Voxels(:,1),pe_vois.VOI(i).Voxels(:,2),pe_vois.VOI(i).Voxels(:,3))) = 1;
        elseif strcmp(pe_vois.VOI(i).Name(1:3),'frn')
            frn_pe(sub2ind([256,256,256], pe_vois.VOI(i).Voxels(:,1),pe_vois.VOI(i).Voxels(:,2),pe_vois.VOI(i).Voxels(:,3))) = 1;
        elseif strcmp(pe_vois.VOI(i).Name(1:3),'tmp')
            tmp_pe(sub2ind([256,256,256], pe_vois.VOI(i).Voxels(:,1),pe_vois.VOI(i).Voxels(:,2),pe_vois.VOI(i).Voxels(:,3))) = 1;
        end
    end
    par_pe_left = par_pe & left_hemi; pcn_pe_left = pcn_pe & left_hemi; frn_pe_left = frn_pe & left_hemi; tmp_pe_left = tmp_pe & left_hemi;
    par_pe_right = par_pe & right_hemi; pcn_pe_right = pcn_pe & right_hemi; frn_pe_right = frn_pe & right_hemi; tmp_pe_right = tmp_pe & right_hemi;

    % place
    par_pl=zeros(256,256,256); pcn_pl=zeros(256,256,256); frn_pl=zeros(256,256,256); tmp_pl=zeros(256,256,256);
    for i=1:length(pl_vois.VOI)
        if strcmp(pl_vois.VOI(i).Name(1:3),'par')
            par_pl(sub2ind([256,256,256], pl_vois.VOI(i).Voxels(:,1),pl_vois.VOI(i).Voxels(:,2),pl_vois.VOI(i).Voxels(:,3))) = 1;
        elseif strcmp(pl_vois.VOI(i).Name(1:3),'pcn')
            pcn_pl(sub2ind([256,256,256], pl_vois.VOI(i).Voxels(:,1),pl_vois.VOI(i).Voxels(:,2),pl_vois.VOI(i).Voxels(:,3))) = 1;
        elseif strcmp(pl_vois.VOI(i).Name(1:3),'frn')
            frn_pl(sub2ind([256,256,256], pl_vois.VOI(i).Voxels(:,1),pl_vois.VOI(i).Voxels(:,2),pl_vois.VOI(i).Voxels(:,3))) = 1;
        elseif strcmp(pl_vois.VOI(i).Name(1:3),'tmp')
            tmp_pl(sub2ind([256,256,256], pl_vois.VOI(i).Voxels(:,1),pl_vois.VOI(i).Voxels(:,2),pl_vois.VOI(i).Voxels(:,3))) = 1;
        end
    end
    par_pl_left = par_pl & left_hemi; pcn_pl_left = pcn_pl & left_hemi; frn_pl_left = frn_pl & left_hemi; tmp_pl_left = tmp_pl & left_hemi;
    par_pl_right = par_pl & right_hemi; pcn_pl_right = pcn_pl & right_hemi; frn_pl_right = frn_pl & right_hemi; tmp_pl_right = tmp_pl & right_hemi;

    % time
    par_ti=zeros(256,256,256); pcn_ti=zeros(256,256,256); frn_ti=zeros(256,256,256); tmp_ti=zeros(256,256,256);
    for i=1:length(ti_vois.VOI)
        if strcmp(ti_vois.VOI(i).Name(1:3),'par')
            par_ti(sub2ind([256,256,256], ti_vois.VOI(i).Voxels(:,1),ti_vois.VOI(i).Voxels(:,2),ti_vois.VOI(i).Voxels(:,3))) = 1;
        elseif strcmp(ti_vois.VOI(i).Name(1:3),'pcn')
            pcn_ti(sub2ind([256,256,256], ti_vois.VOI(i).Voxels(:,1),ti_vois.VOI(i).Voxels(:,2),ti_vois.VOI(i).Voxels(:,3))) = 1;
        elseif strcmp(ti_vois.VOI(i).Name(1:3),'frn')
            frn_ti(sub2ind([256,256,256], ti_vois.VOI(i).Voxels(:,1),ti_vois.VOI(i).Voxels(:,2),ti_vois.VOI(i).Voxels(:,3))) = 1;
        elseif strcmp(ti_vois.VOI(i).Name(1:3),'tmp')
            tmp_ti(sub2ind([256,256,256], ti_vois.VOI(i).Voxels(:,1),ti_vois.VOI(i).Voxels(:,2),ti_vois.VOI(i).Voxels(:,3))) = 1;
        end
    end
    par_ti_left = par_ti & left_hemi; pcn_ti_left = pcn_ti & left_hemi; frn_ti_left = frn_ti & left_hemi; tmp_ti_left = tmp_ti & left_hemi;
    par_ti_right = par_ti & right_hemi; pcn_ti_right = pcn_ti & right_hemi; frn_ti_right = frn_ti & right_hemi; tmp_ti_right = tmp_ti & right_hemi;

    
    % computing the number of voxels in each domain, brain region and subject
    % person
    pe_left_all = par_pe_left | pcn_pe_left | frn_pe_left | tmp_pe_left;
    pe_right_all = par_pe_right | pcn_pe_right | frn_pe_right | tmp_pe_right;    
    numvox_all_left(1,1,s) = sum(par_pe_left(:)); numvox_all_right(1,1,s) = sum(par_pe_right(:));   % parietal
    numvox_all_left(1,2,s) = sum(pcn_pe_left(:)); numvox_all_right(1,2,s) = sum(pcn_pe_right(:));   % precuneus
    numvox_all_left(1,3,s) = sum(frn_pe_left(:)); numvox_all_right(1,3,s) = sum(frn_pe_right(:));   % frontal
    numvox_all_left(1,4,s) = sum(tmp_pe_left(:)); numvox_all_right(1,4,s) = sum(tmp_pe_right(:));   % temporal
    numvox_all_left(1,5,s) = sum(pe_left_all(:)); numvox_all_right(1,5,s) = sum(pe_right_all(:));   % temporal
    % place
    pl_left_all = par_pl_left | pcn_pl_left | frn_pl_left | tmp_pl_left;
    pl_right_all = par_pl_right | pcn_pl_right | frn_pl_right | tmp_pl_right;    
    numvox_all_left(2,1,s) = sum(par_pl_left(:)); numvox_all_right(2,1,s) = sum(par_pl_right(:));   % parietal
    numvox_all_left(2,2,s) = sum(pcn_pl_left(:)); numvox_all_right(2,2,s) = sum(pcn_pl_right(:));   % precuneus
    numvox_all_left(2,3,s) = sum(frn_pl_left(:)); numvox_all_right(2,3,s) = sum(frn_pl_right(:));   % frontal
    numvox_all_left(2,4,s) = sum(tmp_pl_left(:)); numvox_all_right(2,4,s) = sum(tmp_pl_right(:));   % temporal
    numvox_all_left(2,5,s) = sum(pl_left_all(:)); numvox_all_right(2,5,s) = sum(pl_right_all(:));   % temporal
    % time
    ti_left_all = par_ti_left | pcn_ti_left | frn_ti_left | tmp_ti_left;
    ti_right_all = par_ti_right | pcn_ti_right | frn_ti_right | tmp_ti_right;    
    numvox_all_left(3,1,s) = sum(par_ti_left(:)); numvox_all_right(3,1,s) = sum(par_ti_right(:));   % parietal
    numvox_all_left(3,2,s) = sum(pcn_ti_left(:)); numvox_all_right(3,2,s) = sum(pcn_ti_right(:));   % precuneus
    numvox_all_left(3,3,s) = sum(frn_ti_left(:)); numvox_all_right(3,3,s) = sum(frn_ti_right(:));   % frontal
    numvox_all_left(3,4,s) = sum(tmp_ti_left(:)); numvox_all_right(3,4,s) = sum(tmp_ti_right(:));   % temporal
    numvox_all_left(3,5,s) = sum(ti_left_all(:)); numvox_all_right(3,5,s) = sum(ti_right_all(:));   % temporal

end


errorbar([mean(numvox_all_left(1,5,:)-numvox_all_right(1,5,:)) mean(numvox_all_left(2,5,:)-numvox_all_right(2,5,:)) mean(numvox_all_left(3,5,:)-numvox_all_right(3,5,:))], [std(numvox_all_left(1,5,:)-numvox_all_right(1,5,:)) std(numvox_all_left(2,5,:)-numvox_all_right(2,5,:)) std(numvox_all_left(3,5,:)-numvox_all_right(3,5,:))]/4);
