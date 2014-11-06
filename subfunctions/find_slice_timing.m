function find_slice_timing(filename)
% find_slice_timing(filename)
%
% displays the slice-timing parameters of the fMRI data in a dicom file

a=nifti(filename);
disp(['Slice timing is: ' a.diminfo.slice_time.code '. start:' num2str(a.diminfo.slice_time.start) ', end:' num2str(a.diminfo.slice_time.end) '.'])
