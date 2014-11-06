subjects_output_dir = 'f:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end);

list_bad_runs = [];
for s=1:length(subject_names)
    subj=subject_names(s).name;
    output_dir=fullfile(subjects_output_dir, subj);
    motion_sdm_files=getfullfiles(fullfile(output_dir,'*3DMC.sdm'));
    
    for i=1:length(motion_sdm_files)
        motion_sdm = xff(motion_sdm_files{i});
        if find(motion_sdm.SDMMatrix>1.7)
            list_bad_runs = [list_bad_runs; s i];
        end
    end
end
