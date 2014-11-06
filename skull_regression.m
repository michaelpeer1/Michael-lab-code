% This is an optional project file
% 
% The project aims at introducing a new method of data cleaning for
% resting-state fMRI analyses
% Since addition of a global brain signal regressor during pre-processing 
% creates negative correlations and removes actual signal, we aim at taking 
% the average skull signal (based on SPMs new-segment function) and using it 
% as a regressor to remove non-neuronal noise


func_dir='C:\Michael\Patients\Preprocessing\ARCWSF_TGA\slices_33\FunRawAR';
subjname='2013-05-24_COHEN_ILANA';

% get the functional images
func_images=get_func_matrix(fullfile(func_dir,subjname));
func_image1=dir(fullfile(func_dir,subjname)); func_image1=[func_dir '\' subjname '\' func_image1(3).name];

% get the motion parameters
motion_params_dir=fullfile(func_dir,['..\RealignParameter\' subjname]);
motion_params_file=dir(fullfile(motion_params_dir, 'rp*.txt')); motion_params_file=fullfile(motion_params_dir, motion_params_file(1).name);
mov_params=dlmread(motion_params_file);
FD_power=dlmread([motion_params_dir '\FD_Power_' subjname '.txt']);
FD_vandijk=dlmread([motion_params_dir '\FD_VanDijk_' subjname '.txt']);
FD_jenkinson=dlmread([motion_params_dir '\FD_Jenkinson_' subjname '.txt']);

% read the skull image, and get skull signal
segment_dir=fullfile(func_dir,['..\T1ImgNewSegment\' subjname]);
skull_file=dir(fullfile(segment_dir, 'c4*')); skull_file=fullfile(segment_dir, skull_file(1).name);
[sk] = y_Reslice_no_outputfile(skull_file,[],1, func_image1);
sk_signal=[];
for i=1:size(func_images,4)
    ff=func_images(:,:,:,i);
    sk_signal(i)=mean(mean(mean(ff(sk>0.05))));
end

% get the global signal
mask_dir=fullfile(func_dir,['..\Masks\']);
brain_mask_file=dir(fullfile(mask_dir, [subjname '_BrainMask*'])); brain_mask_file=fullfile(mask_dir, brain_mask_file(1).name);
[gs] = y_Reslice_no_outputfile(brain_mask_file,[],1, func_image1);
gs_signal=[];
for i=1:size(func_images,4)
    ff=func_images(:,:,:,i);
    gs_signal(i)=mean(mean(mean(ff(gs>0.05))));
end

% regress
ROISignals_new=zeros(size(func_images,4),90);
for i=1:90
    [~,~,r]=regress(ROISignals(:,i),sk_signal');
    ROISignals_new(:,i)=r;
end

ROISignals_new2=zeros(155,90);
for i=1:90
[~,~,r]=regress(ROISignals_new(:,i),FD_power);
[~,~,r2]=regress(r,FD_vandijk);
[~,~,r3]=regress(r2,FD_jenkinson);
ROISignals_new2(:,i)=r3;
end

