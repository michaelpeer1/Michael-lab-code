function [] = rename_files_starting_with_a(dirname)
% rename_files_starting_with_a(dirname)
%
% This stupid function takes all the files starting with A or C in the
% directory, and adds B_ at the beginning
% This is because of a bug in DPARSFA which cannot process A/C filenames

a=dir(dirname);
cd(dirname);
for i=3:length(a)
    if a(i).name(1)=='A' || a(i).name(1)=='C'
        movefile(a(i).name,['B_' a(i).name])
    end
end

