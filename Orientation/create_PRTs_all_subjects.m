load('C:\ExpyVR\Paradigms\Subjects file 7T.mat')

dirs=dir('E:\Subjects_MRI_data\7T\Analysis'); dirs=dirs(3:end);
for i=1:length(dirs)
    curr_subj_files_temp=subjects(i,3:end); curr_subj_files_temp=curr_subj_files_temp(~cellfun('isempty',curr_subj_files_temp));
    curr_subj_files={}; for j=1:length(curr_subj_files_temp), curr_subj_files{j}=num2str(curr_subj_files_temp{j});end
    times_start_TRs={}; for j=1:length(curr_subj_files), times_start_TRs{j}=0;end
    user_age=subjects{i,2};
    
    % block designs
    disp(i)
    create_block_designs_multiple_files(curr_subj_files, times_start_TRs, 2.5, 10, 15, 0, 0);
    create_paradigm_prt_files(curr_subj_files, fullfile('E:\Subjects_MRI_data\7T\Analysis', dirs(i).name));
    
    % event related design and confounds
    disp(i)
    create_ER_designs_multiple_files(curr_subj_files, times_start_TRs, 2.5, 2.5, 15, 0);
    create_paradigm_ER_prt_files(curr_subj_files, fullfile('E:\Subjects_MRI_data\7T\Analysis', dirs(i).name));
    for j=1:length(curr_subj_files)
        create_ER_design_XLS_w_quest_fields(curr_subj_files(j), times_start_TRs(j), 2.5, 2.5, 15, 0, 0, user_age, fullfile('E:\Subjects_MRI_data\7T\Analysis', dirs(i).name))
    end
end


