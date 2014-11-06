function [names, onsets, durations]=create_design_from_log(filenames, times_start_TRs, TR, len_block, len_rest, len_start_rest, len_end_rest, num_excessive_TRs, num_removed_volumes)
% receives a cell array of filenames and a cell array of times of TR start relative to
% paradigm start, and the TR length in seconds, and the lengths (in
% seconds) of the block, rest between blocks, start rest (25s) and end rest
% (15s), and the number of excessive TRs in the paradigm (sometimes 1), and the number of volumes removed at the beginning (usually 5)

if nargin<2
    times_start_TRs=cell(1,length(filenames));
    for q=1:length(filenames)
        times_start_TRs{q}=0;
    end
end

LOGPATH = 'c:\expyvr\log\';
cur_start_time=0;
all_onsets=cell(0); all_durations=cell(0);

for q=1:length(filenames)
    b=fopen(strcat(LOGPATH,filenames{q},'_keyboard.csv'),'r');
    keyboard_data = textscan(b, '%f %f %f %s %s %s %f %f %f', 'Delimiter',',','HeaderLines',1);
    
    times=keyboard_data{2};
    times=round(times*2)/2-times_start_TRs{q}+cur_start_time;
    conditions=keyboard_data{5};
    
    names=unique(conditions); names{end+1}='rest';
    onsets=cell(1,length(names)); durations=cell(1,length(names));
    onsets{end}=cur_start_time/TR; durations{end}=(len_start_rest-times_start_TRs{q})/TR-num_removed_volumes; % initial rest period
    
    for j=1:length(names)               % first condition
        if strcmp(conditions{1},names{j})
            onsets{j}=[onsets{j} times(1)/TR-num_removed_volumes];         % the first num_removed_volumes TRs were previously removed
            durations{j}=[durations{j} len_block/TR];
            onsets{end}=[onsets{end} times(1)/TR];
            durations{end}=[durations{end} len_rest/TR];
        end
    end
    for i=2:length(times)
        if ~strcmp(conditions{i},conditions{i-1})
            for j=1:length(names)
                if strcmp(conditions{i},names{j})
                    onsets{j}=[onsets{j} times(i)/TR-num_removed_volumes];     % the first num_removed_volumes TRs were previously removed
                    durations{j}=[durations{j} len_block/TR];
                    onsets{end}=[onsets{end} times(i)/TR];
                    durations{end}=[durations{end} len_rest/TR];
                end
            end
        end
    end
    
    onsets{end}=[onsets{end} onsets{end}(end)+durations{end}(end)]; durations{end}=[durations{end} len_end_rest/TR];  % end rest period
    cur_start_time = onsets{end}(end)*TR+durations{end}(end)*TR;
    
    if isempty(all_onsets)
        all_onsets=onsets;
        all_durations=durations;
    else
        for i=1:length(names)
            all_onsets{i}=[all_onsets{i} onsets{i}];
            all_durations{i}=[all_durations{i} durations{i}];
        end
    end
end

onsets=all_onsets; durations=all_durations;
if length(filenames)>1
    save([LOGPATH filenames{1} '_' filenames{2} '_design.mat'],'names','onsets','durations');
else
    save([LOGPATH filenames{1} '_design.mat'],'names','onsets','durations');
end
