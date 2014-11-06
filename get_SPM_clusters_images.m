function get_SPM_clusters_images(SPMmat_dir, con_name, voxnum_threshold, output_dir)
% get_SPM_clusters_images(SPMmat_dir, con_name, voxnum_threshold, output_dir)
%
% Create Nifti images out of activation clusters of a specific SPM 
% contrast, for further ROI timecourse / functional-connectivity analysis
%
% Receives a directory with an SPM.mat file, a contrast name, the minimum
% number of voxels in each cluster, and an output directory for saving ROI 
% images
%
% Heavily relies on code from MarsBar 0.43



% voxnum_threshold = 20;
% con_name = 'Time vs person and place';

% reading the SPM.mat file with the contrasts
SPM_model = mardo(fullfile(SPMmat_dir, 'SPM.mat'));

% reading the contrast
t_con = get_contrast_by_name(SPM_model, con_name);
if isempty(t_con)
  error(['Cannot find the contrast ' con_name ...
	' in the design; has it been estimated?']);
end
t_con_fname = t_con.Vspm.fname;
t_pth = fileparts(t_con_fname);
if isempty(t_pth)
    t_con_fname = fullfile(SPMmat_dir, t_con_fname);
end
if ~exist(t_con_fname)
  error(['Cannot find t image ' t_con_fname ...
	 '; has it been estimated?']);
end

% getting the voxels from t image above threshold - UNCORRECTED P VALUE
p_thresh = 0.05;
erdf = error_df(SPM_model);
t_thresh = spm_invTcdf(1-p_thresh, erdf);

V = spm_vol(t_con_fname);
img = spm_read_vols(V);
tmp = find(img(:) > t_thresh);
img = img(tmp);
XYZ = mars_utils('e2xyz', tmp, V.dim(1:3));

% make into clusters
cluster_nos = spm_clusters(XYZ);

% find clusters above voxel-number threshold
all_clusters=unique(cluster_nos);
clusters_to_save=[];
for i=1:length(all_clusters)
    if size(find(cluster_nos==all_clusters(i)),2)>=voxnum_threshold
        clusters_to_save=[clusters_to_save i];
    end
end

% saving the clusters as Nifti images
for i=1:length(clusters_to_save)
    current_cluster_XYZ = XYZ(:, cluster_nos == clusters_to_save(i));
    
    % Make ROI from max cluster
    act_roi = maroi_pointlist(struct('XYZ', current_cluster_XYZ, ...
				 'mat', V.mat), 'vox');
    % Give it a name
    mid_cluster=round(size(current_cluster_XYZ,2)/2);
    cc_x=num2str(current_cluster_XYZ(1,mid_cluster));
    cc_y=num2str(current_cluster_XYZ(2,mid_cluster));
    cc_z=num2str(current_cluster_XYZ(3,mid_cluster));
    roi_name=[con_name '_' cc_x '_' cc_y '_' cc_z];
    roi_name=strrep(roi_name, ' ', '_');
    act_roi = label(act_roi, roi_name);

    % Save as image
    save_as_image(act_roi, fullfile(output_dir, [roi_name '.nii']));
end


