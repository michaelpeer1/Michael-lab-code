function []=pre_process_7T_subject_anatomical_only(T1_UNI_dirname, T1_INV_dirname, output_dir, subject_name, start_from_stage)
% receives a cell array of names of the two T1 image directories, a name of the
% output directory (new directory), and the name of the subject
% also receives start_from_stage:
% 1 - MP2RAGE correction
% 2 - New segment
% 3 - Skull strip T1 image (for coregistration)
% creates the corresponding directories (FunRaw, T1IMG, etc.) inside the
% output directory

spm('defaults','fmri');
spm_jobman('initcfg');

T1IMGdir=[output_dir '\T1IMG\' subject_name];
if exist(T1IMGdir,'dir')==0
    mkdir(T1IMGdir);
end
T1IMG_filename=fullfile(T1IMGdir, 'Anatomical_corrected.img');
skull_stripped_image=fullfile(T1IMGdir,'skull_stripped.img');


if start_from_stage==1
    % 1. MP2RAGE correction
    load('F:\Michael_scripts\preproc_jobs\MP2RAGE_correct.mat');
    T1_UNI_file=dir([T1_UNI_dirname '\*.img']); T1_UNI_file=fullfile(T1_UNI_dirname,T1_UNI_file.name);
    T1_INV_file=dir([T1_INV_dirname '\*.img']); T1_INV_file=fullfile(T1_INV_dirname,T1_INV_file.name);
    matlabbatch{1}.spm.util.imcalc.input={T1_INV_file, T1_UNI_file};
    matlabbatch{1}.spm.util.imcalc.output=T1IMG_filename;
    % matlabbatch{1}.spm.util.imcalc.outdir={T1IMGdir};
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    start_from_stage=start_from_stage+1;
end

if start_from_stage==2
    % 2. New segment
    load('F:\Michael_scripts\preproc_jobs\new_segment.mat');
    matlabbatch{1}.spm.tools.preproc8.channel.vols={T1IMG_filename};
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    start_from_stage=start_from_stage+1;
end

if start_from_stage==3
    % 3. Create skull_stripped image
    load('F:\Michael_scripts\preproc_jobs\skull_strip.mat');
    m_image=dir([T1IMGdir '\m*.nii']); m_image=fullfile(T1IMGdir,m_image.name);
    c1_image=dir([T1IMGdir '\c1*.nii']); c1_image=fullfile(T1IMGdir,c1_image.name);
    c2_image=dir([T1IMGdir '\c2*.nii']); c2_image=fullfile(T1IMGdir,c2_image.name);
    c3_image=dir([T1IMGdir '\c3*.nii']); c3_image=fullfile(T1IMGdir,c3_image.name);
    matlabbatch{1}.spm.util.imcalc.input={m_image,c1_image,c2_image,c3_image};
    matlabbatch{1}.spm.util.imcalc.output = skull_stripped_image;
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    start_from_stage=start_from_stage+1;
end


