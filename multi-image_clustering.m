% This is an optional project
%
% The project aims at finding cytoarchitectonic areas in the brain, using
% data from a combination of MRI images with different protocols
% The data from all images is merged to one matrix and clustering is
% applied  to identify regions with different characteristics


% load all images and reslice to same resolution
images={};

T1_image = 'C:\temp\Patient\New folder\patient\1_003_t1_mprage_32COIL_p2_20141003\c1LEVI_SARIT_20141003_001_003_t1_mprage_32COIL_p2.img';
a=nifti(T1_image); images{1} = a.dat;      % T1 image - grey-matter segmented
InputFile=('C:\temp\Patient\New folder\patient\1_002_ep2d_bold_REST_20141003\LEVI_SARIT_20141003_001_002_ep2d_bold_REST_0001.img');
images{2} = y_Reslice_no_outputfile(InputFile,[],1, T1_image); % T2* rest - sample image (first one)
InputFile=('C:\temp\Patient\New folder\patient\1_004_ep2d_diff_3scan_trace_TE=93_20141003\LEVI_SARIT_20141003_001_004_ep2d_diff_3scan_trace_TE=93__ep_b0.img');
images{3} = y_Reslice_no_outputfile(InputFile,[],1, T1_image); % diffusion image
InputFile=('C:\temp\Patient\New folder\patient\1_004_ep2d_diff_3scan_trace_TE=93_20141003\LEVI_SARIT_20141003_001_004_ep2d_diff_3scan_trace_TE=93__ep_b500t.img');
images{4} = y_Reslice_no_outputfile(InputFile,[],1, T1_image); % diffusion image 2
InputFile=('C:\temp\Patient\New folder\patient\1_004_ep2d_diff_3scan_trace_TE=93_20141003\LEVI_SARIT_20141003_001_004_ep2d_diff_3scan_trace_TE=93__ep_b1000t.img');
images{5} = y_Reslice_no_outputfile(InputFile,[],1, T1_image); % diffusion image 3
InputFile=('C:\temp\Patient\New folder\patient\1_005_ep2d_diff_3scan_trace_TE=93_ADC_20141003\LEVI_SARIT_20141003_001_005_ep2d_diff_3scan_trace_TE=93_ep2d_diff_3scan_trace_TE=93_ADC.img');
images{6} = y_Reslice_no_outputfile(InputFile,[],1, T1_image); % diffusion ADC image
InputFile=('C:\temp\Patient\New folder\patient\1_006_FLAIR_tra_dark-fluid_FS_p3_+GD_20141003\LEVI_SARIT_20141003_001_006_FLAIR_tra_dark-fluid_FS_p3_+GD.img');
images{7} = y_Reslice_no_outputfile(InputFile,[],1, T1_image); % FLAIR image
InputFile=('C:\temp\Patient\New folder\patient\1_007_Mag_Images_20141003\LEVI_SARIT_20141003_001_007_t2_fl3d_tra_p2_swi_mag_ph_Mag_Images.img');
images{8} = y_Reslice_no_outputfile(InputFile,[],1, T1_image); % MAG image
InputFile=('C:\temp\Patient\New folder\patient\1_008_Pha_Images_20141003\LEVI_SARIT_20141003_001_008_t2_fl3d_tra_p2_swi_mag_ph_Pha_Images.img');
images{9} = y_Reslice_no_outputfile(InputFile,[],1, T1_image); % PHA image
InputFile=('C:\temp\Patient\New folder\patient\1_009_mIP_Images(SW)_20141003\LEVI_SARIT_20141003_001_009_t2_fl3d_tra_p2_swi_mag_ph_mIP_Images(SW).img');
images{10} = y_Reslice_no_outputfile(InputFile,[],1, T1_image); % MIP image
InputFile=('C:\temp\Patient\New folder\patient\1_010_SWI_Images_20141003\LEVI_SARIT_20141003_001_010_t2_fl3d_tra_p2_swi_mag_ph_SWI_Images.img');
images{11} = y_Reslice_no_outputfile(InputFile,[],1, T1_image); % SWI image
InputFile=('C:\temp\Patient\New folder\patient\1_011_AX_T2_TSE__p3(TRIPLE)_20141003\LEVI_SARIT_20141003_001_011_AX_T2_TSE__p3(TRIPLE).img');
images{12} = y_Reslice_no_outputfile(InputFile,[],1, T1_image); % AX-T2 image
InputFile=('C:\temp\Patient\New folder\patient\1_012_t1_fl2d_tra-512_3mm_p2_(NO_GAD)_20141003\LEVI_SARIT_20141003_001_012_t1_fl2d_tra-512_3mm_p2_(NO_GAD).img');
images{13} = y_Reslice_no_outputfile(InputFile,[],1, T1_image); % T1_fl2d_tra image
% InputFile=('C:\temp\Patient\New folder\patient\1_013_ep2d_bold_REST_20141003\LEVI_SARIT_20141003_001_013_ep2d_bold_REST_0001.img');
% images{14} = y_Reslice_no_outputfile(InputFile,[],1, T1_image); % T2* rest run 2 - sample image (first one)

num_images=length(images);

% Take only grey-matter voxels
for i=2:num_images
    images{i}(images{1}(:)==0) = 0;
end

% put in one matrix
grey_threshold = 0.8;
loc_grey=find(images{1}(:)>grey_threshold);
all_images=zeros(sum(images{1}(:)>grey_threshold), num_images);
for i=1:num_images
    all_images(:,i) = images{i}(loc_grey);
end

[IDX, C, SUMD, D] = kmeans(all_images, 10);

image_new = zeros(size(images{1}));
image_new(loc_grey) = IDX;
imagesc(image_new(:,:,100))

% save_mat_to_nifti('C:\temp\Patient\New folder\patient\1_003_t1_mprage_32COIL_p2_20141003\LEVI_SARIT_20141003_001_003_t1_mprage_32COIL_p2.img',image_new,'c:\temp\patient\new folder\trial.nii')


% % put in one matrix
% all_images=zeros(256,256,160,num_images);
% for i=1:num_images
%     all_images(:,:,:,i) = images{i};
% end
% 
% % cluster by voxel
% all_images_new = reshape(all_images, 256*256*160, num_images);
% [IDX, C, SUMD, D] = kmeans(all_images_new, 7);
