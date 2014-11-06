function save_FC_image_from_mat_and_mask(func_matrix, mask_image_matrix, output_filename, output_image_space)
% FC_image = save_FC_image_from_mat_and_mask(func_matrix, mask_image_matrix, output_filename, output_image_space)
%
% receives a 4D functional data matrix, a 3D mask data matrix (e.g. 
% thresholded segmentation image), an output image filename, and a 
% filename of another image with the same parameters as these to be saved 
% (such as a FunRawARWSFC image)
%
% saves an image of the functional connectivity (voxelwise)

FC_image = get_FC_from_func_mat_and_mask(func_matrix, mask_image_matrix);
save_mat_to_nifti(output_image_space, FC_image, output_filename);

