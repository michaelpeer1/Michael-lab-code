% This script takes the  VOIs created from the task activations  (in each
% domain), and calculates their functional connectivity in the resting-state
% scan

subjects_output_dir = 'E:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end);

num_subjects_to_use = 16;

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');

% filenames of VOI files to use, if existing
VOI_filenames{1} = '_pe_vs_others_and_rest.voi';
VOI_filenames{2} = '_pl_vs_others_and_rest.voi';
VOI_filenames{3} = '_ti_vs_others_and_rest.voi';
% VOI_filenames{4} = '_pe_vs_control_and_rest.voi';
% VOI_filenames{5} = '_pl_vs_control_and_rest.voi';
% VOI_filenames{6} = '_ti_vs_control_and_rest.voi';

VOI_names = {'ALL_PAR', 'ALL_PCN'}; % names of VOIs to use from the filenames

% creating an empty RTC file, to save later
RTC_xff=xff('new:rtc');
RTC_xff.FileVersion = 2;
RTC_xff.IncludesConstant = 0;
RTC_xff.FirstConfoundPredictor = 2;


for s=1:num_subjects_to_use
    subj = subject_names(s).name;
    disp(subj);
    ACPC_output_dir=[fullfile(subjects_output_dir, subj) '\ACPC'];
    
    % load VTC files, take only the resting-state scan
    vtc_files=getfullfiles(fullfile(ACPC_output_dir,'*.vtc'));
    vtc_files(cellfun(@(x) isempty(strfind(x,'rest')), vtc_files))=[];   % remove rest files, if existing
    vtc = xff(vtc_files{1});
    
    % loading motion-correction SDM file
    output_dir=fullfile(subjects_output_dir, subj);
    motion_sdm_file=getfullfiles(fullfile(output_dir,'*rest_3DMC.sdm'));
    motion_sdm = xff(motion_sdm_file{1});
    
    % loading and opening the VMR file
    vmr_filename=getfullfiles(fullfile(ACPC_output_dir, '*_ISO_ACPC.vmr'));
    vmr = bvqx.OpenDocument(vmr_filename{1});
    
    % getting the WM and CSF timecourses
    WM_CSF_voi = xff(fullfile(ACPC_output_dir, [subj '_WM_CSF.voi']));
    WM_CSF_voitc = vtc.VOITimeCourse(WM_CSF_voi);
    WM_CSF_voitc = ztrans(WM_CSF_voitc);  % z-transform of WM+CSF signals
    
    % saving the WM and CSF timecourse
    RTC_xff.NrOfDataPoints = size(WM_CSF_voitc,1);
    RTC_xff.PredictorNames = {'WM'};
    RTC_xff.SDMMatrix = WM_CSF_voitc(:,1); RTC_xff.RTCMatrix = WM_CSF_voitc(:,1);
    RTC_name = fullfile(ACPC_output_dir,[subj '_WM.rtc']); RTC_xff.SaveAs(RTC_name);
    RTC_xff.PredictorNames = {'CSF'};
    RTC_xff.SDMMatrix = WM_CSF_voitc(:,2); RTC_xff.RTCMatrix = WM_CSF_voitc(:,2);
    RTC_name = fullfile(ACPC_output_dir,[subj '_CSF.rtc']); RTC_xff.SaveAs(RTC_name);
        
    for i=1:length(VOI_filenames)
        voi_current = fullfile(ACPC_output_dir,[subj VOI_filenames{i}]);
        if exist(voi_current, 'file')
            % reading the VOI and getting its timecourse
            voi = xff(voi_current);
            voitc = vtc.VOITimeCourse(voi);
            
            % Saving the timecourse
            for j=1:length(VOI_names)
                for v=1:length(voi.VOI)
                    % finding the relevant VOI in the list
                    len_comparison = min([length(voi.VOI(v).Name), length(VOI_names{j})]);
                    if strcmp(voi.VOI(v).Name(1:len_comparison), VOI_names{j}(1:len_comparison))
                        
                        % saving the relevant timecourse in an RTC file, after z-transformation
                        RTC_xff.PredictorNames = {VOI_names{j}};
                        RTC_xff.NrOfDataPoints = size(voitc,1);
                        tc_ztrans = ztrans(voitc(:,v)); % z-transform timecourse
                        RTC_xff.SDMMatrix = tc_ztrans; RTC_xff.RTCMatrix = tc_ztrans;
                        RTC_name = fullfile(ACPC_output_dir,[subj '_' VOI_names{j} VOI_filenames{i}(1:end-4) '.rtc']);
                        RTC_xff.SaveAs(RTC_name);
                        
                        % making a new SDM file
                        sdm=xff('new:sdm');
                        sdm.NrOfDataPoints = size(voitc,1);
                        sdm.NrOfPredictors = 10;     % timecourse, motion predictors, WM + CSF signals, and constant
                        sdm.IncludesConstant = 1;
                        sdm.FirstConfoundPredictor = 2;
                        sdm.PredictorColors = ones(sdm.NrOfPredictors,3) * 255;
                        
                        % reading motion predictors and creating design matrix
                        sdm.SDMMatrix = [tc_ztrans motion_sdm.SDMMatrix WM_CSF_voitc ones(size(voitc,1), 1)];
                        sdm.RTCMatrix = tc_ztrans;
                        sdm.PredictorNames=['timecourse' motion_sdm.PredictorNames 'WM' 'CSF' 'Constant'];
                        SDM_name = fullfile(ACPC_output_dir,[subj '_' VOI_names{j} VOI_filenames{i}(1:end-4) '.sdm']);
                        sdm.SaveAs(SDM_name);
                        
                        % calculating GLM
                        GLM_name = fullfile(ACPC_output_dir, [subj '_' VOI_names{j} VOI_filenames{i}(1:end-4) '.glm']);
                        vmr.LinkVTC(vtc_files{1});
                        vmr.LoadSingleStudyGLMDesignMatrix(SDM_name);
                        vmr.CorrectForSerialCorrelations = 1;
                        vmr.FirstConfoundPredictorOfSDM = 2;
                        vmr.PSCTransformStudies = 0;
                        vmr.ComputeSingleStudyGLM;
                        vmr.SaveGLM(GLM_name);
                        vmr.ClearDesignMatrix;
                    end
                end
            end
        end
    end
    
    vmr.Close;
    vtc.ClearObject;
end


    



