function [ff,fvox] = get_volumes_patient(dirname)
% receives a directory name containing functional data (such as 
% 'c:\Patients\funraw\04-01-12-FRIDLIN_NADYA\') and returns a matrix of 
% values per voxel per time point, either 3D (ff) or 1D (fvox)

aa=dir(dirname);
ab={};
for i=1:length(aa)
    if strfind(aa(i).name,'img')
        ab{end+1}=[dirname '\' aa(i).name];
    end
end
files=[];
for i=1:length(ab)
    files=[files spm_vol(ab{i})];
end
ff=spm_read_vols(files);

sff=size(ff);
numvox=sff(1)*sff(2)*sff(3);
fvox=reshape(ff,numvox,sff(4));

return;