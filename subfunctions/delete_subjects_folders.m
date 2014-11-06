function delete_subjects_folders(subjects_dir, names_to_delete)
% delete_subjects_folders(subjects_dir, names_to_delete)
%
% This function deletes the subfolders of "subjects_dir" baring the names listed in "names_to_delete".
%
% For example, "delete_subjects_folders('C:\all_data', {'TA_AM'})" will delete all "TA_AM" folders in subfolders 
% such as "FunRaw", "FunRawA", "T1Img" or any other subfolder

% make sure subjects_dir has '\' at the end
if ~ strcmp(subjects_dir(end), '\')      subjects_dir(end+1) = '\';    end

% enter each folder, and in it each folder with the name from 'names_to_delete'
% delete all files there
% delete the folder

folders_names = dir(subjects_dir);
folders_names = folders_names([folders_names .isdir]); % take only folders, not files
folders_names = {folders_names .name}; % save only the folders names
folders_names(ismember(folders_names, {'.', '..'} )) = []; % discard the names '.' and '..' (if exist) which are not folders

for folderI = 1:length(folders_names) % folders such as "T1Img", "FunRaw" etc.
    for nameI = 1:length(names_to_delete)
        % find all files in subdirectory of patient "names_to_delete(nameI)"
        files_names = dir([ subjects_dir folders_names{folderI} '\' names_to_delete{nameI} ]);
        if isempty(files_names)
            continue
        end
        files_indices = ~[files_names .isdir]; % find the indices of files,  not folders
        files_names = files_names(files_indices);
        files_names = {files_names .name};

        for fileI = 1:length(files_names)
            delete([subjects_dir folders_names{folderI} '\' names_to_delete{nameI} '\' files_names{fileI}]);
        end
    rmdir([subjects_dir folders_names{folderI} '\' names_to_delete{nameI}]);    
    end
end

end