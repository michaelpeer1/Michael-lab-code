function coregister_T1_to_func(T1IMGdir, func_image)
% This function runs co-registration of a subject's functional and
% anatomical data

% preproc_scripts_dir = 'C:\Users\Michael\Dropbox\Michael_scripts\orientation_scripts\preproc_jobs\';
preproc_scripts_dir = 'C:\Michael\Michael_scripts\orientation_scripts\preproc_jobs\';
T1IMG_filename=fullfile(T1IMGdir, 'Anatomical_corrected.img');
m_image=fullfile(T1IMGdir, 'mAnatomical_corrected.nii');
c1_image=fullfile(T1IMGdir, 'c1Anatomical_corrected.nii');
c2_image=fullfile(T1IMGdir, 'c2Anatomical_corrected.nii');
c3_image=fullfile(T1IMGdir, 'c3Anatomical_corrected.nii');
c4_image=fullfile(T1IMGdir, 'c4Anatomical_corrected.nii');
c5_image=fullfile(T1IMGdir, 'c5Anatomical_corrected.nii');
skull_stripped_image=fullfile(T1IMGdir,'skull_stripped.img');


load([preproc_scripts_dir 'coregister.mat']);
matlabbatch{1}.spm.spatial.coreg.estimate.ref={func_image};
matlabbatch{1}.spm.spatial.coreg.estimate.source={skull_stripped_image};
matlabbatch{1}.spm.spatial.coreg.estimate.other={T1IMG_filename, m_image, c1_image, c2_image,c3_image,c4_image,c5_image};
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep=[4 2 0.5];
spm_jobman('run', matlabbatch);
clear matlabbatch
