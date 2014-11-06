function [mnn_abs_dist_including_zero, mnn_abs_dist_far, mnn_between_dist, mnn_isCorrect] = analyze_comparison(LOGPATH, filename, subj_name)
% [mnn_abs_dist_including_zero, mnn_abs_dist_far, mnn_between_dist, mnn_isCorrect] = analyze_comparison(LOGPATH, filename, subj_name)
% 
% This function analyzes the results of the distance comparison paradigm in
% time, space and person, using the output and keyboard files from EXPYVR
% log directory
% (Paradigm: see two stimuli, press left/right based on which is closer to you)
% The function writes the results to an Excel (XLS) file

RightKey='G'; LeftKey='A';

a=fopen(strcat(LOGPATH,filename,'_output.csv'),'r');                                            % the output log file
data = textscan(a, '%f %f %f %f', 'Delimiter',',','HeaderLines',1);
b=fopen(strcat(LOGPATH,filename,'_keyboard.csv'),'r');
keyboard_data = textscan(b, '%f %f %f %s %s %s %f %f %f', 'Delimiter',',','HeaderLines',1);     % the keyboard log file
[~,~,ques_data]=xlsread(strcat(LOGPATH,filename,'_questionnaire.xls'));

% getting the stimulus file
a=fopen(strcat(LOGPATH,filename,'_output.csv'),'r');
datanew=textscan(a, '%s %s %s %s %s %s', 'Delimiter',',');
stimulus_filename=datanew{6}{1};
[~,~,stimulus_data]=xlsread(stimulus_filename);

% reading and sorting the questionnaire data
num_items=0; num_fields=0;
for i=1:length(ques_data(2:end,1))
    if isnan(ques_data{i+1,1})==1
        break;
    end
    num_items=num_items+1;
end
for i=1:length(ques_data(2,1:end))
    if isnan(ques_data{1,i+1})==1
        break;
    end
    num_fields=num_fields+1;
end
ques_data=ques_data(2:num_items+1,1:num_fields+1);
ques_sort=sortrows(ques_data);

% assigning the columns of the log files to variables
trials=data{1};
indexR=data{3};
indexL=data{4};

keys_all={}; keys={};
RT_all={}; RT={};
conditions_all={}; conditions={};
for i=1:length(keyboard_data{1})
    if (keyboard_data{9}(i)~=-1)        % If column 9 is -1, it means two keys were pressed at once.
        keys_all{end+1}=keyboard_data{6}{i};
        RT_all{end+1}=keyboard_data{8}(i);
        conditions_all{end+1}=keyboard_data{5}{i};
    elseif i~=1 && (keyboard_data{8}(i)==-1 || keyboard_data{1}(i)~=keyboard_data{1}(i-1)) % if column 8 is -1, it means the allowed time to answer has passed.
        keys_all{end+1}=keyboard_data{6}{i};
        RT_all{end+1}=keyboard_data{8}(i);
        conditions_all{end+1}=keyboard_data{5}{i};
    elseif i==1
        keys_all{end+1}=keyboard_data{6}{i};
        RT_all{end+1}=keyboard_data{8}(i);
        conditions_all{end+1}=keyboard_data{5}{i};
    end
end
for i=1:length(trials)                  % removing trials missing from the output file
    keys{end+1}=keys_all{trials(i)};
    RT{end+1}=RT_all{trials(i)};
    conditions{end+1}=conditions_all{trials(i)};
end

% getting the different conditions options
all_conditions={};
conditions_column=find(cellfun(@(x)strcmp(x,'conditions'),stimulus_data(1,1:end)));     % find the conditions column in the stimulus file
for i=2:length(stimulus_data(2:end,conditions_column))
    if isnan(stimulus_data{i,conditions_column})
        break;
    end
    all_conditions{end+1}=stimulus_data{i,conditions_column};
    if isstr(all_conditions{end})==0
        all_conditions{end}=int2str(all_conditions{end});
    end
end

% update data from the questionnaire and stimulus files
real_distL={}; real_distR={}; user_distL={}; user_distR={};
knowL={}; emotionL={}; %been_thereL={}; how_many_timesL={};
knowR={}; emotionR={}; %been_thereR={}; how_many_timesR={};
additional_ques_fieldsL={}; additional_ques_fieldsR={};         % for additional questionnaire fields above the general 6 fields
if num_fields>6
    for i=8:num_fields+1
        additional_ques_fieldsL{end+1}={}; additional_ques_fieldsR{end+1}={};
    end
end
add_field_num=num_fields-6;
additional_stim_fieldsL={}; additional_stim_fieldsR={};         % for additional stimulus-file fields above the general 4 fields
if conditions_column>6
    for i=6:conditions_column-1
        additional_stim_fieldsL{end+1}={}; additional_stim_fieldsR{end+1}={};
    end
end
add_stim_field_num=conditions_column-6;
for i=1:length(trials)                                          % adding the needed fields
    for j=1:length(all_conditions)
        if strcmp(conditions{i},all_conditions{j})
            real_distL{end+1}=stimulus_data{indexL(i)+2,2+j};
            real_distR{end+1}=stimulus_data{indexR(i)+2,2+j};
            user_distL{end+1}=ques_sort{indexL(i)+1,2+j};
            user_distR{end+1}=ques_sort{indexR(i)+1,2+j};
        end
    end
    knowL{end+1}=ques_sort{indexL(i)+1,6};
    emotionL{end+1}=ques_sort{indexL(i)+1,7};
    knowR{end+1}=ques_sort{indexR(i)+1,6};
    emotionR{end+1}=ques_sort{indexR(i)+1,7};
    if add_field_num>0                                          % for additional questionnaire fields
        for q=1:add_field_num
            additional_ques_fieldsL{q}{end+1}=ques_sort{indexL(i)+1,7+q};
            additional_ques_fieldsR{q}{end+1}=ques_sort{indexR(i)+1,7+q};
        end
    end
    if add_stim_field_num>0                                          % for additional stimulus-file fields
        for q=1:add_stim_field_num
            additional_stim_fieldsL{q}{end+1}=stimulus_data{indexL(i)+2,5+q};
            additional_stim_fieldsR{q}{end+1}=stimulus_data{indexR(i)+2,5+q};
        end
    end
end

% Calculate if response is correct and which stimulus appeared closer for real distances
isCorrectReal={}; CloserStimulusReal={};
for i=1:length(trials)
    if real_distR{i}==-1 || real_distL{i}==-1
        isCorrectReal{end+1}='no_real_dist';
        CloserStimulusReal{end+1}='no_real_dist';
        continue;
    end
    if keys{i}==RightKey
        if real_distR{i}<real_distL{i}
            isCorrectReal{end+1}='correct';
            CloserStimulusReal{end+1}='Right';
        elseif real_distR{i}>real_distL{i}
            isCorrectReal{end+1}='wrong';
            CloserStimulusReal{end+1}='Left';
        else
            isCorrectReal{end+1}='equal_dist';
            CloserStimulusReal{end+1}='equal_dist';
        end
    elseif keys{i}==LeftKey
        if real_distR{i}>real_distL{i}
            isCorrectReal{end+1}='correct';
            CloserStimulusReal{end+1}='Left';
        elseif real_distR{i}<real_distL{i}
            isCorrectReal{end+1}='wrong';
            CloserStimulusReal{end+1}='Right';
        else
            isCorrectReal{end+1}='equal_dist';
            CloserStimulusReal{end+1}='equal_dist';
        end
    end
end

% Calculate if response is correct and which stimulus appeared closer for user distances
isCorrectUser={}; CloserStimulusUser={}; 
for i=1:length(trials)
    if keys{i}==RightKey
        if user_distR{i}<user_distL{i}
            isCorrectUser{end+1}='correct';
            CloserStimulusUser{end+1}='Right';
        elseif user_distR{i}>user_distL{i}
            isCorrectUser{end+1}='wrong';
            CloserStimulusUser{end+1}='Left';
        else
            isCorrectUser{end+1}='equal_dist';
            CloserStimulusUser{end+1}='equal_dist';
        end
    elseif keys{i}==LeftKey
        if user_distR{i}>user_distL{i}
            isCorrectUser{end+1}='correct';
            CloserStimulusUser{end+1}='Left';
        elseif user_distR{i}<user_distL{i}
            isCorrectUser{end+1}='wrong';
            CloserStimulusUser{end+1}='Right';
        else
            isCorrectUser{end+1}='equal_dist';
            CloserStimulusUser{end+1}='equal_dist';
        end
    end
end

% calculate closest and farthest distances, and distance between stimuli
Closest_dist_user=transpose(min(cell2mat(user_distR),cell2mat(user_distL))); 
Closest_dist_real=transpose(min(cell2mat(real_distR),cell2mat(real_distL))); 
Farthest_dist_user=transpose(max(cell2mat(user_distR),cell2mat(user_distL)));
Farthest_dist_real=transpose(max(cell2mat(real_distR),cell2mat(real_distL))); 
Between_dist_user=transpose(abs(cell2mat(user_distR)-cell2mat(user_distL)));
Between_dist_real=transpose(abs(cell2mat(real_distR)-cell2mat(real_distL))); 

keys=transpose(keys); RT=transpose(RT); conditions=transpose(conditions);
real_distL=transpose(real_distL); real_distR=transpose(real_distR); user_distL=transpose(user_distL); user_distR=transpose(user_distR);
knowL=transpose(knowL); emotionL=transpose(emotionL); %been_thereL=transpose(been_thereL); how_many_timesL=transpose(how_many_timesL);
knowR=transpose(knowR); emotionR=transpose(emotionR); %been_thereR=transpose(been_thereR); how_many_timesR=transpose(how_many_timesR);
isCorrectReal=transpose(isCorrectReal); isCorrectUser=transpose(isCorrectUser);
CloserStimulusUser=transpose(CloserStimulusUser); CloserStimulusReal=transpose(CloserStimulusReal);

% write results to file
headers={'trials','indexR','indexL','RT','condition','key','real_distR','real_distL','isCorrectReal','user_distR','user_distL','isCorrectUser','knowR','emotionR','knowL','emotionL','Closest_dist_user','Closest_dist_real','Farthest_dist_user','Farthest_dist_real','Between_dist_user','Between_dist_real','CloserStimulusUser','CloserStimulusReal'};
DataToFile=[num2cell([trials,indexR,indexL]),RT,conditions,keys,real_distR,real_distL,isCorrectReal,user_distR,user_distL,isCorrectUser,knowR,emotionR,knowL,emotionL,num2cell([Closest_dist_user,Closest_dist_real,Farthest_dist_user,Farthest_dist_real,Between_dist_user,Between_dist_real]),CloserStimulusUser,CloserStimulusReal];
for i=1:length(additional_ques_fieldsL)                 % adding additional questionnaire fields
    additional_ques_fieldsL{i}=transpose(additional_ques_fieldsL{i}); 
    additional_ques_fieldsR{i}=transpose(additional_ques_fieldsR{i});
    headers{end+1}=strcat('questionnaire_field',int2str(i+6),'_R');
    headers{end+1}=strcat('questionnaire_field',int2str(i+6),'_L');
    DataToFile=[DataToFile additional_ques_fieldsR{:,i}];
    DataToFile=[DataToFile additional_ques_fieldsL{:,i}];
end
for i=1:length(additional_stim_fieldsL)                 % adding additional stimulus-file fields
    additional_stim_fieldsL{i}=transpose(additional_stim_fieldsL{i}); 
    additional_stim_fieldsR{i}=transpose(additional_stim_fieldsR{i});
    headers{end+1}=strcat('stimulus_field',int2str(i+5),'_R');
    headers{end+1}=strcat('stimulus_field',int2str(i+5),'_L');
    DataToFile=[DataToFile additional_stim_fieldsR{:,i}];
    DataToFile=[DataToFile additional_stim_fieldsL{:,i}];
end
xlswrite(strcat(LOGPATH,filename,'_results.xls'),[headers;DataToFile]);

% num_trials=length(abs_dist);
% 
% % getting the RTs for each specific absolute distance of closest stimulus
% % from the two stimuli
% abs_dist_RTs=cell(1,max(abs_dist));
% for i=1:max(abs_dist)
%     for j=1:num_trials
%         if abs_dist(j)==i
%             abs_dist_RTs{i}=[abs_dist_RTs{i} RT(trials(j))];
%         end
%     end
% end
% abs_dist_zero_RTs=[];           % for the value of zero in the abs_dist parameter
% for j=1:num_trials
%     if abs_dist(j)==0
%         abs_dist_zero_RTs=[abs_dist_zero_RTs RT(trials(j))];
%     end
% end
% 
% % getting the RTs for each specific distance between the two stimuli
% between_dist_RTs=cell(1,max(between_dist));
% for i=1:max(between_dist)
%     for j=1:num_trials
%         if between_dist(j)==i
%             between_dist_RTs{i}=[between_dist_RTs{i} RT(trials(j))];
%         end
%     end
% end
% 
% % getting the RTs for each specific absolute distance of farthest stimulus
% % from the two stimuli
% abs_dist_far_RTs=cell(1,max(abs_dist_far));
% for i=1:max(abs_dist_far)
%     for j=1:num_trials
%         if abs_dist_far(j)==i
%             abs_dist_far_RTs{i}=[abs_dist_far_RTs{i} RT(trials(j))];
%         end
%     end
% end
% 
% % getting the RTs for each response type (correct / error)
% isCorrect_RTs=cell(1,2);
% for j=1:num_trials
%     if strcmp(isCorrect(j),'correct')
%         isCorrect_RTs{1}=[isCorrect_RTs{1} RT(trials(j))];
%     elseif strcmp(isCorrect(j),'wrong')
%         isCorrect_RTs{2}=[isCorrect_RTs{2} RT(trials(j))];
%     end
% end
% 
% % getting the mean RT for each group and plotting graphs
% figure('Position',[100,100,800,600]);
% 
% subplot(2,2,1);
% l=length(abs_dist_RTs);
% mn=cell(1,l);
% for i=1:l
% mn{i}=mean(abs_dist_RTs{i});
% end
% mn0=mean(abs_dist_zero_RTs);
% mnn_abs_dist=[];
% for i=1:l
% mnn_abs_dist=[mnn_abs_dist mn{i}(1)];
% end
% mnn_abs_dist_including_zero = [mn0 mnn_abs_dist];
% plot(0:length(mnn_abs_dist),mnn_abs_dist_including_zero,'*-');
% xlabel('Absolute Distance of closest point'); ylabel('mean RT');
% 
% subplot(2,2,2);
% l=length(abs_dist_far_RTs);
% mn=cell(1,l);
% for i=1:l
% mn{i}=mean(abs_dist_far_RTs{i});
% end
% mnn_abs_dist_far=[];
% for i=1:l
% mnn_abs_dist_far=[mnn_abs_dist_far mn{i}(1)];
% end
% plot(mnn_abs_dist_far,'*-');
% xlabel('Absolute Distance of farthest point'); ylabel('mean RT');
% 
% subplot(2,2,3);
% l=length(between_dist_RTs);
% mn=cell(1,l);
% for i=1:l
% mn{i}=mean(between_dist_RTs{i});
% end
% mnn_between_dist=[];
% for i=1:l
% mnn_between_dist=[mnn_between_dist mn{i}(1)];
% end
% plot(mnn_between_dist,'*-');
% xlabel('Distance between points'); ylabel('mean RT');
% 
% subplot(2,2,4);
% l=length(isCorrect_RTs);
% mn=cell(1,l);
% for i=1:l
% mn{i}=mean(isCorrect_RTs{i});
% end
% mnn_isCorrect=[];
% for i=1:l
% mnn_isCorrect=[mnn_isCorrect mn{i}(1)];
% end
% imagetemp=plot(mnn_isCorrect,'*-');
% xlabel('Correct answers              Wrong answers'); ylabel('mean RT');
% 
% if isempty(subj_name)
%     annotation('textbox', [0 0.9 1 0.1], 'String', strcat('Paradigm = comparison'),'EdgeColor', 'none','HorizontalAlignment', 'center');
% else
%     annotation('textbox', [0 0.9 1 0.1], 'String', strcat('Subject =  ',subj_name,'      Paradigm = comparison'),'EdgeColor', 'none','HorizontalAlignment', 'center');
% end
% 
% saveas(imagetemp, strcat(LOGPATH,filename,'.bmp'));         % this saves the image with the graphs to the log directory
% 
% close