% Stages of analysis:
% 1. load a specific map (place / time / person vs control) from the vmp
% 2. Convert map clusters to VOIs (options menu) - 300 voxels threshold (default)
% 3. edit names of VOIs (show VOI, edit) into par, frn, pcn, tmp, with _L or _R afterwards (for hemisphere) or without if bilateral
% 4. save VOIs as subject-name_(pe / pl / ti)_vs_control.voi



subjects_output_dir = 'E:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end-6);

num_subjects_to_use = 16;   % excluding the high-res subjects

num_vox=zeros(5,3,num_subjects_to_use); % 5 anatomical regions, 3 domains, N subjects

for s=1:num_subjects_to_use
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC\'];
    
    % reading the VOIs saved before
%     pe_voi_filename = [ACPC_output_dir subj '_pe_vs_control_and_rest.voi'];
%     pl_voi_filename = [ACPC_output_dir subj '_pl_vs_control_and_rest.voi'];
%     ti_voi_filename = [ACPC_output_dir subj '_ti_vs_control_and_rest.voi'];
    pe_voi_filename = [ACPC_output_dir subj '_pe_vs_others_and_rest.voi'];
    pl_voi_filename = [ACPC_output_dir subj '_pl_vs_others_and_rest.voi'];
    ti_voi_filename = [ACPC_output_dir subj '_ti_vs_others_and_rest.voi'];
    if exist(pe_voi_filename,'file'), pe_vois = xff(pe_voi_filename); else pe_vois = xff('new:voi'); end
    if exist(pl_voi_filename,'file'), pl_vois = xff(pl_voi_filename); else pl_vois = xff('new:voi'); end
    if exist(ti_voi_filename,'file'), ti_vois = xff(ti_voi_filename); else ti_vois = xff('new:voi'); end
    
    % creating empty images to calculate VOI voxels number
    par_pe=zeros(256,256,256);
    pcn_pe=zeros(256,256,256);
    frn_pe=zeros(256,256,256);
    tmp_pe=zeros(256,256,256);
    for i=1:length(pe_vois.VOI)
        if ~isempty(strfind(pe_vois.VOI(i).Name(1:3),'par')) || ~isempty(strfind(pe_vois.VOI(i).Name,'PAR'))
            par_pe(sub2ind([256,256,256], pe_vois.VOI(i).Voxels(:,1),pe_vois.VOI(i).Voxels(:,2),pe_vois.VOI(i).Voxels(:,3))) = 1;
        elseif ~isempty(strfind(pe_vois.VOI(i).Name(1:3),'pcn')) || ~isempty(strfind(pe_vois.VOI(i).Name,'PCN'))
            pcn_pe(sub2ind([256,256,256], pe_vois.VOI(i).Voxels(:,1),pe_vois.VOI(i).Voxels(:,2),pe_vois.VOI(i).Voxels(:,3))) = 1;
        elseif ~isempty(strfind(pe_vois.VOI(i).Name(1:3),'frn')) || ~isempty(strfind(pe_vois.VOI(i).Name,'FRN'))
            frn_pe(sub2ind([256,256,256], pe_vois.VOI(i).Voxels(:,1),pe_vois.VOI(i).Voxels(:,2),pe_vois.VOI(i).Voxels(:,3))) = 1;
        elseif ~isempty(strfind(pe_vois.VOI(i).Name(1:3),'tmp')) || ~isempty(strfind(pe_vois.VOI(i).Name,'TMP'))
            tmp_pe(sub2ind([256,256,256], pe_vois.VOI(i).Voxels(:,1),pe_vois.VOI(i).Voxels(:,2),pe_vois.VOI(i).Voxels(:,3))) = 1;
        end
    end
    
    par_pl=zeros(256,256,256);
    pcn_pl=zeros(256,256,256);
    frn_pl=zeros(256,256,256);
    tmp_pl=zeros(256,256,256);
    for i=1:length(pl_vois.VOI)
        if ~isempty(strfind(pl_vois.VOI(i).Name(1:3),'par')) || ~isempty(strfind(pl_vois.VOI(i).Name,'PAR'))
            par_pl(sub2ind([256,256,256], pl_vois.VOI(i).Voxels(:,1),pl_vois.VOI(i).Voxels(:,2),pl_vois.VOI(i).Voxels(:,3))) = 1;
        elseif ~isempty(strfind(pl_vois.VOI(i).Name(1:3),'pcn')) || ~isempty(strfind(pl_vois.VOI(i).Name,'PCN'))
            pcn_pl(sub2ind([256,256,256], pl_vois.VOI(i).Voxels(:,1),pl_vois.VOI(i).Voxels(:,2),pl_vois.VOI(i).Voxels(:,3))) = 1;
        elseif ~isempty(strfind(pl_vois.VOI(i).Name(1:3),'frn')) || ~isempty(strfind(pl_vois.VOI(i).Name,'FRN'))
            frn_pl(sub2ind([256,256,256], pl_vois.VOI(i).Voxels(:,1),pl_vois.VOI(i).Voxels(:,2),pl_vois.VOI(i).Voxels(:,3))) = 1;
        elseif ~isempty(strfind(pl_vois.VOI(i).Name(1:3),'tmp')) || ~isempty(strfind(pl_vois.VOI(i).Name,'TMP'))
            tmp_pl(sub2ind([256,256,256], pl_vois.VOI(i).Voxels(:,1),pl_vois.VOI(i).Voxels(:,2),pl_vois.VOI(i).Voxels(:,3))) = 1;
        end
    end

    par_ti=zeros(256,256,256);
    pcn_ti=zeros(256,256,256);
    frn_ti=zeros(256,256,256);
    tmp_ti=zeros(256,256,256);
    for i=1:length(ti_vois.VOI)
        if ~isempty(strfind(ti_vois.VOI(i).Name(1:3),'par')) || ~isempty(strfind(ti_vois.VOI(i).Name,'PAR'))
            par_ti(sub2ind([256,256,256], ti_vois.VOI(i).Voxels(:,1),ti_vois.VOI(i).Voxels(:,2),ti_vois.VOI(i).Voxels(:,3))) = 1;
        elseif ~isempty(strfind(ti_vois.VOI(i).Name(1:3),'pcn')) || ~isempty(strfind(ti_vois.VOI(i).Name,'PCN'))
            pcn_ti(sub2ind([256,256,256], ti_vois.VOI(i).Voxels(:,1),ti_vois.VOI(i).Voxels(:,2),ti_vois.VOI(i).Voxels(:,3))) = 1;
        elseif ~isempty(strfind(ti_vois.VOI(i).Name(1:3),'frn')) || ~isempty(strfind(ti_vois.VOI(i).Name,'FRN'))
            frn_ti(sub2ind([256,256,256], ti_vois.VOI(i).Voxels(:,1),ti_vois.VOI(i).Voxels(:,2),ti_vois.VOI(i).Voxels(:,3))) = 1;
        elseif ~isempty(strfind(ti_vois.VOI(i).Name(1:3),'tmp')) || ~isempty(strfind(ti_vois.VOI(i).Name,'TMP'))
            tmp_ti(sub2ind([256,256,256], ti_vois.VOI(i).Voxels(:,1),ti_vois.VOI(i).Voxels(:,2),ti_vois.VOI(i).Voxels(:,3))) = 1;
        end
    end
    
    % parietal
    num_vox(1,1,s) = sum(par_pe(:)); num_vox(1,2,s) = sum(par_pl(:)); num_vox(1,3,s) = sum(par_ti(:));

    % precuneus
    num_vox(2,1,s) = sum(pcn_pe(:)); num_vox(2,2,s) = sum(pcn_pl(:)); num_vox(2,3,s) = sum(pcn_ti(:));

    % frontal
    num_vox(3,1,s) = sum(frn_pe(:)); num_vox(3,2,s) = sum(frn_pl(:)); num_vox(3,3,s) = sum(frn_ti(:));

    % temporal
    num_vox(4,1,s) = sum(tmp_pe(:)); num_vox(4,2,s) = sum(tmp_pl(:)); num_vox(4,3,s) = sum(tmp_ti(:));

    % all areas
    all_pe = par_pe | pcn_pe | frn_pe | tmp_pe;
    all_pl = par_pl | pcn_pl | frn_pl | tmp_pl;
    all_ti = par_ti | pcn_ti | frn_ti | tmp_ti;
    num_vox(5,1,s) = sum(all_pe(:)); num_vox(5,2,s) = sum(all_pl(:)); num_vox(5,3,s) = sum(all_ti(:));
    
end


h=pie3(nanmean(num_vox(2,:,:),3));           % can be also done in Excel

