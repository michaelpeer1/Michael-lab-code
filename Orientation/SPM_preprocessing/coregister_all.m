% This function runs co-registration of all subjects' functional and
% anatomical data, by running the coregister_T1_to_func.m function on each
% subject
%
% first we need to orient each wholebrain and T1 images to FunRawR approximate origin!!!!!

preproc_scripts_dir = 'C:\Michael\Michael_scripts\orientation_scripts\preproc_jobs\';
subj_names=dir('G:\Subjects_MRI_data\7T\New_subjs_prep_2013\T1IMG'); subj_names=subj_names(3:end);
for i=1:length(subj_names)
    T1IMGdir=['G:\Subjects_MRI_data\7T\New_subjs_prep_2013\T1IMG\' subj_names(i).name];
    wholebrain_image=fullfile(T1IMGdir, 'wholebrain_func.img');
    a=getfullfiles(['G:\Subjects_MRI_data\7T\New_subjs_prep_2013\FunRawR\' subj_names(i).name '_1\*.img']);    
    func_image=a{1};
    load([preproc_scripts_dir 'coregister.mat']);
    matlabbatch{1}.spm.spatial.coreg.estimate.ref={func_image};
    matlabbatch{1}.spm.spatial.coreg.estimate.source={wholebrain_image};
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep=[4 2 0.5];
    spm_jobman('run', matlabbatch);
    clear matlabbatch
    
    coregister_T1_to_func(T1IMGdir, wholebrain_image);
end
