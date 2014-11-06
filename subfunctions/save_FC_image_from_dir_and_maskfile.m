function save_FC_image_from_dir_and_maskfile(func_dir, mask_filename, output_filename)
% save_FC_image_from_dir_and_maskfile(func_dir, mask_filename, output_filename)
%
% receives a 4D functional data matrix, and a timecourse (from voxel/ROI),
% an output image filename, and a filename of another image with the same
% parameters as these to be saved (such as a FunRawARWSFC image)
%
% saves an image of the functional connectivity (voxelwise)

func_matrix=get_func_matrix(func_dir);
func_filename=dir(func_dir); func_filename=fullfile(func_dir,func_filename(3).name);
mask_image_matrix=y_Reslice_no_outputfile(mask_filename,[],0,func_filename);

FC_image = get_FC_from_func_mat_and_mask(func_matrix, mask_image_matrix);
save_mat_to_nifti([func_filename ',1'], FC_image, output_filename);

