function new_mask = get_func_threshold_and_c1_mask(func_directory_to_threshold, c1mask_filename, c1_threshold)
% new_mask = get_func_threshold_and_c1_mask(func_directory_to_threshold, c1mask_filename, c1_threshold);

% functional threshold
func_images_to_threshold=get_func_matrix(func_directory_to_threshold);
func_threshold = find_func_threshold(func_images_to_threshold);


% grey matter threshold
func_dir_filename1=dir(fullfile(func_directory_to_threshold,'*.img'));
if isempty(func_dir_filename1), func_dir_filename1=dir(fullfile(func_directory_to_threshold,'*.nii')); end
func_dir_filename1=fullfile(func_directory_to_threshold, func_dir_filename1(1).name);

c1mask=y_Reslice_no_outputfile(c1mask_filename,[],1, func_dir_filename1);


% create mean functional image to threshold, for masking
num_images = size(func_images_to_threshold,4);
mean_func_images_to_threshold = zeros(size(func_images_to_threshold(:,:,:,1)));
for i=1:num_images
    mean_func_images_to_threshold = mean_func_images_to_threshold+func_images_to_threshold(:,:,:,i);
end
mean_func_images_to_threshold = mean_func_images_to_threshold/num_images;

% combined thresholded image
new_mask = c1mask>=c1_threshold & mean_func_images_to_threshold>=func_threshold;

