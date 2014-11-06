subj_names={};
subj_paradigm_files={};
ignore_sessions={};

i=1; subj_names{i}='121119_Chrystany'; subj_paradigm_files{i}={'121119094929','121119095640','121119100518','121119102208','121119103146','121119104636'}; ignore_sessions{i}=[];
i=2; subj_names{i}='121119_Sergey'; subj_paradigm_files{i}={'121119115256','121119121016','121119121808','121119122709','121119124246','121119125056'}; ignore_sessions{i}=[1];
i=3; subj_names{i}='121123_alex'; subj_paradigm_files{i}={'121123124913','121123125631','121123130508','121123131956','121123132814','121123133832'}; ignore_sessions{i}=[];
i=4; subj_names{i}='121126_achilleas'; subj_paradigm_files{i}={'121126092118','121126092826','121126093537','121126095317','121126100029','121126101022'}; ignore_sessions{i}=[];
i=5; subj_names{i}='121126_dorian'; subj_paradigm_files{i}={'121126104133','121126105041','121126105806','121126111335','121126112141','121126113159'}; ignore_sessions{i}=[];
i=6; subj_names{i}='121126_wietske'; subj_paradigm_files{i}={'121126121545','121126122336','121126123052','121126124620','121126125439','121126130421'}; ignore_sessions{i}=[];
i=7; subj_names{i}='121126_george'; subj_paradigm_files{i}={'121126133344','121126134133','121126134858','121126140501','121126141417','121126142440'}; ignore_sessions{i}=[];
i=8; subj_names{i}='121127_Killroi'; subj_paradigm_files{i}={'121127091407','121127092148','121127092900','121127094638','121127095444','121127100558'}; ignore_sessions{i}=[];
i=9; subj_names{i}='121129_Thibault'; subj_paradigm_files{i}={'121129091550','121129092323','121129093028','121129094540','121129095352','121129100346'}; ignore_sessions{i}=[];
i=10; subj_names{i}='121129_Jeane'; subj_paradigm_files{i}={'121129103457','121129104305','121129105015','121129110554','121129111419','121129112408'}; ignore_sessions{i}=[];

% make paradigm files in ExpyVR log directory
for i=1:length(subj_paradigm_files)
    create_block_designs_multiple_files(subj_paradigm_files{i}, {0,0,0,0,0,0}, 2.5, 10, 15, 0, 0);
end

% including distances
for i=1:length(subj_paradigm_files)
    output_dir=['C:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\GLM_with_distances'];
    create_paradigm_7T('C:\Subjects_MRI_data\7T\New_subjs_prep_2012\FunRawRS', subj_names{i}, subj_paradigm_files{i}, 1, [ignore_sessions{i}], 1, 0, output_dir);
end

% domains_only - non-normalized data (smoothed by 2mm)
for i=1:length(subj_paradigm_files)
    output_dir=['C:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\GLM_domains_only'];
    mkdir(output_dir);
    create_paradigm_7T_domains_only('C:\Subjects_MRI_data\7T\New_subjs_prep_2012\FunRawRS', subj_names{i}, subj_paradigm_files{i}, 1, [ignore_sessions{i}], 1, 0, output_dir);
end

% domains_only - non-smoothed
for i=1:length(subj_paradigm_files)
    output_dir=['e:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\GLM_domains_only_nonsmoothed'];
    mkdir(output_dir);
    create_paradigm_7T_domains_only('e:\Subjects_MRI_data\7T\New_subjs_prep_2012\FunRawR', subj_names{i}, subj_paradigm_files{i}, 1, [ignore_sessions{i}], 1, 0, output_dir);
end

% domains_only - normalized
for i=1:length(subj_paradigm_files)
    output_dir=['C:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\GLM_domains_only_normalized'];
    mkdir(output_dir);
    create_paradigm_7T_domains_only('C:\Subjects_MRI_data\7T\New_subjs_prep_2012\FunRawRWS', subj_names{i}, subj_paradigm_files{i}, 1, [ignore_sessions{i}], 1, 0, output_dir);
end

% copying T1 files
for i=1:length(subj_names)
    copyfile(['C:\Subjects_MRI_data\7T\New_subjs_prep_2012\T1IMG\' subj_names{i} '\Anatomical_corrected.img'], ['C:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\']);
    copyfile(['C:\Subjects_MRI_data\7T\New_subjs_prep_2012\T1IMG\' subj_names{i} '\Anatomical_corrected.hdr'], ['C:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\']);
    copyfile(['C:\Subjects_MRI_data\7T\New_subjs_prep_2012\T1IMG\' subj_names{i} '\wAnatomical_corrected.img'], ['C:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\']);
    copyfile(['C:\Subjects_MRI_data\7T\New_subjs_prep_2012\T1IMG\' subj_names{i} '\wAnatomical_corrected.hdr'], ['C:\Subjects_MRI_data\7T\Analysis\' subj_names{i} '\']);
end
