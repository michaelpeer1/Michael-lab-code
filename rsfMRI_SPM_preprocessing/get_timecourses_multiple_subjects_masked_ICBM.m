function get_timecourses_multiple_subjects_masked_ICBM(functional_directory, output_directory, func_dir_to_threshold)
% get_timecourses_multiple_subjects_masked(functional_directory, output_directory, func_dir_to_threshold)
% 
% Receives a functional directory, e.g. 'C:\Michael\Patients\Preprocessing\ARCWSF_TGA\descending_33_slices\FunRawARWSFC'
% and output directory, e.g. 'C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Results'
% and functional directory to threshold by, e.g. 'C:\Michael\Patients\Preprocessing\ARCWSF_TGA\descending_33_slices\FunRawARWSF'
% and minimum threshold for voxels in functional files, e.g. 300 (optional parameter - old version).
%
% Saves each patient's AAL areas timecourses in ROISignals file in the output directory.


parcel_filename = 'C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\AAL_61x73x61_YCG.nii';

a=dir(functional_directory); a=a(3:end);
rois=cell(1,length(a));
parfor (i=1:length(a),3)
    disp(a(i).name)
    
    segmentation_dir = [functional_directory '\..\T1ImgSegment\' a(i).name];
    segmentation_file = dir(fullfile(segmentation_dir, 'wc1*.nii')); 
    segmentation_file = fullfile(segmentation_dir, segmentation_file.name);
    
    func_dir_temp = fullfile(functional_directory, a(i).name);
    func_dir_thresh_temp = fullfile(func_dir_to_threshold, a(i).name);
    
%     [~,numvox,timecourses] = get_timecourses_from_parcellation_masked(parcel_filename, func_dir_temp, segmentation_file, func_dir_thresh_temp, func_threshold);
    [~,numvox,timecourses] = get_timecourses_from_parcellation_masked(parcel_filename, func_dir_temp, segmentation_file, func_dir_thresh_temp);
    
    ROISignals=[];
    for j=1:length(timecourses)
        if numvox(j)>10         % checking that the are has more than 10 voxels, to avoid taking areas with bad signal
            ROISignals=[ROISignals timecourses{j}'];
        else
            ROISignals=[ROISignals nan(length(timecourses{j}),1)];
        end
    end
    rois{i}=ROISignals;
end

% saving the variables (can't save inside a parfor loop)
for i=1:length(a)
    savefile=fullfile(output_directory, ['ROISignals_' a(i).name]);
    ROISignals=rois{i};
    save(savefile,'ROISignals');
end




%
% 
% 
% a=dir('C:\Michael\Patients\Preprocessing\ARCWSF_TGA\descending_33_slices\FunRawARCWSF');
% data={};
% for i=3:length(a)
%     disp(a(i).name)
%     data{end+1}=cell(1,2);
%     data{end}{1}=a(i).name;
%     segmentation_file=dir(fullfile(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\descending_33_slices\T1ImgNewSegment\' a(i).name], '\wc1*.nii'));
%     [areas,timecourse]=get_timecourses_from_parcellation_masked('C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\AAL_61x73x61_YCG.nii',['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\descending_33_slices\FunRawARCWSF\' a(i).name], fullfile(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\descending_33_slices\T1ImgNewSegment\' a(i).name],segmentation_file.name));
%     data{end}{2}=timecourse;
% end
% 
% for i=1:length(data)
%     d=data{i}{2};
%     ROISignals=[];
%     for j=1:length(d)
%         ROISignals=[ROISignals d{j}'];
%     end
%     %savefile=['C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\Results\ROISignals_' data{i}{1}];
% %     savefile=['C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\Results_scrubbed\ROISignals_' data{i}{1}];
%     savefile=['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Results\ROISignals_' data{i}{1}];
%     save(savefile,'ROISignals');
% end
% 
% 
% %a=dir('C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\slices_30\FunRawARCWSDF');
% % a=dir('C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\slices_30\FunRawARCWSDFB');
% a=dir('C:\Michael\Patients\Preprocessing\ARCWSF_TGA\slices_30\FunRawARCWSF');
% data={};
% for i=3:length(a)
%     disp(a(i).name)
%     data{end+1}=cell(1,2);
%     data{end}{1}=a(i).name;
%     segmentation_file=dir(fullfile(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\slices_30\T1ImgNewSegment\' a(i).name], '\wc1*.nii'));
%     [areas,timecourse]=get_timecourses_from_parcellation_masked('C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\AAL_61x73x61_YCG.nii',['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\slices_30\FunRawARCWSF\' a(i).name], fullfile(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\slices_30\T1ImgNewSegment\' a(i).name],segmentation_file.name));
%     data{end}{2}=timecourse;
% end
% 
% %a=dir('C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\slices_33\FunRawARCWSDF');
% % a=dir('C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\slices_33\FunRawARCWSDFB');
% a=dir('C:\Michael\Patients\Preprocessing\ARCWSF_TGA\slices_33\FunRawARCWSF');
% for i=3:length(a)
%     disp(a(i).name)
%     data{end+1}=cell(1,2);
%     data{end}{1}=a(i).name;
%     segmentation_file=dir(fullfile(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\slices_33\T1ImgNewSegment\' a(i).name], '\wc1*.nii'));
%     [areas,timecourse]=get_timecourses_from_parcellation_masked('C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\AAL_61x73x61_YCG.nii',['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\slices_33\FunRawARCWSF\' a(i).name], fullfile(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\slices_33\T1ImgNewSegment\' a(i).name],segmentation_file.name));
%     data{end}{2}=timecourse;
% end
% 
% %a=dir('C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\special\FunRawARCWSDF');
% % a=dir('C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\special\FunRawARCWSDFB');
% a=dir('C:\Michael\Patients\Preprocessing\ARCWSF_TGA\special\FunRawARCWSF');
% for i=3:length(a)
%     disp(a(i).name)
%     data{end+1}=cell(1,2);
%     data{end}{1}=a(i).name;
%     segmentation_file=dir(fullfile(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\special\T1ImgNewSegment\' a(i).name], '\wc1*.nii'));
%     [areas,timecourse]=get_timecourses_from_parcellation_masked('C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\AAL_61x73x61_YCG.nii',['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\special\FunRawARCWSF\' a(i).name], fullfile(['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\special\T1ImgNewSegment\' a(i).name],segmentation_file.name));
%     data{end}{2}=timecourse;
% end
% 
% for i=1:length(data)
%     d=data{i}{2};
%     ROISignals=[];
%     for j=1:length(d)
%         ROISignals=[ROISignals d{j}'];
%     end
%     %savefile=['C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\Results\ROISignals_' data{i}{1}];
% %     savefile=['C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\Results_scrubbed\ROISignals_' data{i}{1}];
%     savefile=['C:\Michael\Patients\Preprocessing\ARCWSF_TGA\Results\ROISignals_' data{i}{1}];
%     save(savefile,'ROISignals');
% end
% 
% 
% 
% 
% 
% 
% 
% a=dir('C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\controls_COBRE\FunRawARCWSDF');
% data={};
% for i=3:length(a)
%     disp(a(i).name)
%     data{end+1}=cell(1,2);
%     data{end}{1}=a(i).name;
%     segmentation_file=dir(fullfile(['C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\controls_COBRE\T1ImgNewSegment\' a(i).name], '\wc1*.nii'));
%     [areas,timecourse]=get_timecourses_from_parcellation_masked('C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\AAL_61x73x61_YCG.nii',['C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\controls_COBRE\FunRawARCWSDF\' a(i).name], fullfile(['C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\controls_COBRE\T1ImgNewSegment\' a(i).name],segmentation_file.name));
%     data{end}{2}=timecourse;
% end
% for i=1:length(data)
%     d=data{i}{2};
%     ROISignals=[];
%     for j=1:length(d)
%         ROISignals=[ROISignals d{j}'];
%     end
%     savefile=['C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\Results\ROISignals_' data{i}{1}];
%     save(savefile,'ROISignals');
% end
% 
% 
% %a=dir('C:\INDI\host\ICBM\FunRawARCWSDF');
% a=dir('C:\INDI\host\ICBM\FunRawARCWSF');
% data={};
% for i=3:length(a)
%     disp(a(i).name)
%     data{end+1}=cell(1,2);
%     data{end}{1}=a(i).name;
%     segmentation_file=dir(fullfile(['C:\INDI\host\ICBM\T1ImgSegment\' a(i).name], '\wc1*.nii'));
%     [areas,timecourse]=get_timecourses_from_parcellation_masked('C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\AAL_61x73x61_YCG.nii',['C:\INDI\host\ICBM\FunRawARCWSF\' a(i).name], fullfile(['C:\INDI\host\ICBM\T1ImgSegment\' a(i).name],segmentation_file.name));
%     data{end}{2}=timecourse;
% end
% for i=1:length(data)
%     d=data{i}{2};
%     ROISignals=[];
%     for j=1:length(d)
%         ROISignals=[ROISignals d{j}'];
%     end
%     savefile=['C:\INDI\host\ICBM\Results\ROISignals_' data{i}{1}];
%     save(savefile,'ROISignals');
% end
% 
% a=dir('C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\New\FunRawARCWSDF');
% data={};
% for i=3:length(a)
%     disp(a(i).name)
%     data{end+1}=cell(1,2);
%     data{end}{1}=a(i).name;
%     segmentation_file=dir(fullfile(['C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\New\T1ImgNewSegment\' a(i).name], '\wc1*.nii'));
%     [areas,timecourse]=get_timecourses_from_parcellation_masked('C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\AAL_61x73x61_YCG.nii',['C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\New\FunRawARCWSDF\' a(i).name], fullfile(['C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\New\T1ImgNewSegment\' a(i).name],segmentation_file.name));
%     data{end}{2}=timecourse;
% end
% for i=1:length(data)
%     d=data{i}{2};
%     ROISignals=[];
%     for j=1:length(d)
%         ROISignals=[ROISignals d{j}'];
%     end
%     savefile=['C:\Michael\Patients\Preprocessing\ARCWSDF_TGA\New\Results\ROISignals_' data{i}{1}];
%     save(savefile,'ROISignals');
% end
