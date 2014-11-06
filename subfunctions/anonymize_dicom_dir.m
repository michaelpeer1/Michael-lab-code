function anonymize_dicom_dir(input_dirname, output_dirname)
% anonymize_dicom_dir(input_dirname, output_dirname)
%
% This function is used to remove confidential data (name, ID, etc.) from dicom files
% uses the matlab function 'dicomanon' (see Matlab help)
% 
% Receives: 
% - Name of the directory with dicom files
% - Name of a new directory to put the anonymized dicom files in

if ~exist(output_dirname, 'dir')
    mkdir(output_dirname);
end

% choosing fields to keep, such as the protocol
fields_to_keep = {'StudyDescription', 'SeriesDescription', 'StudyID', 'SeriesNumber', 'ProtocolName'};
values.StudyInstanceUID = dicomuid;
values.SeriesInstanceUID = dicomuid;

% updating the files and removing confidential data
files = dir(input_dirname); files = files(3:end);
for i=1:length(files)
    dicomanon(fullfile(input_dirname, files(i).name), fullfile(output_dirname, files(i).name),...
        'keep', fields_to_keep, 'update', values);
end


