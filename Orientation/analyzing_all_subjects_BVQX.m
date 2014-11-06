% high_res_scans={[18,2] [18,4] [18,5] [19,2] [19,4] [20,2] [20,4] [21,2] [21,4] [22,2] [22,4] [23,2] [23,4]};

% SPM_analysis_dir = 'F:\Subjects_MRI_data\7T\Analysis\';
% subjects_dicom_dir = 'C:\Michael\Subjects_MRI_data\7T\Data\Distance_2012\Dicom\';
% subjects_output_dir = 'C:\Michael\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subjects_dicom_dir = 'C:\Michael\Subjects_MRI_data\7T\Data\Dicom\';
subjects_output_dir = 'F:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
% subject_names=dir(subjects_dicom_dir); subject_names=subject_names(3:end);
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end);

bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');



% renaming DICOM files
disp('Renaming DICOM files')
for s=1:length(subject_names)
    subj=subject_names(s).name;
    dicom_dir=fullfile(subjects_dicom_dir, subj);
    bvqx.RenameDicomFilesInDirectory(dicom_dir);
end


%% FMR PROCESSING

% creating FMR project from each session
disp('Creating FMR files')
for s=1:length(subject_names)
    disp(s);
    subj=subject_names(s).name;
    dicom_dir=fullfile(subjects_dicom_dir, subj);
    output_dir=fullfile(subjects_output_dir, subj);
    mkdir(output_dir);
    
    % find functional sessions
    allfiles=dir(fullfile(dicom_dir,'*.dcm'));
    sessions_first_files={};
    for i=1:length(allfiles)
        if strcmp(allfiles(i).name(end-8:end-4),'00160')
            if i==length(allfiles)
                a = allfiles(i).name; a(end-13:end-4)='0001-00001';
                sessions_first_files{end+1} = a;
            elseif strcmp(allfiles(i+1).name(end-8:end-4),'00001')  % checking that it ends in 160 - longer sessions are T1
                a = allfiles(i).name; a(end-13:end-4)='0001-00001';
                sessions_first_files{end+1} = a;
            end
        end
    end
    
    for i=1:length(sessions_first_files)
        fileType = 'DICOM';
        firstFile = fullfile(dicom_dir, sessions_first_files{i});
        nrOfVols = 160;
        skipVols = 0;
        createAMR = true;
        bytesperpixel = 2;
        targetfolder = output_dir;
        nrVolsInImg = 1;
        byteswap = false;
        
        % checking if high-resolution (0.7mm) or not
        dicom_header=dicominfo(firstFile);
        if isempty(strfind(dicom_header.SeriesDescription,'highres'))
            nrSlices = 45;
            mosaicSizeX = 868;
            mosaicSizeY = 868;
            sizeX = 124;
            sizeY = 124;
            stcprefix = [subj '_' num2str(i)];
            fmr_output_filename = fullfile(output_dir,[subj '_' num2str(i) '.fmr']);
        else
            nrSlices = 36;
            mosaicSizeX = 1536;
            mosaicSizeY = 1536;
            sizeX = 256;
            sizeY = 256;
            stcprefix = [subj '_' num2str(i) '_highres'];
            fmr_output_filename = fullfile(output_dir,[subj '_' num2str(i) '_highres.fmr']);            
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
    fmr_files=getfullfiles(fullfile(output_dir,'*.fmr'));
    ix=1:length(fmr_files);
    for i=1:length(ix)
        if strcmp(fmr_files{i}(end-11:end-4),'firstvol')
            ix(ix==i)=[];
        end
    end
    fmr_files=fmr_files(ix);
    fmr_files(cellfun(@(x) ~isempty(strfind(x,'rest')), fmr_files))=[]; % remove rest files, if existing
    
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
    fmr_files=getfullfiles(fullfile(output_dir,'*_3DMCTS.fmr'));
    fmr_files(cellfun(@(x) ~isempty(strfind(x,'rest')), fmr_files))=[]; % remove rest files, if existing

    for i=1:length(fmr_files)
        fmr = bvqx.OpenDocument(fmr_files{i});
        NumCycles = 2;
        fmr.TemporalHighPassFilterGLMFourier(NumCycles);
        fmr.Remove; % close or remove input FMR
    end
end


%% VMR PROCESSING

% % copying VMR files from SPM analysis
% disp('Copying VMR files from SPM analysis')
% for s=1:length(subject_names)
%     subj=subject_names(s).name;
%     output_dir=fullfile(subjects_output_dir, subj);
%     SPM_dir = fullfile(SPM_analysis_dir, subj);
%     a=getfullfiles(fullfile(SPM_dir, '*.vmr')); copyfile(a{1},[output_dir '\']);
%     a=getfullfiles(fullfile(SPM_dir, '*.v16')); copyfile(a{1},[output_dir '\']);
% end

% combination of UNI+INV files, for the first ten subjects
disp('Combining UNI+INV files')
for s=1:10
    disp(s);
    subj=subject_names(s).name;
    output_dir=fullfile(subjects_output_dir, subj);
    dicom_dir=fullfile(subjects_dicom_dir, subj);
    
    allfiles=getfullfiles(fullfile(dicom_dir,'*.dcm'));
    iso=zeros(256,240,176);     % empty matrix for INV2 file
    uni=zeros(256,240,176);     % empty matrix for UNI file
    uni_header='mp2rage_UNI_Images';
    inv2_header='mp2rage_INV2';
    %cc='mp2rage_T1_Images' %some new sequences use this in the header
    
    % getting the INV2 and UNI files and putting them in the matrices
    for i=1:length(allfiles)
        info = dicominfo(allfiles{i}); 
        series_desc=info.SeriesDescription;
        if strcmp(series_desc,uni_header)   % UNI file
            header=info;
            num=info.InstanceNumber;
            X = dicomread(allfiles{i});
            uni(:,:,num)=X; 
        elseif strcmp(series_desc,inv2_header)  % INV2 file
            num=info.InstanceNumber;
            X = dicomread(allfiles{i});
            iso(:,:,num)=X;
        end
    end
    new=uni.*(iso>300);	% create the combined file
    
    % saving the new files
    header.SeriesDescription = 'mp2rage_UNI-DEN';   % this is to recognize the files in the VMR creation stage
    for ll=1:176  
        y=uint16(new(:,:,ll));
        header.InstanceNumber=ll;
        filename=header.Filename(1:end-19);
        newfilename=([filename 'NewVmr_' num2str(ll) '.dcm']);
        dicomwrite(y, newfilename, header);
    end
end



% Creating VMR files from DICOM files
disp('Creating VMR files')
for s=1:length(subject_names)
    disp(s);
    subj=subject_names(s).name;
    dicom_dir=fullfile(subjects_dicom_dir, subj);
    output_dir=fullfile(subjects_output_dir, subj);
    
    % searching for first antomical file
    allfiles=getfullfiles(fullfile(dicom_dir,'*.dcm'));
    i=1; stop_run=0; numfiles=length(allfiles);
    while i<numfiles && stop_run==0
        info = dicominfo(allfiles{i});
        if strcmp(info.SeriesDescription, 'mp2rage_UNI-DEN')
            if info.InstanceNumber==1
                first_anatomical_filename = allfiles{i};
                stop_run=1;
            end
        end
        i=i+1;
    end
    
    % creating the VMR
    filetype = 'DICOM';
    xres=240;
    yres=256;
    nrslices=176;
    swap=0;
    bytesperpixel=2;
    vmrproject = bvqx.CreateProjectVMR(filetype, first_anatomical_filename, nrslices, swap, xres, yres, bytesperpixel);
    vmrproject.SaveAs(fullfile(output_dir,[subj '.vmr']));
end




%% MANUAL STAGES
%
% FOR EACH SUBJECT:
%
% 1. CORRECT INHOMOGENEITY (+SKULL STRIP) FROM THE VOLUMES MENU - DEFAULT
% PARAMETERS
%
% 2. CHANGE VMR VOXELS TO 0.85X0.85X0.85 MANUALLY (3D tools -> spatial 
% transf -> iso-voxel) AND SAVE IN _ISO.VMR FILENAME
%
% 3. IF THIS SUBJECT HAS HIGH-RES SCANS, ISO-VOXELATE ALSO TO 0.75X0.75X0.75
% AND SAVE IN _ISO_075.VMR FILENAME
%
% 4. COREGISTER



% (Wietske - need to manually correct the mp2rage using SPM and then
% transform to correct orientation by "to sag" function)
% (Aya + Rebecca - need to play with brightness to correct the
% inhomogeneity correctly)



%% VTC PROCESSING - native space

% % Creating a VTC file
% disp('Creating VTC files')
% for s=1:length(subject_names)
%     subj=subject_names(s).name;
%     disp(subj);
%     output_dir=fullfile(subjects_output_dir, subj);
%     
%     fmr_files=getfullfiles(fullfile(output_dir,'*_THPGLMF2c.fmr'));
%     IA_files = getfullfiles(fullfile(output_dir,'*ISO*IA.trf'));
%     FA_files = getfullfiles(fullfile(output_dir,'*ISO*FA.trf'));
%     
%     % remove rest files, if existing
%     fmr_files(cellfun(@(x) ~isempty(strfind(x,'rest')), fmr_files))=[]; 
%     IA_files(cellfun(@(x) ~isempty(strfind(x,'rest')), IA_files))=[]; 
%     FA_files(cellfun(@(x) ~isempty(strfind(x,'rest')), FA_files))=[]; 
% 
%     for i=1:length(fmr_files)
%         fmr_filename = fmr_files{i}; IA_filename=IA_files{i}; FA_filename=FA_files{i};
%         Datatype = 2;       % 1 - integer, 2 - float (GUI default)
%         Interpolation = 1;    % 0 for nearest neighbor , 1 for trilinear (GUI default) , 2 for sinc interpolation
%         Intensity_threshold = 100;    % intensity threshold for voxels
%         
%         % checking if this session is a high-res scan
%         if isempty(strfind(fmr_filename,'highres'))
%             VTC_name = fullfile(output_dir, [subj '_' num2str(i) '.vtc']);
%             vmr_filename=getfullfiles(fullfile(output_dir, '*_ISO.vmr')); 
%             Resolution = 2;     % resolution relative to VMR - 2x2x2 - resulting in 1.7x1.7x1.7 voxels
%         else
%             VTC_name = fullfile(output_dir, [subj '_' num2str(i) '_highres.vtc']);
%             vmr_filename=getfullfiles(fullfile(output_dir, '*_ISO_075.vmr')); 
%             Resolution = 1;     % resolution relative to VMR - 1x1x1 - resulting in 0.75x0.75x0.75 voxels
%         end
%         
%         vmr = bvqx.OpenDocument(vmr_filename{1});
%         vmr.CreateVTCInVMRSpace(fmr_filename, IA_filename, FA_filename,...
%             VTC_name, Datatype, Resolution, Interpolation, Intensity_threshold);
%     end
% end
% 
% 
% 
% %% DESIGN MATRICES, GLM, ETC. - native space
% 
% 
% % % copying PRT files from SPM analysis
% % disp('Copying PRT files from SPM analysis')
% % for s=1:length(subject_names)
% %     subj=subject_names(s).name;
% %     output_dir=fullfile(subjects_output_dir, subj);
% %     SPM_dir = fullfile(SPM_analysis_dir, subj);
% %     a=getfullfiles(fullfile(SPM_dir, '*.prt')); 
% %     for i=1:length(a), copyfile(a{i},[output_dir '\']); end
% % end
% 
% 
% 
% % creating design matrices (SDM files and MDM files for multi-run)
% disp('Creating design matrices (.sdm and .mdm files)')
% for s=1:length(subject_names)
%     subj=subject_names(s).name;
%     disp(subj);
%     output_dir=fullfile(subjects_output_dir, subj);
%     
%     vtc_files=getfullfiles(fullfile(output_dir,'*.vtc'));
%     % prt_files=getfullfiles(fullfile(output_dir,'*ER_paradigm_domains_*.prt'));
%     prt_files=getfullfiles(fullfile(output_dir,'paradigm_domains_*.prt'));
%     motion_sdm_files=getfullfiles(fullfile(output_dir,'*3DMC.sdm'));
%     vmr_filename=getfullfiles(fullfile(output_dir, '*_ISO.vmr')); 
%     vmr = bvqx.OpenDocument(vmr_filename{1});
%     
%     % remove rest files, if existing
%     vtc_files(cellfun(@(x) ~isempty(strfind(x,'rest')), vtc_files))=[];
%     motion_sdm_files(cellfun(@(x) ~isempty(strfind(x,'rest')), motion_sdm_files))=[];
%     
%     % create SDM for each session
%     for i=1:length(vtc_files)
%         vtc_filename = vtc_files{i}; prt_filename=prt_files{i};
%         SDM_name = fullfile(output_dir, [subj '_' num2str(i) '.sdm']);
%         vmr.LinkVTC(vtc_filename);
%         vmr.LinkStimulationProtocol(prt_filename);
%         % vmr.SaveVTC();  % save with link to protocol
%         
%         vmr.ClearDesignMatrix;
%         vmr.AddPredictor('pe');
%         vmr.AddPredictor('pl');
%         vmr.AddPredictor('ti');
%         vmr.SetPredictorValuesFromCondition('pe', 'pe', 1.0);
%         vmr.SetPredictorValuesFromCondition('pl', 'pl', 1.0);
%         vmr.SetPredictorValuesFromCondition('ti', 'ti', 1.0);
%         vmr.ApplyHemodynamicResponseFunctionToPredictor('pe');
%         vmr.ApplyHemodynamicResponseFunctionToPredictor('pl');
%         vmr.ApplyHemodynamicResponseFunctionToPredictor('ti');
%         vmr.SDMContainsConstantPredictor = 0;
%         vmr.SaveSingleStudyGLMDesignMatrix(SDM_name);
%         
%         % adding motion confound variables
%         sdm_inc_confounds=xff(SDM_name);
%         sdm_motion=xff(motion_sdm_files{i});
%         sdm_inc_confounds.NrOfPredictors=sdm_inc_confounds.NrOfPredictors+sdm_motion.NrOfPredictors;
%         sdm_inc_confounds.PredictorColors=[sdm_inc_confounds.PredictorColors;sdm_motion.PredictorColors];
%         sdm_inc_confounds.PredictorNames=[sdm_inc_confounds.PredictorNames sdm_motion.PredictorNames];
%         sdm_inc_confounds.SDMMatrix=[sdm_inc_confounds.SDMMatrix sdm_motion.SDMMatrix];
%         sdm_inc_confounds.SaveAs(SDM_name);
%     end
%     
%     % Adding all runs SDMs
%     vmr.ClearMultiStudyGLMDefinition;
%     for i=1:length(vtc_files)-1     % all runs except the last (control)
%         motion_sdm = xff(motion_sdm_files{i});
%         if isempty(find(motion_sdm.SDMMatrix>1.7,1))  % checking that there is no excessive motion in the run
%             vtc_filename = vtc_files{i};
%             SDM_name = fullfile(output_dir, [subj '_' num2str(i) '.sdm']);
%             if isempty(strfind(vtc_filename,'highres')) % checking that it is not a high-res scan (cannot combine different resolutions in one GLM)
%                 vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);
%             end
%         end
%     end
%     i=length(vtc_files);        % adding the control run, even with excessive motion
%     vtc_filename = vtc_files{i};    
%     SDM_name = fullfile(output_dir, [subj '_' num2str(i) '.sdm']);
%     vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);
%     
%     MDM_name = fullfile(output_dir, [subj '.mdm']);
%     vmr.SaveMultiStudyGLMDefinitionFile(MDM_name);
%     
%     GLM_name = fullfile(output_dir, [subj '.glm']);
%     vmr.CorrectForSerialCorrelations = 1;
%     vmr.SeparationOfStudyPredictors = 1;
%     vmr.PSCTransformStudies = 1;
%     vmr.ComputeMultiStudyGLM;
%     vmr.SaveGLM(GLM_name);
% end
% 
% 
% % adding contrasts
% for s=1:length(subject_names)
%     subj=subject_names(s).name;
%     disp(subj);
%     output_dir=fullfile(subjects_output_dir, subj);
% %     vtc_files=getfullfiles(fullfile(output_dir,'*.vtc')); 
% %     vtc_files(cellfun(@(x) ~isempty(strfind(x,'rest')), vtc_files))=[]; % remove rest files, if existing
%     mdm_file=fullfile(output_dir, [subj '.mdm']); mdm=xff(mdm_file);
%     num_sessions=mdm.NrOfStudies;
%     
%     % adding contrasts - without control
%     CTR_name = fullfile(output_dir, [subj '.ctr']);
%     ctr={}; ctr_names={};
%     i=1; ctr_names{i}='person vs others'; ctr{i}=[repmat([2 -1 -1],1,num_sessions-1) 0 0 0];
%     i=2; ctr_names{i}='place vs others'; ctr{i}=[repmat([-1 2 -1],1,num_sessions-1) 0 0 0];
%     i=3; ctr_names{i}='time vs others'; ctr{i}=[repmat([-1 -1 2],1,num_sessions-1) 0 0 0];
%     i=4; ctr_names{i}='person vs control'; ctr{i}=[repmat([1 0 0],1,num_sessions-1) -1*(num_sessions-1) 0 0];
%     i=5; ctr_names{i}='place vs control'; ctr{i}=[repmat([0 1 0],1,num_sessions-1) 0 -1*(num_sessions-1) 0];
%     i=6; ctr_names{i}='time vs control'; ctr{i}=[repmat([0 0 1],1,num_sessions-1) 0 0 -1*(num_sessions-1)];
%     i=7; ctr_names{i}='person vs rest'; ctr{i}=[repmat([1 0 0],1,num_sessions-1) 0 0 0];
%     i=8; ctr_names{i}='place vs rest'; ctr{i}=[repmat([0 1 0],1,num_sessions-1) 0 0 0];
%     i=9; ctr_names{i}='time vs rest'; ctr{i}=[repmat([0 0 1],1,num_sessions-1) 0 0 0];
%     i=10; ctr_names{i}='control vs rest'; ctr{i}=[repmat([0 0 0],1,num_sessions-1) 1 1 1];
%     i=11; ctr_names{i}='person vs place'; ctr{i}=[repmat([1 -1 0],1,num_sessions-1) 0 0 0];
%     i=12; ctr_names{i}='person vs time'; ctr{i}=[repmat([1 0 -1],1,num_sessions-1) 0 0 0];
%     i=13; ctr_names{i}='place vs person'; ctr{i}=[repmat([-1 1 0],1,num_sessions-1) 0 0 0];
%     i=14; ctr_names{i}='place vs time'; ctr{i}=[repmat([0 1 -1],1,num_sessions-1) 0 0 0];
%     i=15; ctr_names{i}='time vs person'; ctr{i}=[repmat([-1 0 1],1,num_sessions-1) 0 0 0];
%     i=16; ctr_names{i}='time vs place'; ctr{i}=[repmat([0 -1 1],1,num_sessions-1) 0 0 0];
% 
% %     i=7; ctr_names{i}='all domains vs control'; ctr{i}=[repmat([1 1 1],1,num_sessions-1) -5 -5 -5];
% %     i=8; ctr_names{i}='rest vs control'; ctr{i}=[repmat([0 0 0],1,num_sessions-1) -1 -1 -1];    % for default mode network
%     
%     for i=1:length(ctr)
%         ctr{i}=[ctr{i} zeros(1, num_sessions*7)];  % adding zeros for six motion confounds and constant values  
%     end
%     ctr_xff=xff('new:ctr');     % new contrast structure, using NeuroElf
%     ctr_xff.NrOfContrasts = length(ctr_names);
%     ctr_xff.NrOfValues = length(ctr{1});
%     ctr_xff.ContrastNames = ctr_names;
%     ctr_xff.ContrastValues = cell2mat(ctr');
%     ctr_xff.SaveAs(CTR_name);
%     
% %     ctr_xff=xff('new:ctr');     % contrast of the domains-vs-control only, for conjunction analysis
% %     ctr_xff.NrOfContrasts = 3;
% %     ctr_xff.NrOfValues = length(ctr{1});
% %     ctr_xff.ContrastNames = ctr_names(4:6);
% %     ctr_xff.ContrastValues = cell2mat(ctr(4:6)');
% %     ctr_xff.SaveAs(fullfile(output_dir, [subj '_vs_control.ctr']));
% end
% 









%% transform to ACPC and make new VTCs

% NEED TO MANUALLY TRANSFORM ALL SUBJECTS TO ACPC SPACE, and give an
% *_ISO_ACPC.vmr ending to the new VMR filename 
% (if using existing trf file, just transform and give this ending)

% To create meshes - also manually transform to TAL


% copy files to ACPC directory and create new VTCs
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC\'];
    mkdir(ACPC_output_dir);
    ACPC_files_in_output_dir=[getfullfiles(fullfile(output_dir,'*ACPC.vmr*')) getfullfiles(fullfile(output_dir,'*ACPC.trf*'))];
    for i=1:length(ACPC_files_in_output_dir), movefile(ACPC_files_in_output_dir{i},ACPC_output_dir);end
    all_prt_files=getfullfiles(fullfile(output_dir,'*.prt')); for i=1:length(all_prt_files), copyfile(all_prt_files{i},ACPC_output_dir);end
    
    
    fmr_files = getfullfiles(fullfile(output_dir,'*_THPGLMF2c.fmr'));
    IA_files = getfullfiles(fullfile(output_dir,'*ISO*IA.trf'));
    FA_files = getfullfiles(fullfile(output_dir,'*ISO*FA.trf'));
    % remove rest files, if existing
    fmr_files(cellfun(@(x) ~isempty(strfind(x,'rest')), fmr_files))=[]; 
    IA_files(cellfun(@(x) ~isempty(strfind(x,'rest')), IA_files))=[]; 
    FA_files(cellfun(@(x) ~isempty(strfind(x,'rest')), FA_files))=[]; 
    
    for i=1:length(fmr_files)
        fmr_filename = fmr_files{i}; IA_filename=IA_files{i}; FA_filename=FA_files{i};
        Datatype = 2;       % 1 - integer, 2 - float (GUI default)
        Interpolation = 1;    % 0 for nearest neighbor , 1 for trilinear (GUI default) , 2 for sinc interpolation
        Intensity_threshold = 100;    % intensity threshold for voxels
        
        % checking if this session is a high-res scan
        if isempty(strfind(fmr_filename,'highres'))
            VTC_name = fullfile(ACPC_output_dir, [subj '_ACPC_' num2str(i) '.vtc']);
            vmr_filename=getfullfiles(fullfile(output_dir, '*_ISO.vmr')); 
            ACPC_transform_file=getfullfiles(fullfile(ACPC_output_dir,'*ISO_ACPC.trf'));
            Resolution = 2;     % resolution relative to VMR - 2x2x2 - resulting in 1.7x1.7x1.7 voxels
        else
            VTC_name = fullfile(ACPC_output_dir, [subj '_ACPC_' num2str(i) '_highres.vtc']);
            vmr_filename=getfullfiles(fullfile(output_dir, '*_ISO_075.vmr')); 
            ACPC_transform_file=getfullfiles(fullfile(ACPC_output_dir,'*ISO_075_ACPC.trf'));
            Resolution = 1;     % resolution relative to VMR - 1x1x1 - resulting in 0.75x0.75x0.75 voxels
        end
        
        vmr = bvqx.OpenDocument(vmr_filename{1});
        vmr.CreateVTCInACPCSpace(fmr_filename, IA_filename, FA_filename, ACPC_transform_file{1},...
            VTC_name, Datatype, Resolution, Interpolation, Intensity_threshold);
    end
end


% creating design matrices (MDM and GLM files) for ACPC files
disp('Creating design matrices (.mdm files)')
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    all_prt_files=getfullfiles(fullfile(output_dir,'*.prt')); for i=1:length(all_prt_files), copyfile(all_prt_files{i},ACPC_output_dir);end
    
    vtc_files=getfullfiles(fullfile(ACPC_output_dir,'*.vtc'));
    vtc_files(cellfun(@(x) ~isempty(strfind(x,'rest')), vtc_files))=[];   % remove rest files, if existing
    vmr_filename=getfullfiles(fullfile(ACPC_output_dir, '*_ISO_ACPC.vmr')); 
    vmr = bvqx.OpenDocument(vmr_filename{1});
    
    prt_files=getfullfiles(fullfile(output_dir,'paradigm_domains_*.prt'));
    motion_sdm_files=getfullfiles(fullfile(output_dir,'*3DMC.sdm'));
    
    % create SDM for each session
    for i=1:length(vtc_files)
        vtc_filename = vtc_files{i}; prt_filename=prt_files{i};
        SDM_name = fullfile(ACPC_output_dir, [subj '_' num2str(i) '.sdm']);
        vmr.LinkVTC(vtc_filename);
        vmr.LinkStimulationProtocol(prt_filename);
        % vmr.SaveVTC();  % save with link to protocol
        
        vmr.ClearDesignMatrix;
        vmr.AddPredictor('pe');
        vmr.AddPredictor('pl');
        vmr.AddPredictor('ti');
        vmr.SetPredictorValuesFromCondition('pe', 'pe', 1.0);
        vmr.SetPredictorValuesFromCondition('pl', 'pl', 1.0);
        vmr.SetPredictorValuesFromCondition('ti', 'ti', 1.0);
        vmr.ApplyHemodynamicResponseFunctionToPredictor('pe');
        vmr.ApplyHemodynamicResponseFunctionToPredictor('pl');
        vmr.ApplyHemodynamicResponseFunctionToPredictor('ti');
        vmr.SDMContainsConstantPredictor = 0;
        vmr.SaveSingleStudyGLMDesignMatrix(SDM_name);
        
        % adding motion confound variables
        sdm_inc_confounds=xff(SDM_name);
        sdm_motion=xff(motion_sdm_files{i});
        sdm_inc_confounds.NrOfPredictors=sdm_inc_confounds.NrOfPredictors+sdm_motion.NrOfPredictors;
        sdm_inc_confounds.PredictorColors=[sdm_inc_confounds.PredictorColors;sdm_motion.PredictorColors];
        sdm_inc_confounds.PredictorNames=[sdm_inc_confounds.PredictorNames sdm_motion.PredictorNames];
        sdm_inc_confounds.SDMMatrix=[sdm_inc_confounds.SDMMatrix sdm_motion.SDMMatrix];
        sdm_inc_confounds.SaveAs(SDM_name);
    end
    
    % create MDM file
    vmr.ClearMultiStudyGLMDefinition;
    for i=1:length(vtc_files)-1     % all runs except the last (control)
        motion_sdm = xff(motion_sdm_files{i});
        if isempty(find(motion_sdm.SDMMatrix>1.7,1))  % checking that there is no excessive motion in the run
            vtc_filename = vtc_files{i};
            SDM_name = fullfile(ACPC_output_dir, [subj '_' num2str(i) '.sdm']);
            if isempty(strfind(vtc_filename,'highres')) % checking that it is not a high-res scan (cannot combine different resolutions in one GLM)
                vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);
            end
        end
    end
    i=length(vtc_files);        % adding the control run, even with excessive motion
    vtc_filename = vtc_files{i};    
    SDM_name = fullfile(ACPC_output_dir, [subj '_' num2str(i) '.sdm']);
    vmr.AddStudyAndDesignMatrix(vtc_filename, SDM_name);

    MDM_name = fullfile(ACPC_output_dir, [subj '_ACPC.mdm']);
    vmr.SaveMultiStudyGLMDefinitionFile(MDM_name);
    
    GLM_name = fullfile(ACPC_output_dir, [subj '_ACPC.glm']);
    vmr.CorrectForSerialCorrelations = 1;
    vmr.SeparationOfStudyPredictors = 1;
    vmr.PSCTransformStudies = 1;
    vmr.ComputeMultiStudyGLM;
    vmr.SaveGLM(GLM_name);
end

% adding contrasts
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    mdm_file=fullfile(ACPC_output_dir, [subj '_ACPC.mdm']); mdm=xff(mdm_file);
    num_sessions=mdm.NrOfStudies;
    
    % adding contrasts - without control
    CTR_name = fullfile(ACPC_output_dir, [subj '.ctr']);
    ctr={}; ctr_names={};
    i=1; ctr_names{i}='person vs others'; ctr{i}=[repmat([2 -1 -1],1,num_sessions-1) 0 0 0];
    i=2; ctr_names{i}='place vs others'; ctr{i}=[repmat([-1 2 -1],1,num_sessions-1) 0 0 0];
    i=3; ctr_names{i}='time vs others'; ctr{i}=[repmat([-1 -1 2],1,num_sessions-1) 0 0 0];
%     i=4; ctr_names{i}='person vs control'; ctr{i}=[repmat([1 0 0],1,num_sessions-1) -1*(num_sessions-1) 0 0];
%     i=5; ctr_names{i}='place vs control'; ctr{i}=[repmat([0 1 0],1,num_sessions-1) 0 -1*(num_sessions-1) 0];
%     i=6; ctr_names{i}='time vs control'; ctr{i}=[repmat([0 0 1],1,num_sessions-1) 0 0 -1*(num_sessions-1)];
    i=4; ctr_names{i}='person vs control'; ctr{i}=[repmat([3 0 0],1,num_sessions-1) [-1 -1 -1]*(num_sessions-1)];
    i=5; ctr_names{i}='place vs control'; ctr{i}=[repmat([0 3 0],1,num_sessions-1) [-1 -1 -1]*(num_sessions-1)];
    i=6; ctr_names{i}='time vs control'; ctr{i}=[repmat([0 0 3],1,num_sessions-1) [-1 -1 -1]*(num_sessions-1)];
    i=7; ctr_names{i}='person vs rest'; ctr{i}=[repmat([1 0 0],1,num_sessions-1) 0 0 0];
    i=8; ctr_names{i}='place vs rest'; ctr{i}=[repmat([0 1 0],1,num_sessions-1) 0 0 0];
    i=9; ctr_names{i}='time vs rest'; ctr{i}=[repmat([0 0 1],1,num_sessions-1) 0 0 0];
    i=10; ctr_names{i}='control vs rest'; ctr{i}=[repmat([0 0 0],1,num_sessions-1) 1 1 1];
    i=11; ctr_names{i}='person vs place'; ctr{i}=[repmat([1 -1 0],1,num_sessions-1) 0 0 0];
    i=12; ctr_names{i}='person vs time'; ctr{i}=[repmat([1 0 -1],1,num_sessions-1) 0 0 0];
    i=13; ctr_names{i}='place vs person'; ctr{i}=[repmat([-1 1 0],1,num_sessions-1) 0 0 0];
    i=14; ctr_names{i}='place vs time'; ctr{i}=[repmat([0 1 -1],1,num_sessions-1) 0 0 0];
    i=15; ctr_names{i}='time vs person'; ctr{i}=[repmat([-1 0 1],1,num_sessions-1) 0 0 0];
    i=16; ctr_names{i}='time vs place'; ctr{i}=[repmat([0 -1 1],1,num_sessions-1) 0 0 0];
    
%     i=7; ctr_names{i}='all domains vs control'; ctr{i}=[repmat([1 1 1],1,num_sessions-1) -5 -5 -5];
%     i=8; ctr_names{i}='rest vs control'; ctr{i}=[repmat([0 0 0],1,num_sessions-1) -1 -1 -1];    % for default mode network
    
    for i=1:length(ctr)
        ctr{i}=[ctr{i} zeros(1, num_sessions*7)];  % adding zeros for constant values and motion confounds 
    end
    ctr_xff=xff('new:ctr');     % new contrast structure, using NeuroElf
    ctr_xff.NrOfContrasts = length(ctr_names);
    ctr_xff.NrOfValues = length(ctr{1});
    ctr_xff.ContrastNames = ctr_names;
    ctr_xff.ContrastValues = cell2mat(ctr');
    ctr_xff.SaveAs(CTR_name);
    
%     ctr_xff=xff('new:ctr');     % contrast of the domains-vs-control only, for conjunction analysis
%     ctr_xff.NrOfContrasts = 3;
%     ctr_xff.NrOfValues = length(ctr{1});
%     ctr_xff.ContrastNames = ctr_names(4:6);
%     ctr_xff.ContrastValues = cell2mat(ctr(4:6)');
%     ctr_xff.SaveAs(fullfile(ACPC_output_dir, [subj '_vs_control.ctr']));

end






%% Linking VTC and PRT files, for event-related averaging

disp('Linking VTC and PRT files')
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    
%     vtc_files=getfullfiles(fullfile(output_dir,'*.vtc'));
    ACPC_vtc_files=getfullfiles(fullfile(ACPC_output_dir,'*.vtc'));
%     vtc_files(cellfun(@(x) ~isempty(strfind(x,'rest')), vtc_files))=[];   % remove rest files, if existing
    ACPC_vtc_files(cellfun(@(x) ~isempty(strfind(x,'rest')), ACPC_vtc_files))=[];   % remove rest files, if existing
    prt_files=getfullfiles(fullfile(output_dir,'paradigm_domains_*.prt'));
    
%     for i=1:length(vtc_files)
%         if isempty(strfind(vtc_files{i},'highres')) % checking that it is not a high-res scan (cannot combine different resolutions in one GLM)
%             curr_vtc = xff(vtc_files{i});
%             curr_vtc.NrOfLinkedPRTs = 1;
%             [fp1, fp2, fp3] = fileparts(prt_files{i});      % getting the filename only, without the path
%             curr_vtc.NameOfLinkedPRT = [fp2 fp3];
%             curr_vtc.Save;
%             curr_vtc.ClearObject;
%         end
%     end
    for i=1:length(ACPC_vtc_files)
        if isempty(strfind(vtc_files{i},'highres')) % checking that it is not a high-res scan (cannot combine different resolutions in one GLM)
            curr_vtc = xff(ACPC_vtc_files{i});
            curr_vtc.NrOfLinkedPRTs = 1;
            [fp1, fp2, fp3] = fileparts(prt_files{i});      % getting the filename only, without the path
            curr_vtc.NameOfLinkedPRT = [fp2 fp3];
            curr_vtc.Save;
            curr_vtc.ClearObject;
        end
    end
end




%% changing VMP visualization

% CREATE VMP FILES BY OPENING THE CONTRAST FILE IN BV, CHOOSING OPTIONS,
% AND CHOOSING CREATE MAPS, AND THEN CTRL+M AND SAVE AS
% (save with '_domains.vmp' ending)

% RUN THE 'CHANGE_VMP_VISUALIZATION.M' SCRIPT TO CHANGE COLORS, NAMES, ETC.