function [names, onsets, durations]=create_design_PRT_XLS_from_log(filenames, times_start_TRs, TR, len_block, len_end_rest, num_excessive_TRs, num_removed_volumes)
% receives:
% - a cell array of filenames
% - a cell array of times of TR start relative to paradigm start 
%   (if paradigm was started 2 seconds before the scan was started, this would be 2)
% - the TR length in seconds
% - the block length in seconds
% - the end-rest length in seconds (usually 15s)
% - the number of excessive TRs in the paradigm (sometimes 1)
% - the number of volumes removed at the beginning (sometimes 5)

% 3T distance design: times_start_TRs - changing, TR - 2 or 2.5, len_block
% - 10, len_end_rest - 15, num_excessive_TRs - 1, num_removed_volumes - 5

% 7T distance design: times_start_TRs - 0, TR - 2.5, len_block - 10,
% len_end_rest - 15, num_excessive_TRs - 0, num_removed_volumes - 0


% LEN_REST=10;
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
    % onsets{end}=cur_start_time/TR; durations{end}=(len_start_rest-times_start_TRs{q})/TR-num_removed_volumes; % initial rest period
    
    % first timepoint
    for j=1:length(names)
        if strcmp(conditions{1},names{j})
            onsets{j}=[onsets{j} times(1)/TR-num_removed_volumes];
            durations{j}=[durations{j} len_block/TR];
            onsets{end}=[onsets{end} 0]; % start rest
            durations{end}=[durations{end} times(1)/TR]; 
            onsets{end}=[onsets{end} times(1)/TR-num_removed_volumes+len_block/TR]; % rest after first block
            durations{end}=[durations{end} LEN_REST/TR];            
        end
    end
        
    % the rest of the timepoints
    for i=2:length(times)
        if ~strcmp(conditions{i},conditions{i-1})   % check for switching of blocks
            for j=1:length(names)
                if strcmp(conditions{i},names{j})
                    onsets{j}=[onsets{j} times(i)/TR-num_removed_volumes];     % the first num_removed_volumes TRs were previously removed
                    durations{j}=[durations{j} len_block/TR];
                    onsets{end}=[onsets{end} times(i)/TR-num_removed_volumes+len_block/TR];
                    % durations{end}=[durations{end} LEN_REST/TR];
                    durations{end}=[durations{end} (times(i)-times(i-1)-len_stimulus)/TR];
                end
            end
        end
    end
    
    durations{end}(end)=len_end_rest/TR;  % end rest period
    cur_start_time = times(i)+len_block/4+len_end_rest+num_excessive_TRs*TR-2*num_removed_volumes; % computed in seconds
    
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
onsets=all_onsets'; durations=all_durations';

% saving the results to PRT excel file
% calculating end_points
m=cell2mat(onsets(1:end-1))'; 
m_inc_endpoints=zeros(size(m,1),size(m,2)*2); m_inc_endpoints(:,1:2:end)=m; 
m_inc_endpoints(:,2:2:end)=m+cell2mat(durations(1:end-1))';
m_inc_endpoints(:,1:2:end)=m_inc_endpoints(:,1:2:end)+1;
% preparing final matrix for saving
m_new=cell(length(onsets{end}),length(names)*2);
m_new(1:size(m_inc_endpoints,1),1:size(m_inc_endpoints,2))=num2cell(m_inc_endpoints);
% adding rest and rest end_points
rest_m=num2cell(onsets_new{end}+1);
m_new(1:length(rest_m),end-1)=rest_m;
m_new(1:length(rest_m),end)=num2cell(onsets_new{end}+durations_new{end});
names_new_new=cell(1,length(names)*2); names_new_new(1:2:end)=names;
xlswrite([LOGPATH filenames{1} '_PRT_block_design.xls'],[names_new_new;m_new]);


% domain design
names_new={'pe','pl','ti','rest'};
onsets_new=cell(length(names_new),1); durations_new=cell(length(names_new),1);
for i=1:length(names)
    for j=1:length(names_new)
        if strcmp(names{i}(1:2),names_new{j}) || strcmp(names{i}(1:4),names_new{j})
            onsets_new{j}=[onsets_new{j} onsets{i}];
            durations_new{j}=[durations_new{j} durations{i}];     % length of block/stimulus
        end
    end
end
% onsets_new{end}=onsets{end}; durations_new{end}=durations{end};

% saving the results to PRT excel file
% calculating end_points
m=cell2mat(onsets_new(1:end-1))'; 
m_inc_endpoints=zeros(size(m,1),size(m,2)*2); m_inc_endpoints(:,1:2:end)=m; 
m_inc_endpoints(:,2:2:end)=m+cell2mat(durations_new(1:end-1))';
m_inc_endpoints(:,1:2:end)=m_inc_endpoints(:,1:2:end)+1;
% preparing final matrix for saving
m_new=cell(length(onsets_new{end}),length(names_new)*2);
m_new(1:size(m_inc_endpoints,1),1:size(m_inc_endpoints,2))=num2cell(m_inc_endpoints);
% adding rest and rest end_points
rest_m=num2cell(onsets_new{end}+1);
m_new(1:length(rest_m),end-1)=rest_m;
m_new(1:length(rest_m),end)=num2cell(onsets_new{end}+durations_new{end});
names_new_new=cell(1,length(names_new)*2); names_new_new(1:2:end)=names_new;
xlswrite([LOGPATH filenames{1} '_PRT_domain_design.xls'],[names_new_new;m_new]);

% if length(filenames)>1
%     save([LOGPATH filenames{1} '_' filenames{2} '_design.mat'],'names','onsets','durations');
% else
%     save([LOGPATH filenames{1} '_design.mat'],'names','onsets','durations');
% end
