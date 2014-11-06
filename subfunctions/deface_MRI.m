function deface_MRI(filename)
% deface_MRI(filename)
%
% This script removes the face from MRI images, for anonymous sending
% Receives a filename  of an anatomical MRI image
%
% UNTESTED ON MANY IMAGES - MAY NOT WORK ON ALL IMAGES - REMOVES SPECIFIC VOXELS

file=spm_vol(filename);
file_data=spm_read_vols(file);
file_data(1:100,1:100,:)=0;
spm_write_vol(file,file_data);
