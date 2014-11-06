function [names, onsets, durations]=create_ER_design_from_log(filenames, times_start_TRs, TR, len_stimulus, len_end_rest, num_removed_volumes)
% [names, onsets, durations]=create_ER_design_from_log(filenames, times_start_TRs, TR, len_stimulus, len_end_rest, num_removed_volumes)
%
% This function analyzes the results of runs of the distance comparison MRI 
% paradigm, and creates a .mat file with the study design (onsets/offsets
% of stimuli), for use in SPM analysis of the data
%
% The script treats each stimulus as separate (instead of all stimuli as
% one block)
% Also includes a rest predictor
%
% receives:
% - a cell array of filenames - number only (e.g. for c:\expyvr\log\123456789_keyboard.csv, give the function {'123456789'} )
% - a cell array of times of TR start relative to paradigm start 
%   (if paradigm was started 2 seconds before the scan was started, this would be 2)
% - the TR length in seconds
% - the stimulus length in seconds
% - the end-rest length in seconds (usually 15s)
% - the number of volumes removed at the beginning (sometimes 5)

% 3T distance design: times_start_TRs - changing, TR - 2 or 2.5, 
% len_stimulus - 2.5, len_end_rest - 15, num_removed_volumes - 5

% 7T distance design: times_start_TRs - 0, TR - 2.5, 
% len_stimulus - 2.5, len_end_rest - 15, num_removed_volumes - 0

LOGPATH = 'c:\expyvr\log\';
cur_start_time=0;
all_onsets=cell(0); all_durations=cell(0);

for q=1:length(filenames)
    b=fopen(strcat(LOGPATH,filenames{q},'_keyboard.csv'),'r');
    keyboard_data = textscan(b, '%f %f %f %s %s %s %f %f %f', 'Delimiter',',','HeaderLines',1);
    
    times=keyboard_data{2};
    times=round(times*2)/2-times_start_TRs{q}+cur_start_time;
    conditions=keyboard_data{5};
    
    names=unique(conditions); %names{end+1}='rest';
    onsets=cell(1,length(names)); durations=cell(1,length(names));
    % onsets{end}=cur_start_time/TR; durations{end}=(len_start_rest-times_start_TRs{q})/TR-num_removed_volumes; % initial rest period
    
    % first timepoint
    for j=1:length(names)
        if strcmp(conditions{1},names{j})
            onsets{j}=[onsets{j} times(1)/TR-num_removed_volumes];
            durations{j}=[durations{j} len_stimulus/TR];
        end
    end
    
    % the rest of the timepoints
    for i=2:length(times)
        if times(i)~=times(i-1)     % check for repeated clicks in the same stimulus
            for j=1:length(names)
                if strcmp(conditions{i},names{j})
                    onsets{j}=[onsets{j} times(i)/TR-num_removed_volumes];
                    durations{j}=[durations{j} len_stimulus/TR];
                end
            end
        end
    end
    
    cur_start_time = times(i)+len_stimulus+len_end_rest-2*num_removed_volumes;  % computed in seconds     
    
    if isempty(all_onsets)
        all_onsets=onsets;
        all_durations=durations;
    else
        for i=1:length(names)
            all_onsets{i}=[all_onsets{i} onsets{i}];
            all_durations{i}=[all_durations{i} durations{i}];
        end
    end
    
    fclose(b);
    
end

onsets=all_onsets; durations=all_durations;
if length(filenames)>1
    save([LOGPATH filenames{1} '_' filenames{2} '_ER_design.mat'],'names','onsets','durations');
else
    save([LOGPATH filenames{1} '_ER_design.mat'],'names','onsets','durations');
end
