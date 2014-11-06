% Stages of analysis:
% 1. load a specific map (place / time / person vs control) from the vmp
% 2. Convert map clusters to VOIs (options menu) - 300 voxels threshold (default)
% 3. edit names of VOIs (show VOI, edit) into par, frn, pcn, tmp, with _L or _R afterwards (for hemisphere) or without if bilateral
% 4. save VOIs as subject-name_(pe / pl / ti)_vs_control.voi



subjects_output_dir = 'E:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end-6);

num_subjects_to_use = 16;   % excluding the high-res subjects

overlap_all=zeros(5,7,num_subjects_to_use);

for s=1:num_subjects_to_use
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC\'];
    
    % reading the VOIs saved before
    pe_voi_filename = [ACPC_output_dir subj '_pe_vs_control_and_rest.voi'];
    pl_voi_filename = [ACPC_output_dir subj '_pl_vs_control_and_rest.voi'];
    ti_voi_filename = [ACPC_output_dir subj '_ti_vs_control_and_rest.voi'];
    if exist(pe_voi_filename,'file'), pe_vois = xff(pe_voi_filename); else pe_vois = xff('new:voi'); end
    if exist(pl_voi_filename,'file'), pl_vois = xff(pl_voi_filename); else pl_vois = xff('new:voi'); end
    if exist(ti_voi_filename,'file'), ti_vois = xff(ti_voi_filename); else ti_vois = xff('new:voi'); end

    % creating empty images to calculate VOI overlap
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
    
    % overlap_domains = {'person place','person time','place time', 'person place time'};
    % overlap_regions = {'parietal';'precuneus';'frontal';'temporal'};
    % overlap_all{s}=zeros(4);
    
    % parietal
    par_all = sum(par_pe(:) | par_pl(:) | par_ti(:));
    overlap_all(1,1,s) = sum(par_pe(:) & ~par_pl(:) & ~par_ti(:)) / par_all;
    overlap_all(1,2,s) = sum(~par_pe(:) & par_pl(:) & ~par_ti(:)) / par_all;
    overlap_all(1,3,s) = sum(~par_pe(:) & ~par_pl(:) & par_ti(:)) / par_all;
    overlap_all(1,4,s) = sum(par_pe(:) & par_pl(:) & ~par_ti(:)) / par_all;
    overlap_all(1,5,s) = sum(par_pe(:) & ~par_pl(:) & par_ti(:)) / par_all;
    overlap_all(1,6,s) = sum(~par_pe(:) & par_pl(:) & par_ti(:)) / par_all;
    overlap_all(1,7,s) = sum(par_pe(:) & par_pl(:) & par_ti(:)) / par_all;

    % precuneus
    pcn_all = sum(pcn_pe(:) | pcn_pl(:) | pcn_ti(:));
    overlap_all(2,1,s) = sum(pcn_pe(:) & ~pcn_pl(:) & ~pcn_ti(:)) / pcn_all;
    overlap_all(2,2,s) = sum(~pcn_pe(:) & pcn_pl(:) & ~pcn_ti(:)) / pcn_all;
    overlap_all(2,3,s) = sum(~pcn_pe(:) & ~pcn_pl(:) & pcn_ti(:)) / pcn_all;
    overlap_all(2,4,s) = sum(pcn_pe(:) & pcn_pl(:) & ~pcn_ti(:)) / pcn_all;
    overlap_all(2,5,s) = sum(pcn_pe(:) & ~pcn_pl(:) & pcn_ti(:)) / pcn_all;
    overlap_all(2,6,s) = sum(~pcn_pe(:) & pcn_pl(:) & pcn_ti(:)) / pcn_all;
    overlap_all(2,7,s) = sum(pcn_pe(:) & pcn_pl(:) & pcn_ti(:)) / pcn_all;

    % frontal
    frn_all = sum(frn_pe(:) | frn_pl(:) | frn_ti(:));
    overlap_all(3,1,s) = sum(frn_pe(:) & ~frn_pl(:) & ~frn_ti(:)) / frn_all;
    overlap_all(3,2,s) = sum(~frn_pe(:) & frn_pl(:) & ~frn_ti(:)) / frn_all;
    overlap_all(3,3,s) = sum(~frn_pe(:) & ~frn_pl(:) & frn_ti(:)) / frn_all;
    overlap_all(3,4,s) = sum(frn_pe(:) & frn_pl(:) & ~frn_ti(:)) / frn_all;
    overlap_all(3,5,s) = sum(frn_pe(:) & ~frn_pl(:) & frn_ti(:)) / frn_all;
    overlap_all(3,6,s) = sum(~frn_pe(:) & frn_pl(:) & frn_ti(:)) / frn_all;
    overlap_all(3,7,s) = sum(frn_pe(:) & frn_pl(:) & frn_ti(:)) / frn_all;

    % temporal
    tmp_all = sum(tmp_pe(:) | tmp_pl(:) | tmp_ti(:));
    overlap_all(4,1,s) = sum(tmp_pe(:) & ~tmp_pl(:) & ~tmp_ti(:)) / tmp_all;
    overlap_all(4,2,s) = sum(~tmp_pe(:) & tmp_pl(:) & ~tmp_ti(:)) / tmp_all;
    overlap_all(4,3,s) = sum(~tmp_pe(:) & ~tmp_pl(:) & tmp_ti(:)) / tmp_all;
    overlap_all(4,4,s) = sum(tmp_pe(:) & tmp_pl(:) & ~tmp_ti(:)) / tmp_all;
    overlap_all(4,5,s) = sum(tmp_pe(:) & ~tmp_pl(:) & tmp_ti(:)) / tmp_all;
    overlap_all(4,6,s) = sum(~tmp_pe(:) & tmp_pl(:) & tmp_ti(:)) / tmp_all;
    overlap_all(4,7,s) = sum(tmp_pe(:) & tmp_pl(:) & tmp_ti(:)) / tmp_all;

    % all areas
    all_pe = par_pe | pcn_pe | frn_pe | tmp_pe;
    all_pl = par_pl | pcn_pl | frn_pl | tmp_pl;
    all_ti = par_ti | pcn_ti | frn_ti | tmp_ti;
    all_sum = sum(all_pe(:) | all_pl(:) | all_ti(:));
    overlap_all(5,1,s) = sum(all_pe(:) & ~all_pl(:) & ~all_ti(:)) / all_sum;
    overlap_all(5,2,s) = sum(~all_pe(:) & all_pl(:) & ~all_ti(:)) / all_sum;
    overlap_all(5,3,s) = sum(~all_pe(:) & ~all_pl(:) & all_ti(:)) / all_sum;
    overlap_all(5,4,s) = sum(all_pe(:) & all_pl(:) & ~all_ti(:)) / all_sum;
    overlap_all(5,5,s) = sum(all_pe(:) & ~all_pl(:) & all_ti(:)) / all_sum;
    overlap_all(5,6,s) = sum(~all_pe(:) & all_pl(:) & all_ti(:)) / all_sum;
    overlap_all(5,7,s) = sum(all_pe(:) & all_pl(:) & all_ti(:)) / all_sum;
    
    
%     % parietal
%     overlap_all(1,1,s) = sum(par_pe(:) & par_pl(:)) / sum(par_pe(:) | par_pl(:));
%     overlap_all(1,2,s) = sum(par_pe(:) & par_ti(:)) / sum(par_pe(:) | par_ti(:));
%     overlap_all(1,3,s) = sum(par_pl(:) & par_ti(:)) / sum(par_pl(:) | par_ti(:));
%     overlap_all(1,4,s) = sum(par_pe(:) & par_pl(:) & par_ti(:)) / sum(par_pe(:) | par_pl(:) | par_ti(:));
% 
%     % precuneus
%     overlap_all(2,1,s) = sum(pcn_pe(:) & pcn_pl(:)) / sum(pcn_pe(:) | pcn_pl(:));
%     overlap_all(2,2,s) = sum(pcn_pe(:) & pcn_ti(:)) / sum(pcn_pe(:) | pcn_ti(:));
%     overlap_all(2,3,s) = sum(pcn_pl(:) & pcn_ti(:)) / sum(pcn_pl(:) | pcn_ti(:));
%     overlap_all(2,4,s) = sum(pcn_pe(:) & pcn_pl(:) & pcn_ti(:)) / sum(pcn_pe(:) | pcn_pl(:) | pcn_ti(:));
% 
%     % frontal
%     overlap_all(3,1,s) = sum(frn_pe(:) & frn_pl(:)) / sum(frn_pe(:) | frn_pl(:));
%     overlap_all(3,2,s) = sum(frn_pe(:) & frn_ti(:)) / sum(frn_pe(:) | frn_ti(:));
%     overlap_all(3,3,s) = sum(frn_pl(:) & frn_ti(:)) / sum(frn_pl(:) | frn_ti(:));
%     overlap_all(3,4,s) = sum(frn_pe(:) & frn_pl(:) & frn_ti(:)) / sum(frn_pe(:) | frn_pl(:) | frn_ti(:));
% 
%     % temporal
%     overlap_all(4,1,s) = sum(tmp_pe(:) & tmp_pl(:)) / sum(tmp_pe(:) | tmp_pl(:));
%     overlap_all(4,2,s) = sum(tmp_pe(:) & tmp_ti(:)) / sum(tmp_pe(:) | tmp_ti(:));
%     overlap_all(4,3,s) = sum(tmp_pl(:) & tmp_ti(:)) / sum(tmp_pl(:) | tmp_ti(:));
%     overlap_all(4,4,s) = sum(tmp_pe(:) & tmp_pl(:) & tmp_ti(:)) / sum(tmp_pe(:) | tmp_pl(:) | tmp_ti(:));
end


h=pie3(nanmean(overlap_all(2,:,:),3));           % can be also done in Excel



% %% Compute overlap with DMN
% 
% % to visualize negative ICA components: make an SMP out of the component,
% % choose advanced tab->create POIs (area threshold 0), combine all POIs
% % using "a OR b", and go to options->POI functions->POI to SMP.
% 
% 
% percent_DMN_in_domains=zeros(3,5,num_subjects_to_use);
% percent_domains_in_DMN=zeros(3,5,num_subjects_to_use);
% 
% for s=1:num_subjects_to_use
%     subj=subject_names(s).name;
%     output_dir=fullfile(subjects_output_dir, subj);
%     ACPC_output_dir=[output_dir '\ACPC\'];
%     
%     DMN_voi_file = getfullfiles([ACPC_output_dir subj '_DMN*good.voi']);
%     
%     if isempty(DMN_voi_file)
%         
%         percent_DMN_in_domains(:,:,s) = NaN;
%         percent_domains_in_DMN(:,:,s) = NaN;
%         
%     else
%         disp(subj);
%         
%         % reading the VOIs saved before
%         DMN_voi = xff(DMN_voi_file{1});
% %         pe_voi_filename = [ACPC_output_dir subj '_pe_vs_control_and_rest.voi'];
% %         pl_voi_filename = [ACPC_output_dir subj '_pl_vs_control_and_rest.voi'];
% %         ti_voi_filename = [ACPC_output_dir subj '_ti_vs_control_and_rest.voi'];
%         pe_voi_filename = [ACPC_output_dir subj '_pe_vs_others_and_rest.voi'];
%         pl_voi_filename = [ACPC_output_dir subj '_pl_vs_others_and_rest.voi'];
%         ti_voi_filename = [ACPC_output_dir subj '_ti_vs_others_and_rest.voi'];
% 
%         if exist(pe_voi_filename,'file'), pe_vois = xff(pe_voi_filename); else pe_vois = xff('new:voi'); end
%         if exist(pl_voi_filename,'file'), pl_vois = xff(pl_voi_filename); else pl_vois = xff('new:voi'); end
%         if exist(ti_voi_filename,'file'), ti_vois = xff(ti_voi_filename); else ti_vois = xff('new:voi'); end
%         
%         
%         % Creating 3D matrices with 1 in each active voxel
%         par_pe=zeros(256,256,256); pcn_pe=zeros(256,256,256); frn_pe=zeros(256,256,256); tmp_pe=zeros(256,256,256);
%         par_pl=zeros(256,256,256); pcn_pl=zeros(256,256,256); frn_pl=zeros(256,256,256); tmp_pl=zeros(256,256,256);
%         par_ti=zeros(256,256,256); pcn_ti=zeros(256,256,256); frn_ti=zeros(256,256,256); tmp_ti=zeros(256,256,256);
%         DMN=zeros(256,256,256);
%         
%         for i=1:length(pe_vois.VOI)
%             if ~isempty(strfind(pe_vois.VOI(i).Name(1:3),'par')) || ~isempty(strfind(pe_vois.VOI(i).Name,'PAR'))
%                 par_pe(sub2ind([256,256,256], pe_vois.VOI(i).Voxels(:,1),pe_vois.VOI(i).Voxels(:,2),pe_vois.VOI(i).Voxels(:,3))) = 1;
%             elseif ~isempty(strfind(pe_vois.VOI(i).Name(1:3),'pcn')) || ~isempty(strfind(pe_vois.VOI(i).Name,'PCN'))
%                 pcn_pe(sub2ind([256,256,256], pe_vois.VOI(i).Voxels(:,1),pe_vois.VOI(i).Voxels(:,2),pe_vois.VOI(i).Voxels(:,3))) = 1;
%             elseif ~isempty(strfind(pe_vois.VOI(i).Name(1:3),'frn')) || ~isempty(strfind(pe_vois.VOI(i).Name,'FRN'))
%                 frn_pe(sub2ind([256,256,256], pe_vois.VOI(i).Voxels(:,1),pe_vois.VOI(i).Voxels(:,2),pe_vois.VOI(i).Voxels(:,3))) = 1;
%             elseif ~isempty(strfind(pe_vois.VOI(i).Name(1:3),'tmp')) || ~isempty(strfind(pe_vois.VOI(i).Name,'TMP'))
%                 tmp_pe(sub2ind([256,256,256], pe_vois.VOI(i).Voxels(:,1),pe_vois.VOI(i).Voxels(:,2),pe_vois.VOI(i).Voxels(:,3))) = 1;
%             end
%         end
%         for i=1:length(pl_vois.VOI)
%             if ~isempty(strfind(pl_vois.VOI(i).Name(1:3),'par')) || ~isempty(strfind(pl_vois.VOI(i).Name,'PAR'))
%                 par_pl(sub2ind([256,256,256], pl_vois.VOI(i).Voxels(:,1),pl_vois.VOI(i).Voxels(:,2),pl_vois.VOI(i).Voxels(:,3))) = 1;
%             elseif ~isempty(strfind(pl_vois.VOI(i).Name(1:3),'pcn')) || ~isempty(strfind(pl_vois.VOI(i).Name,'PCN'))
%                 pcn_pl(sub2ind([256,256,256], pl_vois.VOI(i).Voxels(:,1),pl_vois.VOI(i).Voxels(:,2),pl_vois.VOI(i).Voxels(:,3))) = 1;
%             elseif ~isempty(strfind(pl_vois.VOI(i).Name(1:3),'frn')) || ~isempty(strfind(pl_vois.VOI(i).Name,'FRN'))
%                 frn_pl(sub2ind([256,256,256], pl_vois.VOI(i).Voxels(:,1),pl_vois.VOI(i).Voxels(:,2),pl_vois.VOI(i).Voxels(:,3))) = 1;
%             elseif ~isempty(strfind(pl_vois.VOI(i).Name(1:3),'tmp')) || ~isempty(strfind(pl_vois.VOI(i).Name,'TMP'))
%                 tmp_pl(sub2ind([256,256,256], pl_vois.VOI(i).Voxels(:,1),pl_vois.VOI(i).Voxels(:,2),pl_vois.VOI(i).Voxels(:,3))) = 1;
%             end
%         end
%         for i=1:length(ti_vois.VOI)
%             if ~isempty(strfind(ti_vois.VOI(i).Name(1:3),'par')) || ~isempty(strfind(ti_vois.VOI(i).Name,'PAR'))
%                 par_ti(sub2ind([256,256,256], ti_vois.VOI(i).Voxels(:,1),ti_vois.VOI(i).Voxels(:,2),ti_vois.VOI(i).Voxels(:,3))) = 1;
%             elseif ~isempty(strfind(ti_vois.VOI(i).Name(1:3),'pcn')) || ~isempty(strfind(ti_vois.VOI(i).Name,'PCN'))
%                 pcn_ti(sub2ind([256,256,256], ti_vois.VOI(i).Voxels(:,1),ti_vois.VOI(i).Voxels(:,2),ti_vois.VOI(i).Voxels(:,3))) = 1;
%             elseif ~isempty(strfind(ti_vois.VOI(i).Name(1:3),'frn')) || ~isempty(strfind(ti_vois.VOI(i).Name,'FRN'))
%                 frn_ti(sub2ind([256,256,256], ti_vois.VOI(i).Voxels(:,1),ti_vois.VOI(i).Voxels(:,2),ti_vois.VOI(i).Voxels(:,3))) = 1;
%             elseif ~isempty(strfind(ti_vois.VOI(i).Name(1:3),'tmp')) || ~isempty(strfind(ti_vois.VOI(i).Name,'TMP'))
%                 tmp_ti(sub2ind([256,256,256], ti_vois.VOI(i).Voxels(:,1),ti_vois.VOI(i).Voxels(:,2),ti_vois.VOI(i).Voxels(:,3))) = 1;
%             end
%         end
%         
%         DMN(sub2ind([256,256,256], DMN_voi.VOI(1).Voxels(:,1),DMN_voi.VOI(1).Voxels(:,2),DMN_voi.VOI(1).Voxels(:,3))) = 1;
%         
%         % calculating the percent of DMN voxels inside each domain's activation clusters
%         percent_DMN_in_domains(1,1,s) = sum(par_pe(:) & DMN(:)) / sum(par_pe(:));
%         percent_DMN_in_domains(1,2,s) = sum(pcn_pe(:) & DMN(:)) / sum(pcn_pe(:));
%         percent_DMN_in_domains(1,3,s) = sum(frn_pe(:) & DMN(:)) / sum(frn_pe(:));
%         percent_DMN_in_domains(1,4,s) = sum(tmp_pe(:) & DMN(:)) / sum(tmp_pe(:));
%         percent_DMN_in_domains(1,5,s) = sum((par_pe(:) | pcn_pe(:) | frn_pe(:) | tmp_pe(:)) & DMN(:)) / sum(par_pe(:) | pcn_pe(:) | frn_pe(:) | tmp_pe(:));
% 
%         percent_DMN_in_domains(2,1,s) = sum(par_pl(:) & DMN(:)) / sum(par_pl(:));
%         percent_DMN_in_domains(2,2,s) = sum(pcn_pl(:) & DMN(:)) / sum(pcn_pl(:));
%         percent_DMN_in_domains(2,3,s) = sum(frn_pl(:) & DMN(:)) / sum(frn_pl(:));
%         percent_DMN_in_domains(2,4,s) = sum(tmp_pl(:) & DMN(:)) / sum(tmp_pl(:));
%         percent_DMN_in_domains(2,5,s) = sum((par_pl(:) | pcn_pl(:) | frn_pl(:) | tmp_pl(:)) & DMN(:)) / sum(par_pl(:) | pcn_pl(:) | frn_pl(:) | tmp_pl(:));
% 
%         percent_DMN_in_domains(3,1,s) = sum(par_ti(:) & DMN(:)) / sum(par_ti(:));
%         percent_DMN_in_domains(3,2,s) = sum(pcn_ti(:) & DMN(:)) / sum(pcn_ti(:));
%         percent_DMN_in_domains(3,3,s) = sum(frn_ti(:) & DMN(:)) / sum(frn_ti(:));
%         percent_DMN_in_domains(3,4,s) = sum(tmp_ti(:) & DMN(:)) / sum(tmp_ti(:));
%         percent_DMN_in_domains(3,5,s) = sum((par_ti(:) | pcn_ti(:) | frn_ti(:) | tmp_ti(:)) & DMN(:)) / sum(par_ti(:) | pcn_ti(:) | frn_ti(:) | tmp_ti(:));
%         
%         
%         % calculating the percent of each domain's active voxels inside the DMN component
%         percent_domains_in_DMN(1,1,s) = sum(par_pe(:) & DMN(:)) / sum(DMN(:));
%         percent_domains_in_DMN(1,2,s) = sum(pcn_pe(:) & DMN(:)) / sum(DMN(:));
%         percent_domains_in_DMN(1,3,s) = sum(frn_pe(:) & DMN(:)) / sum(DMN(:));
%         percent_domains_in_DMN(1,4,s) = sum(tmp_pe(:) & DMN(:)) / sum(DMN(:));
%         percent_domains_in_DMN(1,5,s) = sum((par_pe(:) | pcn_pe(:) | frn_pe(:) | tmp_pe(:)) & DMN(:)) / sum(DMN(:));
% 
%         percent_domains_in_DMN(2,1,s) = sum(par_pl(:) & DMN(:)) / sum(DMN(:));
%         percent_domains_in_DMN(2,2,s) = sum(pcn_pl(:) & DMN(:)) / sum(DMN(:));
%         percent_domains_in_DMN(2,3,s) = sum(frn_pl(:) & DMN(:)) / sum(DMN(:));
%         percent_domains_in_DMN(2,4,s) = sum(tmp_pl(:) & DMN(:)) / sum(DMN(:));
%         percent_domains_in_DMN(2,5,s) = sum((par_pl(:) | pcn_pl(:) | frn_pl(:) | tmp_pl(:)) & DMN(:)) / sum(DMN(:));
% 
%         percent_domains_in_DMN(3,1,s) = sum(par_ti(:) & DMN(:)) / sum(DMN(:));
%         percent_domains_in_DMN(3,2,s) = sum(pcn_ti(:) & DMN(:)) / sum(DMN(:));
%         percent_domains_in_DMN(3,3,s) = sum(frn_ti(:) & DMN(:)) / sum(DMN(:));
%         percent_domains_in_DMN(3,4,s) = sum(tmp_ti(:) & DMN(:)) / sum(DMN(:));
%         percent_domains_in_DMN(3,5,s) = sum((par_ti(:) | pcn_ti(:) | frn_ti(:) | tmp_ti(:)) & DMN(:)) / sum(DMN(:));
% 
%         
%         DMN_voi.ClearObject; pe_vois.ClearObject; pl_vois.ClearObject; ti_vois.ClearObject;
%     end
% end
% 
% 
% a=nanmean(percent_DMN_in_domains,3);
% b=nanstd(percent_DMN_in_domains,[],3);
% c=b ./ sqrt(sum(~isnan(percent_DMN_in_domains), 3));
% 
% aa=nanmean(percent_domains_in_DMN,3);
% bb=nanstd(percent_domains_in_DMN,[],3);
% cc=bb ./ sqrt(sum(~isnan(percent_domains_in_DMN), 3));
