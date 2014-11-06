% This is a script for pre-processing of all the fMRI scans of the orientation 
% experiment 7-Tesla subjects
%
% Runs the pre_process_7T_subject.m script on each subject, and then
% runs normalization and smoothing on all subjects



% a=cell(1,2);
% a{1}={{'C:\Subjects_MRI_data\7T\121119_Chrystany\Nifti\1_003_distance1_20121119','C:\Subjects_MRI_data\7T\121119_Chrystany\Nifti\1_004_distance2_20121119','C:\Subjects_MRI_data\7T\121119_Chrystany\Nifti\1_005_distance3_20121119','C:\Subjects_MRI_data\7T\121119_Chrystany\Nifti\1_010_distance4_20121119','C:\Subjects_MRI_data\7T\121119_Chrystany\Nifti\1_013_distance5_20121119','C:\Subjects_MRI_data\7T\121119_Chrystany\Nifti\1_014_distance_control_20121119'},...
%     'C:\Subjects_MRI_data\7T\121119_Chrystany\Nifti\1_008_mp2rage_UNI_Images_20121119', ...
%     'C:\Subjects_MRI_data\7T\121119_Chrystany\Nifti\1_009_mp2rage_INV2_20121119', ...
%     'C:\Subjects_MRI_data\7T\New_subjs_prep\new', ...
%     '121119_Chrystany', 1};
% a{2}={{'C:\Subjects_MRI_data\7T\121119_Sergey\Nifti\1_003_distance1_20121119','C:\Subjects_MRI_data\7T\121119_Sergey\Nifti\1_005_distance2_20121119','C:\Subjects_MRI_data\7T\121119_Sergey\Nifti\1_006_distance3_20121119','C:\Subjects_MRI_data\7T\121119_Sergey\Nifti\1_009_distance4_20121119','C:\Subjects_MRI_data\7T\121119_Sergey\Nifti\1_014_distance5_20121119','C:\Subjects_MRI_data\7T\121119_Sergey\Nifti\1_015_distance_control_20121119'},...
%     'C:\Subjects_MRI_data\7T\121119_Sergey\Nifti\1_013_mp2rage_UNI_Images_20121119', ...
%     'C:\Subjects_MRI_data\7T\121119_Sergey\Nifti\1_011_mp2rage_INV2_20121119', ...
%     'C:\Subjects_MRI_data\7T\New_subjs_prep\new', ...
%     '121119_Sergey', 1};
% parfor i=1:2
%     pre_process_7T_subject_with_normalize(a{i}{1},a{i}{2},a{i}{3},a{i}{4},a{i}{5},a{i}{6});
% end
% 

start_from_stage=1; end_stage=5;
preproc_scripts_dir = 'C:\Users\Michael\Dropbox\Michael_scripts\orientation_scripts\preproc_jobs\';
path='C:\Subjects_MRI_data\7T\';
output_dir='C:\Subjects_MRI_data\7T\New_subjs_prep_2012';
a=dir([path '1211*']); a=a(2:end); num_subjs=length(a);

% pre-processing with script
parfor i=1:10
    disp(i)
    func_dirnames=cell(1,6);
    b=dir([path a(i).name '\Nifti\*distance*']);
    for j=1:6
        func_dirnames{j}=fullfile([path a(i).name '\Nifti\'], b(j).name);
    end
    T1_UNI_dirname=dir([path a(i).name '\Nifti\*UNI*']); T1_UNI_dirname=fullfile([path a(i).name '\Nifti\'], T1_UNI_dirname.name);
    T1_INV_dirname=dir([path a(i).name '\Nifti\*INV2*']); T1_INV_dirname=fullfile([path a(i).name '\Nifti\'], T1_INV_dirname.name);
    subject_name=a(i).name;
    % running the script
    pre_process_7T_subject(func_dirnames, T1_UNI_dirname, T1_INV_dirname, output_dir, subject_name, start_from_stage, end_stage);
end


% run DARTEL - create template
disp('Running DARTEL - create template');
rc1files={}; rc2files={};
for i=1:num_subjs
    rc1files{end+1}=[output_dir '\T1IMG\' a(i).name '\rc1Anatomical_corrected.nii'];
    rc2files{end+1}=[output_dir '\T1IMG\' a(i).name '\rc2Anatomical_corrected.nii'];
end
spm('defaults','fmri');
spm_jobman('initcfg');
load([preproc_scripts_dir 'DARTEL_create_template.mat']);
matlabbatch{1}.spm.tools.dartel.warp.images{1}=rc1files;
matlabbatch{1}.spm.tools.dartel.warp.images{2}=rc1files;

spm_jobman('run', matlabbatch);
clear matlabbatch


% run DARTEL - normalize
disp('Running DARTEL - normalize');
load([preproc_scripts_dir 'DARTEL_normalize.mat']);
NumSessions=6;
for i=1:num_subjs
    disp(i);
    subject_name=a(i).name;
    T1IMGdir=[output_dir '\T1IMG\' subject_name];
%     FunRawRDDir = cell(1,NumSessions);
    FunRawRDir = cell(1,NumSessions);
    RealignParametersDir = cell(1,NumSessions);
    for s=1:NumSessions
        FunRawRDir{s}=[output_dir '\FunRawR\' subject_name '_' num2str(s)];
        RealignParametersDir{s}=[output_dir '\RealignParameter\' subject_name '_' num2str(s)];
%         FunRawRDDir{s}=[output_dir '\FunRawRD\' subject_name '_' num2str(s)];
    end

    files_to_normalize={};
    for s=1:NumSessions
        aa=dir(fullfile(FunRawRDir{s},'*.img'));
        for j=1:length(aa)
            files_to_normalize{end+1} = fullfile(FunRawRDir{s},aa(j).name);
        end
    end
    files_to_normalize{end+1}=fullfile(T1IMGdir, 'Anatomical_corrected.img');
    files_to_normalize{end+1}=fullfile(T1IMGdir, 'mAnatomical_corrected.nii');
    files_to_normalize{end+1}=fullfile(T1IMGdir, 'c1Anatomical_corrected.nii');
    files_to_normalize{end+1}=fullfile(T1IMGdir, 'c2Anatomical_corrected.nii');
    files_to_normalize{end+1}=fullfile(T1IMGdir, 'c3Anatomical_corrected.nii');
    mean_func_image=dir([RealignParametersDir{1} '\mean*.img']); 
    files_to_normalize{end+1}=fullfile(RealignParametersDir{1},mean_func_image(1).name);

    flow_field_file=dir([T1IMGdir '\u_*']);
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(i).flowfield={fullfile(T1IMGdir, flow_field_file(1).name)};
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(i).images=files_to_normalize;
end

template_file=dir([output_dir '\T1IMG\' a(1).name '\Template_6.*']);
matlabbatch{1}.spm.tools.dartel.mni_norm.template={[output_dir '\T1IMG\' a(1).name '\' template_file(1).name]};

spm_jobman('run', matlabbatch);

% smoothing by 2mm
matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [2 2 2];
spm_jobman('run', matlabbatch);
clear matlabbatch


% moving files
disp('Moving files...');
for i=1:num_subjs
    disp(i)
    subject_name=a(i).name;
%     FunRawRDDir = cell(1,NumSessions);
%     FunRawRDWDir = cell(1,NumSessions);
%     FunRawRDWSDir = cell(1,NumSessions);
%     for s=1:NumSessions
%         FunRawRDDir{s}=[output_dir '\FunRawRD\' subject_name '_' num2str(s)];
%         FunRawRDWDir{s}=[output_dir '\FunRawRDW\' subject_name '_' num2str(s)];
%         FunRawRDWSDir{s}=[output_dir '\FunRawRDWS\' subject_name '_' num2str(s)];
%     end
    FunRawRDir = cell(1,NumSessions);
    FunRawRWDir = cell(1,NumSessions);
    FunRawRWSDir = cell(1,NumSessions);
    for s=1:NumSessions
        FunRawRDir{s}=[output_dir '\FunRawR\' subject_name '_' num2str(s)];
        FunRawRWDir{s}=[output_dir '\FunRawRW\' subject_name '_' num2str(s)];
        FunRawRWSDir{s}=[output_dir '\FunRawRWS\' subject_name '_' num2str(s)];
    end


    for s=1:NumSessions
        mkdir(FunRawRWDir{s});
        aa=dir(fullfile(FunRawRDir{s},'w*'));
        for j=1:length(aa)
            movefile(fullfile(FunRawRDir{s}, aa(j).name),FunRawRWDir{s});
        end
    end
    for s=1:NumSessions
        mkdir(FunRawRWSDir{s});
        aa=dir(fullfile(FunRawRDir{s},'sw*'));
        for j=1:length(aa)
            movefile(fullfile(FunRawRDir{s}, aa(j).name),FunRawRWSDir{s});
        end
    end

end


% smoothing the FunRawR data
disp('Smoothing FunRawR...');
for i=1:num_subjs
    disp(i)
    subject_name=a(i).name;
    FunRawRDir = cell(1,NumSessions);
    FunRawRSDir = cell(1,NumSessions);
    for s=1:NumSessions
        FunRawRDir{s}=[output_dir '\FunRawR\' subject_name '_' num2str(s)];
        FunRawRSDir{s}=[output_dir '\FunRawRS\' subject_name '_' num2str(s)];
    end
    load([preproc_scripts_dir 'smooth.mat']);
    files_to_smooth={};
    for s=1:NumSessions
        aa=dir(FunRawRDir{s});
        for j=1:length(aa)
            files_to_smooth{end+1} = fullfile(FunRawRDir{s},aa(j).name);
        end
    end
    matlabbatch{1}.spm.spatial.smooth.data = files_to_smooth;
    matlabbatch{1}.spm.spatial.smooth.fwhm = [2 2 2];
    spm_jobman('run', matlabbatch);
    for s=1:NumSessions
        mkdir(FunRawRSDir{s});
        aa=dir(fullfile(FunRawRDir{s},'s_*'));
        for j=1:length(aa)
            movefile(fullfile(FunRawRDir{s}, aa(j).name),FunRawRSDir{s});
        end
    end
    clear matlabbatch
end


