% high_res_scans={[18,2] [18,4] [18,5] [19,2] [19,4] [20,2] [20,4] [21,2] [21,4] [22,2] [22,4] [23,2] [23,4]};

% SPM_analysis_dir = 'F:\Subjects_MRI_data\7T\Analysis\';
% subjects_dicom_dir = 'C:\Michael\Subjects_MRI_data\7T\Data\Distance_2012\Dicom\';
% subjects_output_dir = 'C:\Michael\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subjects_dicom_dir = 'C:\Michael\Subjects_MRI_data\7T\Data\Dicom\';
subjects_output_dir = 'F:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');
% subject_names=dir(subjects_dicom_dir); subject_names=subject_names(3:end);
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end);




%% FMR PROCESSING

% creating FMR project from each session
disp('Creating FMR files')
for s=1:length(subject_names)
    disp(s);
    subj=subject_names(s).name;
    dicom_dir=fullfile(subjects_dicom_dir, subj);
    output_dir=fullfile(subjects_output_dir, subj);
%     mkdir(output_dir);
    
    % find functional sessions of resting state (120 TRs)
    allfiles=dir(fullfile(dicom_dir,'*.dcm'));
    sessions_first_files={};
    for i=1:length(allfiles)
        if strcmp(allfiles(i).name(end-8:end-4),'00120')
            current_file_info = dicominfo(fullfile(dicom_dir,allfiles(i).name));
            if ~isempty(strfind(current_file_info.SeriesDescription,'rest')) || ~isempty(strfind(current_file_info.SeriesDescription,'Rest'))
                a = allfiles(i).name; a(end-13:end-4)='0001-00001';
                sessions_first_files{end+1} = a;
            end
        end
    end
    
    for i=1:length(sessions_first_files)
        fileType = 'DICOM';
        firstFile = fullfile(dicom_dir, sessions_first_files{i});
        nrOfVols = 120;
        skipVols = 0;
        createAMR = true;
        bytesperpixel = 2;
        targetfolder = output_dir;
        nrVolsInImg = 1;
        byteswap = false;
        
        % checking if high-resolution (0.7mm) or not
        dicom_header=dicominfo(firstFile);
        if isempty(strfind(dicom_header.SeriesDescription,'highres'))
            dicom_header=dicominfo(firstFile);
            nrSlices = 45;
            mosaicSizeX = 868;
            mosaicSizeY = 868;
            sizeX = 124;
            sizeY = 124;
            stcprefix = [subj '_rest'];
            fmr_output_filename = fullfile(output_dir,[subj '_rest.fmr']);
        else
            nrSlices = 36;
            mosaicSizeX = 1536;
            mosaicSizeY = 1536;
            sizeX = 256;
            sizeY = 256;
            stcprefix = [subj '_rest_highres'];
            fmr_output_filename = fullfile(output_dir,[subj '_rest_highres.fmr']);            
        end

        fmr = bvqx.CreateProjectMosaicFMR(fileType, firstFile,...
            nrOfVols, skipVols, createAMR, nrSlices,...
            stcprefix, byteswap, mosaicSizeX, mosaicSizeY, bytesperpixel,...
            targetfolder, nrVolsInImg, sizeX, sizeY);
        
        fmr.SaveAs(fmr_output_filename);
    end
end



% FMR motion correction
disp('FMR motion correction')
for s=1:length(subject_names)
    disp(s);
    subj=subject_names(s).name;
    output_dir=fullfile(subjects_output_dir, subj);
    
    % finding relevant fmr files
    fmr_files=getfullfiles(fullfile(output_dir,'*rest*.fmr'));
    ix=1:length(fmr_files);
    for i=1:length(ix)
        if strcmp(fmr_files{i}(end-11:end-4),'firstvol')
            ix(ix==i)=[];
        end
    end
    fmr_files=fmr_files(ix);
    
    % first run    
    TargetVolume = 1;           % the number of volume in the series to align to
    Interpolation_type = 2;     % 0 and 1 - trilinear detection and trilinear interpolation, 2: trilinear detection and sinc interpolation or 3: sinc detection of motion and sinc interpolation
    UseFullDataSet = false;     % false is the default in the GUI
    MaxNumIterations = 100;     % 100 is the default in the GUI
    GenerateMovie = true;
    GenerateLogFile = true;     % creates a log file with the movement parameters
    
%     fmr = bvqx.OpenDocument(fmr_files{1});
%     fmr.CorrectMotionEx(TargetVolume, Interpolation_type, UseFullDataSet,...
%         MaxNumIterations, GenerateMovie, GenerateLogFile);    
% %     fmr.Remove; % close or remove input FMR
%     delete(fmr_files{1}); % delete original files without deleting firstvol_as_anat
%     delete([fmr_files{1}(1:end-3) 'stc']); 
%     
%     % FMR motion correction of next runs to first run
%     fmr_target = [fmr_files{1}(1:end-4) '_3DMCTS.fmr'];
%     for i=2:length(fmr_files)
%         fmrnew = bvqx.OpenDocument(fmr_files{i});
%         fmrnew.CorrectMotionTargetVolumeInOtherRunEx(fmr_target, TargetVolume, Interpolation_type, UseFullDataSet,...
%             MaxNumIterations, GenerateMovie, GenerateLogFile);
% %         fmrnew.Remove; % close or remove input FMR
%         delete(fmr_files{i}); % delete original files without deleting firstvol_as_anat
%         delete([fmr_files{i}(1:end-3) 'stc']);
%     end

    for i=1:length(fmr_files)
        fmr = bvqx.OpenDocument(fmr_files{i});
        fmr.CorrectMotionEx(TargetVolume, Interpolation_type, UseFullDataSet,...
            MaxNumIterations, GenerateMovie, GenerateLogFile);    
%       fmr.Remove; % close or remove input FMR
        delete(fmr_files{i}); % delete original files without deleting firstvol_as_anat
        delete([fmr_files{i}(1:end-3) 'stc']); 
    end

end



% High pass filtering
disp('High pass filtering')
for s=1:length(subject_names)
    disp(s);
    subj=subject_names(s).name;
    output_dir=fullfile(subjects_output_dir, subj);
    
    % finding relevant fmr files
    fmr_files=getfullfiles(fullfile(output_dir,'*rest*_3DMCTS.fmr'));
    
    for i=1:length(fmr_files)
        fmr = bvqx.OpenDocument(fmr_files{i});
        Cutoff = 0.005; Cutoff_type = 'Hz';
        fmr.TemporalHighPassFilter(Cutoff, Cutoff_type);
        fmr.Remove; % close or remove input FMR
    end
end





%% MANUAL STAGES
%
% FOR EACH SUBJECT:  COREGISTER




%% VTC PROCESSING

% % Creating VTC files
% disp('Creating VTC files')
% for s=1:length(subject_names)
%     subj=subject_names(s).name;
%     disp(subj);
%     output_dir=fullfile(subjects_output_dir, subj);
%     
%     fmr_files = getfullfiles(fullfile(output_dir,'*rest*_THP0.00Hz.fmr'));
%     IA_files = getfullfiles(fullfile(output_dir,'*rest*ISO*IA.trf'));
%     FA_files = getfullfiles(fullfile(output_dir,'*rest*ISO*FA.trf'));
%     
%     for i=1:length(IA_files)
%         fmr_filename = fmr_files{i}; IA_filename=IA_files{i}; FA_filename=FA_files{i};
%         Datatype = 2;       % 1 - integer, 2 - float (GUI default)
%         Interpolation = 1;    % 0 for nearest neighbor , 1 for trilinear (GUI default) , 2 for sinc interpolation
%         Intensity_threshold = 100;    % intensity threshold for voxels
%         
%         if isempty(strfind(fmr_filename,'highres'))
%             VTC_name = fullfile(output_dir, [subj '_rest.vtc']);
%             vmr_filename=getfullfiles(fullfile(output_dir, '*_ISO.vmr')); 
%             Resolution = 2;     % resolution relative to VMR - 2x2x2 - resulting in 1.7x1.7x1.7 voxels
%         else
%             VTC_name = fullfile(output_dir, [subj '_rest_highres.vtc']);
%             vmr_filename=getfullfiles(fullfile(output_dir, '*_ISO_075.vmr')); 
%             Resolution = 1;     % resolution relative to VMR - 1x1x1 - resulting in 0.75x0.75x0.75 voxels
%         end
%         
%         vmr = bvqx.OpenDocument(vmr_filename{1});
%         vmr.CreateVTCInVMRSpace(fmr_filename, IA_filename, FA_filename,...
%             VTC_name, Datatype, Resolution, Interpolation, Intensity_threshold);
%     end
% end



%% VTC PROCESSING - ACPC

% Creating VTC files
disp('Creating VTC files')
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC\'];

    fmr_files = getfullfiles(fullfile(output_dir,'*rest*_THP0.00Hz.fmr'));
    IA_files = getfullfiles(fullfile(output_dir,'*rest*ISO*IA.trf'));
    FA_files = getfullfiles(fullfile(output_dir,'*rest*ISO*FA.trf'));
    
    for i=1:length(IA_files)
        fmr_filename = fmr_files{i}; IA_filename=IA_files{i}; FA_filename=FA_files{i};
        Datatype = 2;       % 1 - integer, 2 - float (GUI default)
        Interpolation = 1;    % 0 for nearest neighbor , 1 for trilinear (GUI default) , 2 for sinc interpolation
        Intensity_threshold = 100;    % intensity threshold for voxels
        
        % checking if this session is a high-res scan
        if isempty(strfind(fmr_filename,'highres'))
            VTC_name = fullfile(ACPC_output_dir, [subj '_ACPC_rest.vtc']);
            vmr_filename=getfullfiles(fullfile(output_dir, '*_ISO.vmr')); 
            ACPC_transform_file=getfullfiles(fullfile(ACPC_output_dir,'*ISO_ACPC.trf'));
            Resolution = 2;     % resolution relative to VMR - 2x2x2 - resulting in 1.7x1.7x1.7 voxels
        else
            VTC_name = fullfile(ACPC_output_dir, [subj '_ACPC_rest_highres.vtc']);
            vmr_filename=getfullfiles(fullfile(output_dir, '*_ISO_075.vmr')); 
            ACPC_transform_file=getfullfiles(fullfile(ACPC_output_dir,'*ISO_075_ACPC.trf'));
            Resolution = 1;     % resolution relative to VMR - 1x1x1 - resulting in 0.75x0.75x0.75 voxels
        end
        
        vmr = bvqx.OpenDocument(vmr_filename{1});
        vmr.CreateVTCInACPCSpace(fmr_filename, IA_filename, FA_filename, ACPC_transform_file{1},...
            VTC_name, Datatype, Resolution, Interpolation, Intensity_threshold);
    end
end


% check motion
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    
    motion_sdm_files=getfullfiles(fullfile(output_dir,'*rest_3DMC.sdm'));
    motion_sdm = xff(motion_sdm_files{1});
    disp(max(motion_sdm.SDMMatrix(:)));
%     if ~isempty(find(motion_sdm.SDMMatrix>1.7,1))
%         disp(['subject ' subj ' has max motion of ' num2str(max(motion_sdm.SDMMatrix(:))) ', which is more than 1.7mm']);
%     end
end

