function segmentation_mask = make_full_segmentation_mask(segmentation_dir, use_normalized, save_image)
% segmentation_mask = make_full_segmentation_mask(segmentation_dir, use_normalized, save_image)
%
% this function receives a T1 segmentation directory with c1,c2,etc. images
% and computes a combined mask based on maximum tissue probability in each
% voxel (each voxel will be coded according to the most probable tissue
% there)
% if use_normalized is 1, normalized files (wc1*,wc2*,etc.) will be used
% if save_image is 1, a segmentation.nii file will be saved in the segmentation directory
% 
% returns a mask with the following code:
% 0 - outside the brain
% 1 - grey matter
% 2 - white matter
% 3 - cerebrospinal fluid 

% getting files
if use_normalized
    GM_file_temp = dir(fullfile(segmentation_dir, 'w*c1*.nii')); GM_file = fullfile(segmentation_dir, GM_file_temp.name);
    WM_file_temp = dir(fullfile(segmentation_dir, 'w*c2*.nii')); WM_file = fullfile(segmentation_dir, WM_file_temp.name);
    CSF_file_temp = dir(fullfile(segmentation_dir, 'w*c3*.nii')); CSF_file = fullfile(segmentation_dir, CSF_file_temp.name);
    
    T1Img_file_index = strfind(GM_file_temp.name,'c1'); T1Img_file_temp = GM_file_temp.name(T1Img_file_index+2:end-4);
    T1Img_file = dir(fullfile(segmentation_dir, ['w' T1Img_file_temp '.nii']));
    if isempty(T1Img_file)
        T1Img_file = dir(fullfile(segmentation_dir, ['w' T1Img_file_temp '.img']));
    end
    T1Img_file = fullfile(segmentation_dir, T1Img_file.name);
else
    GM_file_temp = dir(fullfile(segmentation_dir, 'c1*.nii')); GM_file = fullfile(segmentation_dir, GM_file_temp.name);
    WM_file_temp = dir(fullfile(segmentation_dir, 'c2*.nii')); WM_file = fullfile(segmentation_dir, WM_file_temp.name);
    CSF_file_temp = dir(fullfile(segmentation_dir, 'c3*.nii')); CSF_file = fullfile(segmentation_dir, CSF_file_temp.name);

    T1Img_file_index = strfind(GM_file_temp.name,'c1'); T1Img_file_temp = GM_file_temp.name(T1Img_file_index+2:end-4);
    T1Img_file = dir(fullfile(segmentation_dir, [T1Img_file_temp '.nii']));
    if isempty(T1Img_file)
        T1Img_file = dir(fullfile(segmentation_dir, [T1Img_file_temp '.img']));
    end
    T1Img_file = fullfile(segmentation_dir, T1Img_file.name);
end
GM_image=spm_read_vols(spm_vol(GM_file));
WM_image=spm_read_vols(spm_vol(WM_file));
CSF_image=spm_read_vols(spm_vol(CSF_file));

% creating mask
temp_mask=GM_image; temp_mask(:,:,:,2)=WM_image; temp_mask(:,:,:,3)=CSF_image;
[max_val,max_ind]=max(temp_mask,[],4);
max_ind(max_val<0.2)=0;
segmentation_mask = max_ind;

% saving mask
if save_image
    if use_normalized
        save_mat_to_nifti(T1Img_file, segmentation_mask, fullfile(segmentation_dir, 'wSegmentation.nii'));
    else
        save_mat_to_nifti(T1Img_file, segmentation_mask, fullfile(segmentation_dir, 'Segmentation.nii'));
    end
end
