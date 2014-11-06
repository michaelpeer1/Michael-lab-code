function thresh = find_func_threshold(func_images_mat)
% thresh = find_func_threshold(func_images)
%
% This function receives a 4d-matrix of functional images, and uses Otsu's
% method to calcultate a division between intensities which are part of the
% brain and intensities which are not
%
% This is later used to threshold the images, to find voxels which are
% brain related and avoid using voxels with signal dropout


% func_images_mat=get_func_matrix(func_dir);

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

mean_fi_norm = mean_func_image/max(mean_func_image(:));
thresh = graythresh(mean_fi_norm);
thresh = thresh * max(mean_func_image(:));
