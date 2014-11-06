function [mnn_stimulus_RTs, mnn_keysPressed_RTs, mnn_stimulus_keysPressed] = analyze_estimation(LOGPATH, filename, subj_name)
% [mnn_stimulus_RTs, mnn_keysPressed_RTs, mnn_stimulus_keysPressed] = analyze_estimation(LOGPATH, filename, subj_name)
% 
% This function analyzes the results of the distance estimation paradigm in
% time, space and person, using the output and keyboard files from EXPYVR
% log directory
% (Paradigm: see one stimuli, press 1-4 based on its distance from you)
% The function writes the results to an Excel (XLS) file

a=fopen(strcat(LOGPATH,filename,'_output.csv'),'r');                                            % the output log file
data = textscan(a, '%f %f %f', 'Delimiter',',','HeaderLines',1);
b=fopen(strcat(LOGPATH,filename,'_keyboard.csv'),'r');
keyboard_data = textscan(b, '%f %f %f %s %s %s %f %f %f', 'Delimiter',',','HeaderLines',1);     % the keyboard log file
[~,~,ques_data]=xlsread(strcat(LOGPATH,filename,'_questionnaire.xls'));

% getting the stimulus file
a=fopen(strcat(LOGPATH,filename,'_output.csv'),'r');
datanew=textscan(a, '%s %s %s %s %s %s', 'Delimiter',',');
stimulus_filename=datanew{5}{1};
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
indexPic=data{3};

keys_all={}; keys={};
RT_all={}; RT={};
conditions_all={}; conditions={};
for i=1:length(keyboard_data{1})
    if (keyboard_data{9}(i)~=-1)        % If column 9 is -1, it means two keys were pressed at once.
        keys_all{end+1}=keyboard_data{6}{i};
        if keyboard_data{8}(i)>0
            RT_all{end+1}=keyboard_data{8}(i);
        else
            RT_all{end+1}=keyboard_data{7}(i);
        end
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
real_dist={}; user_dist={};
know={}; emotion={}; 
additional_ques_fields={};          % for additional questionnaire fields above the general 6 fields
if num_fields>6
    for i=8:num_fields+1
        additional_ques_fields{end+1}={};
    end
end
add_field_num=num_fields-6;
additional_stim_fields={};          % for additional stimulus-file fields above the general 4 fields
if conditions_column>6
    for i=6:conditions_column-1
        additional_stim_fields{end+1}={};
    end
end
add_stim_field_num=conditions_column-6;
for i=1:length(trials)                                          % adding the needed fields
    for j=1:length(all_conditions)
        if strcmp(conditions{i},all_conditions{j})
            real_dist{end+1}=stimulus_data{indexPic(i)+2,2+j};
            user_dist{end+1}=ques_sort{indexPic(i)+1,2+j};
        end
    end
    know{end+1}=ques_sort{indexPic(i)+1,6};
    emotion{end+1}=ques_sort{indexPic(i)+1,7};
    if add_field_num>0                                          % for additional questionnaire fields
        for q=1:add_field_num
            additional_ques_fields{q}{end+1}=ques_sort{indexPic(i)+1,7+q};
        end
    end
    if add_stim_field_num>0                                          % for additional stimulus-file fields
        for q=1:add_stim_field_num
            additional_stim_fields{q}{end+1}=stimulus_data{indexPic(i)+2,5+q};
        end
    end
end

% writing the numeric answer of the user
answers={};
for i=1:length(trials)
   if keys{i}(end)=='A'
       answers{end+1}=1;
   elseif keys{i}(end)=='G'
       answers{end+1}=2;
   end
%    if keys{i}(end)=='Q'
%        answers{end+1}=1;
%    elseif keys{i}(end)=='R'
%        answers{end+1}=2;
%    elseif keys{i}(end)=='U'
%        answers{end+1}=3;
%    elseif keys{i}(end)=='P'
%        answers{end+1}=4;
%    end
end

keys=transpose(keys); RT=transpose(RT); conditions=transpose(conditions); answers=transpose(answers);
real_dist=transpose(real_dist); user_dist=transpose(user_dist); 
know=transpose(know); emotion=transpose(emotion); 

% write results to file
headers={'trials','indexPic','RT','condition','key','answer','real_dist','user_dist_questionnaire','know','emotion'};
DataToFile=[num2cell([trials,indexPic]),RT,conditions,keys,answers,real_dist,user_dist,know,emotion];
for i=1:length(additional_ques_fields)                 % adding additional questionnaire fields
    additional_ques_fields{i}=transpose(additional_ques_fields{i}); 
    headers{end+1}=strcat('questionnaire_field',int2str(i+6));
    DataToFile=[DataToFile additional_ques_fields{:,i}];
end
for i=1:length(additional_stim_fields)                 % adding additional stimulus-file fields
    additional_stim_fields{i}=transpose(additional_stim_fields{i}); 
    headers{end+1}=strcat('stimulus_field',int2str(i+5));
    DataToFile=[DataToFile additional_stim_fields{:,i}];
end
xlswrite(strcat(LOGPATH,filename,'_results.xls'),[headers;DataToFile]);



%keysPressed=keyboard_data{6};
%RT=keyboard_data{8};
%num_trials=length(indexPic);
% keysPressedNums=zeros(length(keysPressed),1);        % changing the keys to numbers
% for i=1:length(keysPressed)
%     keysPressedNums(i)=str2double(keysPressed{i}(2));
% end
% 
% % getting the RTs for each specific stimulus (picture index)
% stimulus_RTs=cell(1,max(indexPic));
% for i=1:max(indexPic)
%     for j=1:num_trials
%         if indexPic(j)==i
%             stimulus_RTs{i}=[stimulus_RTs{i} RT(trials(j))];
%         end
%     end
% end
% 
% % getting the RTs for each specific user-entered distance (key pressed)
% keysPressed_RTs=cell(1,max(keysPressedNums));
% for i=1:max(keysPressedNums)
%     for j=1:num_trials
%         if keysPressedNums(trials(j))==i
%             keysPressed_RTs{i}=[keysPressed_RTs{i} RT(trials(j))];
%         end
%     end
% end
% 
% % getting the user-entered distance for each stimulus
% stimulus_keysPressed=cell(1,max(indexPic));
% for i=1:max(indexPic)
%     for j=1:num_trials
%         if indexPic(j)==i
%             stimulus_keysPressed{i}=[stimulus_keysPressed{i} keysPressedNums(trials(j))];
%         end
%     end
% end
% 
% % getting the mean RT / distance for each group and plotting graphs
% figure('Position',[100,100,800,600]);
% 
% subplot(2,2,1);
% l=length(stimulus_RTs);
% mn=cell(1,l);
% for i=1:l
% mn{i}=mean(stimulus_RTs{i});
% end
% mnn_stimulus_RTs=[];
% for i=1:l
% mnn_stimulus_RTs=[mnn_stimulus_RTs mn{i}(1)];
% end
% plot(mnn_stimulus_RTs,'*-');
% xlabel('Stimulus presented'); ylabel('mean RT');
% 
% subplot(2,2,2);
% l=length(keysPressed_RTs);
% mn=cell(1,l);
% for i=1:l
% mn{i}=mean(keysPressed_RTs{i});
% end
% mnn_keysPressed_RTs=[];
% for i=1:l
% mnn_keysPressed_RTs=[mnn_keysPressed_RTs mn{i}(1)];
% end
% plot(mnn_keysPressed_RTs,'*-');
% xlabel('Key pressed (measured distance)'); ylabel('mean RT');
% 
% subplot(2,2,3);
% l=length(stimulus_keysPressed);
% mn=cell(1,l);
% for i=1:l
% mn{i}=mean(stimulus_keysPressed{i});
% end
% mnn_stimulus_keysPressed=[];
% for i=1:l
% mnn_stimulus_keysPressed=[mnn_stimulus_keysPressed mn{i}(1)];
% end
% imagetemp=plot(mnn_stimulus_keysPressed,'*-');
% xlabel('Stimulus'); ylabel('mean distance measured');
% 
% if isempty(subj_name)
%     annotation('textbox', [0 0.9 1 0.1], 'String', strcat('Paradigm = estimation'),'EdgeColor', 'none','HorizontalAlignment', 'center');
% else
%     annotation('textbox', [0 0.9 1 0.1], 'String', strcat('Subject =  ',subj_name,'      Paradigm = estimation'),'EdgeColor', 'none','HorizontalAlignment', 'center');
% end
% 
% saveas(imagetemp, strcat(LOGPATH,filename,'.bmp'));         % this saves the image with the graphs to the log directory
% 
% close
