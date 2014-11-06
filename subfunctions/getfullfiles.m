function files = getfullfiles(expression)
% files = getfullfiles(expression)
%
% gets all the files which correspond to an expression, e.g. 'c:\temp\*.mat' or 'c:\temp\'
% returns a cell array with the full paths of the files

a=dir(expression);

[f1,f2]=fileparts(expression); 
if isdir(expression)    % searching a directory without specifying file type
    a=a(3:end);     % this is because of the results '.' and '..'
    directory=[f1 '\' f2];
else
    directory=f1;
end

files=cell(1,length(a));
for i=1:length(a)
    files{i}=fullfile(directory, a(i).name);
end

