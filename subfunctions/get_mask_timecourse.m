function timecourse = get_mask_timecourse(func_matrix, mask_image_matrix)
% timecourse = get_mask_timecourse(func_matrix, mask_image_matrix)
%
% receives a 4D matrix of functional data (e.g. results of get_func_matrix), 
% and a 3D matrix of the mask image (e.g. ROI image or segmentation image).
% Mask image should contain only 1s or 0s.
%
% returns the timecourse from the region defined by the mask 

num_images=size(func_matrix,4);
timecourse=zeros(num_images,1);

for i=1:num_images
    func_image_temp=func_matrix(:,:,:,i);
    timecourse(i)=mean(func_image_temp(mask_image_matrix==1));
end
