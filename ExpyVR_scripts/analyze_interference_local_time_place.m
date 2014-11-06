function [isSameTime_RTs, isClosestStimulusEarly_RTs, isCongruent_RTs, isleftLocationFront_RTs] = analyze_interference_local_time_place(LOGPATH, filename, subj_name)
% [isSameTime_RTs, isClosestStimulusEarly_RTs, isCongruent_RTs, isleftLocationFront_RTs] = analyze_interference_local_time_place(LOGPATH, filename, subj_name)
%
% This function analyzes the results of the interference paradigm,
% performed in EXPYVR
% The idea is to present visual stimuli in a room, far or close in space,
% and at separate times, and see whether spatial and temporal proximity
% interact
% (no good results were found...)

b=fopen(strcat(LOGPATH,filename,'_keyboard.csv'),'r');
keyboard_data = textscan(b, '%f %f %f %s %s %s %f %f %f', 'Delimiter',',','HeaderLines',1);     % the keyboard log file

% assigning the columns of the keyboard log file to variables
RT=keyboard_data{7};
keysPressed=keyboard_data{6};
conditions=keyboard_data{5};
num_trials=length(RT);

leftLocationFront=zeros(num_trials,1);
leftTime=cell(num_trials,1);
rightTime=cell(num_trials,1);
isCorrect=zeros(num_trials,1);
isCongruent=zeros(num_trials,1);
isSameTime=zeros(num_trials,1);
isClosestStimulusEarly=zeros(num_trials,1);

for i=1:num_trials
    % separating the 'conditions' variable
    leftLocationFront(i)=strcmp(conditions{i}(5:9),'Front');     % 1 if left is in the front, 0 if in the back
    leftTime{i}=conditions{i}(end-3);
    rightTime{i}=conditions{i}(end);
    % checking if the response is correct
    if (leftLocationFront(i) && keysPressed{i}=='A') || (~leftLocationFront(i) && keysPressed{i}=='G')
        isCorrect(i)=1;
    end
    % Checking if both stimuli appeared at the same time
    if leftTime{i}==rightTime{i}
        isSameTime(i)=1;
    % Checking if time and space proximity are the same
    elseif (leftLocationFront(i) && leftTime{i}=='E') || (~leftLocationFront(i) && leftTime{i}=='L')
        isCongruent(i)=1;
    end
    % Checking if the closest stimulus appeared early
    if (leftLocationFront(i) && leftTime{i}=='E') || (~leftLocationFront(i) && rightTime{i}=='E')
        isClosestStimulusEarly(i)=1;
    end
end

% getting the RTs for each parameter
isSameTime_RTs=[sum(isSameTime.*RT)/nnz(isSameTime.*RT) sum(~isSameTime.*RT)/nnz(~isSameTime.*RT)];
isClosestStimulusEarly_RTs=[sum(isClosestStimulusEarly.*RT)/nnz(isClosestStimulusEarly.*RT) sum(~isClosestStimulusEarly.*RT)/nnz(~isClosestStimulusEarly.*RT)];
isCongruent_RTs=[sum(isCongruent.*RT)/nnz(isCongruent.*RT) sum(~isCongruent.*RT)/nnz(~isCongruent.*RT)];
isleftLocationFront_RTs=[sum(leftLocationFront.*RT)/nnz(leftLocationFront.*RT) sum(~leftLocationFront.*RT)/nnz(~leftLocationFront.*RT)];

% plotting graphs
figure('Position',[100,100,800,600]);

subplot(2,2,1);
plot(isSameTime_RTs,'*-');
xlabel('Stimuli appearing at the same time'); ylabel('mean RT');

subplot(2,2,2);
plot(isClosestStimulusEarly_RTs,'*-');
xlabel('The closest stimulus appeared early'); ylabel('mean RT');

subplot(2,2,3);
plot(isCongruent_RTs,'*-');
xlabel('Time and space proximity are congruent'); ylabel('mean RT');

subplot(2,2,4);
imagetemp=plot(isleftLocationFront_RTs,'*-');
xlabel('Left stimulus appeared at the front'); ylabel('mean RT');

if isempty(subj_name)
    annotation('textbox', [0 0.9 1 0.1], 'String', strcat('Paradigm = interference local time-place'),'EdgeColor', 'none','HorizontalAlignment', 'center');
else
    annotation('textbox', [0 0.9 1 0.1], 'String', strcat('Subject =  ',subj_name,'      Paradigm = interference local time-place'),'EdgeColor', 'none','HorizontalAlignment', 'center');    
end

saveas(imagetemp, strcat(LOGPATH,filename,'.bmp'));         % this saves the image with the graphs to the log directory

close