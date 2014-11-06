function [parc_areas, timecourses]=get_timecourses_from_parcellation_4D(parcellation_filename, functional_directory)
% this script gets a file with a parcellation mask (each number represents
% a different area), and a directory with functional images, and returns
% the areas and the timecourse for each area in a matrix
%
% CURRENTLY, THE DIMENSIONS OF THE IMAGES MUST AGREE (THE SCRIPT DOESN'T DO
% RESLICING)

%%parcellation_filename='C:\temp\for_ilan\r_TEST_rBoJo_aparc.a2009s_aseg.nii';
%%functional_directory='C:\Subjects_MRI_data\3T\120929_gilad_goldberg\Preprocessing\FunRawARWSDF\120929_GOLDBERG_GILAD_1\';


% read the parcellation file
a=spm_read_vols(spm_vol(parcellation_filename));
parc_areas=unique(a);

% read the 4D file and convert it to 3D
func_dir_4D_filename=dir(fullfile(functional_directory,'*.nii'));
spm_file_split(fullfile(functional_directory, func_dir_4D_filename(1).name));
%delete(fullfile(functional_directory, func_dir_4D_filename(1).name));

% read the functional images
func_images={};
func_dir_filenames=dir(fullfile(functional_directory,'*.img'));
for i=1:length(func_dir_filenames)
    func_images{end+1}=spm_read_vols(spm_vol(fullfile(functional_directory,func_dir_filenames(i).name)));
end

% check that the dimensions of the images agree
if size(func_images{1})~=size(a)
    disp('The sizes of the parcellation and functional images do not agree!!!!!')
    disp('Exiting...')
    return
end

% get the timecourses
timecourses=cell(1,length(parc_areas));
for i=1:length(parc_areas)
    for j=1:length(func_images);
        aaa=func_images{j}(a==parc_areas(i));
        timecourses{i}=[timecourses{i} mean(aaa)];
    end
end

