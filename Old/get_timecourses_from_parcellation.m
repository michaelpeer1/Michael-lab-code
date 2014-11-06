function [parc_areas, timecourses]=get_timecourses_from_parcellation(parcellation_filename, functional_directory)
% this script gets a file with a parcellation mask (each number represents
% a different area), and a directory with functional images, and returns
% the areas and the timecourse for each area in a matrix

% the script supports both 3D and 4D image files




% read the parcellation file
func_dir_filenames=dir(fullfile(functional_directory,'*.img'));
if isempty(func_dir_filenames)
    func_dir_filenames=dir(fullfile(functional_directory,'*.nii'));
end
parc_images = y_Reslice_no_outputfile(parcellation_filename,[],0, fullfile(functional_directory, func_dir_filenames(1).name));
parc_areas=unique(parc_images);
parc_areas=parc_areas(2:end); % the first value is zero

% read the functional images
b = get_func_matrix(functional_directory);
func_images={};
for i=1:length(b)
    func_images{end+1}=b(:,:,:,i);
end

% get the timecourses
timecourses=cell(1,length(parc_areas));
for i=1:length(parc_areas)
    for j=1:length(func_images);
        aaa=func_images{j}(parc_images==parc_areas(i));
        timecourses{i}=[timecourses{i} mean(aaa)];
    end
end

