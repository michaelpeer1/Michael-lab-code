% mydir='C:\temp\Sami\1'; a=dir(fullfile(mydir,'*.nii'));
% for i=1:length(a)
% mask_filename=fullfile(mydir,a(i).name);
% disp(i)
% output_filename=fullfile(mydir,['FC_' a(i).name]);
% save_FC_image_from_dir_and_maskfile(func_dir, mask_filename, mask_threshold, output_filename);
% end
% 
% mydir='C:\temp\Sami\3'; a=dir(fullfile(mydir,'*.nii'));
% func_dir='C:\Subjects_MRI_data\7T\New_subjs_prep\Resting state\FunRawRFCWS\121123_alex';
% for i=1:length(a)
% mask_filename=fullfile(mydir,a(i).name);
% disp(i)
% output_filename=fullfile(mydir,['FC_' a(i).name]);
% save_FC_image_from_dir_and_maskfile(func_dir, mask_filename, mask_threshold, output_filename);
% end


% this is after writing all ROIs from SPM clusters using MarsBar or the
% script 'get_SPM_clusters_images.m'
parent_func_dir='C:\Subjects_MRI_data\7T\New_subjs_prep\Resting state\FunRawRFCWS\';
func_dirs=dir(parent_func_dir);
func_dirs=func_dirs(3:end);

for i=1:length(func_dirs)
    disp(i)
    current_dir=['C:\temp\Orientation\FC - 1.5mm\' num2str(i)];
    a=dir(fullfile(current_dir,'*_roi.mat'));
    func_dir=fullfile(parent_func_dir,func_dirs(i).name);
    func_matrix=get_func_matrix(func_dir);
    func_filename=dir(func_dir); func_filename=fullfile(func_dir,func_filename(3).name);
    for j=1:length(a)
        % saving the ROIs as images
         load(fullfile(current_dir,a(j).name));
        Nifti_filename = fullfile(current_dir,[a(j).name(1:end-8) '.nii']);
         save_as_image(roi,Nifti_filename);
        mask_image_matrix=y_Reslice_no_outputfile(Nifti_filename,[],0,func_filename);

        % calculating functional connectivity and saving images
        FC_filename=fullfile(current_dir,['FC_' a(j).name(1:end-8) '.nii']);
%         save_FC_image_from_dir_and_maskfile(fullfile(parent_func_dir,func_dirs(i).name), Nifti_filename, FC_filename);
        FC_image = get_FC_from_func_mat_and_mask(func_matrix, mask_image_matrix);
        save_mat_to_nifti([func_filename ',1'], FC_image, FC_filename);
    end
end
