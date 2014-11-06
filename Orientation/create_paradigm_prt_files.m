function create_paradigm_prt_files(design_filenames, output_dir)
% create_paradigm_prt_file(design_filename)
%
% Receives a cell array of names of ExpyVR files (number only) which
% were converted to design and domain_design files, from the same 
% paradigm run, and an output directory
% Saves PRT files with the paradigm

LOG_PATH='c:\ExpyVR\log\';

% designs with distances
colors={[170, 85, 255],[10 96 180],[186 57 68],[172 122 159],[60 45 212],[196 239 27],[46 25 125],[49 229 25],[11 142 197],[79 45 86],[53 130 232],[160 25 100],[13 128 110],[255 207 124],[228 35 99],[237 234 182],[158 87 239],[31 187 165],[213 101 191]};
for file_num=1:length(design_filenames)
    output_filename=fullfile(output_dir, ['paradigm_with_distances_' num2str(file_num) '.prt']);
    load([LOG_PATH design_filenames{file_num} '_design']);    
    all_onsets=[]; all_ends=[];
    
    % finding start and end times for conditions
    conditions=names;
    times=cell(1, length(conditions));
    for i=1:length(conditions)
        times{i}=cell(1,length(onsets{i}));
        for j=1:length(onsets{i})
            times{i}{j}=[onsets{i}(j)+1, onsets{i}(j)+durations{i}(j)];
            all_onsets=[all_onsets onsets{i}(j)+1];
            all_ends=[all_ends onsets{i}(j)+durations{i}(j)];
        end
    end
    all_onsets=sort(all_onsets); all_ends=sort(all_ends);
    
    % finding start and end times for rest
    rest_ends=all_onsets-1;
    rest_starts=[1];
    for i=1:length(all_ends)
        rest_starts=[rest_starts all_ends(i)+1];
    end
    rest_ends=[rest_ends rest_starts(end)+9];
    times_rest={};
    for i=1:length(rest_starts)
        times_rest{end+1} = [rest_starts(i),rest_ends(i)];
    end
    conditions=['Rest'; conditions]; times=[{times_rest} times];
    
    fid=fopen(output_filename,'w');
    fprintf(fid,'\nFileVersion:        2\n\nResolutionOfTime:   Volumes\n\nExperiment:         distances - run %d\n\n', file_num);
    fprintf(fid,'BackgroundColor:    0 0 0\nTextColor:          255 255 255\nTimeCourseColor:    192 192 192\n');
    fprintf(fid,'TimeCourseThick:    2\nReferenceFuncColor: 0 0 80\nReferenceFuncThick: 2\n\nNrOfConditions:     %d\n\n', length(conditions));
    
    for i=1:length(conditions)
        fprintf(fid,'%s\n',conditions{i});
        fprintf(fid,'%d\n',length(times{i}));
        for j=1:length(times{i})
            if times{i}{j}(1)<10
                fprintf(fid,'   %d',times{i}{j}(1));
            elseif times{i}{j}(1)<100
                fprintf(fid,'  %d',times{i}{j}(1));
            else
                fprintf(fid,' %d',times{i}{j}(1));
            end
            
            if times{i}{j}(2)<10
                fprintf(fid,'    %d',times{i}{j}(2));
            elseif times{i}{j}(2)<100
                fprintf(fid,'   %d',times{i}{j}(2));
            else
                fprintf(fid,'  %d',times{i}{j}(2));
            end
            fprintf(fid,'\n');
        end
        fprintf(fid,'Color:              %d %d %d\n\n', colors{i}(1),colors{i}(2),colors{i}(3));
    end
    fclose(fid);
end


% Paradigm with domains only
colors={[170, 85, 255],[255, 0, 0],[52, 198, 205],[182 246 62]};
for file_num=1:length(design_filenames)
    output_filename=fullfile(output_dir, ['paradigm_domains_' num2str(file_num) '.prt']);
    load([LOG_PATH design_filenames{file_num} '_domain_design']);
    all_onsets=[]; all_ends=[];

    % finding start and end times for conditions
    conditions=names;
    times=cell(1, length(conditions));
    for i=1:length(conditions)
        times{i}=cell(1,length(onsets{i}));
        for j=1:length(onsets{i})
            times{i}{j}=[onsets{i}(j)+1, onsets{i}(j)+durations{i}(j)];
            all_onsets=[all_onsets onsets{i}(j)+1];
            all_ends=[all_ends onsets{i}(j)+durations{i}(j)];
        end
    end
    all_onsets=sort(all_onsets); all_ends=sort(all_ends);
    
    % finding start and end times for rest
    rest_ends=all_onsets-1;
    rest_starts=[1];
    for i=1:length(all_ends)
        rest_starts=[rest_starts all_ends(i)+1];
    end
    rest_ends=[rest_ends rest_starts(end)+9];
    times_rest={};
    for i=1:length(rest_starts)
        times_rest{end+1} = [rest_starts(i),rest_ends(i)];
    end
    conditions=['Rest' conditions]; times=[{times_rest} times];
    
    fid=fopen(output_filename,'w');
    fprintf(fid,'\nFileVersion:        2\n\nResolutionOfTime:   Volumes\n\nExperiment:         distances - run %d\n\n', file_num);
    fprintf(fid,'BackgroundColor:    0 0 0\nTextColor:          255 255 255\nTimeCourseColor:    192 192 192\n');
    fprintf(fid,'TimeCourseThick:    2\nReferenceFuncColor: 0 0 80\nReferenceFuncThick: 2\n\nNrOfConditions:     %d\n\n', length(conditions));
    
    for i=1:length(conditions)
        fprintf(fid,'%s\n',conditions{i});
        fprintf(fid,'%d\n',length(times{i}));
        for j=1:length(times{i})
            if times{i}{j}(1)<10
                fprintf(fid,'   %d',times{i}{j}(1));
            elseif times{i}{j}(1)<100
                fprintf(fid,'  %d',times{i}{j}(1));
            else
                fprintf(fid,' %d',times{i}{j}(1));
            end
            
            if times{i}{j}(2)<10
                fprintf(fid,'    %d',times{i}{j}(2));
            elseif times{i}{j}(2)<100
                fprintf(fid,'   %d',times{i}{j}(2));
            else
                fprintf(fid,'  %d',times{i}{j}(2));
            end
            fprintf(fid,'\n');
        end
        fprintf(fid,'Color:              %d %d %d\n\n', colors{i}(1),colors{i}(2),colors{i}(3));
    end
    fclose(fid);
end
