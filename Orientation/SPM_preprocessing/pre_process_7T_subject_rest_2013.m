function []=pre_process_7T_subject_rest_2013(func_dirname, T1_uni_den_dirname, func_wholebrain_dir, output_dir, subject_name, start_from_stage, end_stage)
% This script pre-processes resting-state scans of subjects of the 7-Tesla 
% orientation experiment, by SPM batch-processing - only the new subjects
% from 2013
%
% receives a cell array of names of functional image directories (with
% NIFTI files), names of the two T1 image directories, a name of the
% output directory (new directory), and the name of the subject
% also receives start_from_stage:
% 1 - MP2RAGE correction
% 2 - New segment
% 3 - Skull strip T1 image (for coregistration)
% 4 - Co-register
% 5 - Realign image
% 6 - Normalize
% 7 - Smooth (2mm)
% creates the corresponding directories (FunRaw, T1IMG, etc.) inside the
% output directory
% 
% THIS MUST BE CONTINUED BY DPARSFA - FILTERING AND NUISANCE COVARIATES REGRESSION

preproc_scripts_dir = 'C:\Users\Michael\Dropbox\Michael_scripts\orientation_scripts\preproc_jobs\';

spm('defaults','fmri');
spm_jobman('initcfg');

T1IMGdir=[output_dir '\T1IMG\' subject_name];
if exist(T1IMGdir,'dir')==0
    mkdir(T1IMGdir);
end
T1IMG_filename=fullfile(T1IMGdir, 'Anatomical_corrected.img');
m_image=fullfile(T1IMGdir, 'mAnatomical_corrected.nii');
c1_image=fullfile(T1IMGdir, 'c1Anatomical_corrected.nii');
c2_image=fullfile(T1IMGdir, 'c2Anatomical_corrected.nii');
c3_image=fullfile(T1IMGdir, 'c3Anatomical_corrected.nii');
skull_stripped_image=fullfile(T1IMGdir,'skull_stripped.img');
wholebrain_func_image=fullfile(T1IMGdir,'wholebrain_func.img');

FunRawDir=[output_dir '\FunRaw\' subject_name];
FunRawRDir=[output_dir '\FunRawR\' subject_name];
RealignParametersDir=[output_dir '\RealignParameter\' subject_name];
FunRawRWDir=[output_dir '\FunRawRW\' subject_name];
FunRawRWSDir=[output_dir '\FunRawRWS\' subject_name];
if exist(FunRawDir,'dir')==0
    mkdir(FunRawDir);
    copyfile(func_dirname,FunRawDir);
end

if start_from_stage==1
    % 1. MP2RAGE and wholebrain_func copy
     T1_img_file=getfullfiles(fullfile(T1_uni_den_dirname,'*.img'));
     T1_hdr_file=getfullfiles(fullfile(T1_uni_den_dirname,'*.hdr'));     
     copyfile(T1_img_file{1},T1IMG_filename);
     copyfile(T1_hdr_file{1},[T1IMG_filename(1:end-4) '.hdr']);
     % copy wholebrain_func_image
     wholebrain_func_img_file=getfullfiles(fullfile(func_wholebrain_dir,'*.img'));
     wholebrain_func_hdr_file=getfullfiles(fullfile(func_wholebrain_dir,'*.hdr'));     
     copyfile(wholebrain_func_img_file{1},wholebrain_func_image);
     copyfile(wholebrain_func_hdr_file{1},[wholebrain_func_image(1:end-4) '.hdr']);     
    if start_from_stage < end_stage
        start_from_stage=start_from_stage+1;
    end
end

if start_from_stage==2
    % 2. New segment
    load([preproc_scripts_dir 'new_segment.mat']);
    matlabbatch{1}.spm.tools.preproc8.channel.vols={T1IMG_filename};
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    if start_from_stage < end_stage
        start_from_stage=start_from_stage+1;
    end
end

if start_from_stage==3
    % 3. Create skull_stripped image
    load([preproc_scripts_dir 'skull_strip.mat']);
    %m_image=dir([T1IMGdir '\m*.nii']); m_image=fullfile(T1IMGdir,m_image.name);
    %c1_image=dir([T1IMGdir '\c1*.nii']); c1_image=fullfile(T1IMGdir,c1_image.name);
    %c2_image=dir([T1IMGdir '\c2*.nii']); c2_image=fullfile(T1IMGdir,c2_image.name);
    %c3_image=dir([T1IMGdir '\c3*.nii']); c3_image=fullfile(T1IMGdir,c3_image.name);
    matlabbatch{1}.spm.util.imcalc.input={m_image,c1_image,c2_image,c3_image};
    matlabbatch{1}.spm.util.imcalc.output = skull_stripped_image;
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    if start_from_stage < end_stage
        start_from_stage=start_from_stage+1;
    end
end

if start_from_stage==4
    % 4. Co-register (estimate)
    % Co-register wholebrain_func to skull_stripped
    load([preproc_scripts_dir 'coregister.mat']);
    matlabbatch{1}.spm.spatial.coreg.estimate.ref={skull_stripped_image};
    matlabbatch{1}.spm.spatial.coreg.estimate.source={wholebrain_func_image};
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep=[4 2 0.5];
    spm_jobman('run', matlabbatch);
    % co-register functional images to wholebrain_func
    FunRawImages=getfullfiles(fullfile(FunRawDir,'*.img'));
    matlabbatch{1}.spm.spatial.coreg.estimate.ref={wholebrain_func_image};
    matlabbatch{1}.spm.spatial.coreg.estimate.source=FunRawImages(1);
    matlabbatch{1}.spm.spatial.coreg.estimate.other=FunRawImages(2:end);
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep=[4 2 0.5];
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    if start_from_stage < end_stage
        start_from_stage=start_from_stage+1;
    end
end

if start_from_stage==5
    % 5. Realign images
    load([preproc_scripts_dir 'realign.mat']);
    FunRawImages=getfullfiles(fullfile(FunRawDir,'*.img'));
    matlabbatch{1}.spm.spatial.realign.estwrite.data={FunRawImages};
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix='r_';
    spm_jobman('run', matlabbatch);
    
    mkdir(FunRawRDir);
    mkdir(RealignParametersDir);
    a=dir(fullfile(FunRawDir,'r_*'));
    for j=1:length(a)
        movefile(fullfile(FunRawDir,a(j).name),FunRawRDir);
    end
    b=dir(fullfile(FunRawDir,'mean*'));
    for j=1:length(b)
        movefile(fullfile(FunRawDir,b(j).name),RealignParametersDir);
    end
    c=dir(fullfile(FunRawDir,'rp*.txt'));
    movefile(fullfile(FunRawDir,c.name),RealignParametersDir);
    
    clear matlabbatch
    if start_from_stage < end_stage
        start_from_stage=start_from_stage+1;
    end
end


% if start_from_stage==6
%     % 7. normalize
%     mean_func_image=dir([RealignParametersDir '\mean*.img']); mean_func_image=fullfile(RealignParametersDir,mean_func_image(1).name);
%     
%     load([preproc_scripts_dir 'normalize.mat']);
%     matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox=[1.5 1.5 1.5];   % the voxel size in the resulting image
%     files_to_normalize={};
%     a=dir(FunRawRDir);
%     for j=1:length(a)
%         files_to_normalize{end+1} = fullfile(FunRawRDir,a(j).name);
%     end
%     files_to_normalize{end+1}=T1IMG_filename;
%     files_to_normalize{end+1}=skull_stripped_image;
%     files_to_normalize{end+1}=m_image;
%     files_to_normalize{end+1}=c1_image;
%     files_to_normalize{end+1}=c2_image;
%     files_to_normalize{end+1}=c3_image;
%     files_to_normalize{end+1}=mean_func_image;
%     
%     matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = {m_image};
%     matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = files_to_normalize;
%     spm_jobman('run', matlabbatch);
%     mkdir(FunRawRWDir);
%     a=dir(fullfile(FunRawRDir,'w_*'));
%     for j=1:length(a)
%         movefile(fullfile(FunRawRDir, a(j).name),FunRawRWDir);
%     end
%     clear matlabbatch
%     start_from_stage=start_from_stage+1;
% end
% 
% if start_from_stage==7
%     % 8. smooth
%     load([preproc_scripts_dir 'smooth.mat']);
%     files_to_smooth={};
%     a=dir(FunRawRWDir);
%     for j=1:length(a)
%         files_to_smooth{end+1} = fullfile(FunRawRWDir,a(j).name);
%     end
%     matlabbatch{1}.spm.spatial.smooth.data = files_to_smooth;
%     matlabbatch{1}.spm.spatial.smooth.fwhm = [2 2 2];
%     spm_jobman('run', matlabbatch);
%     mkdir(FunRawRWSDir);
%     a=dir(fullfile(FunRawRWDir,'s_*'));
%     for j=1:length(a)
%         movefile(fullfile(FunRawRWDir, a(j).name),FunRawRWSDir);
%     end
%     clear matlabbatch
%     start_from_stage=start_from_stage+1;
% end
