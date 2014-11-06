% This script anonymizes names of NIFTI files from my firectories
%
% The names of the directories need to be changed manually, and the names
% of the files are then changed accordingly by the script

a=getfullfiles('C:\Michael\Patients\TGA_data_to_send\Anatomy\CONTROLS');
for i=1:length(a)
    [~,dirname]=fileparts(a{i});

    b1 = getfullfiles([a{i} '\*.img']);
    b2 = getfullfiles([a{i} '\*.hdr']);
    b = [b1 b2];
    if isempty(b)
        b=getfullfiles([a{i} '\*.nii']);
    end
    
    for j=1:length(b)
        if strcmp(b{j}(end-7),'0')      % functional file
            movefile(b{j}, [a{i} '\' dirname b{j}(end-8:end)]);
        else                            % anatomical file
            movefile(b{j}, [a{i} '\' dirname b{j}(end-3:end)]);
        end
    end
end


