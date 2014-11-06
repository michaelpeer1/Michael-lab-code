function []=pre_process_3T_subject(func_dirnames, T1_dirname, output_dir, subject_name, start_from_stage, end_stage)
% This script pre-processes fMRI scans of subjects of the 3-Tesla 
% orientation experiment, by SPM batch-processing
%
% receives a cell array of names of functional image directories (with
% NIFTI files), a name of the output directory (new directory), and the name of the subject
% also receives start_from_stage:
% 1 - New segment
% 2 - Co-register
% 3 - Realign image
% 4 - detrend
% 5 - normalize
% 6 - smooth - 4MM
% creates the corresponding directories (FunRaw, T1IMG, etc.) inside the
% output directory

preproc_scripts_dir = 'C:\Users\Michael\Dropbox\Michael_scripts\preproc_jobs\';

spm('defaults','fmri');
spm_jobman('initcfg');

T1IMGdir=[output_dir '\T1Img\' subject_name];
if exist(T1IMGdir,'dir')==0
    mkdir(T1IMGdir);
end
T1IMG_filename=dir(fullfile(T1_dirname,'*.img')); T1IMG_filename=T1IMG_filename(1).name;
copyfile(fullfile(T1_dirname, T1IMG_filename),T1IMGdir);
copyfile(fullfile(T1_dirname, [T1IMG_filename(1:end-4) '.hdr']),T1IMGdir);
T1IMG_filename_full=fullfile(T1IMGdir, T1IMG_filename);
m_image=fullfile(T1IMGdir, ['m' T1IMG_filename(1:end-4) '.nii']);
c1_image=fullfile(T1IMGdir, ['c1' T1IMG_filename(1:end-4) '.nii']);
c2_image=fullfile(T1IMGdir, ['c2' T1IMG_filename(1:end-4) '.nii']);
c3_image=fullfile(T1IMGdir, ['c3' T1IMG_filename(1:end-4) '.nii']);

NumSessions=length(func_dirnames);
FunRawDir = cell(1,NumSessions);
FunRawRDir = cell(1,NumSessions);
RealignParametersDir = cell(1,NumSessions);
FunRawRDDir = cell(1,NumSessions);
FunRawRDWDir = cell(1,NumSessions);
FunRawRDWSDir = cell(1,NumSessions);
for i=1:NumSessions
    FunRawDir{i}=[output_dir '\FunRaw\' subject_name '_' num2str(i)];
    FunRawRDir{i}=[output_dir '\FunRawR\' subject_name '_' num2str(i)];
    RealignParametersDir{i}=[output_dir '\RealignParameter\' subject_name '_' num2str(i)];
    FunRawRDDir{i}=[output_dir '\FunRawRD\' subject_name '_' num2str(i)];
    FunRawRDWDir{i}=[output_dir '\FunRawRDW\' subject_name '_' num2str(i)];
    FunRawRDWSDir{i}=[output_dir '\FunRawRDWS\' subject_name '_' num2str(i)];
    if exist(FunRawDir{i},'dir')==0
        mkdir(FunRawDir{i});
        copyfile(func_dirnames{i},FunRawDir{i});
    end
end

if start_from_stage==1
    % 1. New segment
    load([preproc_scripts_dir 'new_segment.mat']);
    matlabbatch{1}.spm.tools.preproc8.channel.vols={T1IMG_filename_full};
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    if start_from_stage < end_stage
        start_from_stage=start_from_stage+1;
    end
end

if start_from_stage==2
    % 2. Co-register (estimate)
    load([preproc_scripts_dir 'coregister.mat']);
    FunRawImages={};
    for i=1:NumSessions
        a=dir(fullfile(FunRawDir{i},'*.img'));
        for j=1:length(a)
            FunRawImages{end+1}=fullfile(FunRawDir{i},a(j).name);
        end
    end
    matlabbatch{1}.spm.spatial.coreg.estimate.ref={T1IMG_filename_full};
    matlabbatch{1}.spm.spatial.coreg.estimate.source=FunRawImages(1);
    matlabbatch{1}.spm.spatial.coreg.estimate.other=FunRawImages(2:end);
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep=[4 2];
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    if start_from_stage < end_stage
        start_from_stage=start_from_stage+1;
    end
end

if start_from_stage==3
    % 3. Realign images by session
    load([preproc_scripts_dir 'realign.mat']);
    FunRawImages_by_session=cell(1,NumSessions);
    for i=1:NumSessions
        a=dir(fullfile(FunRawDir{i},'*.img'));
        for j=1:length(a)
            FunRawImages_by_session{i}{end+1}=fullfile(FunRawDir{i},a(j).name);
        end
    end
    matlabbatch{1}.spm.spatial.realign.estwrite.data=FunRawImages_by_session;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix='r_';
    spm_jobman('run', matlabbatch);
    for i=1:NumSessions
        mkdir(FunRawRDir{i});
        mkdir(RealignParametersDir{i});
        a=dir(fullfile(FunRawDir{i},'r_*'));
        for j=1:length(a)
            movefile(fullfile(FunRawDir{i},a(j).name),FunRawRDir{i});
        end
        b=dir(fullfile(FunRawDir{i},'mean*'));
        for j=1:length(b)
            movefile(fullfile(FunRawDir{i},b(j).name),RealignParametersDir{i});
        end
        c=dir(fullfile(FunRawDir{i},'rp*.txt'));
        movefile(fullfile(FunRawDir{i},c.name),RealignParametersDir{i});
    end
    clear matlabbatch
    if start_from_stage < end_stage
        start_from_stage=start_from_stage+1;
    end
end

mean_func_image=dir([RealignParametersDir{1} '\mean*.img']); mean_func_image=fullfile(RealignParametersDir{1},mean_func_image(1).name);

if start_from_stage==4
    % 4. Detrend
    for i=1:NumSessions
        rest_detrend(FunRawRDir{i},'_detrend');
        mkdir(FunRawRDDir{i});
        movefile([FunRawRDir{i} '_detrend\detrend_4DVolume.nii'],FunRawRDDir{i});
        rmdir([FunRawRDir{i} '_detrend']);
    end
    if start_from_stage < end_stage
        start_from_stage=start_from_stage+1;
    end
end


% if start_from_stage==5
%     % 5. normalize
%     load([preproc_scripts_dir 'normalize.mat']);
%     matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox=[3 3 3];   % the voxel size in the resulting image
%     files_to_normalize={};
%     for i=1:NumSessions
%         a=dir(FunRawRDDir{i});
%         for j=1:length(a)
%             files_to_normalize{end+1} = fullfile(FunRawRDDir{i},a(j).name);
%         end
%     end
%     files_to_normalize{end+1}=T1IMG_filename_full;
%     files_to_normalize{end+1}=m_image;
%     files_to_normalize{end+1}=c1_image;
%     files_to_normalize{end+1}=c2_image;
%     files_to_normalize{end+1}=c3_image;
%     files_to_normalize{end+1}=mean_func_image;
%     
%     matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = {m_image};
%     matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = files_to_normalize;
%     spm_jobman('run', matlabbatch);
%     for i=1:NumSessions
%         mkdir(FunRawRDWDir{i});
%         a=dir(fullfile(FunRawRDDir{i},'w_*'));
%         for j=1:length(a)
%             movefile(fullfile(FunRawRDDir{i}, a(j).name),FunRawRDWDir{i});
%         end
%     end
%     clear matlabbatch
%     if start_from_stage < end_stage
%         start_from_stage=start_from_stage+1;
%     end
% end
% 
% if start_from_stage==6
%     % 8. smooth
%     load([preproc_scripts_dir 'smooth.mat']);
%     files_to_smooth={};
%     for i=1:NumSessions
%         %spm_file_split([FunRawRDWDir{i} '\detrend_4DVolume.nii']);
%         %delete([FunRawRDWDir{i} '\detrend_4DVolume.nii']);
%         a=dir(FunRawRDWDir{i});
%         for j=1:length(a)
%             files_to_smooth{end+1} = fullfile(FunRawRDWDir{i},a(j).name);
%         end
%     end
%     matlabbatch{1}.spm.spatial.smooth.data = files_to_smooth;
%     matlabbatch{1}.spm.spatial.smooth.fwhm = [4 4 4];
%     spm_jobman('run', matlabbatch);
%     for i=1:NumSessions
%         mkdir(FunRawRDWSDir{i});
%         a=dir(fullfile(FunRawRDWDir{i},'s_*'));
%         for j=1:length(a)
%             movefile(fullfile(FunRawRDWDir{i}, a(j).name),FunRawRDWSDir{i});
%         end
%     end
%     clear matlabbatch
%     if start_from_stage < end_stage
%         start_from_stage=start_from_stage+1;
%     end
% end
