subj_names={};
subj_paradigm_files={};

i=1; subj_names{i}='120929_gilad_goldberg'; subj_paradigm_files{i}={'120929190625','120929191513','120929192335','120929194148','120929195033','120929195832'}; ignore_sessions{i}=[];
i=2; subj_names{i}='121026_yair_cohen'; subj_paradigm_files{i}={'121026144455','121026145235','121026150016','121026151341','121026152100','121026152814'}; ignore_sessions{i}=[];
i=3; subj_names{i}='121103_noam_grosman'; subj_paradigm_files{i}={'121103201147','121103202012','121103202738','121103204011','121103204734','121103205541'}; ignore_sessions{i}=[];
i=4; subj_names{i}='121109_maayan_gerecht'; subj_paradigm_files{i}={'121109125741','121109130510','121109131231','121109132824','121109133532','121109134309'}; ignore_sessions{i}=[];
i=5; subj_names{i}='121109_aya_porat'; subj_paradigm_files{i}={'121109140817','121109141600','121109142343','121109143946','121109144656','121109145434'}; ignore_sessions{i}=[];

% domains_only
for i=1:length(subj_paradigm_files)
    output_dir=['C:\Subjects_MRI_data\3T\' subj_names{i} '\Analysis\GLM_normalized_domains_only'];
    create_paradigm_7T_domains_only('C:\Subjects_MRI_data\3T\preprocessing_new\FunRawRDWS', subj_names{i}, subj_paradigm_files{i}, 1, [ignore_sessions{i}], 1, 0, output_dir);
end

% including distances
for i=1:length(subj_paradigm_files)
    output_dir=['C:\Subjects_MRI_data\3T\' subj_names{i} '\Analysis\GLM_normalized'];
    create_paradigm_7T('C:\Subjects_MRI_data\3T\preprocessing_new\FunRawRDWS', subj_names{i}, subj_paradigm_files{i}, 1, [ignore_sessions{i}], 1, 0, output_dir);
end
