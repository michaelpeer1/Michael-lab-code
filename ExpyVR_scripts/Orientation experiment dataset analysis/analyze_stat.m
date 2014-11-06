function [ds] = analyze_stat(filename)
% [ds] = analyze_stat(filename)
% 
% This function creates a dataset for later statistical analysis of the results from an XLS file
% uses excel files from analyze_comparison.m / analyze_estimation.m functions

LOGPATH = 'C:\ExpyVR\log\';


[a,b,c]=xlsread(strcat(LOGPATH,filename,'_results.xls'));
bb=[]; aa=[]; b_names={};a_names={};
fieldnum=size(b);
for i=1:fieldnum(2)
    if strcmp(b(2,i),'')==1
        aa=[aa a(1:end,i)];
        a_names{end+1}=b{1,i};
    else
        bb=[bb nominal(b(2:end,i))];
        b_names{end+1}=b{1,i};
    end
end
ds=dataset({bb,b_names{:}},{aa,a_names{:}});

% removing values the user does not know
a=textread(strcat(LOGPATH,filename,'_output.csv'),'%s');
% estimation paradigms
if ~isempty(strfind(a{1},'stimation'))
    if ~isempty(strfind(a{2},'lace'))             % place paradigms - we want to remove places the user does not know
        ds(ds.know==0,:)=[];
    elseif ~isempty(strfind(a{2},'ime'))          % time paradigms - we want to remove events the user does not know, but not future events
        ds(ds.know==0 & ds.questionnaire_field7==-1,:)=[];
    elseif ~isempty(strfind(a{2},'erson'))        % person paradigms - we want to remove people that each character does not know
        ds((ds.know==0 & strcmp(b(2:end,4),'self')) | (ds.questionnaire_field8==0 & strcmp(b(2:end,4),'friend1')) | (ds.questionnaire_field9==0 & strcmp(b(2:end,4),'family1')),:)=[];
    end
% comparison paradigms
elseif ~isempty(strfind(a{1},'omparison'))
    if ~isempty(strfind(a{2},'lace'))             % place paradigms - we want to remove places the user does not know
        ds(ds.knowL==0 | ds.knowR==0,:)=[];
    elseif ~isempty(strfind(a{2},'ime'))          % time paradigms - we want to remove events the user does not know, but not future events
        ds((ds.knowL==0 & ds.questionnaire_field7_L==-1) | (ds.knowR==0 & ds.questionnaire_field7_R==-1),:)=[];
    elseif ~isempty(strfind(a{2},'erson'))        % person paradigms - we want to remove people that each character does not know
        ds((ds.knowL==0 & strcmp(b(2:end,5),'self')) | (ds.questionnaire_field8_L==0 & strcmp(b(2:end,5),'friend1')) | (ds.questionnaire_field9_L==0 & strcmp(b(2:end,5),'family1')) | (ds.knowR==0 & strcmp(b(2:end,5),'self')) | (ds.questionnaire_field8_R==0 & strcmp(b(2:end,5),'friend1')) | (ds.questionnaire_field9_R==0 & strcmp(b(2:end,5),'family1')),:)=[];
    end
end

% removing outliers
ds(ds.('RT')>=mean(ds.('RT'))+2.5*std(ds.('RT')),:)=[];
ds(ds.('RT')>=3,:)=[];