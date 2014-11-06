subjects_output_dir = 'E:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end-6);

num_subjects_to_use = 16;   % excluding the high-res subjects

all_corr = nan(3,3,num_subjects_to_use);

for s=1:num_subjects_to_use
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC\'];
    
    pcn_pe_filename = [ACPC_output_dir subj '_ALL_PCN_pe_vs_others_and_rest.rtc'];
    pcn_pl_filename = [ACPC_output_dir subj '_ALL_PCN_pl_vs_others_and_rest.rtc'];
    pcn_ti_filename = [ACPC_output_dir subj '_ALL_PCN_ti_vs_others_and_rest.rtc'];
    par_pe_filename = [ACPC_output_dir subj '_ALL_PAR_pe_vs_others_and_rest.rtc'];
    par_pl_filename = [ACPC_output_dir subj '_ALL_PAR_pl_vs_others_and_rest.rtc'];
    par_ti_filename = [ACPC_output_dir subj '_ALL_PAR_ti_vs_others_and_rest.rtc'];
    
    if exist(pcn_pe_filename,'file'), pcn_pe = xff(pcn_pe_filename); pcn_pe = pcn_pe.RTCMatrix; else pcn_pe = nan(120,1); end
    if exist(pcn_pl_filename,'file'), pcn_pl = xff(pcn_pl_filename); pcn_pl = pcn_pl.RTCMatrix; else pcn_pl = nan(120,1); end
    if exist(pcn_ti_filename,'file'), pcn_ti = xff(pcn_ti_filename); pcn_ti = pcn_ti.RTCMatrix; else pcn_ti = nan(120,1); end
    if exist(par_pe_filename,'file'), par_pe = xff(par_pe_filename); par_pe = par_pe.RTCMatrix; else par_pe = nan(120,1); end
    if exist(par_pl_filename,'file'), par_pl = xff(par_pl_filename); par_pl = par_pl.RTCMatrix; else par_pl = nan(120,1); end
    if exist(par_ti_filename,'file'), par_ti = xff(par_ti_filename); par_ti = par_ti.RTCMatrix; else par_ti = nan(120,1); end
    
    pcn=[pcn_pe pcn_pl pcn_ti]; par=[par_pe par_pl par_ti];
    
    all_corr(:,:,s) = corr(pcn,par);
end
