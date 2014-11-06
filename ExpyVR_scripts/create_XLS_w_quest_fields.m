function create_XLS_w_quest_fields(filenames, RightKey, LeftKey)
% create_XLS_w_quest_fields(filenames, RightKey, LeftKey)
% 
% this script is similar to create_ER_design_XLS_w_quest_fields, but
% assumes no questionnaire was filled after the experiment, and adds
% computation of isCorrectUser
%
% receives:
% - a cell array of filenames - number only (e.g. for c:\expyvr\log\123456789_keyboard.csv, give the function {'123456789'} )
% - the right key (e.g. 'G')
% - the left key (e.g. 'A')


LOGPATH = 'c:\expyvr\log\';


all_new_data=cell(0);
data = cell(length(filenames),1);
keyboard_data = cell(length(filenames),1);

for q=1:length(filenames)
    % loading files and creating the paradigm
    
    b=fopen(strcat(LOGPATH,filenames{q},'_keyboard.csv'),'r');                                      % the keyboard log file
    keyboard_data{q} = textscan(b, '%f %f %f %s %s %s %f %f %f', 'Delimiter',',','HeaderLines',1);
    fclose(b);
    
    % removing bad lines (can be created by manual manipulation in excel)
    bad_lines = isnan(keyboard_data{q}{1});
    for i=1:length(keyboard_data{q})
        keyboard_data{q}{i}(bad_lines) = [];
    end
    
    % getting all times of stimuli
    times=keyboard_data{q}{2};
%     times=round(times*2)/2-times_start_TRs{q}+cur_start_time;
    times=round(times*2)/2;
    conditions=keyboard_data{q}{4};
    
    names=unique(conditions); % names{end+1}='rest';
    onsets=cell(1,length(names)); % durations=cell(1,length(names));
    % onsets{end}=cur_start_time/TR; durations{end}=(len_start_rest-times_start_TRs{q})/TR-num_removed_volumes; % initial rest period
    
    % getting the onsets of each condition separately
    % first timepoint
    for j=1:length(names)
        if strcmp(conditions{1},names{j})
%             onsets{j}=[onsets{j} times(1)/TR-num_removed_volumes];
            onsets{j}=[onsets{j} times(1)];
            % durations{j}=[durations{j} len_stimulus/TR];
%             onsets{end}=[onsets{end} 0]; % start rest
            % durations{end}=[durations{end} times(1)/TR];
        end
    end
    
    % the rest of the timepoints
    for i=2:length(times)
        if times(i)~=times(i-1)     % check for repeated clicks in the same stimulus
            for j=1:length(names)
                if strcmp(conditions{i},names{j})
%                     onsets{j}=[onsets{j} times(i)/TR-num_removed_volumes];     % the first num_removed_volumes TRs were previously removed
                    onsets{j}=[onsets{j} times(i)];     % the first num_removed_volumes TRs were previously removed
                    % durations{j}=[durations{j} len_stimulus/TR];
                end
            end
%             if (times(i)-times(i-1)) > len_stimulus   % rest between blocks
%                 onsets{end}=[onsets{end} times(i-1)/TR-num_removed_volumes+len_stimulus/TR];
%                 onsets{end}=[onsets{end} times(i-1)/TR-num_removed_volumes+len_stimulus/TR];
%                 % durations{end}=[durations{end} LEN_REST/TR];
%                 % durations{end}=[durations{end} (times(i)-times(i-1)-len_stimulus)/TR];
%             end
        end
    end
    
%     onsets{end}=[onsets{end} times(end)/TR-num_removed_volumes+len_stimulus/TR]; % end rest period
    % durations{end}=[durations{end} durations{end}(end) len_end_rest/TR];
    
%     cur_start_time = times(i)+len_stimulus+len_end_rest+num_excessive_TRs*TR-2*num_removed_volumes; % computed in seconds
    
%     if isempty(all_onsets)
%         all_onsets=onsets;
%         all_durations=durations;
%     else
%         for i=1:length(names)
%             all_onsets{i}=[all_onsets{i} onsets{i}];
%             all_durations{i}=[all_durations{i} durations{i}];
%         end
%     end
    
    
    %% adding questionnaire fields
    
    a=fopen(strcat(LOGPATH,filenames{q},'_output.csv'),'r');                                            % the output log file
    data{q} = textscan(a, '%f %f %f %f', 'Delimiter',',','HeaderLines',1);
    fclose(a);
    a=fopen(strcat(LOGPATH,filenames{q},'_output.csv'),'r');                                            % the output log file
    header=textscan(a, '%s %s %s %s %s %s', 'Delimiter',',');
    fclose(a);
    stimulus_filename=header{6}{1};
%     if strfind(stimulus_filename,'Michael-Distance')
%         stimulus_filename=strcat('c:',stimulus_filename(strfind(stimulus_filename,'Michael-Distance')+16:end));
%     end
    [~,~,stimulus_data]=xlsread(stimulus_filename);
%     ques_data=cell(3,1);
%     [~,~,ques_data{1}]=xlsread(strcat(stimulus_filename(1:end-11),'person_questionnaire.xls'));
%     [~,~,ques_data{2}]=xlsread(strcat(stimulus_filename(1:end-11),'place_questionnaire.xls'));
%     [~,~,ques_data{3}]=xlsread(strcat(stimulus_filename(1:end-11),'time_questionnaire.xls'));
%     num_items=cell(3,1); num_fields=cell(3,1); ques_sort=cell(3,1);
%     for i=1:3
%         for j=1:length(ques_data{i}(1:end,1))
%             if isnan(ques_data{i}{j,1})==1, j=j-1; break; end
%         end
%         num_items{i}=j;
%         for j=1:length(ques_data{i}(2,1:end))
%             if isnan(ques_data{i}{1,j})==1, j=j-1; break; end
%         end
%         num_fields{i}=j;
%         
%         ques_data{i}=ques_data{i}(2:num_items{i},1:num_fields{i});
%         ques_sort{i}=sortrows(ques_data{i});    % IF THERE IS AN ERROR HERE, it is probably because of wrong values in the questionnaires (e.g. string instead of int)
%     end
    
    
    % creating new data matrix with sorted stimuli
    new_data={};
    % add each trial_time and condition
%     for i=1:length(names)-1
    for i=1:length(names)
        for j=1:length(onsets{i})
            new_data{end+1,1}=onsets{i}(j);
            new_data{end,2}=names{i};
        end
    end
    new_data=sortrows(new_data,1);
    headers={'trial_time', 'condition'};
    
    % adding trial_num
    curr_col=3;  headers{curr_col}='trial_num';
    new_data(:,curr_col)=num2cell(1:size(new_data,1))';
    
    
    % adding index_R and index_L
    curr_col=4;  headers{curr_col}='index_R'; headers{curr_col+1}='index_L';
    data{q}{1}=data{q}{1}-1;        % this is because the trials start from 2
    if data{q}{1}(1)==0             
        for i=1:length(data{q})
            data{q}{i}(1) = [];     % removing trial 1, if existing
        end
    end
    % saving the R and L indices - first row
    new_data{data{q}{1}(1),curr_col}=data{q}{3}(1);    % index_R
    new_data{data{q}{1}(1),curr_col+1}=data{q}{4}(1);    % index_L
    row_counter=2;
    for i=2:length(data{q}{1})      % saving the R and L indices - second row and forward
        if data{q}{3}(i)~=data{q}{3}(i-1) || data{q}{4}(i)~=data{q}{4}(i-1)     % checking that the row isn't duplicated in the output file
            new_data{data{q}{1}(row_counter),curr_col}=data{q}{3}(i);    % index_R
            new_data{data{q}{1}(row_counter),curr_col+1}=data{q}{4}(i);    % index_L
            row_counter = row_counter + 1;
        end
    end
    
    
    % adding run number (in case of several runs on the same subject)
    curr_col=6;  headers{curr_col}='run';
    new_data(:,curr_col)=num2cell(ones(1,size(new_data,1))*q)';

    
    % adding response_time and key_pressed
    % first stimulus
    curr_col=7;  headers{curr_col}='RT'; headers{curr_col+1}='key_pressed';
    new_data{1,curr_col}=keyboard_data{q}{7}(1);   % RT
    new_data{1,curr_col+1}=keyboard_data{q}{6}{1};   % key_pressed
    % rest of stimuli
    trial_counter=2;
    for i=2:size(keyboard_data{q}{1},1)
        if keyboard_data{q}{3}(i) ~= keyboard_data{q}{3}(i-1)   % new stimulus
            % if column 3 is -1, it means the response box continued sending signal from the last stimulus. we don't want to use those indexes.
            if keyboard_data{q}{3}(i)~=-1
                new_data{trial_counter,curr_col}=keyboard_data{q}{7}(i);   % RT
                new_data{trial_counter,curr_col+1}=keyboard_data{q}{6}{i};   % key_pressed
                trial_counter=trial_counter+1;
            elseif keyboard_data{q}{3}(i)==-1 && keyboard_data{q}{2}(i) ~= keyboard_data{q}{2}(i+1)
                new_data{trial_counter,curr_col} = -1;   % RT
                new_data{trial_counter,curr_col+1} = '';   % key_pressed
                trial_counter=trial_counter+1;
            end
        end
    end
    
    
    % adding domain and distance
    curr_col=9;  headers{curr_col}='domain'; % headers{curr_col+1}='distance';
    for i=1:size(new_data,1)
        new_data{i,curr_col}=new_data{i,2}(1:2);
        % new_data{i,curr_col+1}=str2num(new_data{i,2}(end));
    end
    
    
    % adding length of stimulus and number of words
    curr_col=10;  headers{curr_col}='length_stim'; headers{curr_col+1}='num_words';
    for i=1:size(new_data,1)
        ind_R=new_data{i,4}; ind_L=new_data{i,5};   % getting the stimuli indices
        if ~isempty(ind_R)
            curr_stim_R=stimulus_data{ind_R+2,2}; len_stim_R = length(curr_stim_R); numwords_R = length(regexp(curr_stim_R, '\s+'))+1;
            curr_stim_L=stimulus_data{ind_L+2,2}; len_stim_L = length(curr_stim_L); numwords_L = length(regexp(curr_stim_L, '\s+'))+1;
            new_data{i,curr_col}=mean([len_stim_R, len_stim_L]);
            new_data{i,curr_col+1}=mean([numwords_R, numwords_L]);
        end
    end
    
    
    % getting user distances from the stimulus file
    curr_col=12;  headers{curr_col}='UserDistR'; headers{curr_col+1}='UserDistL';
    for i=1:size(new_data,1)
        ind_R=new_data{i,4}; ind_L=new_data{i,5};   % getting the stimuli indices
        if ~isempty(ind_R)
            curr_stim_R_dist = stimulus_data{ind_R+2,3};
            curr_stim_L_dist = stimulus_data{ind_L+2,3};
            new_data{i,curr_col} = curr_stim_R_dist;
            new_data{i,curr_col+1} = curr_stim_L_dist;
        end
    end

    
    % calculating if response is correct and which stimulus appeared closer for user distances
    curr_col=14;  headers{curr_col}='IsCorrectUser'; headers{curr_col+1}='CloserStimulusUser';
    for i=1:size(new_data,1)
        curr_stim_R_dist=new_data{i,12}; curr_stim_L_dist=new_data{i,13};
        curr_key_pressed=new_data{i,8};

        if curr_key_pressed==RightKey
            if curr_stim_R_dist<curr_stim_L_dist
                new_data{i,curr_col}='correct';
                new_data{i,curr_col+1}='Right';
            elseif curr_stim_R_dist>curr_stim_L_dist
                new_data{i,curr_col}='wrong';
                new_data{i,curr_col+1}='Left';
            else
                new_data{i,curr_col}='equal_dist';
                new_data{i,curr_col+1}='equal_dist';
            end
        elseif curr_key_pressed==LeftKey
            if curr_stim_R_dist>curr_stim_L_dist
                new_data{i,curr_col}='correct';
                new_data{i,curr_col+1}='Left';
            elseif curr_stim_R_dist<curr_stim_L_dist
                new_data{i,curr_col}='wrong';
                new_data{i,curr_col+1}='Right';
            else
                new_data{i,curr_col}='equal_dist';
                new_data{i,curr_col+1}='equal_dist';
            end 
        end
    end
    
    
%     % adding emotion
%     curr_col=size(new_data,2)+1;  headers{curr_col}='emotion_avg';
%     for i=1:size(new_data,1)
%         ind_R=new_data{i,4}; ind_L=new_data{i,5};   % getting the stimuli indices
%         if ~isempty(ind_R)
%             if strcmp(new_data{i,9},'pe')
%                 emotion_R=ques_sort{1}{cell2mat(ques_sort{1}(:,1))==ind_R, 3};
%                 emotion_L=ques_sort{1}{cell2mat(ques_sort{1}(:,1))==ind_L, 3};
%             elseif strcmp(new_data{i,9},'pl')
%                 emotion_R=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_R, 3};
%                 emotion_L=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_L, 3};
%             elseif strcmp(new_data{i,9},'ti')
%                 emotion_R=ques_sort{3}{cell2mat(ques_sort{3}(:,1))==ind_R, 3};
%                 emotion_L=ques_sort{3}{cell2mat(ques_sort{3}(:,1))==ind_L, 3};
%             end
%             new_data{i,curr_col}=mean([emotion_R, emotion_L]);
%         end
%     end
%     
%     
%     % adding person fields - know_personally, relation_type
%     curr_col=size(new_data,2)+1;  headers{curr_col}='know_personally'; headers{curr_col+1}='relation_type';
%     for i=1:size(new_data,1)
%         ind_R=new_data{i,4}; ind_L=new_data{i,5};   % getting the stimuli indices
%         if ~isempty(ind_R)
%             if strcmp(new_data{i,9},'pe')
%                 % know_personally
%                 kp_R=ques_sort{1}{cell2mat(ques_sort{1}(:,1))==ind_R, 4};
%                 kp_L=ques_sort{1}{cell2mat(ques_sort{1}(:,1))==ind_L, 4};
%                 if kp_R+kp_L==0, new_data{i,curr_col}='nn';
%                 elseif kp_R+kp_L==1, new_data{i,curr_col}='yn';
%                 else new_data{i,curr_col}='yy';
%                 end
%                 % relation_type
%                 rty_R=ques_sort{1}{cell2mat(ques_sort{1}(:,1))==ind_R, 5};
%                 rty_L=ques_sort{1}{cell2mat(ques_sort{1}(:,1))==ind_L, 5};
%                 tmp_rty=sort({rty_R,rty_L});
%                 new_data{i,curr_col+1}=[tmp_rty{1} '-' tmp_rty{2}];
%             end
%         end
%     end
%     
%     
%     % adding place fields - been_there, how_many_times_avg, know_to_get
%     curr_col=size(new_data,2)+1;  headers{curr_col}='been_there'; headers{curr_col+1}='how_many_times_avg'; headers{curr_col+2}='know_to_get';
%     for i=1:size(new_data,1)
%         ind_R=new_data{i,4}; ind_L=new_data{i,5};   % getting the stimuli indices
%         if ~isempty(ind_R)
%             if strcmp(new_data{i,9},'pl')
%                 % been_there
%                 bt_R=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_R, 4};
%                 bt_L=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_L, 4};
%                 if bt_R+bt_L==0, new_data{i,curr_col}='nn';
%                 elseif bt_R+bt_L==1, new_data{i,curr_col}='yn';
%                 else new_data{i,curr_col}='yy';
%                 end
%                 % how_many_times_avg
%                 hmt_R=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_R, 5};
%                 hmt_L=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_L, 5};
%                 new_data{i,curr_col+1}=mean([hmt_R,hmt_L]);
%                 % know_to_get
%                 ktg_R=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_R, 6};
%                 ktg_L=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_L, 6};
%                 if ktg_R+ktg_L==0, new_data{i,curr_col+2}='nn';
%                 elseif ktg_R+ktg_L==1, new_data{i,curr_col+2}='yn';
%                 else new_data{i,curr_col+2}='yy';
%                 end
%             end
%         end
%     end
%     
%     
%     % adding time fields - future-past, age_at_event_avg, age_dist_abs_avg
%     curr_col=size(new_data,2)+1;  headers{curr_col}='future-past'; headers{curr_col+1}='age_at_event_avg'; headers{curr_col+2}='age_dist_abs_avg';
%     for i=1:size(new_data,1)
%         ind_R=new_data{i,4}; ind_L=new_data{i,5};   % getting the stimuli indices
%         if ~isempty(ind_R)
%             if strcmp(new_data{i,9},'ti')
%                 % future-past
%                 fp_R=ques_sort{3}{cell2mat(ques_sort{3}(:,1))==ind_R, 4};
%                 fp_L=ques_sort{3}{cell2mat(ques_sort{3}(:,1))==ind_L, 4};
%                 if fp_R+fp_L==0, new_data{i,curr_col}='fp';
%                 elseif fp_R+fp_L==2, new_data{i,curr_col}='ff';
%                 elseif  fp_R+fp_L==-2, new_data{i,curr_col}='pp';
%                 end
%                 % age_at_event_avg
%                 aae_R=ques_sort{3}{cell2mat(ques_sort{3}(:,1))==ind_R, 5};
%                 aae_L=ques_sort{3}{cell2mat(ques_sort{3}(:,1))==ind_L, 5};
%                 new_data{i,curr_col+1}=mean([aae_R,aae_L]);
%                 % age_dist_abs_avg - absolute difference from current age
%                 ada_R=abs(user_age-aae_R);
%                 ada_L=abs(user_age-aae_R);
%                 new_data{i,curr_col+2}=mean([ada_R,ada_L]);
%             end
%         end
%     end
    
    %% combining results from many files (if needed) and saving to XLS

    if isempty(all_new_data)
        all_new_data=new_data;
    else
            all_new_data = [all_new_data; new_data];
    end
    
    % write results to XLS file
%     if length(filenames)==1
        xlswrite(strcat(LOGPATH,filenames{q},'_XLS_simple_w_quest_fields.xls'),[headers;all_new_data]);
%     else
%         xlswrite(strcat(LOGPATH,filenames{1},'_',filenames{end},'_XLS_w_quest_fields.xls'),[headers;all_new_data]);
%     end
    
     %% writing PRT file
% %     conditions_for_PRT=[3 6:7 10:13];
%     conditions_for_PRT=[7 11:13];
%     new_data_for_prt=new_data(:, conditions_for_PRT); 
%     headers_for_prt=headers(:, conditions_for_PRT);
%     output_filename=fullfile(output_dir, ['Confounds_' num2str(q) '.sdm']);
% 
%     fid=fopen(output_filename,'w');
%     fprintf(fid,'FileVersion:        1\n\nNrOfPredictors:   %d\n', length(conditions_for_PRT)+2);
% %     fprintf(fid,'NrOfDataPoints:         %d\n', size(new_data,1));
%     fprintf(fid,'NrOfDataPoints:         160\n');
%     fprintf(fid,'IncludesConstant:    0\nFirstConfoundPredictor:          1\n\n');
%     
%     rows=cell(1,size(new_data_for_prt,1)+3);
%     for i=1:length(conditions_for_PRT)
%         % first row - colors
%         rows{1}=[rows{1} '   255 0 0'];
%         % second row - names of conditions
%         rows{2}=[rows{2} ' "' headers_for_prt{i} '"'];
%         % third row and down - values
%         for j=1:size(new_data_for_prt,1)
%             if ~isnan(new_data_for_prt{j,i})
%                 rows{2+j}=[rows{2+j}  ' ' num2str(new_data_for_prt{j,i})];
%             else
%                 rows{2+j}=[rows{2+j}  ' 0'];
%             end
%         end
%     end
%     
%     % adding past-future regressors - column 17
%     rows{1}=[rows{1} '   255 0 0   255 0 0'];
%     rows{2}=[rows{2} ' "future" "past"'];
%     for j=1:size(new_data,1)
%         if strcmp(new_data{j,19},'pp')
%             rows{2+j}=[rows{2+j}  ' 0 1'];
%         elseif strcmp(new_data{j,19},'fp')
%             rows{2+j}=[rows{2+j}  ' 1 1'];
%         elseif strcmp(new_data{j,19},'ff')
%             rows{2+j}=[rows{2+j}  ' 1 0'];
%         else
%             rows{2+j}=[rows{2+j}  ' 0 0'];
%         end
%     end
%     
%     % adding rest times
%     rows_new={}; counter_rows=3;
%     for j=1:10     % start rest
%         rows_new{j} = repmat(' 0', 1, length(conditions_for_PRT)+2);
%     end
%     % blocks with rest
%     for j=11:150
%         if mod(ceil((j-10)/4),2)
%             rows_new{j}=rows{counter_rows};
%             counter_rows=counter_rows+1;
%         else
%             rows_new{j} = repmat(' 0', 1, length(conditions_for_PRT)+2);
%         end
%     end
%     for j=151:160     % end rest
%         rows_new{j} = repmat(' 0', 1, length(conditions_for_PRT)+2);
%     end
%     rows_new=[rows(1:2) rows_new];
%     
%     % zeroing the -1 values in the RT column
%     for i=1:length(rows_new)
%         if strcmp(rows_new{i}(1:3),' -1')
%             rows_new{i}=[' 0' rows_new{i}(4:end)];
%         end
%     end
% 
%     % writing PRT file
% %     for i=1:length(rows)
% %         fprintf(fid, [rows{i} '\n']);
% %     end
%     for i=1:length(rows_new)
%         fprintf(fid, [rows_new{i} '\n']);
%     end
%     
%     fclose(fid);

end


