function files = getfiles(expression)
% files = getfiles(expression)
% 
% gets all the files which correspond to an expression, e.g. 'c:\temp\*.mat' or 'c:\temp\'
% returns a cell array with the names of the files (without full path)

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
    files{i}=a(i).name;
end

