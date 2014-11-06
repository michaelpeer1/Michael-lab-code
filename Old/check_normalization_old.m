function [t1_corr, epi_corr] =  check_normalization(segment_dir, realign_dir)

% This function compares the normalized T1 and mean functional images to
% the corresponding SPM templates, and returns the correlation
%
% input: 
% segment_dir - the subject's segmentation directory (should contain
% c1* and wT1* files
% realign_dir - the subject's realignment directory (should contain the
% wmean* file (mean functional image, normalized)

template_t1_filename='C:\spm8\templates\T1.nii';
template_epi_filename='C:\spm8\templates\EPI.nii';
C1_filename=dir(fullfile(segment_dir, '\c1*'));
T1_norm_filename=dir(fullfile(segment_dir, ['w' C1_filename.name(3:end-4) '.*i*'])); T1_norm_filename=fullfile(segment_dir,T1_norm_filename(1).name);
mean_func_norm_filename=dir([realign_dir '\w*mean*.img']);
if isempty(mean_func_norm_filename)  %YAN Chao-Gan, 111114. Also support .nii files.
    mean_func_norm_filename=dir([realign_dir '\w*mean*.nii.gz']);
    if length(mean_func_norm_filename)==1
        gunzip(fullfile(realign_dir,mean_func_norm_filename(1).name));delete(fullfile(realign_dir,mean_func_norm_filename(1).name));
    end
    mean_func_norm_filename=dir([realign_dir '\w*mean*.nii']);
end
mean_func_norm_filename=fullfile(realign_dir,mean_func_norm_filename.name);
% reslice the T1 and EPI images using DPARSFA reslice
T1_norm_resliced_filename=fullfile(segment_dir,'T1_norm_resliced.nii');
y_Reslice(T1_norm_filename,T1_norm_resliced_filename,[],0, template_t1_filename);
template_epi_resliced_filename=fullfile(segment_dir,'epi_resliced.nii');
y_Reslice(template_epi_filename,template_epi_resliced_filename,[],0, mean_func_norm_filename);
% smooth the images by 8mm, to match the templates
spm('defaults','fmri');
spm_jobman('initcfg');
matlabbatch={struct('spm',struct('spatial',struct('smooth',struct('data','','dtype',0,'fwhm',[8 8 8],'im',0,'prefix','s'))))};
matlabbatch{1}.spm.spatial.smooth.data = {T1_norm_resliced_filename, mean_func_norm_filename};
spm_jobman('run', matlabbatch);
clear matlabbatch
smoothed_t1_norm_resliced_filename=fullfile(segment_dir,'sT1_norm_resliced.nii');
[~,meanfuncfile,meanfuncext]=fileparts(mean_func_norm_filename);
smoothed_mean_func_norm_filename=fullfile(realign_dir,['s' meanfuncfile meanfuncext]);
% read the images into matrices
T1_norm_resliced=spm_read_vols(spm_vol(smoothed_t1_norm_resliced_filename));
mean_func_norm=spm_read_vols(spm_vol(smoothed_mean_func_norm_filename));
template_t1=spm_read_vols(spm_vol(template_t1_filename));
template_epi_resliced=spm_read_vols(spm_vol(template_epi_resliced_filename));
template_t1(T1_norm_resliced==0)=0;         % this is to compare only the parts existing in the scanned images
template_epi_resliced(mean_func_norm==0)=0;
% comparing the matrices
t1_corr=corrcoef(T1_norm_resliced,template_t1); t1_corr=t1_corr(2);
epi_corr=corrcoef(mean_func_norm,template_epi_resliced); epi_corr=epi_corr(2);
% deleting the files created in the process
delete(T1_norm_resliced_filename); delete(template_epi_resliced_filename);
delete(smoothed_t1_norm_resliced_filename); 
delete(fullfile(realign_dir,['s' meanfuncfile '.*']));
