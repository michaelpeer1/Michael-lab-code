% This is a test for many different preprocessing options, conducted with
% DPARSFA, to measure the pre-processing effect on functional connectivity


aa=dir('C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc'); aa=aa(3:end-1);
for q=1:length(aa)
    if ~exist(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\' aa(q).name '\Results'],'dir')
        disp(aa(q).name)
        currdir=['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\' aa(q).name];
        data={};
        a=dir([currdir '\FunRawARCWSF']);
        if ~isempty(a)
            for i=3:length(a)
                %         disp(a(i).name)
                data{end+1}=cell(1,2);
                data{end}{1}=a(i).name;
                disp([currdir '\T1ImgNewSegment\' a(i).name])
                segmentation_file=dir(fullfile([currdir '\T1ImgNewSegment\' a(i).name], '\wc1*.nii'));
                [areas,timecourse]=get_timecourses_from_parcellation_masked('C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\AAL_61x73x61_YCG.nii',[currdir '\FunRawARCWSF\' a(i).name], fullfile([currdir '\T1ImgNewSegment\' a(i).name],segmentation_file(1).name));
                data{end}{2}=timecourse;
            end
        else
            a=dir([currdir '\FunRawRCWSF']);
            for i=3:length(a)
                %         disp(a(i).name)
                data{end+1}=cell(1,2);
                data{end}{1}=a(i).name;
                disp([currdir '\T1ImgNewSegment\' a(i).name])
                segmentation_file=dir(fullfile([currdir '\T1ImgNewSegment\' a(i).name], '\wc1*.nii'));
                [areas,~,timecourse]=get_timecourses_from_parcellation_masked('C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\AAL_61x73x61_YCG.nii',[currdir '\FunRawRCWSF\' a(i).name], fullfile([currdir '\T1ImgNewSegment\' a(i).name],segmentation_file(1).name));
                data{end}{2}=timecourse;
            end
        end
        
        mkdir([currdir '\Results']);
        for i=1:length(data)
            d=data{i}{2};
            ROISignals=[];
            for j=1:length(d)
                ROISignals=[ROISignals d{j}'];
            end
            savefile=[currdir '\Results\ROISignals_' data{i}{1}];
            save(savefile,'ROISignals');
        end
        
        %[mat_corr, mat_thresholded, mat_thresholded_inc_negative] = adj_mat_builder(data_mat, corr_threshold, timebin_size, jump_size);
        [all_patients_list, mat_corr_all, ~, ~]=new_get_adj_mat_from_AAL_directory([currdir '\results\'], 0.7, 20, 1);
        savefile=[currdir '\Results\adjmat_07_20_1'];
        save(savefile,'all_patients_list', 'mat_corr_all');
        [all_patients_list, mat_corr_all, ~, ~]=new_get_adj_mat_from_AAL_directory([currdir '\results\'], 0.7, 155, 10);
        savefile=[currdir '\Results\adjmat_07_155_full'];
        save(savefile,'all_patients_list', 'mat_corr_all');
    end
end

% make movies
for q=1:length(aa)
    currdir=['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\' aa(q).name '\Results'];
    load([currdir '\adjmat_07_20_1.mat']);
    for i=1:length(mat_corr_all)
        make_movie_from_matrices(mat_corr_all{i}, [currdir '\movie_' all_patients_list{i}]);
    end
end

% plotting the timecourse
namesubjfile='ROISignals_2013-01-22_SALOMON_ORA.mat';
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('6 parameters+CSF removal+0.15 filtering'), colorbar, caxis([-5 5])
%load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Results_scrubbed\' namesubjfile])
%figure;imagesc(ROISignals(:,1:90)'), title('6 parameters+CSF removal+0.15 filtering+scrubbing by interpolation'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\1_derivative12_CSF_0.15\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('12 parameters+CSF removal+0.15 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\2_Friston24_CSF_0.15\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF removal+0.15 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\3_Friston24_CSF_0.08\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF removal+0.08 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\4_Friston_24_spikes_CSF_0.15\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF removal+spike regressors+0.15 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\5_Friston_24_spikes_CSF_0.10\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF removal+spike regressors+0.10 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\6_Friston_24_spikes_CSF_0.08\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF removal+spike regressors+0.08 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\7_Friston_24_spikes_CSF_WM_0.10\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF,WM removal+spike regressors+0.10 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\8_Friston_24_spikes_CSF_GS_0.10\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF,GS removal+spike regressors+0.10 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\9_Friston_24_spikes_CSF_GS_WM_0.10\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF,WM,GS removal+spike regressors+0.10 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\10_Friston_24_spikes_CSF_WM_0.08\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF,WM removal+spike regressors+0.08 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\11_Friston_24_spikes_CSF_GS_0.08\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF,GS removal+spike regressors+0.08 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\12_Friston_24_spikes_CSF_GS_WM_0.08\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF,WM,GS removal+spike regressors+0.08 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\13_6parameters_CSF_WM_0.15\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('6 parameters+CSF,WM removal+0.15 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\14_6parameters_CSF_GS_0.15\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('6 parameters+CSF,GS removal+0.15 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\15_6parameters_CSF_GS_WM_0.15\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('6 parameters+CSF,WM,GS removal+0.15 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\16_Friston_24_spikes11_CSF_GS_WM_0.10\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF,WM,GS removal+spike regressors 1b1f+0.10 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\17_Friston_24_spikes11_CSF_0.10\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF removal+spike regressors 1b1f+0.10 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\18_Friston_24_spikes_CSF_GS_WM_0.15\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF,WM,GS removal+spike regressors+0.15 filtering'), colorbar, caxis([-5 5])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\19_Friston_24_spikes_CSF_GS_WM_0.15_no_slice_timing\Results\' namesubjfile])
figure;imagesc(ROISignals(:,1:90)'), title('24 parameters+CSF,WM,GS removal+spike regressors+0.15 filtering, no slice timing'), colorbar, caxis([-5 5])

% plotting the whole-timeseries FC
subjectnum=1;
patient_list={'2013-01-22_SALOMON_ORA','2013-02-25_YARIV_YUDITH','2013-03-29_KATZ_ERNESTINA','2013_03_02_Shani_Yaacov'};
disp(patient_list{subjectnum})
load(['C:\Michael\Network_scripts\Data_new\smoothing_4\TGA_and_controls_adjmat_07_155_full.mat'])
nums_allpatients=[6 9 14 18];
figure;imagesc(mat_corr_all{nums_allpatients(subjectnum)}{1}), title('6 parameters+CSF removal+0.15 filtering'), colorbar, caxis([-1 1])
% load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Results_scrubbed\adjmat_07_155_full.mat'])
% figure;imagesc(mat_corr_all{subjectnum}{1}), title('6 parameters+CSF removal+0.15 filtering+scrubbing by interpolation'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\1_derivative12_CSF_0.15\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('12 parameters+CSF removal+0.15 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\2_Friston24_CSF_0.15\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF removal+0.15 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\3_Friston24_CSF_0.08\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF removal+0.08 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\4_Friston_24_spikes_CSF_0.15\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF removal+spike regressors+0.15 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\5_Friston_24_spikes_CSF_0.10\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF removal+spike regressors+0.10 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\6_Friston_24_spikes_CSF_0.08\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF removal+spike regressors+0.08 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\7_Friston_24_spikes_CSF_WM_0.10\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF,WM removal+spike regressors+0.10 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\8_Friston_24_spikes_CSF_GS_0.10\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF,GS removal+spike regressors+0.10 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\9_Friston_24_spikes_CSF_GS_WM_0.10\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF,WM,GS removal+spike regressors+0.10 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\10_Friston_24_spikes_CSF_WM_0.08\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF,WM removal+spike regressors+0.08 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\11_Friston_24_spikes_CSF_GS_0.08\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF,GS removal+spike regressors+0.08 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\12_Friston_24_spikes_CSF_GS_WM_0.08\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF,WM,GS removal+spike regressors+0.08 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\13_6parameters_CSF_WM_0.15\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('6 parameters+CSF,WM removal+0.15 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\14_6parameters_CSF_GS_0.15\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('6 parameters+CSF,GS removal+0.15 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\15_6parameters_CSF_GS_WM_0.15\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('6 parameters+CSF,WM,GS removal+0.15 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\16_Friston_24_spikes11_CSF_GS_WM_0.10\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF,WM,GS removal+spike regressors 1b1f+0.10 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\17_Friston_24_spikes11_CSF_0.10\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF removal+spike regressors 1b1f+0.10 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\18_Friston_24_spikes_CSF_GS_WM_0.15\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF,WM,GS removal+spike regressors+0.15 filtering'), colorbar, caxis([-1 1])
load(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Test_preproc\19_Friston_24_spikes_CSF_GS_WM_0.15_no_slice_timing\Results\adjmat_07_155_full.mat'])
figure;imagesc(mat_corr_all{subjectnum}{1}), title('24 parameters+CSF,WM,GS removal+spike regressors+0.15 filtering, no slice timing'), colorbar, caxis([-1 1])

