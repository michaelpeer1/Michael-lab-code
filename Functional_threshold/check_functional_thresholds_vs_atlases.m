%% definitions of directories and patients

subj_names={'2013-03-29_KATZ_DANIEL','2013-03-29_KATZ_ERNESTINA','2013-04-26_GOLDBERG_RENEE','2013-04-26_GOLDBERG_SIMON',...
    '2013-04-26_MAYER_SOMER_TIVONA','2013-05-24_COHEN_ILANA','2013-05-24_KELPER_HAIM','2013-05-24_LACHMAN_RAN','2013-05-24_SHANI_AVRAHAM',...
    '2013-05-31_GROSMAN_NOAM','2013-05-31_KATZ_JUDITH','2013-06-14_ATIDIEA_JUDITH','2013-06-14_GROSSMAN_LIOR','2013-06-14_RAHAT_EHUD',...
    '2013-06-14_ZLOTKIN_GILAD'};
%    '2013-06-14_RUMBAK_TALI','2013-06-14_ZLOTKIN_GILAD','2013-06-14_ZLOTKIN_TAMAR'};

% parent_dir='C:\Michael\Patients\Preprocessing\ARWSFC_TGA\TGA_patients_from_article\descending_33_slices';
% parent_dir='F:\Patients\descending_33_slices';
atlas_files={'C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\AAL_resliced_61x73x61_v2_michael.nii',...
'C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\CC200ROI_tcorr05_2level_all.nii',...
'C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\HarvardOxford-cort-maxprob-thr25-2mm_YCG.nii'};
atlas_names={'aal','CC200','HO'};
[~,AAL_names]=xlsread('f:\Network_scripts\Data_new\AAL_NODES.xls'); AAL_names=AAL_names(:,2);
parent_dir='E:\Data_for_Sami_article';

num_subjs=length(subj_names);
num_atlases=length(atlas_files);
% GM_thresh = 0.4;


%% loading sample functional image for reslicing
func_dir=[parent_dir '\FunRawARW\' subj_names{1}];
func_dir_filename1=dir(fullfile(func_dir,'*.img'));
if isempty(func_dir_filename1), func_dir_filename1=dir(fullfile(func_dir,'*.nii')); end
func_dir_filename1=fullfile(func_dir, func_dir_filename1(1).name);


%% getting atlases
atlas_images=cell(1,num_atlases); atlas_regions=cell(1,num_atlases); num_atlas_regions=cell(1,num_atlases);
for atl=1:num_atlases
    atlas_images{atl} = y_Reslice_no_outputfile(atlas_files{atl},[],0, func_dir_filename1); % reslicing to fit functional images
    atlas_regions{atl}=unique(atlas_images{atl}); atlas_regions{atl}=atlas_regions{atl}(2:end); % the first value is zero
    num_atlas_regions{atl}=length(atlas_regions{atl});
end
atlas_regions{1}=atlas_regions{1}(1:90); num_atlas_regions{1}=90; % AAL - only cotrical regions
atlas_images{1}(atlas_images{1}>90)=0;


%% creating segmentation masks, by maximum tissue probability
segmentation_masks=cell(1,num_subjs); segmentation_files=cell(1,num_subjs);
for i=1:num_subjs
    % getting normalized GM, WM and CSF images
    segmentation_dir = [parent_dir '\T1ImgNewSegment\' subj_names{i}];
    segmentation_mask_temp = make_segmentation_mask(segmentation_dir, 1, 1);
    segmentation_files{i} = [segmentation_dir '\wSegmentation.nii'];
    segmentation_masks{i} = y_Reslice_no_outputfile(segmentation_files{i},[],0, func_dir_filename1); % reslicing to fit functional images
end
% each value of the mask is now 0 if it is out of the brain, 1 if GM, 2 if WM, 3 if CSF


%% getting thresholds and tSNR

thresholds=cell(1,num_subjs); GOF=cell(1,num_subjs); 
mean_func_images_to_threshold=cell(1,num_subjs); func_threshold_mask=cell(1,num_subjs);
tSNR_images=cell(1,num_subjs); tSNR_above_threshold_inside_GM=zeros(1,num_subjs); tSNR_below_threshold_inside_GM=zeros(1,num_subjs);
percents_tissues_in_func_mask=zeros(num_subjs,4); 
percents_high_intensity_in_brain_mask=zeros(num_subjs,1); percents_high_intensity_in_GM=zeros(num_subjs,1); 
for i=1:num_subjs
    disp(subj_names{i})
    
    % getting functional files
    func_image_to_threshold_current = get_func_matrix(fullfile([parent_dir '\FunRawARW'],subj_names{i}));
    mean_func_images{i}=mean(func_image_to_threshold_current,4);
    num_images = size(func_image_to_threshold_current,4);
    
    % getting intensity threshold, goodness of fit, and thresholded mask
    [thresholds{i},GOF{i}] = find_func_threshold_sami(func_image_to_threshold_current);
    func_threshold_mask{i} = mean(func_image_to_threshold_current,4) >= thresholds{i};
    
    % removing voxels which have value of 0 (were not included in the
    % initial scan FOV) from segmentation masks
    segmentation_masks{i}(mean_func_images{i}==0) = 0;
    
    % calculating percent of each tissue type in the high-intensity mask
    segmentation_mask_temp=segmentation_masks{i}(func_threshold_mask{i});
    aa=hist(segmentation_mask_temp,4); percents_tissues_in_func_mask(i,:)=aa/sum(aa);
    % calculating percent of high/low intensity voxels in brain mask
    percents_high_intensity_in_brain_mask(i) = sum(segmentation_mask_temp(:)>0)/sum(segmentation_masks{i}(:)>0);
    percents_high_intensity_in_GM(i) = sum(segmentation_mask_temp(:)==1)/sum(segmentation_masks{i}(:)==1);
    
    % calculating voxelwise temporal SNR (tSNR) - mean/std
    tSNR_images{i}=mean(func_image_to_threshold_current,4)./std(func_image_to_threshold_current,0,4);
    tSNR_images{i}(isnan(tSNR_images{i}))=0; tSNR_images{i}(~isfinite(tSNR_images{i}))=0;
    tSNR_above_threshold_inside_GM(i)=mean(tSNR_images{i}(segmentation_masks{i}==1 & func_threshold_mask{i}));
    tSNR_below_threshold_inside_GM(i)=mean(tSNR_images{i}(segmentation_masks{i}==1 & ~func_threshold_mask{i}));
end
average_GOF=mean(cell2mat(GOF).^2);
average_percent_tissues_in_func_mask=mean(percents_tissues_in_func_mask);


%% getting atlas regions, timecourses, number of voxels, and regional tSNR
% defining  variables
subject_atlas_images=cell(1,num_atlases); subject_atlas_images_above_threshold=cell(1,num_atlases); subject_atlas_images_below_threshold=cell(1,num_atlases);
atlas_numvox=cell(1,num_atlases); atlas_numvox_above_threshold=cell(1,num_atlases);
atlas_timecourses=cell(1,num_atlases); atlas_timecourses_above_threshold=cell(1,num_atlases); atlas_timecourses_below_threshold=cell(1,num_atlases);
for atl=1:num_atlases
    atlas_numvox{atl}=zeros(num_subjs,num_atlas_regions{atl});
    atlas_numvox_above_threshold{atl}=zeros(num_subjs,num_atlas_regions{atl});
    atlas_timecourses{atl}=cell(1,num_subjs);
    atlas_timecourses_above_threshold{atl}=cell(1,num_subjs);
    atlas_timecourses_below_threshold{atl}=cell(1,num_subjs);
    subject_atlas_images{atl}=cell(1,num_subjs); subject_atlas_images_above_threshold{atl}=cell(1,num_subjs); subject_atlas_images_below_threshold{atl}=cell(1,num_subjs);
end

for i=1:num_subjs
    disp(subj_names{i})
    func_image_current = get_func_matrix(fullfile([parent_dir '\FunRawARWSFC'],subj_names{i}));
    num_images = size(func_image_current,4);
    for atl=1:num_atlases
        % removing voxels which have value of 0 (were not included in the
        % initial scan FOV)
        subject_atlas_images{atl}{i} = atlas_images{atl};
        subject_atlas_images{atl}{i}(mean_func_images{i}==0) = 0;
        % thresholding atlases by grey-matter image
        subject_atlas_images{atl}{i}(segmentation_masks{i}~=1) = 0;
        % thresholding atlases by intensity threshold
        subject_atlas_images_above_threshold{atl}{i}=subject_atlas_images{atl}{i}; subject_atlas_images_above_threshold{atl}{i}(func_threshold_mask{i}==0)=0;
        subject_atlas_images_below_threshold{atl}{i}=subject_atlas_images{atl}{i}; subject_atlas_images_below_threshold{atl}{i}(func_threshold_mask{i}==1)=0;
        
        % calculating number of voxels in each region for each subject, with or
        % without thresholding
        for j=1:num_atlas_regions{atl}, atlas_numvox{atl}(i,j)=sum(sum(sum(subject_atlas_images{atl}{i}==atlas_regions{atl}(j)))); end
        for j=1:num_atlas_regions{atl}, atlas_numvox_above_threshold{atl}(i,j)=sum(sum(sum(subject_atlas_images_above_threshold{atl}{i}==atlas_regions{atl}(j)))); end
        
        % getting the timecourses
        atlas_timecourses{atl}{i}=zeros(num_atlas_regions{atl},num_images);
        atlas_timecourses_above_threshold{atl}{i}=zeros(num_atlas_regions{atl},num_images);
        atlas_timecourses_below_threshold{atl}{i}=zeros(num_atlas_regions{atl},num_images);
        for j=1:num_atlas_regions{atl}
            current_region_mask = subject_atlas_images{atl}{i}==atlas_regions{atl}(j);
            current_region_mask_above_threshold = subject_atlas_images_above_threshold{atl}{i}==atlas_regions{atl}(j);
            current_region_mask_below_threshold = subject_atlas_images_below_threshold{atl}{i}==atlas_regions{atl}(j);
            for q=1:num_images
                func_image_temp=func_image_current(:,:,:,q);
                atlas_timecourses{atl}{i}(j,q)=mean(func_image_temp(current_region_mask));
                atlas_timecourses_above_threshold{atl}{i}(j,q)=mean(func_image_temp(current_region_mask_above_threshold));
                atlas_timecourses_below_threshold{atl}{i}(j,q)=mean(func_image_temp(current_region_mask_below_threshold));
            end
        end
    end
end


%% the magnitude of the dropout phenomenon in each atlas

% computing percent voxel loss in each region
mean_atlas_difference=cell(1,num_atlases); overall_mean_atlas_difference=cell(1,num_atlases);
atlas_regions_with_large_signal_loss=cell(1,num_atlases); atlas_regions_with_small_signal_loss=cell(1,num_atlases);
percent_region_loss_images=cell(1,num_atlases); percent_atlas_numvox_above_threshold=cell(1,num_atlases); 
dir_tmp=fullfile([parent_dir '\FunRawARWSFC'],subj_names{1}); n=dir(dir_tmp); filename_tmp=[dir_tmp '\' n(3).name ',1']; clear dir_tmp; clear n;
for atl=1:num_atlases
    % finding the average number of affected voxels in each region and overall
    percent_atlas_numvox_above_threshold{atl} = nanmean(atlas_numvox_above_threshold{atl}./atlas_numvox{atl});
    overall_mean_atlas_difference{atl} = nanmean(atlas_numvox_above_threshold{atl}(:)./atlas_numvox{atl}(:));

    % Finding regions with more than 10% voxel loss due to dropout
    atlas_regions_with_large_signal_loss{atl} = find(mean(atlas_numvox_above_threshold{atl}./atlas_numvox{atl})<0.9);
    atlas_regions_with_small_signal_loss{atl} = find(mean(atlas_numvox_above_threshold{atl}./atlas_numvox{atl})>=0.9);
    
    % making atlas images representing percent of signal loss
    percent_region_loss_images{atl}=atlas_images{atl};
    for j=1:num_atlas_regions{atl}
        percent_region_loss_images{atl}(percent_region_loss_images{atl}==atlas_regions{atl}(j)) = 1-mean_atlas_difference{atl}(j);
    end
    % saving the images
    output_file_tmp=['c:\temp\sami\percent_region_loss_' atlas_names{atl} '.nii'];
    save_mat_to_nifti(filename_tmp,percent_region_loss_images{atl},output_file_tmp);
end


%% the relation between voxel intensity in regions and tSNR
% average_tSNR_in_large_signal_loss_regions = cell(1,num_atlases);
% average_tSNR_overall = zeros(1,num_subjs);
% for atl=1:num_atlases
%     temp_image=zeros(size(tSNR_images{1}));
%     for j=1:length(atlas_regions_with_large_signal_loss{atl})
%         temp_image(atlas_images{atl}==atlas_regions{atl}(atlas_regions_with_large_signal_loss{atl}(j))) = 1;
%     end
%     for i=1:num_subjs
%         average_tSNR_in_large_signal_loss_regions{atl}(i)=mean(tSNR_images{i}(temp_image==1 & segmentation_masks{i}==1));
%     end
% end
% for i=1:num_subjs
%     temp_image = (segmentation_masks{i}==1);
%     average_tSNR_overall(i) = mean(tSNR_images{i}(temp_image==1));
% end
% 

% linear_relations_numvox_tSNR=cell(1,num_atlases);
% for atl=1:num_atlases
%     for i=1:num_subjs
%         y=tSNR_atlas_region_inside_GM{atl}{i}';
%         x=(atlas_numvox_above_threshold{atl}(i,:)./atlas_numvox{atl}(i,:))';
%         x(isnan(y))=[]; y(isnan(y))=[];
%         [f,gof]=fit(x,y,'poly1');
%         linear_relations_numvox_tSNR{atl}(i)=f.p2;
%     end
% end
% [~,p]=ttest(linear_relations_numvox_tSNR{1})



%% getting the connectivity matrices and regional tSNR

mat_corr_atlas=cell(1,num_atlases); mat_corr_atlas_above_threshold=cell(1,num_atlases); mat_corr_atlas_below_threshold=cell(1,num_atlases);
mean_mat_corr_atlas=cell(1,num_atlases); mean_mat_corr_atlas_above_threshold=cell(1,num_atlases); mean_mat_corr_atlas_below_threshold=cell(1,num_atlases); 
tSNR_atlas_region_inside_GM=cell(1,num_atlases);
for atl=1:num_atlases
    mat_corr_atlas{atl}=cell(1,num_subjs); mat_corr_atlas_above_threshold{atl}=cell(1,num_subjs); mat_corr_atlas_below_threshold{atl}=cell(1,num_subjs);
    mean_mat_corr_atlas{atl}=zeros(num_atlas_regions{atl},num_atlas_regions{atl}); 
    mean_mat_corr_atlas_above_threshold{atl}=zeros(num_atlas_regions{atl},num_atlas_regions{atl}); 
    mean_mat_corr_atlas_below_threshold{atl}=zeros(num_atlas_regions{atl},num_atlas_regions{atl});
    tSNR_atlas_region_inside_GM{atl}=cell(1,num_subjs);
end

for i=1:num_subjs
    disp(subj_names{i})
    for atl=1:num_atlases
        % getting the connectivity matrices
        mat_corr_atlas{atl}{i}=zeros(num_atlas_regions{atl}); 
        mat_corr_atlas_above_threshold{atl}{i}=zeros(num_atlas_regions{atl}); 
        mat_corr_atlas_below_threshold{atl}{i}=zeros(num_atlas_regions{atl}); 
        for j=1:num_atlas_regions{atl}
            for q=1:num_atlas_regions{atl}
                mat_corr_atlas{atl}{i}(j,q)=corr(atlas_timecourses{atl}{i}(j,:)',atlas_timecourses{atl}{i}(q,:)');
                mat_corr_atlas_above_threshold{atl}{i}(j,q)=corr(atlas_timecourses_above_threshold{atl}{i}(j,:)',atlas_timecourses_above_threshold{atl}{i}(q,:)');
                mat_corr_atlas_below_threshold{atl}{i}(j,q)=corr(atlas_timecourses_below_threshold{atl}{i}(j,:)',atlas_timecourses_below_threshold{atl}{i}(q,:)');
            end
        end
        mean_mat_corr_atlas{atl}=mean_mat_corr_atlas{atl}+mat_corr_atlas{atl}{i};
        mean_mat_corr_atlas_above_threshold{atl}=mean_mat_corr_atlas_above_threshold{atl}+mat_corr_atlas_above_threshold{atl}{i};
        mean_mat_corr_atlas_below_threshold{atl}=mean_mat_corr_atlas_below_threshold{atl}+mat_corr_atlas_below_threshold{atl}{i};
        
        % getting each region's tSNR
        for j=1:num_atlas_regions{atl}
            tSNR_atlas_region_inside_GM{atl}{i}(j)=mean(tSNR_images{i}(segmentation_masks{i}==1 & subject_atlas_images{atl}{i}==atlas_regions{atl}(j)));
        end
    end
end
for atl=1:num_atlases
    mean_mat_corr_atlas{atl}=mean_mat_corr_atlas{atl}/num_subjs;
end

[~,p]=ttest(tSNR_above_threshold_inside_GM,tSNR_below_threshold_inside_GM,[],'right');

% correlation between tSNR and percent low-intensity voxels
avg_tSNR_atlas_region_inside_GM=cell(1,num_atlases);
corr_numvox_tSNR=cell(1,num_atlases);
for atl=1:num_atlases
    temp_mat=cell2mat(tSNR_atlas_region_inside_GM{atl});
    for j=1:num_atlas_regions{atl}
        avg_tSNR_atlas_region_inside_GM{atl}(j)=nanmean(temp_mat(j:num_atlas_regions{atl}:end));
    end
    corr_numvox_tSNR{atl}=corr(avg_tSNR_atlas_region_inside_GM{atl}',percent_atlas_numvox_above_threshold{atl}');
end



%% connectivity of low-intensity voxels

% seeds from voxels above and below threshold
atlas_percent_FC_above_in_tissues = cell(1,num_atlases); atlas_percent_FC_below_in_tissues = cell(1,num_atlases);
atlas_percent_FC_total_in_tissues = cell(1,num_atlases); atlas_percent_FC_below_in_low_intensity = cell(1,num_atlases);
atlas_region_homogeneity_above = cell(1,num_atlases); atlas_region_homogeneity_total = cell(1,num_atlases); 
FC_thresh=0.3; % GM_thresh = 0.4;
% getting sample image for header for saving
dir_tmp=fullfile([parent_dir '\FunRawARWSFC'],subj_names{1}); n=dir(dir_tmp); filename_tmp=[dir_tmp '\' n(3).name ',1']; clear dir_tmp; clear n;
output_file='C:\temp\Sami\fc';

for atl=1:num_atlases
    atlas_percent_FC_above_in_tissues{atl}=cell(1,4);
    atlas_percent_FC_below_in_tissues{atl}=cell(1,4);
    atlas_percent_FC_total_in_tissues{atl}=cell(1,4);
    for i=1:4
%         atlas_percent_FC_above_in_tissues{atl}{i}=zeros(num_atlas_regions{atl},num_subjs);
%         atlas_percent_FC_below_in_tissues{atl}{i}=zeros(num_atlas_regions{atl},num_subjs);
%         atlas_percent_FC_total_in_tissues{atl}{i}=zeros(num_atlas_regions{atl},num_subjs);
        atlas_percent_FC_above_in_tissues{atl}{i}=zeros(length(atlas_regions_with_large_signal_loss{atl}),num_subjs);
        atlas_percent_FC_below_in_tissues{atl}{i}=zeros(length(atlas_regions_with_large_signal_loss{atl}),num_subjs);
        atlas_percent_FC_total_in_tissues{atl}{i}=zeros(length(atlas_regions_with_large_signal_loss{atl}),num_subjs);
    end
%     atlas_percent_FC_below_in_low_intensity{atl}=zeros(num_atlas_regions{atl},num_subjs);
%     atlas_region_homogeneity_above{atl}=zeros(num_atlas_regions{atl},num_subjs);
%     atlas_region_homogeneity_total{atl}=zeros(num_atlas_regions{atl},num_subjs);
end

for i=1:num_subjs
    disp(subj_names{i})
    func_image_current = get_func_matrix(fullfile([parent_dir '\FunRawARWSFC'],subj_names{i}));
    sf=size(func_image_current);
    func_image_current_reshaped = reshape(func_image_current, sf(1)*sf(2)*sf(3), sf(4));
    for atl=1:num_atlases
        for r=1:length(atlas_regions_with_large_signal_loss{atl})
            region=atlas_regions_with_large_signal_loss{atl}(r);
            if mod(region,10)==0
                disp(region);
            end
            current_atlas_region_FC_below=corr(func_image_current_reshaped',atlas_timecourses_below_threshold{atl}{i}(region,:)');
            atlas_percent_FC_below_in_tissues{atl}{1}(r,i) = sum(current_atlas_region_FC_below(:)>FC_thresh & segmentation_masks{i}(:)==1 & subject_atlas_images{atl}{i}(:)~=region) / sum(current_atlas_region_FC_below(:)>FC_thresh & subject_atlas_images{atl}{i}(:)~=region);
            atlas_percent_FC_below_in_tissues{atl}{2}(r,i) = sum(current_atlas_region_FC_below(:)>FC_thresh & segmentation_masks{i}(:)==2 & subject_atlas_images{atl}{i}(:)~=region) / sum(current_atlas_region_FC_below(:)>FC_thresh & subject_atlas_images{atl}{i}(:)~=region);
            atlas_percent_FC_below_in_tissues{atl}{3}(r,i) = sum(current_atlas_region_FC_below(:)>FC_thresh & segmentation_masks{i}(:)==3 & subject_atlas_images{atl}{i}(:)~=region) / sum(current_atlas_region_FC_below(:)>FC_thresh & subject_atlas_images{atl}{i}(:)~=region);
            atlas_percent_FC_below_in_tissues{atl}{4}(r,i) = sum(current_atlas_region_FC_below(:)>FC_thresh & segmentation_masks{i}(:)==0 & subject_atlas_images{atl}{i}(:)~=region) / sum(current_atlas_region_FC_below(:)>FC_thresh & subject_atlas_images{atl}{i}(:)~=region);

            current_atlas_region_FC_above=corr(func_image_current_reshaped',atlas_timecourses_above_threshold{atl}{i}(region,:)');
            atlas_percent_FC_above_in_tissues{atl}{1}(r,i) = sum(current_atlas_region_FC_above(:)>FC_thresh & segmentation_masks{i}(:)==1 & subject_atlas_images{atl}{i}(:)~=region) / sum(current_atlas_region_FC_above(:)>FC_thresh & subject_atlas_images{atl}{i}(:)~=region);
            atlas_percent_FC_above_in_tissues{atl}{2}(r,i) = sum(current_atlas_region_FC_above(:)>FC_thresh & segmentation_masks{i}(:)==2 & subject_atlas_images{atl}{i}(:)~=region) / sum(current_atlas_region_FC_above(:)>FC_thresh & subject_atlas_images{atl}{i}(:)~=region);
            atlas_percent_FC_above_in_tissues{atl}{3}(r,i) = sum(current_atlas_region_FC_above(:)>FC_thresh & segmentation_masks{i}(:)==3 & subject_atlas_images{atl}{i}(:)~=region) / sum(current_atlas_region_FC_above(:)>FC_thresh & subject_atlas_images{atl}{i}(:)~=region);
            atlas_percent_FC_above_in_tissues{atl}{4}(r,i) = sum(current_atlas_region_FC_above(:)>FC_thresh & segmentation_masks{i}(:)==0 & subject_atlas_images{atl}{i}(:)~=region) / sum(current_atlas_region_FC_above(:)>FC_thresh & subject_atlas_images{atl}{i}(:)~=region);

            current_atlas_region_FC_total=corr(func_image_current_reshaped',atlas_timecourses{atl}{i}(region,:)');
            atlas_percent_FC_total_in_tissues{atl}{1}(r,i) = sum(current_atlas_region_FC_total(:)>FC_thresh & segmentation_masks{i}(:)==1 & subject_atlas_images{atl}{i}(:)~=region) / sum(current_atlas_region_FC_total(:)>FC_thresh & subject_atlas_images{atl}{i}(:)~=region);
            atlas_percent_FC_total_in_tissues{atl}{2}(r,i) = sum(current_atlas_region_FC_total(:)>FC_thresh & segmentation_masks{i}(:)==2 & subject_atlas_images{atl}{i}(:)~=region) / sum(current_atlas_region_FC_total(:)>FC_thresh & subject_atlas_images{atl}{i}(:)~=region);
            atlas_percent_FC_total_in_tissues{atl}{3}(r,i) = sum(current_atlas_region_FC_total(:)>FC_thresh & segmentation_masks{i}(:)==3 & subject_atlas_images{atl}{i}(:)~=region) / sum(current_atlas_region_FC_total(:)>FC_thresh & subject_atlas_images{atl}{i}(:)~=region);
            atlas_percent_FC_total_in_tissues{atl}{4}(r,i) = sum(current_atlas_region_FC_total(:)>FC_thresh & segmentation_masks{i}(:)==0 & subject_atlas_images{atl}{i}(:)~=region) / sum(current_atlas_region_FC_total(:)>FC_thresh & subject_atlas_images{atl}{i}(:)~=region);

%             current_atlas_region_FC_below = get_FC_from_func_mat(func_image_current, atlas_timecourses_below_threshold{atl}{i}(region,:)');
%             current_atlas_region_FC_above = get_FC_from_func_mat(func_image_current, atlas_timecourses_above_threshold{atl}{i}(region,:)');
%             current_atlas_region_FC_total = get_FC_from_func_mat(func_image_current, atlas_timecourses{atl}{i}(region,:)');    
%             save_mat_to_nifti(filename_tmp,current_atlas_region_FC_above,[output_file subj_names{i} '_aal_' num2str(region) '_above_threshold.nii']);
%             save_mat_to_nifti(filename_tmp,current_atlas_region_FC_below,[output_file subj_names{i} '_aal_' num2str(region) '_below_threshold.nii']);
%             save_mat_to_nifti(filename_tmp,current_atlas_region_FC_total,[output_file subj_names{i} '_aal_' num2str(region) '_total.nii']);
            
%             % in low-intensity areas of the grey matter
%             atlas_percent_FC_below_in_low_intensity{atl}(region,i) = sum(current_atlas_region_FC_below(:)>FC_thresh & subject_atlas_images_below_threshold{atl}{i}(:)>0 & subject_atlas_images_below_threshold{atl}{i}(:)~=region) / sum(current_atlas_region_FC_below(:)>FC_thresh & subject_atlas_images_below_threshold{atl}{i}(:)~=region);
%             
%             % homogeneity before and after thresholding
%             current_region_mask_above = find(current_atlas_region_FC_above(:)>FC_thresh & segmentation_masks{i}(:)==1 & subject_atlas_images{atl}{i}(:));
%             current_region_mask_total = find(current_atlas_region_FC_total(:)>FC_thresh & segmentation_masks{i}(:)==1 & subject_atlas_images{atl}{i}(:));
%             
%             current_region_mat_corr_above = zeros(length(current_region_mask_above));
%             for vox1=1:length(current_region_mask_above)
% %                 for vox2=(vox1+1):length(current_region_mask_above)
%                                 if mod(vox1,50)==0
%                                     disp(vox1);
%                                 end
%                     current_region_mat_corr_above(current_region_mask_above(vox1),:)=corr(func_image_current_reshaped(current_region_mask_above(vox1),:)',func_image_current_reshaped(current_region_mask_above,:)');
% %                 end
%             end
%             atlas_region_homogeneity_above = nanmean(current_region_mat_corr_above(current_region_mat_corr_above~=0));
%             
%             atlas_region_homogeneity_total
        end
    end
end


%% changes in functional connectivity after intensity thresholding

% % checking correlations between bilateral regions
% bilat_conn_atlas=cell(1,num_atlases); bilat_conn_atlas_above_thresh=cell(1,num_atlases);
% for atl=1:num_atlases
%     bilat_conn_atlas{atl}=zeros(num_subjs,num_atlas_regions{atl}/2);
%     bilat_conn_atlas_above_thresh{atl}=zeros(num_subjs,num_atlas_regions{atl}/2);
%     for i=1:num_subjs
%         for j=1:2:num_atlas_regions{atl}
%             bilat_conn_atlas{atl}(i,(j+1)/2)=mat_corr_atlas{atl}{i}(j,j+1);
%             bilat_conn_atlas_above_thresh{atl}(i,(j+1)/2)=mat_corr_atlas_above_threshold{atl}{i}(j,j+1);
%         end
%     end
% end


% finding significant correlations in the matrices
mat_corr_atlas_new=cell(1,num_atlases); mat_corr_atlas_above_threshold_new=cell(1,num_atlases);
mat_corr_atlas_diff_new=cell(1,num_atlases); significant_atlas_diff=cell(1,num_atlases);
significant_correl=cell(1,num_atlases); significant_correl_neg=cell(1,num_atlases);
significant_atlas_diff=cell(1,num_atlases); significant_atlas_diff_neg=cell(1,num_atlases);
for atl=1:num_atlases
    mat_corr_atlas_new{atl}=cell(1,num_subjs); mat_corr_atlas_above_threshold_new{atl}=cell(1,num_subjs);
    mat_corr_atlas_diff_new{atl}=cell(1,num_subjs);
    for i=1:num_subjs
        mat_corr_atlas_new{atl}{i}=mat_corr_atlas{atl}(i);
        mat_corr_atlas_above_threshold_new{atl}{i}=mat_corr_atlas_above_threshold{atl}(i);
        mat_corr_atlas_diff_new{atl}{i}={mat_corr_atlas_above_threshold{atl}{i}-mat_corr_atlas{atl}{i}};
    end
    [significant_correl_neg{atl},significant_correl{atl}]=find_significant_correlations(mat_corr_atlas_new{atl}, 1);
    [significant_atlas_diff_neg{atl},significant_atlas_diff{atl}]=find_significant_correlations_no_fisherz(mat_corr_atlas_diff_new{atl}, 1);
end
% changes in the significantly correlated regions and overall
atlas_conn_diff=cell(1,num_atlases);  atlas_conn_diff_overall=cell(1,num_atlases);
atlas_conn_diff_highconn_mean=cell(1,num_atlases); atlas_conn_diff_lowconn_mean=cell(1,num_atlases);
for i=1:num_subjs
    for atl=1:num_atlases
        atlas_conn_diff{atl}{i} = mat_corr_atlas_above_threshold{atl}{i}-mat_corr_atlas{atl}{i};
        atlas_conn_diff_highconn_mean{atl}(i)=nanmean(nanmean(atlas_conn_diff{atl}{i}(significant_correl{atl}>0)));
        atlas_conn_diff_lowconn_mean{atl}(i)=nanmean(nanmean(atlas_conn_diff{atl}{i}(significant_correl{atl}==0 & significant_correl_neg{atl}==0)));
        atlas_conn_diff_overall{atl}(i)=nanmean(nanmean(atlas_conn_diff{atl}{i}));
    end
end
[~,p]=ttest(atlas_conn_diff_highconn_mean{1},0,[],'right');


% average functional connectivity changes before and after threshold
% application
atlas_conn_diff_abs=cell(1,num_atlases); mean_atlas_conn_diff_per_subject=cell(1,num_atlases);
mean_atlas_conn_diff_per_region=cell(1,num_atlases);
relative_atlas_conn_diff=cell(1,num_atlases); mean_relative_atlas_conn_diff_per_region=cell(1,num_atlases); 
percent_region_conn_diff_images=cell(1,num_atlases);
dir_tmp=fullfile([parent_dir '\FunRawARWSFC'],subj_names{1}); n=dir(dir_tmp); filename_tmp=[dir_tmp '\' n(3).name ',1']; clear dir_tmp; clear n;
for atl=1:num_atlases
    atlas_conn_diff_abs{atl}=cell(1,num_subjs); relative_atlas_conn_diff{atl}=cell(1,num_subjs);
    mean_atlas_conn_diff_per_subject{atl}=[];
    mean_atlas_conn_diff_per_region{atl}=zeros(num_atlas_regions{atl});
    mean_relative_atlas_conn_diff_per_region{atl}=zeros(num_atlas_regions{atl});
    for i=1:num_subjs
        atlas_conn_diff_abs{atl}{i} = abs(mat_corr_atlas_above_threshold{atl}{i}-mat_corr_atlas{atl}{i});
        relative_atlas_conn_diff{atl}{i} = atlas_conn_diff_abs{atl}{i} ./ abs(mat_corr_atlas{atl}{i});
        mean_atlas_conn_diff_per_subject{atl} = [mean_atlas_conn_diff_per_subject{atl} nanmean(atlas_conn_diff_abs{atl}{i}(:))];
        a_c_d_temp=atlas_conn_diff_abs{atl}{i}; a_c_d_temp(isnan(a_c_d_temp))=0;
        mean_atlas_conn_diff_per_region{atl} = mean_atlas_conn_diff_per_region{atl} + a_c_d_temp;
        r_a_c_d_temp=relative_atlas_conn_diff{atl}{i}; r_a_c_d_temp(isnan(r_a_c_d_temp))=0;
        mean_relative_atlas_conn_diff_per_region{atl} = mean_relative_atlas_conn_diff_per_region{atl} + r_a_c_d_temp;
    end
    mean_atlas_conn_diff_per_region{atl}=mean_atlas_conn_diff_per_region{atl}./num_subjs;
    mean_relative_atlas_conn_diff_per_region{atl}=mean_relative_atlas_conn_diff_per_region{atl}./num_subjs;
    
    % making atlas images representing connectivity changes in each region
    percent_region_conn_diff_images{atl}=atlas_images{atl};
    for j=1:num_atlas_regions{atl}
        conn_diff_region = nanmean(mean_atlas_conn_diff_per_region{atl}(j,:));
        percent_region_conn_diff_images{atl}(percent_region_conn_diff_images{atl}==atlas_regions{atl}(j)) = conn_diff_region;
    end
    % saving the images
    output_file_tmp=['c:\temp\sami\percent_region_conn_diff_' atlas_names{atl} '.nii'];
    save_mat_to_nifti(filename_tmp,percent_region_conn_diff_images{atl},output_file_tmp);
end

% the relation between connectivity changes and number of voxels
% figure;plot(mean(atlas_numvox_above_threshold{atl})./mean(atlas_numvox{atl}),nanmean(abs(mean_mat_corr_atlas_above_threshold{atl}-mean_mat_corr_atlas{atl})),'o')
i=1;figure;plot(atlas_numvox_above_threshold{atl}(i,:)./atlas_numvox{atl}(i,:),nanmean(abs(mat_corr_atlas_above_threshold{atl}{i}-mat_corr_atlas{atl}{i})),'o')
linear_relations=cell(1,num_atlases);
for atl=1:num_atlases
    for i=1:num_subjs
        y=nanmean(abs(mat_corr_atlas_above_threshold{atl}{i}-mat_corr_atlas{atl}{i}))';
        x=(atlas_numvox_above_threshold{atl}(i,:)./atlas_numvox{atl}(i,:))';
        x(isnan(y))=[]; y(isnan(y))=[];
        [f,gof]=fit(x,y,'poly1');
        linear_relations{atl}(i)=f.p2;
    end
end
[~,p]=ttest(linear_relations{1})

% checking between-subjects correlation
corrsubjs=cell(1,num_atlases); corrsubjs_above=cell(1,num_atlases);
all_corr=cell(1,num_atlases); all_corr_above=cell(1,num_atlases);
for atl=1:num_atlases
    corrsubjs{atl}=zeros(num_subjs);
    for i=1:num_subjs
        for j=1:num_subjs
            if i~=j
                corrsubjs{atl}(i,j)=corr(mat_corr_atlas{atl}{i}(:),mat_corr_atlas{atl}{j}(:),'rows','complete');
            end
        end
    end
    corrsubjs_above{atl}=zeros(num_subjs);
    for i=1:num_subjs
        for j=1:num_subjs
            if i~=j
                corrsubjs_above{atl}(i,j)=corr(mat_corr_atlas_above_threshold{atl}{i}(:),mat_corr_atlas_above_threshold{atl}{j}(:),'rows','complete');
            end
        end
    end

    all_corr{atl}=triu(corrsubjs{atl}); all_corr{atl}(all_corr{atl}==0)=[];
    all_corr_above{atl}=triu(corrsubjs_above{atl}); all_corr_above{atl}(all_corr_above{atl}==0)=[];
%     [~,p]=ttest(fisherz(all_corr_above{atl}),fisherz(all_corr{atl}),[],'right');
end

% identification of the default network and others, and their strength
num_subjs_for_definition=9;
seeds={};
seeds{1}=cell(1,3); seeds{1}{1}=[35,36]; seeds{1}{2}=[58,58]; seeds{1}{3}=[59,60]; % Default mode, MNI coordinate -3 -50 24, 3 50 24
seeds{2}=cell(1,3); seeds{2}{1}=[1,2]; seeds{2}{2}=[73,115]; seeds{2}{3}=[13,14]; % Motor, MNI coordinate -45 -5 44, 45 -5 44
seeds{3}=cell(1,3); seeds{3}{1}=[55,56]; seeds{3}{2}=[27,87]; seeds{3}{3}=[75,76]; % Fusiform, MNI coordinate -36 -15 -27, 40 -15 -27
seeds{4}=cell(1,3); seeds{4}{1}=[25,26]; seeds{4}{2}=[51,51]; seeds{4}{3}=[49,50]; % mOFC, MNI coordinate -6 47 -14, 6 47 -14
seeds{5}=cell(1,3); seeds{5}{1}=[9,10]; seeds{5}{2}=[42,124]; seeds{5}{3}=[1,2]; % lOFC, MNI coordinate -29 50 -11, 29 50 -11
seeds{6}=cell(1,3); seeds{6}{1}=[89,90]; seeds{6}{2}=[72,49]; seeds{6}{3}=[29,30]; % Inf temporal, MNI coordinate -56 -18 -27, 56 -18 -27
num_seeds=length(seeds);

means_nets=cell(1,num_seeds); means_nets_above=cell(1,num_seeds);
nets=cell(1,num_seeds); nets_above=cell(1,num_seeds); pvs_nets_diff=cell(1,num_seeds);
for n=1:num_seeds
    nets{n}=cell(1,num_atlases); means_nets{n}=cell(1,num_atlases); means_nets_above{n}=cell(1,num_atlases);
    pvs_nets_diff{n}=cell(1,num_atlases);
    
    for atl=1:num_atlases
    % identifying the networks by their functional connectivity
        %current_alpha = 0.001;
        current_alpha = 0.05/num_atlas_regions{atl};
        temp_conn=[]; temp_conn_above=[];
%         for i=1:num_subjs_for_definition
        for i=1:num_subjs
            temp_conn=[temp_conn; nanmean(mat_corr_atlas{atl}{i}(seeds{n}{atl}(2),:),1)];
            temp_conn_above=[temp_conn_above; nanmean(mat_corr_atlas_above_threshold{atl}{i}(seeds{n}{atl}(2),:),1)];
        end
        temp_conn=fisherz(temp_conn); temp_conn_above=fisherz(temp_conn_above);
        for i=1:num_atlas_regions{atl}
            [~,p1]=ttest(temp_conn(:,i),[],[],'right');
            [~,p2]=ttest(temp_conn_above(:,i),[],[],'right');
            if p1<current_alpha
                nets{n}{atl}=[nets{n}{atl} i];
            end
            if p2<current_alpha
                nets_above{n}{atl}=[nets{n}{atl} i];
            end
        end
        
        % calculating the means before and after threshold application
%         for i=num_subjs_for_definition:num_subjs
%             i_new=i-num_subjs_for_definition+1;
        for i_new=1:num_subjs
            means_nets{n}{atl}(i_new)=mean(mean(mat_corr_atlas{atl}{i_new}(nets{n}{atl},nets{n}{atl})));
%             means_nets_above{n}{atl}(i_new)=mean(mean(mat_corr_atlas_above_threshold{atl}{i_new}(nets_above{n}{atl},nets_above{n}{atl})));
            means_nets_above{n}{atl}(i_new)=mean(mean(mat_corr_atlas_above_threshold{atl}{i_new}(nets{n}{atl},nets{n}{atl})));
        end
        
        [~,p]=ttest(means_nets_above{n}{atl},means_nets{n}{atl},[],'right');
        pvs_nets_diff{n}{atl}=p;
    end
end
 

%% false connectivity between regions with large signal loss

% checking connectivity between regions with large signal dropout
corr_low_signal_regions=cell(1,num_atlases); corr_low_signal_regions_above=cell(1,num_atlases);
corr_high_signal_regions=cell(1,num_atlases); corr_high_signal_regions_above=cell(1,num_atlases);
corr_high_low_signal_regions=cell(1,num_atlases); corr_high_low_signal_regions_above=cell(1,num_atlases);
means_diff_corr_low_signal_regions=cell(1,num_atlases); means_diff_corr_high_signal_regions=cell(1,num_atlases); 
means_diff_corr_high_low_signal_regions=cell(1,num_atlases); 
means_corr_low_signal_regions=cell(1,num_atlases); means_corr_low_signal_regions_above=cell(1,num_atlases); 
means_corr_high_signal_regions=cell(1,num_atlases); means_corr_high_signal_regions_above=cell(1,num_atlases);
means_corr_high_low_signal_regions=cell(1,num_atlases); means_corr_high_low_signal_regions_above=cell(1,num_atlases); 
for atl=1:num_atlases
    corr_low_signal_regions{atl}=cell(1,num_subjs); corr_low_signal_regions_above{atl}=cell(1,num_subjs);
    corr_high_signal_regions{atl}=cell(1,num_subjs); corr_high_signal_regions_above{atl}=cell(1,num_subjs);
    corr_high_low_signal_regions{atl}=cell(1,num_subjs); corr_high_low_signal_regions_above{atl}=cell(1,num_subjs);
    for i=1:num_subjs
        corr_low_signal_regions{atl}{i}=mat_corr_atlas{atl}{i}(atlas_regions_with_large_signal_loss{atl},atlas_regions_with_large_signal_loss{atl});
        corr_low_signal_regions_above{atl}{i}=mat_corr_atlas_above_threshold{atl}{i}(atlas_regions_with_large_signal_loss{atl},atlas_regions_with_large_signal_loss{atl});
        corr_high_signal_regions{atl}{i}=mat_corr_atlas{atl}{i}(atlas_regions_with_small_signal_loss{atl},atlas_regions_with_small_signal_loss{atl});
        corr_high_signal_regions_above{atl}{i}=mat_corr_atlas_above_threshold{atl}{i}(atlas_regions_with_small_signal_loss{atl},atlas_regions_with_small_signal_loss{atl});        
        corr_high_low_signal_regions{atl}{i}=mat_corr_atlas{atl}{i}(atlas_regions_with_small_signal_loss{atl},atlas_regions_with_large_signal_loss{atl});
        corr_high_low_signal_regions_above{atl}{i}=mat_corr_atlas_above_threshold{atl}{i}(atlas_regions_with_small_signal_loss{atl},atlas_regions_with_large_signal_loss{atl});
        
        means_corr_low_signal_regions{atl}=[means_corr_low_signal_regions{atl} nanmean(corr_low_signal_regions{atl}{i}(:))];
        means_corr_low_signal_regions_above{atl}=[means_corr_low_signal_regions_above{atl} nanmean(corr_low_signal_regions_above{atl}{i}(:))];
        means_corr_high_signal_regions{atl}=[means_corr_high_signal_regions{atl} nanmean(corr_high_signal_regions{atl}{i}(:))];
        means_corr_high_signal_regions_above{atl}=[means_corr_high_signal_regions_above{atl} nanmean(corr_high_signal_regions_above{atl}{i}(:))];
        means_corr_high_low_signal_regions{atl}=[means_corr_high_low_signal_regions{atl} nanmean(corr_high_low_signal_regions{atl}{i}(:))];
        means_corr_high_low_signal_regions_above{atl}=[means_corr_high_low_signal_regions_above{atl} nanmean(corr_high_low_signal_regions_above{atl}{i}(:))];
        
        means_diff_corr_low_signal_regions{atl}=[means_diff_corr_low_signal_regions{atl} nanmean(corr_low_signal_regions{atl}{i}(:)-corr_low_signal_regions_above{atl}{i}(:))];
        means_diff_corr_high_signal_regions{atl}=[means_diff_corr_high_signal_regions{atl} nanmean(corr_high_signal_regions{atl}{i}(:)-corr_high_signal_regions_above{atl}{i}(:))];
        means_diff_corr_high_low_signal_regions{atl}=[means_diff_corr_high_low_signal_regions{atl} nanmean(corr_high_low_signal_regions{atl}{i}(:)-corr_high_low_signal_regions_above{atl}{i}(:))];        

%     [~,p]=ttest2(means_corr_low_signal_regions_above{1},means_corr_low_signal_regions{1},[],'left')
    end
end
