function [] = analyze_MRI(filenames, RightKey, LeftKey, user_age)
% analyze_MRI(filenames, RightKey, LeftKey, user_age)
%
% This function analyzes the results of the distance comparison paradigm in
% MRI (time, space and person)
% (Paradigm: see two stimuli, press left/right based on which is closer to you)
% 
% receives a cell array of filenames
% receives RightKey (usually G), LeftKey (usually R/Z), and user age
%
% The function writes the results to an Excel (XLS) file

LOGPATH='c:\expyVR\log\';
%RightKey='G'; LeftKey='R';

% reading the output and keyboard files
data = cell(length(filenames),1);
keyboard_data = cell(length(filenames),1);
for i=1:length(filenames)
    a=fopen(strcat(LOGPATH,filenames{i},'_output.csv'),'r');                                            % the output log file
    data{i} = textscan(a, '%f %f %f %f', 'Delimiter',',','HeaderLines',1);
    %for j=1:4
    %    data{j}=[data{j};data_new{j}];
    %end
    b=fopen(strcat(LOGPATH,filenames{i},'_keyboard.csv'),'r');
    keyboard_data{i} = textscan(b, '%f %f %f %s %s %s %f %f %f', 'Delimiter',',','HeaderLines',1);     % the keyboard log file
    %for j=1:9
    %    keyboard_data{j}=[keyboard_data{j};keyboard_data_new{j}];
    %end
end

% getting the stimulus + questionnaire files
a=fopen(strcat(LOGPATH,filenames{1},'_output.csv'),'r');
header=textscan(a, '%s %s %s %s %s %s', 'Delimiter',',');
stimulus_filename=header{6}{1};
[~,~,stimulus_data]=xlsread(stimulus_filename);
ques_data=cell(3,1);
[~,~,ques_data{1}]=xlsread(strcat(stimulus_filename(1:end-11),'place_questionnaire.xls'));
[~,~,ques_data{2}]=xlsread(strcat(stimulus_filename(1:end-11),'person_questionnaire.xls'));
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

trials_allsessions=[];
indexR_allsessions=[];
indexL_allsessions=[];
sessions_all=[];
keys_allsessions={};
RT_allsessions={};
conditions_allsessions={};

for session=1:length(data)
    % assigning the columns of the log files to variables
    trials=data{session}{1};
    indexR=data{session}{3};
    indexL=data{session}{4};
        
    keys_all={}; keys={};
    RT_all={}; RT={};
    conditions_all={}; conditions={};
    
    trials=trials-1;    % because the paradigm starts at trial number 2
    current_stim_time=0;
    current_trial=0;
    i=1;
    while i<=length(keyboard_data{session}{1})
        if current_stim_time~=keyboard_data{session}{1}(i)
            current_trial=current_trial+1;
            current_stim_time=keyboard_data{session}{1}(i);     % this is because the response box / user sometimes creates multiple inputs during the same stimulus presentation, and we want to take the first one
            if keyboard_data{session}{8}(i)~=-1 && keyboard_data{session}{3}(i)~=-1
                % if column 8 is -1, it means all three columns are -1, which means the allowed time to answer has passed. we don't want to use those indexes.
                % if column 3 is -1, it means the response box continued sending signal from the last stimulus. we don't want to use those indexes.
                keys{end+1}=keyboard_data{session}{6}{i};
                RT{end+1}=keyboard_data{session}{8}(i);
                conditions{end+1}=keyboard_data{session}{5}{i};
                sessions_all=[sessions_all session];
            elseif keyboard_data{session}{3}(i)==-1
                % in this case we have to remove this row from the trials
                indexR(trials==current_trial)=[];
                indexL(trials==current_trial)=[];
                trials(trials==current_trial)=[];
            end
        end
        i=i+1;
    end
    
   
%        if keyboard_data{session}{8}(i)~=-1
%            % if column 8 is -1, it means all three columns are -1, which means the allowed time to answer has passed. we remove those indexes.
%           
%            if keyboard_data{session}{1}(i)~=keyboard_data{session}{1}(i+1)   
%                % if the response box sends a few messages at once (or the user pressed a few times in the same stimulus presentation), their absolute time is similar - we ignore those (they don't enter the loop).
%            end
%        end
%        
%            if (keyboard_data{session}{9}(i)~=-1)        % If column 9 is not -1, all is okay. if only column 9 is -1, it is also okay (user didn't release until after end of stimulus presentation).
%                keys_all{end+1}=keyboard_data{session}{6}{i};
%                RT_all{end+1}=keyboard_data{session}{8}(i);
%                conditions_all{end+1}=keyboard_data{session}{5}{i};
%            elseif i~=1     % if not the first stimulus
%                if keyboard_data{session}{8}(i)==-1  % if column 8 and 9 are -1, it means the allowed time to answer has passed.
%                    keys_all{end+1}=keyboard_data{session}{6}{i};
%                    RT_all{end+1}=keyboard_data{session}{8}(i);
%                    conditions_all{end+1}=keyboard_data{session}{5}{i};
%                elseif keyboard_data{session}{1}(i)~=keyboard_data{session}{1}(i-1)
%                    keys_all{end+1}=keyboard_data{session}{6}{i};
%                    RT_all{end+1}=keyboard_data{session}{8}(i);
%                    conditions_all{end+1}=keyboard_data{session}{5}{i};
%                end
%            elseif i==1     % first stimulus
%                keys_all{end+1}=keyboard_data{session}{6}{i};
%                RT_all{end+1}=keyboard_data{session}{8}(i);
%                conditions_all{end+1}=keyboard_data{session}{5}{i};
%            end
%        end
%    end    
%    % last stimulus
%    keys_all{end+1}=keyboard_data{session}{6}{length(keyboard_data{session}{1})};
%    RT_all{end+1}=keyboard_data{session}{8}(length(keyboard_data{session}{1}));
%    conditions_all{end+1}=keyboard_data{session}{5}{length(keyboard_data{session}{1})};

%    for i=1:length(trials)                  % removing trials missing from the output file
%        % IF THERE ARE ERRORS HERE, it may result from saving the csv file using Excel, which results in adding ',,' to each line
%        keys{end+1}=keys_all{trials(i)};
%        RT{end+1}=RT_all{trials(i)};
%        conditions{end+1}=conditions_all{trials(i)};
%        sessions_all=[sessions_all session];
%    end
    
    trials_allsessions=[trials_allsessions; trials];
    indexR_allsessions=[indexR_allsessions; indexR];
    indexL_allsessions=[indexL_allsessions; indexL];
    keys_allsessions=cat(1,keys_allsessions,transpose(keys));
    RT_allsessions=cat(1,RT_allsessions,transpose(RT));
    conditions_allsessions=cat(1,conditions_allsessions,transpose(conditions));
end

% getting the different conditions options
% all_conditions={};
% conditions_column=find(cellfun(@(x)strcmp(x,'conditions'),stimulus_data(1,1:end)));     % find the conditions column in the stimulus file
% for i=2:length(stimulus_data(2:end,conditions_column))
%     if isnan(stimulus_data{i,conditions_column})
%         break;
%     end
%     all_conditions{end+1}=stimulus_data{i,conditions_column};
%     if ischar(all_conditions{end})==0
%         all_conditions{end}=int2str(all_conditions{end});
%     end
% end
all_conditions={'pl_1','pl_2','pl_3','pl_4','pl_5','pl_6','pe_1','pe_2','pe_3','pe_4','pe_5','pe_6','ti_1','ti_2','ti_3','ti_4','ti_5','ti_6'};

num_trials=length(trials_allsessions);
%user_age=ques_sort{3}{4,8};
% update data from the questionnaire and stimulus files
user_distL=cell(num_trials,1); user_distR=cell(num_trials,1); 
emotionL=cell(num_trials,1); been_thereL=cell(num_trials,1); emotionR=cell(num_trials,1); been_thereR=cell(num_trials,1); 
how_many_timesL=cell(num_trials,1); know_to_getL=cell(num_trials,1); how_many_timesR=cell(num_trials,1); know_to_getR=cell(num_trials,1);       % place fields
know_personallyL=cell(num_trials,1); know_personallyR=cell(num_trials,1); relationL=cell(num_trials,1); relationR=cell(num_trials,1);           % person fields
future_pastL=cell(num_trials,1); age_at_eventL=cell(num_trials,1); future_pastR=cell(num_trials,1); age_at_eventR=cell(num_trials,1);           % time fields
age_distL=cell(num_trials,1); age_distR=cell(num_trials,1);     % distance by difference from age
domain=cell(num_trials,1);

for i=1:num_trials                                              % adding the needed fields
    user_distL{i}=stimulus_data{indexL_allsessions(i)+2,3};
    user_distR{i}=stimulus_data{indexR_allsessions(i)+2,3};
    if strcmp(conditions_allsessions{i}(1:2),'pl')
        domain{i}='place';
        emotionL{i}=ques_sort{1}{indexL_allsessions(i)+1,3};
        emotionR{i}=ques_sort{1}{indexR_allsessions(i)+1,3};
        been_thereL{i}=ques_sort{1}{indexL_allsessions(i)+1,4};
        been_thereR{i}=ques_sort{1}{indexR_allsessions(i)+1,4};
        how_many_timesL{i}=ques_sort{1}{indexL_allsessions(i)+1,5};
        how_many_timesR{i}=ques_sort{1}{indexR_allsessions(i)+1,5};
        know_to_getL{i}=ques_sort{1}{indexL_allsessions(i)+1,6};
        know_to_getR{i}=ques_sort{1}{indexR_allsessions(i)+1,6};
        know_personallyL{i}=NaN;
        know_personallyR{i}=NaN;
        relationL{i}=NaN;
        relationR{i}=NaN;
        future_pastL{i}=NaN;
        age_at_eventL{i}=NaN;
        future_pastR{i}=NaN;
        age_at_eventR{i}=NaN;
        age_distL{i}=NaN;
        age_distR{i}=NaN;
    elseif strcmp(conditions_allsessions{i}(1:2),'pe')
        domain{i}='person';
        emotionL{i}=ques_sort{2}{indexL_allsessions(i)+1-70,3};
        emotionR{i}=ques_sort{2}{indexR_allsessions(i)+1-70,3};
        been_thereL{i}=NaN;
        been_thereR{i}=NaN;
        how_many_timesL{i}=NaN;
        know_to_getL{i}=NaN;
        how_many_timesR{i}=NaN;
        know_to_getR{i}=NaN;
        know_personallyL{i}=ques_sort{2}{indexL_allsessions(i)+1-70,4};
        know_personallyR{i}=ques_sort{2}{indexR_allsessions(i)+1-70,4};
        relationL{i}=ques_sort{2}{indexL_allsessions(i)+1-70,5};
        relationR{i}=ques_sort{2}{indexR_allsessions(i)+1-70,5};
        future_pastL{i}=NaN;
        future_pastR{i}=NaN;
        age_at_eventL{i}=NaN;
        age_at_eventR{i}=NaN;
        age_distL{i}=NaN;
        age_distR{i}=NaN;
    elseif strcmp(conditions_allsessions{i}(1:2),'ti')
        domain{i}='time';
        emotionL{i}=ques_sort{3}{indexL_allsessions(i)+1-35,3};
        emotionR{i}=ques_sort{3}{indexR_allsessions(i)+1-35,3};
        been_thereL{i}=NaN;
        been_thereR{i}=NaN;
        how_many_timesL{i}=NaN;
        know_to_getL{i}=NaN;
        how_many_timesR{i}=NaN;
        know_to_getR{i}=NaN;
        know_personallyL{i}=NaN;
        know_personallyR{i}=NaN;
        relationL{i}=NaN;
        relationR{i}=NaN;
        future_pastL{i}=ques_sort{3}{indexL_allsessions(i)+1-35,4};
        future_pastR{i}=ques_sort{3}{indexR_allsessions(i)+1-35,4};
        age_at_eventL{i}=ques_sort{3}{indexL_allsessions(i)+1-35,5};
        age_at_eventR{i}=ques_sort{3}{indexR_allsessions(i)+1-35,5};
        age_distL{i}=age_at_eventL{i}-user_age;
        age_distR{i}=age_at_eventR{i}-user_age;
    end
end

% Calculate if response is correct and which stimulus appeared closer for user distances
isCorrectUser=cell(num_trials,1); CloserStimulusUser=cell(num_trials,1); isCorrectByAge=cell(num_trials,1); CloserStimulusByAge=cell(num_trials,1);
for i=1:num_trials
    if keys_allsessions{i}==RightKey
        if user_distR{i}<user_distL{i}
            isCorrectUser{i}='correct';
            CloserStimulusUser{i}='Right';
        elseif user_distR{i}>user_distL{i}
            isCorrectUser{i}='wrong';
            CloserStimulusUser{i}='Left';
        else
            isCorrectUser{i}='equal_dist';
            CloserStimulusUser{i}='equal_dist';
        end
        if ~isnan(age_distL{i})
            if abs(age_distR{i})<abs(age_distL{i})
                isCorrectByAge{i}='correct';
                CloserStimulusByAge{i}='Right';
            elseif abs(age_distR{i})>abs(age_distL{i})
                isCorrectByAge{i}='wrong';
                CloserStimulusByAge{i}='Left';
            else
                isCorrectByAge{i}='equal_dist';
                CloserStimulusByAge{i}='equal_dist';
            end
        else
            isCorrectByAge{i}=NaN;
            CloserStimulusByAge{i}=NaN;
        end
        
    elseif keys_allsessions{i}==LeftKey
        if user_distR{i}>user_distL{i}
            isCorrectUser{i}='correct';
            CloserStimulusUser{i}='Left';
        elseif user_distR{i}<user_distL{i}
            isCorrectUser{i}='wrong';
            CloserStimulusUser{i}='Right';
        else
            isCorrectUser{i}='equal_dist';
            CloserStimulusUser{i}='equal_dist';
        end
        if ~isnan(age_distL{i})
            if abs(age_distR{i})>abs(age_distL{i})
                isCorrectByAge{i}='correct';
                CloserStimulusByAge{i}='Left';
            elseif abs(age_distR{i})<abs(age_distL{i})
                isCorrectByAge{i}='wrong';
                CloserStimulusByAge{i}='Right';
            else
                isCorrectByAge{i}='equal_dist';
                CloserStimulusByAge{i}='equal_dist';
            end
        else
            isCorrectByAge{i}=NaN;
            CloserStimulusByAge{i}=NaN;
        end
    end
end

% calculate closest and farthest distances, and distance between stimuli
Closest_dist_user=min(cell2mat(user_distR),cell2mat(user_distL));
Farthest_dist_user=max(cell2mat(user_distR),cell2mat(user_distL));
Between_dist_user=abs(cell2mat(user_distR)-cell2mat(user_distL));
 
% keys_allsessions=transpose(keys_allsessions); RT_allsessions=transpose(RT_allsessions); conditions_allsessions=transpose(conditions_allsessions);
% trials_allsessions=transpose(trials_allsessions); 
% indexR_allsessions=transpose(indexR_allsessions); indexL_allsessions=transpose(indexL_allsessions); 
% user_distL=transpose(user_distL); user_distR=transpose(user_distR);
% emotionL=transpose(emotionL); been_thereL=transpose(been_thereL); how_many_timesL=transpose(how_many_timesL);
% emotionR=transpose(emotionR); been_thereR=transpose(been_thereR); how_many_timesR=transpose(how_many_timesR);
% know_to_getL=transpose(know_to_getL); know_to_getR=transpose(know_to_getR);
% know_personallyL=transpose(know_personallyL); know_personallyR=transpose(know_personallyR); 
% relationL=transpose(relationL); relationR=transpose(relationR);
% future_pastL=transpose(future_pastL); age_at_eventL=transpose(age_at_eventL); 
% future_pastR=transpose(future_pastR); age_at_eventR=transpose(age_at_eventR);
% age_distL=transpose(age_distL); age_distR=transpose(age_distR);
% isCorrectUser=transpose(isCorrectUser); CloserStimulusUser=transpose(CloserStimulusUser);
% isCorrectByAge=transpose(isCorrectByAge); CloserStimulusByAge=transpose(CloserStimulusByAge);
sessions_all=transpose(sessions_all);


% write results to file
headers={'trials','indexR','indexL','session','RT','condition','domain','key','user_distR','user_distL','isCorrectUser','emotionR','emotionL','Closest_dist_user','Farthest_dist_user','Between_dist_user','CloserStimulusUser','been_thereR','been_thereL','how_many_timesR','how_many_timesL','know_to_getR','know_to_getL','know_personallyR','know_personallyL','relationR','relationL','future_pastR','future_pastL','age_at_eventR','age_at_eventL','age_distR','age_distL','isCorrectByAge','CloserStimulusByAge'};
DataToFile=[num2cell([trials_allsessions+1,indexR_allsessions,indexL_allsessions,sessions_all]),RT_allsessions,conditions_allsessions,domain,keys_allsessions,user_distR,user_distL,isCorrectUser,emotionR,emotionL,num2cell([Closest_dist_user,Farthest_dist_user,Between_dist_user]),CloserStimulusUser,been_thereR,been_thereL,how_many_timesR,how_many_timesL,know_to_getR,know_to_getL,know_personallyR,know_personallyL,relationR,relationL,future_pastR,future_pastL,age_at_eventR,age_at_eventL,age_distR,age_distL,isCorrectByAge,CloserStimulusByAge];

if length(filenames)==1
    xlswrite(strcat(LOGPATH,filenames{1},'_results.xls'),[headers;DataToFile]);
else
    xlswrite(strcat(LOGPATH,filenames{1},'_',filenames{2},'_results.xls'),[headers;DataToFile]);
end