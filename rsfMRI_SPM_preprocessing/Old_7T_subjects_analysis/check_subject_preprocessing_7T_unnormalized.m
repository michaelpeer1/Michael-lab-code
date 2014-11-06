function check_subject_preprocessing_7T_unnormalized(all_subj_dirname, subjname)
% check_subject_preprocessing_7T_unnormalized(all_subj_dirname, subjname)
% 
% This function checks the pre-processing of a subjects from the 7T paradigm.
% It assumes the DPARSFA directory structure - a mother directory, with
% subdirectories such as 'realignParameter' and 'T1Img', and inside each
% one a directory for each subject (or each session).
%
% Stages performed:
% 1. Create movement graphs and check max movements
% 2. Creating picture for checking coregistration

rr=dir([all_subj_dirname '\RealignParameter\' subjname '*']);
ff=dir([all_subj_dirname '\FunRawRS\' subjname '*']);
num_sessions=length(rr);
realign_dirs=cell(1,num_sessions); func_dirs=cell(1,num_sessions);
for i=1:num_sessions
    realign_dirs{i}=fullfile([all_subj_dirname '\RealignParameter\'], rr(i).name);
    func_dirs{i}=fullfile([all_subj_dirname '\FunRawRS\'], ff(i).name);
end
preproc_check_master_dir=[all_subj_dirname '\Preproc_check'];
preproc_check_dir=[preproc_check_master_dir '\' subjname];
if ~exist(preproc_check_master_dir,'dir')
    mkdir(preproc_check_master_dir);
end
if ~exist(preproc_check_dir,'dir')
    mkdir(preproc_check_dir);
end
segment_dir=[all_subj_dirname '\T1Img\' subjname];    
data_to_write=cell(200,200);

% 1. make movement graphs, and calculate maximum translations+rotations
for i=1:num_sessions
    realignfile=dir(fullfile(realign_dirs{i},'rp*')); realignfile=fullfile(realign_dirs{i},realignfile.name);
    movement=dlmread(realignfile);
    % plot translations
    figure;
    plot(movement(:,1:3)); set(gca,'ylim',[-3 3],'YTick',-3:0.5:3); legend('X','Y','Z'); xlabel('Time'); ylabel('Translation (mm)'); title([subjname '_' num2str(i) ' - Translation (mm)'])
    print('-djpeg',fullfile(preproc_check_dir,['translations_' subjname '_' num2str(i)]));
    %plot rotations
    movement(:,4:6)=movement(:,4:6)./0.01745;     % converting from radians to degrees
    plot(movement(:,4:6)); set(gca, 'ylim', [-3 3],'YTick',-3:0.5:3); legend('X','Y','Z'); xlabel('Time'); ylabel('Rotation (degrees)'); title([subjname '_' num2str(i) ' - Rotation (degrees)'])
    print('-djpeg',fullfile(preproc_check_dir,['rotations_' subjname '_' num2str(i)]));
    close;
    
    % calculate maximum translations+rotations
    max_translation=max(max(abs(movement(:,1:3))));
    max_rotation=max(max(abs(movement(:,4:6))));
    data_to_write(1:2,i*2-1:i*2)={['max_translation_' num2str(i)],['max_rotation_' num2str(i)];max_translation,max_rotation};
    if max_translation>1.5
        disp('Max translation larger than 1.5mm!!');
        data_to_write(3,i*2-1)={'Max translation larger than 1.5mm!!'};
    end
    if max_rotation>1.5
        disp('Max rotation larger than 1.5 degrees!!');
        data_to_write(4,i*2-1)={'Max rotation larger than 1.5 degrees!!'};
    end
end



% 2. Creating picture for checking coregistration
% search for the mean functional image file
DirMean=dir([realign_dirs{1} '\mean*.img']);
if isempty(DirMean)  %YAN Chao-Gan, 111114. Also support .nii files.
    DirMean=dir([realign_dirs{1} '\mean*.nii.gz']);
    if length(DirMean)==1
        gunzip(fullfile(realign_dirs{1},DirMean(1).name));delete(fullfile(realign_dirs{1},DirMean(1).name));
    end
    DirMean=dir([realign_dirs{1} '\mean*.nii']);
end
DirMean=dir([realign_dirs{1} '\mean*.img']);
Filename_mean_func = fullfile(realign_dirs{1},DirMean(1).name);
% search for the T1 image file
C1_filename=dir(fullfile(segment_dir, '\c1*'));
T1_filename=dir(fullfile(segment_dir, [C1_filename.name(3:end-4) '.*i*'])); T1_filename=fullfile(segment_dir,T1_filename(1).name);
% checking mean functional to T1 normalization
output_coreg_compare=fullfile(preproc_check_dir,['coregistration_check' subjname]);
create_overlap_picture(T1_filename,Filename_mean_func,output_coreg_compare);


% write all data to file
xlswrite([preproc_check_dir '\check.xls'],data_to_write);
