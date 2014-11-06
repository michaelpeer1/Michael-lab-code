function add_quest_fields_to_PRT_XLS(filenames, RightKey, LeftKey, user_age)

LOGPATH='c:\expyVR\log\';
%RightKey='G'; LeftKey='R';

% reading the output and keyboard files
data = cell(length(filenames),1);
keyboard_data = cell(length(filenames),1);
for i=1:length(filenames)
% i=1;
    a=fopen(strcat(LOGPATH,filenames{i},'_output.csv'),'r');                                            % the output log file
    data{i} = textscan(a, '%f %f %f %f', 'Delimiter',',','HeaderLines',1);
    b=fopen(strcat(LOGPATH,filenames{i},'_keyboard.csv'),'r');                                      % the keyboard log file
    keyboard_data{i} = textscan(b, '%f %f %f %s %s %s %f %f %f', 'Delimiter',',','HeaderLines',1);
    [ER_design,ER_design_names]=xlsread(strcat(LOGPATH,filenames{i},'_PRT_ER_design.xls'));   % the event-related design file created earlier
    ER_design=ER_design(:,1:2:end); ER_design_names=ER_design_names(:,1:2:end);
    ER_design=ER_design(:,1:end-1); ER_design_names=ER_design_names(:,1:end-1);
end


% getting the stimulus + questionnaire files
a=fopen(strcat(LOGPATH,filenames{1},'_output.csv'),'r');
header=textscan(a, '%s %s %s %s %s %s', 'Delimiter',',');
stimulus_filename=header{6}{1};
if strfind(stimulus_filename,'Michael-Distance')
    stimulus_filename=strcat('c:',stimulus_filename(strfind(stimulus_filename,'Michael-Distance')+16:end));
end
[~,~,stimulus_data]=xlsread(stimulus_filename);
ques_data=cell(3,1);
[~,~,ques_data{1}]=xlsread(strcat(stimulus_filename(1:end-11),'person_questionnaire.xls'));
[~,~,ques_data{2}]=xlsread(strcat(stimulus_filename(1:end-11),'place_questionnaire.xls'));
[~,~,ques_data{3}]=xlsread(strcat(stimulus_filename(1:end-11),'time_questionnaire.xls'));


% reading and sorting the questionnaire data
num_items=cell(3,1); num_fields=cell(3,1); ques_sort=cell(3,1);
for i=1:3
    for j=1:length(ques_data{i}(1:end,1))
        if isnan(ques_data{i}{j,1})==1, j=j-1; break; end
    end
    num_items{i}=j;
    for j=1:length(ques_data{i}(2,1:end))
        if isnan(ques_data{i}{1,j})==1, j=j-1; break; end
    end
    num_fields{i}=j;
    
    ques_data{i}=ques_data{i}(2:num_items{i},1:num_fields{i});
    ques_sort{i}=sortrows(ques_data{i});    % IF THERE IS AN ERROR HERE, it is probably because of wrong values in the questionnaires (e.g. string instead of int)
end


% creating new data matrix with sorted stimuli
new_data={};
% add each trial_time and condition
for i=1:size(ER_design,1)
    for j=1:size(ER_design,2)
        if ~isnan(ER_design(i,j))
            new_data{end+1,1}=ER_design(i,j);
            new_data{end,2}=ER_design_names{j};
        end
    end
end
new_data=sortrows(new_data,1);
headers={'trial_time', 'condition'};

% adding trial_num
curr_col=size(new_data,2)+1;  headers{curr_col}='trial_num';
new_data(:,curr_col)=num2cell(1:size(new_data,1))';


% adding index_R and index_L
curr_col=size(new_data,2)+1;  headers{curr_col}='index_R'; headers{curr_col+1}='index_L';
data{1}{1}=data{1}{1}-1;        % this is because the trials start from 2
for i=1:length(data{1}{1})
    new_data{data{1}{1}(i),curr_col}=data{1}{3}(i);    % index_R
    new_data{data{1}{1}(i),curr_col+1}=data{1}{4}(i);    % index_L
end


% adding response_time and key_pressed
% first stimulus
curr_col=size(new_data,2)+1;  headers{curr_col}='RT'; headers{curr_col+1}='key_pressed';
new_data{1,curr_col}=keyboard_data{1}{8}(1);   % RT
new_data{1,curr_col+1}=keyboard_data{1}{6}{1};   % key_pressed
% rest of stimuli
trial_counter=2;
for i=2:size(keyboard_data{1}{1},1)
    if keyboard_data{1}{1}(i) ~= keyboard_data{1}{1}(i-1)   % new stimulus
        % if column 3 is -1, it means the response box continued sending signal from the last stimulus. we don't want to use those indexes.
        if keyboard_data{1}{3}(i)~=-1
            new_data{trial_counter,curr_col}=keyboard_data{1}{8}(i);   % RT
            new_data{trial_counter,curr_col+1}=keyboard_data{1}{6}{i};   % key_pressed
            trial_counter=trial_counter+1;
        end
    end
end


% adding domain and distance
curr_col=size(new_data,2)+1;  headers{curr_col}='domain'; headers{curr_col+1}='distance';
for i=1:size(new_data,1)
    new_data{i,curr_col}=new_data{i,2}(1:2);
    new_data{i,curr_col+1}=str2num(new_data{i,2}(end));
end


% adding emotion
curr_col=size(new_data,2)+1;  headers{curr_col}='emotion_avg';
for i=1:size(new_data,1)
    ind_R=new_data{i,4}; ind_L=new_data{i,5};   % getting the stimuli indices
    if ~isempty(ind_R)
        if strcmp(new_data{i,8},'pe')
            emotion_R=ques_sort{1}{cell2mat(ques_sort{1}(:,1))==ind_R, 3};
            emotion_L=ques_sort{1}{cell2mat(ques_sort{1}(:,1))==ind_L, 3};
        elseif strcmp(new_data{i,8},'pl')
            emotion_R=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_R, 3};
            emotion_L=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_L, 3};
        elseif strcmp(new_data{i,8},'ti')
            emotion_R=ques_sort{3}{cell2mat(ques_sort{3}(:,1))==ind_R, 3};
            emotion_L=ques_sort{3}{cell2mat(ques_sort{3}(:,1))==ind_L, 3};
        end
        new_data{i,curr_col}=mean([emotion_R, emotion_L]);
    end
end


% adding person fields - know_personally, relation_type
curr_col=size(new_data,2)+1;  headers{curr_col}='know_personally'; headers{curr_col+1}='relation_type';
for i=1:size(new_data,1)
    ind_R=new_data{i,4}; ind_L=new_data{i,5};   % getting the stimuli indices
    if ~isempty(ind_R)
        if strcmp(new_data{i,8},'pe')
            % know_personally
            kp_R=ques_sort{1}{cell2mat(ques_sort{1}(:,1))==ind_R, 4};
            kp_L=ques_sort{1}{cell2mat(ques_sort{1}(:,1))==ind_L, 4};
            if kp_R+kp_L==0, new_data{i,curr_col}='nn';
            elseif kp_R+kp_L==1, new_data{i,curr_col}='yn';
            else new_data{i,curr_col}='yy';
            end
            % relation_type
            rty_R=ques_sort{1}{cell2mat(ques_sort{1}(:,1))==ind_R, 5};
            rty_L=ques_sort{1}{cell2mat(ques_sort{1}(:,1))==ind_L, 5};
            tmp_rty=sort({rty_R,rty_L});
            new_data{i,curr_col+1}=[tmp_rty{1} '-' tmp_rty{2}];
        end
    end
end


% adding place fields - been_there, how_many_times_avg, know_to_get
curr_col=size(new_data,2)+1;  headers{curr_col}='been_there'; headers{curr_col+1}='how_many_times_avg'; headers{curr_col+2}='know_to_get';
for i=1:size(new_data,1)
    ind_R=new_data{i,4}; ind_L=new_data{i,5};   % getting the stimuli indices
    if ~isempty(ind_R)
        if strcmp(new_data{i,8},'pl')
            % been_there
            bt_R=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_R, 4};
            bt_L=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_L, 4};
            if bt_R+bt_L==0, new_data{i,curr_col}='nn';
            elseif bt_R+bt_L==1, new_data{i,curr_col}='yn';
            else new_data{i,curr_col}='yy';
            end
            % how_many_times_avg
            hmt_R=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_R, 5};
            hmt_L=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_L, 5};
            new_data{i,curr_col+1}=mean([hmt_R,hmt_L]);
            % know_to_get
            ktg_R=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_R, 6};
            ktg_L=ques_sort{2}{cell2mat(ques_sort{2}(:,1))==ind_L, 6};
            if ktg_R+ktg_L==0, new_data{i,curr_col+2}='nn';
            elseif ktg_R+ktg_L==1, new_data{i,curr_col+2}='yn';
            else new_data{i,curr_col+2}='yy';
            end
        end
    end
end


% adding time fields - future-past, age_at_event_avg, age_dist_abs_avg
curr_col=size(new_data,2)+1;  headers{curr_col}='future-past'; headers{curr_col+1}='age_at_event_avg'; headers{curr_col+2}='age_dist_abs_avg';
for i=1:size(new_data,1)
    ind_R=new_data{i,4}; ind_L=new_data{i,5};   % getting the stimuli indices
    if ~isempty(ind_R)
        if strcmp(new_data{i,8},'ti')
            % future-past
            fp_R=ques_sort{3}{cell2mat(ques_sort{3}(:,1))==ind_R, 4};
            fp_L=ques_sort{3}{cell2mat(ques_sort{3}(:,1))==ind_L, 4};
            if fp_R+fp_L==0, new_data{i,curr_col}='fp';
            elseif fp_R+fp_L==2, new_data{i,curr_col}='ff';
            elseif  fp_R+fp_L==-2, new_data{i,curr_col}='pp';
            end
            % age_at_event_avg
            aae_R=ques_sort{3}{cell2mat(ques_sort{3}(:,1))==ind_R, 5};
            aae_L=ques_sort{3}{cell2mat(ques_sort{3}(:,1))==ind_L, 5};
            new_data{i,curr_col+1}=mean([aae_R,aae_L]);
            % age_dist_abs_avg - absolute difference from current age
            ada_R=abs(user_age-aae_R);
            ada_L=abs(user_age-aae_R);
            new_data{i,curr_col+2}=mean([ada_R,ada_L]);
        end
    end
end


% write results to file
if length(filenames)==1
    xlswrite(strcat(LOGPATH,filenames{1},'_PRT_w_quest_fields.xls'),[headers;new_data]);
else
    xlswrite(strcat(LOGPATH,filenames{1},'_',filenames{2},'_PRT_w_quest_fields.xls'),[headers;new_data]);
end


