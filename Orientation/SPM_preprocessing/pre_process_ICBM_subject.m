function []=pre_process_ICBM_subject(output_dir, job_dir, subject_name, start_from_stage)
% This script is for pre-processing subjects (old version - for analyzing
% subjects from the INDI ICBM database). Only runs segmentation,
% skull-stripping and co-registration
%
% receives a cell array of names of functional image directories (with 
% NIFTI files), names of the two T1 image directories, a name of the
% output directory (new directory), and the name of the subject
% also receives start_from_stage:
% 1 - New segment
% 2 - Skull strip T1 image (for coregistration)
% 3 - Co-register
% creates the corresponding directories (FunRaw, T1IMG, etc.) inside the 
% output directory
%
% should be run after slice-timing and motion correction. Copy the
% anonymized mprage image to T1IMG directory.
% NOTICE THAT SLICE TIMING INFO IS SEQUENTIAL DESCENDING!!!!

spm('defaults','fmri');
spm_jobman('initcfg');

T1IMGdir=[output_dir '\T1IMG\' subject_name];
RealignDir=[output_dir '\RealignParameter\' subject_name];
% T1ImgNewSegmentDir=[output_dir '\T1ImgNewSegment\' subject_name];
% if exist(T1ImgNewSegmentDir,'dir')==0
%     mkdir(T1ImgNewSegmentDir);
% end
T1ImgSegmentDir=[output_dir '\T1ImgSegment\' subject_name];
if exist(T1ImgSegmentDir,'dir')==0
    mkdir(T1ImgSegmentDir);
end

T1IMG_filename=fullfile(T1IMGdir, 'mprage_anonymized.nii');
skull_stripped_image=fullfile(T1ImgSegmentDir,'skull_stripped_new.nii');
mean_func_image=fullfile(RealignDir,'meanarest.nii');

% job_dir='C:\michael\michael_scripts\preproc_jobs';

if start_from_stage==1
%     % 1. New segment
%     load(fullfile(job_dir,'new_segment.mat'));
%     matlabbatch{1}.spm.tools.preproc8.channel.vols={T1IMG_filename};
%     matlabbatch{1}.spm.tools.preproc8.tissue(4).native=[0 0];
%     matlabbatch{1}.spm.tools.preproc8.tissue(5).native=[0 0];
%     spm_jobman('run', matlabbatch);
%     clear matlabbatch
%     m_image=dir([T1IMGdir '\mm*.nii']); m_image=fullfile(T1IMGdir,m_image.name);
%     c1_image=dir([T1IMGdir '\c1*.nii']); c1_image=fullfile(T1IMGdir,c1_image.name);
%     c2_image=dir([T1IMGdir '\c2*.nii']); c2_image=fullfile(T1IMGdir,c2_image.name);
%     c3_image=dir([T1IMGdir '\c3*.nii']); c3_image=fullfile(T1IMGdir,c3_image.name);
%     start_from_stage=start_from_stage+1;

    % 1. Segment
    load(fullfile(job_dir,'segment.mat'));
    matlabbatch{1}.spm.spatial.preproc.data={T1IMG_filename};
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    m_image=dir([T1IMGdir '\mm*.nii']); m_image=fullfile(T1IMGdir,m_image.name);
    c1_image=dir([T1IMGdir '\c1*.nii']); c1_image=fullfile(T1IMGdir,c1_image.name);
    c2_image=dir([T1IMGdir '\c2*.nii']); c2_image=fullfile(T1IMGdir,c2_image.name);
    c3_image=dir([T1IMGdir '\c3*.nii']); c3_image=fullfile(T1IMGdir,c3_image.name);
    start_from_stage=start_from_stage+1;
end

if start_from_stage==2
    % 2. Create skull_stripped image
    load(fullfile(job_dir,'skull_strip.mat'));
    matlabbatch{1}.spm.util.imcalc.input={m_image,c1_image,c2_image,c3_image};
    matlabbatch{1}.spm.util.imcalc.output = skull_stripped_image;
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    start_from_stage=start_from_stage+1;
end

if start_from_stage==3
    % 3. Co-register (estimate)
    load(fullfile(job_dir,'coregister.mat'));
    copyfile(T1IMG_filename,fullfile(T1ImgSegmentDir,'mprage_anonymized_orig.nii')); % backing up the original T1IMG
    matlabbatch{1}.spm.spatial.coreg.estimate.ref={mean_func_image};
    matlabbatch{1}.spm.spatial.coreg.estimate.source={skull_stripped_image};
    matlabbatch{1}.spm.spatial.coreg.estimate.other={m_image,c1_image,c2_image,c3_image,T1IMG_filename};
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    start_from_stage=start_from_stage+1;
end

a=dir(T1IMGdir); a=a(3:end);
for i=1:length(a)
    movefile(fullfile(T1IMGdir,a(i).name),T1ImgSegmentDir);
end
movefile(fullfile(T1ImgSegmentDir,'mprage_anonymized_orig.nii'),fullfile(T1IMGdir,'mprage_anonymized.nii'));
