function thresh = find_func_threshold_otsu_from_func_dir(functional_directory)
% thresh = find_func_threshold_otsu_from_func_dir(func_images_directory)
%
% This function receives a directory with functional images in NIFTI format, and uses 
% Otsu's method to calcultate a division between intensities which are part of the
% brain and intensities which are not.
%
% This is later used to threshold the images, to find voxels which are
% brain related and avoid using voxels with signal dropout


% read the functional images into a matrix
func_images_mat=[];
func_dir_filenames=dir(fullfile(functional_directory,'*.img'));
if isempty(func_dir_filenames)
    func_dir_filenames=dir(fullfile(functional_directory,'*.nii'));
end
if length(func_dir_filenames)>1
    % for 3D files
    for i=1:length(func_dir_filenames)
        func_images_mat(:,:,:,i)=spm_read_vols(spm_vol(fullfile(functional_directory,func_dir_filenames(i).name)));
    end
else
    % for one 4D file
    func_images_mat=spm_read_vols(spm_vol(fullfile(functional_directory,func_dir_filenames(1).name)));
end


% calculate mean functional image
mean_func_image=zeros(size(func_images_mat(:,:,:,1)));
for i=1:size(func_images_mat,1)
    for j=1:size(func_images_mat,2)
        for q=1:size(func_images_mat,3)
            mean_func_image(i,j,q)=round(nanmean(squeeze(func_images_mat(i,j,q,:))));
        end
    end
end
mean_func_image(mean_func_image<1)=1;
mean_func_image(isnan(mean_func_image))=1;


% calculate threshold by Otsu's method
mean_fi_norm = mean_func_image/max(mean_func_image(:));
thresh = graythresh(mean_fi_norm);
thresh = thresh * max(mean_func_image(:));
