function save_FC_image_from_mat(func_matrix, timecourse, output_filename, output_image_space)
% FC_image = save_FC_image_from_mat(func_matrix, timecourse, output_filename, output_image_space)
%
% receives a 4D functional data matrix, and a timecourse (from voxel/ROI),
% an output image filename, and a filename of another image with the same
% parameters as these to be saved (such as a FunRawARWSFC image)
%
% saves an image of the functional connectivity (voxelwise)

FC_image = get_FC_from_func_mat(func_matrix, timecourse);
save_mat_to_nifti(output_image_space, FC_image, output_filename);

