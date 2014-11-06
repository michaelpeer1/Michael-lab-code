subj_names={};
subj_paradigm_files={};
ignore_sessions={};

i=1; subj_names{i}='131001_Charles'; subj_paradigm_files{i}={'131001141659','131001142545','131001143432','131001145309','131001150121','131001151410'}; ignore_sessions{i}=[];
i=2; subj_names{i}='131002_Aya'; subj_paradigm_files{i}={'131002091549','131002092437','131002095539','131002100443','131002102112','131002103316'}; ignore_sessions{i}=[];
i=3; subj_names{i}='131002_Ian'; subj_paradigm_files{i}={'131002110335','131002111200','131002112013','131002113716','131002114611','131002115801'}; ignore_sessions{i}=[];
i=4; subj_names{i}='131003_Gene'; subj_paradigm_files{i}={'131003091647','131003092453','131003093626','131003095441','131003100322','131003101531'}; ignore_sessions{i}=[];
i=5; subj_names{i}='131003_Michael'; subj_paradigm_files{i}={'131003111821','131003112926','131003113742','131003115413','131003121934','131003120417'}; ignore_sessions{i}=[];
i=6; subj_names{i}='131004_Can'; subj_paradigm_files{i}={'131004105612','131004110450','131004111224','131004113041','131004113937','131004115120'}; ignore_sessions{i}=[];
i=7; subj_names{i}='131004_Milad'; subj_paradigm_files{i}={'131004091948','131004092816','131004093538','131004095313','131004100140','131004101134'}; ignore_sessions{i}=[];


% make paradigm files in ExpyVR log directory
for i=1:length(subj_paradigm_files)
    create_block_designs_multiple_files(subj_paradigm_files{i}, {0,0,0,0,0,0}, 2.5, 10, 15, 0, 0);
end

% including distances
for i=1:length(subj_paradigm_files)
    output_dir=['e:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\GLM_with_distances'];
    create_paradigm_7T('e:\Subjects_MRI_data\7T\New_subjs_prep_2013\FunRawRS', subj_names{i}, subj_paradigm_files{i}, 1, [ignore_sessions{i}], 1, 0, output_dir);
end

% domains_only - non-normalized data (smoothed by 2mm)
for i=1:length(subj_paradigm_files)
    output_dir=['e:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\GLM_domains_only'];
    mkdir(output_dir);
    create_paradigm_7T_domains_only('e:\Subjects_MRI_data\7T\New_subjs_prep_2013\FunRawRS', subj_names{i}, subj_paradigm_files{i}, 1, [ignore_sessions{i}], 1, 0, output_dir);
end

% domains_only - non-smoothed
for i=1:length(subj_paradigm_files)
    output_dir=['e:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\GLM_domains_only_nonsmoothed'];
    mkdir(output_dir);
    create_paradigm_7T_domains_only('e:\Subjects_MRI_data\7T\New_subjs_prep_2013\FunRawR', subj_names{i}, subj_paradigm_files{i}, 1, [ignore_sessions{i}], 1, 0, output_dir);
end

% % domains_only
% for i=1:length(subj_paradigm_files)
%     output_dir=['C:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\GLM_domains_only_normalized'];
%     mkdir(output_dir);
%     create_paradigm_7T_domains_only('C:\Subjects_MRI_data\7T\New_subjs_prep_2013\FunRawRWS', subj_names{i}, subj_paradigm_files{i}, 1, [ignore_sessions{i}], 1, 0, output_dir);
% end

% copying T1 files
for i=1:length(subj_names)
    copyfile(['e:\Subjects_MRI_data\7T\New_subjs_prep_2013\T1IMG\' subj_names{i} '\mAnatomical_corrected.nii'], ['e:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\']);
%     copyfile(['C:\Subjects_MRI_data\7T\New_subjs_prep_2013\T1IMG\' subj_names{i} '\wAnatomical_corrected.img'], ['C:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\']);
%     copyfile(['C:\Subjects_MRI_data\7T\New_subjs_prep_2013\T1IMG\' subj_names{i} '\wAnatomical_corrected.hdr'], ['C:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\']);
end

