function func_mat = get_func_matrix(functional_directory)
% func_mat = get_func_matrix(dirname)
%
% Receives a directory with functional files, and puts them in a 4D matrix
% in Matlab

func_dir_filenames=dir(fullfile(functional_directory,'*.img'));
if isempty(func_dir_filenames)
    func_dir_filenames=dir(fullfile(functional_directory,'*.nii'));
end
num_pics=length(func_dir_filenames);

func_image1=spm_read_vols(spm_vol(fullfile(functional_directory,func_dir_filenames(1).name)));
if num_pics>1
    % for 3D files
    func_mat=zeros([size(func_image1) num_pics]);
    func_mat(:,:,:,1)=func_image1;
    for i=2:num_pics
        func_mat(:,:,:,i)=spm_read_vols(spm_vol(fullfile(functional_directory,func_dir_filenames(i).name)));
    end
else
    % for 4D files
    func_mat=func_image1;
end
