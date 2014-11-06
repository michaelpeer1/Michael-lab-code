function check_subject_preprocessing(all_subj_dirname, subjname)
% check_subject_preprocessing(all_subj_dirname, subjname)
% 
% This function checks the pre-processing of a subject.
% It assumes the DPARSFA directory structure - a mother directory, with
% subdirectories such as 'realignParameter' and 'T1Img', and inside each
% one a directory for each subject (or each session).
%
% Stages performed:
% 1. Create movement graphs and check max movements
% 2. Creating picture for checking coregistration
% 3. Creating picture for checking normalization
% 4. Compare normalized images to templates (quantitatively)
% 5. Check AAL areas - which areas have low voxel numbers, low signal, or NaN values 

realign_dir=[all_subj_dirname '\RealignParameter\' subjname];
% func_dir=[all_subj_dirname '\FunRawARCWSF\' subjname];
func_dir=[all_subj_dirname '\FunRawARWSFC\' subjname];
func_dir_to_threshold=[all_subj_dirname '\FunRawARW\' subjname];
preproc_check_master_dir=[all_subj_dirname '\Preproc_check'];
preproc_check_dir=[preproc_check_master_dir '\' subjname];
if ~exist(preproc_check_master_dir,'dir')
    mkdir(preproc_check_master_dir);
end
if ~exist(preproc_check_dir,'dir')
    mkdir(preproc_check_dir);
end
segment_dir=[all_subj_dirname '\T1ImgNewSegment\' subjname];    
if ~exist(segment_dir,'dir')
    segment_dir=[all_subj_dirname '\T1ImgSegment\' subjname];
    if ~exist(segment_dir,'dir')
        disp('No segmentation directory!!!');
    end
end

% 1. make movement graphs, and calculate maximum translations+rotations
realignfile=dir(fullfile(realign_dir,'rp*')); realignfile=fullfile(realign_dir,realignfile.name);
movement=dlmread(realignfile);
% plot translations
figure;
plot(movement(:,1:3)); set(gca,'ylim',[-3 3],'YTick',-3:0.5:3); legend('X','Y','Z'); xlabel('Time'); ylabel('Translation (mm)'); title([subjname ' - Translation (mm)'])
print('-djpeg',fullfile(preproc_check_dir,['translations_' subjname]));
%plot rotations
movement(:,4:6)=movement(:,4:6)./0.01745;     % converting from radians to degrees
plot(movement(:,4:6)); set(gca, 'ylim', [-3 3],'YTick',-3:0.5:3); legend('X','Y','Z'); xlabel('Time'); ylabel('Rotation (degrees)'); title([subjname ' - Rotation (degrees)'])
print('-djpeg',fullfile(preproc_check_dir,['rotations_' subjname]));
close;
% calculate maximum translations+rotations
max_translation=max(max(abs(movement(:,1:3))));
max_rotation=max(max(abs(movement(:,4:6))));
data_to_write=cell(200,200);
data_to_write(1:2,1:2)={'max_translation','max_rotation';max_translation,max_rotation};
if max_translation>1.5
    disp('Max translation larger than 1.5mm!!');
    data_to_write(3,1)={'Max translation larger than 1.5mm!!'};
end
if max_rotation>1.5
    disp('Max rotation larger than 1.5 degrees!!');
     data_to_write(4,1)={'Max rotation larger than 1.5 degrees!!'};
end


% 2. Creating picture for checking coregistration
% search for the mean functional image file
DirMean=dir([realign_dir '\mean*.img']);
if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
    DirMean=dir([realign_dir '\mean*.nii.gz']);
    if length(DirMean)==1
        gunzip(fullfile(realign_dir,DirMean(1).name));delete(fullfile(realign_dir,DirMean(1).name));
    end
    DirMean=dir([realign_dir '\mean*.nii']);
end
Filename_mean_func = fullfile(realign_dir,DirMean(1).name);
% search for the T1 image file
C1_filename=dir(fullfile(segment_dir, '\c1*'));
T1_filename=dir(fullfile(segment_dir, [C1_filename.name(3:end-4) '.*i*'])); T1_filename=fullfile(segment_dir,T1_filename(1).name);
% checking mean functional to T1 normalization
output_coreg_compare=fullfile(preproc_check_dir,['coregistration_check' subjname]);
create_brain_overlap_picture(T1_filename,Filename_mean_func,output_coreg_compare);


% 3. Creating picture for checking normalization
% search for the normalized mean functional image file
DirMean=dir([realign_dir '\wmean*.img']);
if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
    DirMean=dir([realign_dir '\wmean*.nii.gz']);
    if length(DirMean)==1
        gunzip(fullfile(realign_dir,DirMean(1).name));delete(fullfile(realign_dir,DirMean(1).name));
    end
    DirMean=dir([realign_dir '\wmean*.nii']);
end
Filename_mean_func_norm = fullfile(realign_dir,DirMean(1).name);
% checking EPI normalization
EPI_template='C:\spm8\templates\EPI.nii';
output_norm_compare=fullfile(preproc_check_dir,['normalization_check_func' subjname]);
create_brain_overlap_picture(EPI_template,Filename_mean_func_norm,output_norm_compare);



% 4. compare normalized images to templates
T1_template='C:\spm8\templates\T1.nii';
T1_norm_filename=dir(fullfile(segment_dir, ['w' C1_filename.name(3:end-4) '.*i*'])); T1_norm_filename=fullfile(segment_dir,T1_norm_filename(1).name);
t1_corr=check_normalization(T1_norm_filename, T1_template);
epi_corr=check_normalization(Filename_mean_func_norm, EPI_template);
data_to_write(6,1:2)={'correlation T1 to template',t1_corr};
if t1_corr<0.9
    disp('T1 normalization correlation to template is lower than 0.9!!');
    data_to_write(7,1)={'T1 normalization correlation to template is lower than 0.9!!'};
end
data_to_write(9,1:2)={'correlation EPI to template',epi_corr};
if epi_corr<0.9
    disp('EPI normalization correlation to template is lower than 0.9!!');
    data_to_write(10,1)={'EPI normalization correlation to template is lower than 0.9!!'};
end


% % 3. calculate coregistration between T1 and mean functional image
% % REQUIRES THE MUTUAL INFORMATION PACKAGE -
% % http://www.mathworks.com/matlabcentral/fileexchange/13289-fast-mutual-information-of-two-images-or-signals
% coreg_mutual_info=check_coregistration(T1_filename, Filename_mean_func);
% 
% T1_coreg_resliced_filename=fullfile(segment_dir,'T1_coreg_resliced.nii');
% y_Reslice(T1_filename,T1_coreg_resliced_filename,[],0, Filename_mean_func);
% % comparing the matrices
% T1_coreg=spm_read_vols(spm_vol(T1_coreg_resliced_filename));
% mean_func=spm_read_vols(spm_vol(mean_func_filename));
% mutual_info=mi(T1_coreg,mean_func);
% delete(T1_coreg_resliced_filename);



% 5. Check AAL areas
func_threshold = find_func_threshold(func_dir_to_threshold);
[numvox, sum_values_area] =  check_AAL_areas(segment_dir, func_dir, func_dir_to_threshold, func_threshold);
% find which areas are problematic
areas_fewvoxels={}; areas_smallvalues={}; areas_nan={};
for i=1:90
    if numvox{i}<10
        areas_fewvoxels{end+1}=i;
    end
    if sum_values_area{i}<0.1
        areas_smallvalues{end+1}=i;
    end
    if isnan(sum_values_area{i})
        areas_nan{end+1}=i;
    end
end
% write to file: area(number,name);number of voxels;mean value
data_to_write(12,1)={'AAL areas numbers'}; data_to_write(14,1)={'num_voxels'}; data_to_write(15,1)={'sum_corr_values'};
data_to_write(13,1)={'AAL areas'}; data_to_write(13,2:91)={'Precentral_L'    'Precentral_R'    'Frontal_Sup_L'    'Frontal_Sup_R'...
 'Frontal_Sup_Orb_L'    'Frontal_Sup_Orb_R'    'Frontal_Mid_L'    'Frontal_Mid_R' 'Frontal_Mid_Orb_L'...
 'Frontal_Mid_Orb_R'    'Frontal_Inf_Oper_L'  'Frontal_Inf_Oper_R'    'Frontal_Inf_Tri_L'    'Frontal_Inf_Tri_R'...
 'Frontal_Inf_Orb_L'    'Frontal_Inf_Orb_R'    'Rolandic_Oper_L'    'Rolandic_Oper_R'...
 'Supp_Motor_Area_L'    'Supp_Motor_Area_R'    'Olfactory_L'    'Olfactory_R'...
 'Frontal_Sup_Medial_L' 'Frontal_Sup_Medial_R' 'Frontal_Sup_Medial_Orb_L' 'Frontal_Sup_Medial_Orb_R'...
 'Rectus_L'    'Rectus_R' 'Insula_L'    'Insula_R'    'Cingulum_Ant_L'    'Cingulum_Ant_R'    'Cingulum_Mid_L'...
 'Cingulum_Mid_R'    'Cingulum_Post_L'    'Cingulum_Post_R'    'Hippocampus_L'...
 'Hippocampus_R'    'ParaHippocampal_L'    'ParaHippocampal_R'    'Amygdala_L'...
 'Amygdala_R'    'Calcarine_L'    'Calcarine_R'    'Cuneus_L'    'Cuneus_R'...
 'Lingual_L'    'Lingual_R'    'Occipital_Sup_L'    'Occipital_Sup_R'...
 'Occipital_Mid_L'    'Occipital_Mid_R'    'Occipital_Inf_L'    'Occipital_Inf_R'...
 'Fusiform_L'    'Fusiform_R'    'Postcentral_L'    'Postcentral_R'    'Parietal_Sup_L'...
 'Parietal_Sup_R'    'Parietal_Inf_L'    'Parietal_Inf_R'    'SupraMarginal_L'...
 'SupraMarginal_R'    'Angular_L'    'Angular_R'    'Precuneus_L'    'Precuneus_R'...
 'Paracentral_Lobule_L' 'Paracentral_Lobule_R' 'Caudate_L'    'Caudate_R'    'Putamen_L'    'Putamen_R'...
 'Pallidum_L'    'Pallidum_R'    'Thalamus_L'    'Thalamus_R'    'Heschl_L'...
 'Heschl_R'    'Temporal_Sup_L'    'Temporal_Sup_R'    'Temporal_Pole_Sup_L'...
 'Temporal_Pole_Sup_R'    'Temporal_Mid_L'    'Temporal_Mid_R'    'Temporal_Pole_Mid_L'...
 'Temporal_Pole_Mid_R'    'Temporal_Inf_L'    'Temporal_Inf_R'};
for i=1:90
    data_to_write{12,i+1}=i;
    data_to_write{14,i+1}=numvox{i};
    data_to_write{15,i+1}=sum_values_area{i};
end
if ~isempty(areas_fewvoxels)
    data_to_write(17,1)={'Areas with few voxels'};
    data_to_write(17,2:length(areas_fewvoxels)+1)=areas_fewvoxels;
end
if ~isempty(areas_smallvalues)
    data_to_write(18,1)={'Areas with low activity'};
    data_to_write(18,2:length(areas_smallvalues)+1)=areas_smallvalues;
end
if ~isempty(areas_nan)
    data_to_write(19,1)={'Areas with NaN values'};
    data_to_write(19,2:length(areas_nan)+1)=areas_nan;
end


% write all data to file
xlswrite([preproc_check_dir '\check.xls'],data_to_write);
