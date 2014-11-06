function [numvox, sum_values_area] =  check_AAL_areas(segment_dir, func_dir, func_dir_to_threshold, func_threshold)
% [numvox, sum_values_area] =  check_AAL_areas(segment_dir, func_dir, func_dir_to_threshold, func_threshold)
% 
% This function takes the normalized functional images, masks them with the
% C1 (grey-matter) mask, and then checks the AAL areas for number of
% voxels, mean ROI intensity value across scans, and the existence of NaN values
%
% input: 
% segment_dir - the subject's segmentation directory (should contain
% c1* and wT1* files
% func_dir - contains the subject's normalized functional images
% 
% output:
% numvox - a cell array with the number of voxels in each AAL area
% sum_values_area - a cell array with the absolute mean values in each area (actually
% representing the variance inside the area, since it is z-transformed)

if nargin==2
    func_threshold = -1000;
    func_dir_to_threshold=func_dir;
end

func_dir_filename1=dir(fullfile(func_dir,'*.img'));
if isempty(func_dir_filename1), func_dir_filename1=dir(fullfile(func_dir,'*.nii')); end
func_dir_filename1=fullfile(func_dir, func_dir_filename1(1).name);

% read the normalized C1 image and reslice it
WC1_filename=dir(fullfile(segment_dir, '\wc1*')); WC1_filename=fullfile(segment_dir,WC1_filename.name);
WC1_image=y_Reslice_no_outputfile(WC1_filename,[],1, func_dir_filename1);

% read the AAL image
AAL_template_filename='C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\AAL_61x73x61_YCG.nii';
AAL_template=y_Reslice_no_outputfile(AAL_template_filename,[],0, func_dir_filename1);

% read the functional images
func_images = get_func_matrix(func_dir);
func_images_size=size(func_images); num_func_images=func_images_size(4); func_images_size=func_images_size(1:3);
func_images_to_threshold=get_func_matrix(func_dir_to_threshold);

% create mean functional image to threshold
mean_func_images_to_threshold = zeros(size(func_images(:,:,:,1)));
for i=1:num_func_images
    mean_func_images_to_threshold = mean_func_images_to_threshold+func_images_to_threshold(:,:,:,i);
end
mean_func_images_to_threshold = mean_func_images_to_threshold/num_func_images;

% check number of voxels and absolute mean values in each area in the
% original pictures
AAL_masked_by_WC1_thresholded=AAL_template; AAL_masked_by_WC1_thresholded(WC1_image<0.01)=0;
AAL_masked_by_WC1_thresholded(mean_func_images_to_threshold<func_threshold)=0;

numvox=cell(1,90);
sum_values_area=cell(1,90);
for i=1:90
    numvox{i}=sum(sum(sum(AAL_masked_by_WC1_thresholded==i)));
    sum_values_area{i}=0;
    for j=1:num_func_images
        curr_func_image=func_images_to_threshold(:,:,:,j);
        sum_values_area{i}=sum_values_area{i}+abs(mean(mean(mean(curr_func_image(AAL_masked_by_WC1_thresholded==i)))));
    end
end




% OLD CODE

% num_func_images=length(func_dir_filenames);
% if num_func_images>1
%     % for 3D files
%     func_images_size=size(spm_read_vols(spm_vol(func_dir_filename1))));
%     func_images=zeros([func_images_size num_func_images]);
%     for i=1:num_func_images
%         func_images(:,:,:,i)=spm_read_vols(spm_vol(fullfile(func_dir,func_dir_filenames(i).name)));
%     end
% else
%     % for one 4D file
%     func_images=spm_read_vols(spm_vol(func_dir_filename1)));
%     func_images_size=size(func_images); num_func_images=func_images_size(4); func_images_size=func_images_size(1:3);
% end

% % reslice AAL and C1 images to func image
% if size(AAL_template)~=func_images_size
%     AAL_template_resliced_filename='C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\aal_resliced.nii';
%     y_Reslice(AAL_template_filename,AAL_template_resliced_filename,[],0, func_dir_filename1));
%     AAL_template=spm_read_vols(spm_vol(AAL_template_resliced_filename));
% end
% if size(WC1_image)~=func_images_size
%     WC1_image_resliced_filename=fullfile(segment_dir,'wc1_resliced.nii');
%     y_Reslice(WC1_filename,WC1_image_resliced_filename,[],0, func_dir_filename1));
%     WC1_image=spm_read_vols(spm_vol(WC1_image_resliced_filename));
%     delete(WC1_image_resliced_filename);
% end
