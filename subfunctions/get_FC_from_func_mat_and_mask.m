function FC_image = get_FC_from_func_mat_and_mask(func_matrix, mask_image_matrix)
% FC_image = get_FC_from_func_mat_and_mask(func_matrix, mask_image_matrix)
%
% receives a 4D functional data matrix, and a mask image with the same
% dimensions (e.g. ROI mask), and computes functional connectivity to areas
% in the mask above the threshold 
%
% returns a 3D matrix (image) of the correlation of the timecourse to each voxel

timecourse = get_mask_timecourse(func_matrix, mask_image_matrix);
FC_image = get_FC_from_func_mat(func_matrix, timecourse);

