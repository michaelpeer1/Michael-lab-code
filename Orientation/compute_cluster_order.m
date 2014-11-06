% Stages of analysis:

subjects_output_dir = 'E:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end-6);

num_subjects_to_use = 16;   % excluding the high-res subjects
num_domains=3;  %  space person time

PCN_centers = nan(num_subjects_to_use, num_domains,2); 
PAR_centers = nan(num_subjects_to_use, num_domains,2); 
FRN_centers = nan(num_subjects_to_use, num_domains,2); 
PCN_centers_no_rotation = nan(num_subjects_to_use, num_domains,3); 

for s=1:num_subjects_to_use
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC\'];
    
    % reading the VOIs saved before
%     pl_voi_filename = [ACPC_output_dir subj '_pl_vs_control_and_rest.voi'];
%     pe_voi_filename = [ACPC_output_dir subj '_pe_vs_control_and_rest.voi'];
%     ti_voi_filename = [ACPC_output_dir subj '_ti_vs_control_and_rest.voi'];
    pl_voi_filename = [ACPC_output_dir subj '_pl_vs_others_and_rest.voi'];
    pe_voi_filename = [ACPC_output_dir subj '_pe_vs_others_and_rest.voi'];
    ti_voi_filename = [ACPC_output_dir subj '_ti_vs_others_and_rest.voi'];
    if exist(pl_voi_filename,'file'), pl_vois = xff(pl_voi_filename); else pl_vois = xff('new:voi'); end
    if exist(pe_voi_filename,'file'), pe_vois = xff(pe_voi_filename); else pe_vois = xff('new:voi'); end
    if exist(ti_voi_filename,'file'), ti_vois = xff(ti_voi_filename); else ti_vois = xff('new:voi'); end
    
    % finding the Y-coordinate of the center of each cluster
    % (the order in v_xff.Voi(n).Voxels is: y, z, x)
    par_pl=nan(1,3); pcn_pl=nan(1,3); frn_pl=nan(1,3);
    for i=1:length(pl_vois.VOI)
%         if ~isempty(strfind(pl_vois.VOI(i).Name(1:3),'par')) || ~isempty(strfind(pl_vois.VOI(i).Name,'PAR'))
        if ~isempty(strfind(pl_vois.VOI(i).Name(1:3),'par')) || ~isempty(strfind(pl_vois.VOI(i).Name,'PAR')) ...
                || ~isempty(strfind(pl_vois.VOI(i).Name,'tmp')) || ~isempty(strfind(pl_vois.VOI(i).Name,'TMP'))
            par_pl = [par_pl; pl_vois.VOI(i).Voxels];
        elseif ~isempty(strfind(pl_vois.VOI(i).Name(1:3),'pcn')) || ~isempty(strfind(pl_vois.VOI(i).Name,'PCN'))
            pcn_pl = [pcn_pl; pl_vois.VOI(i).Voxels];
        elseif ~isempty(strfind(pl_vois.VOI(i).Name(1:3),'frn')) || ~isempty(strfind(pl_vois.VOI(i).Name,'FRN'))
            frn_pl = [frn_pl; pl_vois.VOI(i).Voxels];
        end
    end
    par_pl = unique(par_pl,'rows'); pcn_pl = unique(pcn_pl,'rows'); frn_pl = unique(frn_pl,'rows');
    
    par_pe=nan(1,3); pcn_pe=nan(1,3); frn_pe=nan(1,3);
    for i=1:length(pe_vois.VOI)
        if ~isempty(strfind(pe_vois.VOI(i).Name(1:3),'par')) || ~isempty(strfind(pe_vois.VOI(i).Name,'PAR')) ...
                || ~isempty(strfind(pe_vois.VOI(i).Name,'tmp')) || ~isempty(strfind(pe_vois.VOI(i).Name,'TMP'))
            par_pe = [par_pe; pe_vois.VOI(i).Voxels];
        elseif ~isempty(strfind(pe_vois.VOI(i).Name(1:3),'pcn')) || ~isempty(strfind(pe_vois.VOI(i).Name,'PCN'))
            pcn_pe = [pcn_pe; pe_vois.VOI(i).Voxels];
        elseif ~isempty(strfind(pe_vois.VOI(i).Name(1:3),'frn')) || ~isempty(strfind(pe_vois.VOI(i).Name,'FRN'))
            frn_pe = [frn_pe; pe_vois.VOI(i).Voxels];
        end
    end
    par_pe = unique(par_pe,'rows'); pcn_pe = unique(pcn_pe,'rows'); frn_pe = unique(frn_pe,'rows');
    
    par_ti=nan(1,3); pcn_ti=nan(1,3); frn_ti=nan(1,3);
    for i=1:length(ti_vois.VOI)
        if ~isempty(strfind(ti_vois.VOI(i).Name(1:3),'par')) || ~isempty(strfind(ti_vois.VOI(i).Name,'PAR')) ...
                || ~isempty(strfind(ti_vois.VOI(i).Name,'tmp')) || ~isempty(strfind(ti_vois.VOI(i).Name,'TMP'))
            par_ti = [par_ti; ti_vois.VOI(i).Voxels];
        elseif ~isempty(strfind(ti_vois.VOI(i).Name(1:3),'pcn')) || ~isempty(strfind(ti_vois.VOI(i).Name,'PCN'))
            pcn_ti = [pcn_ti; ti_vois.VOI(i).Voxels];
        elseif ~isempty(strfind(ti_vois.VOI(i).Name(1:3),'frn')) || ~isempty(strfind(ti_vois.VOI(i).Name,'FRN'))
            frn_ti = [frn_ti; ti_vois.VOI(i).Voxels];
        end
    end
    par_ti = unique(par_ti,'rows'); pcn_ti = unique(pcn_ti,'rows'); frn_ti = unique(frn_ti,'rows');
    
    % rotating PCN clusters by -45 degrees, using a rotation matrix, to get the correct axis 
    % (the precuneus is rotated by 45 degrees)
    a = [cos(-0.78) -sin(-0.78) 0; sin(-0.78) cos(-0.78) 0; 0 0 1] * pcn_pl'; pcn_pl_new = a';
    b = [cos(-0.78) -sin(-0.78) 0; sin(-0.78) cos(-0.78) 0; 0 0 1] * pcn_pe'; pcn_pe_new = b';
    c = [cos(-0.78) -sin(-0.78) 0; sin(-0.78) cos(-0.78) 0; 0 0 1] * pcn_ti'; pcn_ti_new = c';
    
    % calculating center of mass for each region and cluster
    % left hemisphere - X value>128
    PAR_centers(s,1,1) = nanmean(par_pl(par_pl(:,3)>128,1)); PCN_centers(s,1,1) = nanmean(pcn_pl_new(pcn_pl_new(:,3)>128,1)); FRN_centers(s,1,1) = nanmean(frn_pl(frn_pl(:,3)>128,1)); 
    PAR_centers(s,2,1) = nanmean(par_pe(par_pe(:,3)>128,1)); PCN_centers(s,2,1) = nanmean(pcn_pe_new(pcn_pe_new(:,3)>128,1)); FRN_centers(s,2,1) = nanmean(frn_pe(frn_pe(:,3)>128,1)); 
    PAR_centers(s,3,1) = nanmean(par_ti(par_ti(:,3)>128,1)); PCN_centers(s,3,1) = nanmean(pcn_ti_new(pcn_ti_new(:,3)>128,1)); FRN_centers(s,3,1) = nanmean(frn_ti(frn_ti(:,3)>128,1));     
    PCN_centers_no_rotation(s,1,1) = nanmean(pcn_pl(pcn_pl(:,3)>128,1)); PCN_centers_no_rotation(s,2,1) = nanmean(pcn_pe(pcn_pe(:,3)>128,1)); PCN_centers_no_rotation(s,3,1) = nanmean(pcn_ti(pcn_ti(:,3)>128,1));
    % right hemisphere - X value<=128
    PAR_centers(s,1,2) = nanmean(par_pl(par_pl(:,3)<=128,1)); PCN_centers(s,1,2) = nanmean(pcn_pl_new(pcn_pl_new(:,3)<=128,1)); FRN_centers(s,1,2) = nanmean(frn_pl(frn_pl(:,3)<=128,1)); 
    PAR_centers(s,2,2) = nanmean(par_pe(par_pe(:,3)<=128,1)); PCN_centers(s,2,2) = nanmean(pcn_pe_new(pcn_pe_new(:,3)<=128,1)); FRN_centers(s,2,2) = nanmean(frn_pe(frn_pe(:,3)<=128,1)); 
    PAR_centers(s,3,2) = nanmean(par_ti(par_ti(:,3)<=128,1)); PCN_centers(s,3,2) = nanmean(pcn_ti_new(pcn_ti_new(:,3)<=128,1)); FRN_centers(s,3,2) = nanmean(frn_ti(frn_ti(:,3)<=128,1));     
    PCN_centers_no_rotation(s,1,2) = nanmean(pcn_pl(pcn_pl(:,3)<=128,1)); PCN_centers_no_rotation(s,2,2) = nanmean(pcn_pe(pcn_pe(:,3)<=128,1)); PCN_centers_no_rotation(s,3,2) = nanmean(pcn_ti(pcn_ti(:,3)<=128,1));    
    % both hemispheres together
    PAR_centers(s,1,3) = nanmean(par_pl(:,1)); PCN_centers(s,1,3) = nanmean(pcn_pl_new(:,1)); FRN_centers(s,1,3) = nanmean(frn_pl(:,1)); 
    PAR_centers(s,2,3) = nanmean(par_pe(:,1)); PCN_centers(s,2,3) = nanmean(pcn_pe_new(:,1)); FRN_centers(s,2,3) = nanmean(frn_pe(:,1)); 
    PAR_centers(s,3,3) = nanmean(par_ti(:,1)); PCN_centers(s,3,3) = nanmean(pcn_ti_new(:,1)); FRN_centers(s,3,3) = nanmean(frn_ti(:,1));     
    PCN_centers_no_rotation(s,1,3) = nanmean(pcn_pl(:,1)); PCN_centers_no_rotation(s,2,3) = nanmean(pcn_pe(:,1)); PCN_centers_no_rotation(s,3,3) = nanmean(pcn_ti(:,1));
    
    pe_vois.ClearObject; pl_vois.ClearObject; ti_vois.ClearObject;
end

% using the wilcoxon signed-rank test to measure the consistency of the
% order of  activations
a=PCN_centers(sum(isnan(PCN_centers(:,:,3)),2)==0,:,3);
pcn_p1 = signrank(a(:,1),a(:,2)); pcn_p2 = signrank(a(:,2),a(:,3)); pcn_p3 = signrank(a(:,1),a(:,3));
b=PAR_centers(sum(isnan(PAR_centers(:,:,3)),2)==0,:,3);
par_p1 = signrank(b(:,1),b(:,2)); par_p2 = signrank(b(:,2),b(:,3)); par_p3 = signrank(b(:,1),b(:,3));
c=FRN_centers(sum(isnan(FRN_centers(:,:,3)),2)==0,:,3);
frn_p1 = signrank(c(:,1),c(:,2)); frn_p2 = signrank(c(:,2),c(:,3)); frn_p3 = signrank(c(:,1),c(:,3));

% % treating the left and right hemispheres  separately
% a=[PCN_centers(sum(isnan(PCN_centers(:,:,3)),2)==0,:,1); PCN_centers(sum(isnan(PCN_centers(:,:,3)),2)==0,:,2)] ;
% pcn_p1 = signrank(a(:,1),a(:,2)); pcn_p2 = signrank(a(:,2),a(:,3)); pcn_p3 = signrank(a(:,1),a(:,3));
% b=[PAR_centers(sum(isnan(PAR_centers(:,:,3)),2)==0,:,1); PAR_centers(sum(isnan(PAR_centers(:,:,3)),2)==0,:,2)];
% par_p1 = signrank(b(:,1),b(:,2)); par_p2 = signrank(b(:,2),b(:,3)); par_p3 = signrank(b(:,1),b(:,3));
% c=[FRN_centers(sum(isnan(FRN_centers(:,:,3)),2)==0,:,1); FRN_centers(sum(isnan(FRN_centers(:,:,3)),2)==0,:,2)];
% frn_p1 = signrank(c(:,1),c(:,2)); frn_p2 = signrank(c(:,2),c(:,3)); frn_p3 = signrank(c(:,1),c(:,3));
