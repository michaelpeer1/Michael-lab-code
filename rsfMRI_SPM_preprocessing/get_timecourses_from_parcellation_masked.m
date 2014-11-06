function [parc_areas, numvox, timecourses] = get_timecourses_from_parcellation_masked(parcel_filename, func_dir, mask_filename, mask_threshold, func_dir_to_threshold, func_threshold)
% [parc_areas, numvox, timecourses]=get_timecourses_from_parcellation_masked(parcel_filename, func_dir, mask_filename, mask_threshold, func_dir_to_threshold, func_threshold)
%
% This script gets a file with a parcellation mask (each number represents
% a different area - e.g. AAL mask), and a directory with functional images, and returns
% the areas and the timecourse for each area in a matrix, and the number of voxels which were 
% used in each area (passed the threshold, etc.).
%
% The functional images are masked with mask_filename (e.g. a normalized c1
% segmentation image), with the specified mask threshold.
%
% The func_threshold optional variable takes only voxels which pass the minimum
% intensity given in the functional images to threshold (e.g. FuncRawARW). To use all voxels, use
% func_lower_threshold=0. If this parameter is not given it is computed by
% find_func_threshold.m.

if nargin==4
    disp('no functional threshold given, setting functional threshold at -1000...')
    func_threshold = -1000;
    func_dir_to_threshold=func_dir;
end

% read first functional image filename, for reslicing of other images
func_dir_filename1=dir(fullfile(func_dir,'*.img'));
if isempty(func_dir_filename1), func_dir_filename1=dir(fullfile(func_dir,'*.nii')); end
func_dir_filename1=fullfile(func_dir, func_dir_filename1(1).name);

% read the functional images
func_images = get_func_matrix(func_dir);
func_images_to_threshold=get_func_matrix(func_dir_to_threshold);

% check if func_lower_threshold is given by user, and compute it otherwise
if nargin==5
    disp('computing functional threshold...')
    func_threshold=find_func_threshold(func_images_to_threshold);
    disp(['functional threshold set at' num2str(func_threshold)])
end

% create mean functional image to threshold, for masking
num_images = size(func_images,4);
mean_func_images_to_threshold = zeros(size(func_images(:,:,:,1)));
for i=1:num_images
    mean_func_images_to_threshold = mean_func_images_to_threshold+func_images_to_threshold(:,:,:,i);
end
mean_func_images_to_threshold = mean_func_images_to_threshold/num_images;

% read the parcellation file
parc_image = y_Reslice_no_outputfile(parcel_filename,[],0, func_dir_filename1);
parc_areas=unique(parc_image);
parc_areas=parc_areas(2:end); % the first value is zero

% read the mask file (e.g. C1 image)
mask_image=y_Reslice_no_outputfile(mask_filename,[],1, func_dir_filename1);

% get the timecourses
timecourses=cell(1,length(parc_areas));
numvox_all=cell(1,length(parc_areas));
numvox=zeros(1,length(parc_areas));

images_to_use = mask_image>=mask_threshold & mean_func_images_to_threshold>=func_threshold;

for i=1:length(parc_areas)
    current_area_image = (parc_image==parc_areas(i));
    current_mask = images_to_use & current_area_image;
    
    for j=1:num_images
        current_image=func_images(:,:,:,j);
        timecourses{i} = [timecourses{i} mean(current_image(current_mask))];
        numvox_all{i}=[numvox_all{i} sum(sum(sum(current_mask)))];
    end
    numvox(i)=round(mean(numvox_all{i}));
end

