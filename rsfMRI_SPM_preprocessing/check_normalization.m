function normalization_corr = check_normalization(normalized_image_filename, template_filename)

% normalization_corr =  check_normalization(normalized_image_filename, template_filename)
%
% This function compares a normalized image to a template and returns the
% correlation level after smoothing
% High correlation indicates correct normalization
% Assumes that the template is smoothed by 8mm (like SPM templates)
%
% SPM T1 template - 'C:\spm8\templates\T1.nii'
% SPM EPI template - 'C:\spm8\templates\EPI.nii'


% reslice the images using DPARSFA reslice
[norm_a,norm_b,norm_c]=fileparts(normalized_image_filename);
normalized_image_resliced_filename=[norm_a '\' norm_b '_resliced' norm_c];
y_Reslice(normalized_image_filename,normalized_image_resliced_filename,[],0, template_filename);

% smooth the images by 8mm, to match the templates
spm('defaults','fmri');
spm_jobman('initcfg');
matlabbatch={struct('spm',struct('spatial',struct('smooth',struct('data','','dtype',0,'fwhm',[8 8 8],'im',0,'prefix','s'))))};
matlabbatch{1}.spm.spatial.smooth.data = {normalized_image_resliced_filename};
spm_jobman('run', matlabbatch);
smoothed_normalized_image_resliced_filename=[norm_a '\s' norm_b '_resliced' norm_c];

% read the images into matrices
norm_image=spm_read_vols(spm_vol(smoothed_normalized_image_resliced_filename));
template=spm_read_vols(spm_vol(template_filename));
template(norm_image==0)=0;         % this is to compare only the parts existing in the scanned images
% mask with brain mask, to compare only the brains (in T1 for example)
brain_mask_file='C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\BrainMask_05_91x109x91.img';
brain_mask=y_Reslice_no_outputfile(brain_mask_file,[],0, template_filename);
template(brain_mask==0)=0; norm_image(brain_mask==0)=0;
% comparing the matrices
normalization_corr=corrcoef(norm_image,template); normalization_corr=normalization_corr(2);
% deleting the files created in the process
delete(normalized_image_resliced_filename); delete(smoothed_normalized_image_resliced_filename);



% OLD CODE
% [norm_a,norm_b,norm_c]=fileparts(normalized_image_filename);
% normalized_image_resliced_filename=[norm_a '\' norm_b '_resliced' norm_c];
% y_Reslice(normalized_image_filename,normalized_image_resliced_filename,[],0, template_filename);
% 
% brain_mask=spm_read_vols(spm_vol(brain_mask_file));
% if size(brain_mask)~=size(template)
%     brain_mask_reslice_file='C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\BrainMask_05_91x109x91_resliced.img';
%     y_Reslice(brain_mask_file,brain_mask_reslice_file,[],0, template_filename);
%     brain_mask=spm_read_vols(spm_vol(brain_mask_reslice_file));
%     delete(brain_mask_reslice_file);
% end
