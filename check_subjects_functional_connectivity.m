% This is a temporary file, which calculates functional connectivity of AAL
% regions (each region is used as a seed and a resulting connectivity map
% is created)
% Uses data from our control subjects



% func_dir='F:\Patients\descending_33_slices\FunRawARWSFC\';
% ROISignals_dir='C:\Users\Michael\Dropbox\Network_scripts\Data_new\Raw_data\';
% output_file='c:\temp\aaa\original_';
func_dir='C:\Michael\Patients\Preprocessing\TGA_patients_from_article\descending_33_slices\FunRawARWFC\';
ROISignals_dir='C:\Michael\Patients\Preprocessing\TGA_patients_from_article\Results\';
output_file='c:\temp\FC\original_';

controls_list={'2013-03-29_KATZ_DANIEL','2013-03-29_KATZ_ERNESTINA','2013-04-26_GOLDBERG_RENEE','2013-04-26_GOLDBERG_SIMON','2013-04-26_MAYER_SOMER_TIVONA','2013-05-24_KELPER_HAIM','2013-05-24_LACHMAN_RAN','2013-05-24_SHANI_AVRAHAM','2013-06-14_ATIDIEA_JUDITH','2013-06-14_GROSSMAN_LIOR','2013-06-14_RAHAT_EHUD','2013-06-14_RUMBAK_TALI','2013-06-14_ZLOTKIN_GILAD','2013-06-14_ZLOTKIN_TAMAR'};
controls_ROISignals={'ROISignals_control_KA_DA_2013-03-29','ROISignals_control_KA_ER_2013-03-29','ROISignals_control_GO_RE_2013-04-26','ROISignals_control_GO_SI_2013-04-26','ROISignals_control_MA_TI_2013-04-26','ROISignals_control_KE_HA_2013-05-24','ROISignals_control_LA_RA_2013-05-24','ROISignals_control_SH_AV_2013-05-24','ROISignals_control_AT_JU_2013-06-14','ROISignals_control_GR_LI_2013-06-14','ROISignals_control_RA_EH_2013-06-14','ROISignals_control_RU_TA_2013-06-14','ROISignals_control_ZLO_GI_2013-06-14','ROISignals_control_ZLO_TA_2013-06-14'};

tmp_dir=dir([func_dir controls_list{1}]); 
output_image_space=[func_dir controls_list{1} '\' tmp_dir(3).name ',1'];

all_FC_PCC = zeros(61,73,61); all_FC_hip = zeros(61,73,61); all_FC_SMG = zeros(61,73,61); all_FC_AG = zeros(61,73,61);

for r=1:length(controls_list)
    disp(controls_list{r})
    func_matrix=get_func_matrix([func_dir controls_list{r}]);
    load([ROISignals_dir controls_ROISignals{r} '.mat']);
    
    save_FC_image_from_mat(func_matrix, ROISignals(:,35), [output_file controls_list{r} '_PCC_con_left.nii'], output_image_space);
    save_FC_image_from_mat(func_matrix, ROISignals(:,36), [output_file controls_list{r} '_PCC_con_right.nii'], output_image_space);
    save_FC_image_from_mat(func_matrix, ROISignals(:,37), [output_file controls_list{r} '_hip_con_left.nii'], output_image_space);
    save_FC_image_from_mat(func_matrix, ROISignals(:,38), [output_file controls_list{r} '_hip_con_right.nii'], output_image_space);
    save_FC_image_from_mat(func_matrix, ROISignals(:,63), [output_file controls_list{r} '_SMG_con_left.nii'], output_image_space);
    save_FC_image_from_mat(func_matrix, ROISignals(:,64), [output_file controls_list{r} '_SMG_con_right.nii'], output_image_space);
    save_FC_image_from_mat(func_matrix, ROISignals(:,65), [output_file controls_list{r} '_AG_con_left.nii'], output_image_space);
    save_FC_image_from_mat(func_matrix, ROISignals(:,66), [output_file controls_list{r} '_AG_con_right.nii'], output_image_space);


    save_FC_image_from_mat(func_matrix, mean(ROISignals(:,35:36),2), [output_file controls_list{r} '_PCC_con_bilat.nii'], output_image_space);
    save_FC_image_from_mat(func_matrix, mean(ROISignals(:,37:38),2), [output_file controls_list{r} '_hip_con_bilat.nii'], output_image_space);
    save_FC_image_from_mat(func_matrix, mean(ROISignals(:,63:64),2), [output_file controls_list{r} '_SMG_con_bilat.nii'], output_image_space);
    save_FC_image_from_mat(func_matrix, mean(ROISignals(:,65:66),2), [output_file controls_list{r} '_AG_con_bilat.nii'], output_image_space);
    
    all_FC_PCC = all_FC_PCC + get_FC_from_func_mat(func_matrix, mean(ROISignals(:,35:36),2));
    all_FC_hip = all_FC_hip + get_FC_from_func_mat(func_matrix, mean(ROISignals(:,37:38),2));    
    all_FC_SMG = all_FC_SMG + get_FC_from_func_mat(func_matrix, mean(ROISignals(:,63:64),2));
    all_FC_AG = all_FC_AG + get_FC_from_func_mat(func_matrix, mean(ROISignals(:,65:66),2));
end

all_FC_PCC = all_FC_PCC./length(controls_list); all_FC_hip = all_FC_hip./length(controls_list); 
all_FC_SMG = all_FC_SMG./length(controls_list); all_FC_AG = all_FC_AG./length(controls_list); 
save_mat_to_nifti(output_image_space, all_FC_PCC, [output_file controls_list{1} '_all_subjects_PCC_con.nii']);
save_mat_to_nifti(output_image_space, all_FC_hip, [output_file controls_list{1} '_all_subjects_hip_con.nii']);
save_mat_to_nifti(output_image_space, all_FC_SMG, [output_file controls_list{1} '_all_subjects_SMG_con.nii']);
save_mat_to_nifti(output_image_space, all_FC_AG, [output_file controls_list{1} '_all_subjects_AG_con.nii']);

%     hip_left=ROISignals(:,37);
%     hip_right=ROISignals(:,38);
%     s=size(ff);
%     ff_left=zeros(s(1:3)); ff_right=zeros(s(1:3));
%     for i=1:s(1)
%         if mod(i,20)==0
%             disp(i)
%         end
%         for j=1:s(2)
%             for q=1:s(3)
%                 c_left=corrcoef(hip_left,squeeze(ff(i,j,q,:)));
%                 c_right=corrcoef(hip_right,squeeze(ff(i,j,q,:)));
%                 ff_left(i,j,q)=c_left(2);
%                 ff_right(i,j,q)=c_right(2);
%             end
%         end
%     end
% %     save_mat_to_nifti('E:\Michael_scripts\subfunctions\AAL_resliced_61x73x61_v2_michael.nii',ff_left,[output_file controls_list{r} '_hip_con_left.nii']);
% %     save_mat_to_nifti('E:\Michael_scripts\subfunctions\AAL_resliced_61x73x61_v2_michael.nii',ff_right,[output_file controls_list{r} '_hip_con_right.nii']);
%     save_mat_to_nifti('c:\michael\Michael_scripts\subfunctions\AAL_resliced_61x73x61_v2_michael.nii',ff_left,[output_file controls_list{r} '_hip_con_left.nii']);
%     save_mat_to_nifti('c:\michael\Michael_scripts\subfunctions\AAL_resliced_61x73x61_v2_michael.nii',ff_right,[output_file controls_list{r} '_hip_con_right.nii']);
end
