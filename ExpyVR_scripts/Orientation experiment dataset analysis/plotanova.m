function [] = plotanova(ds, prop)
% plotanova(ds, prop)
% 
% This is an obsolete function, using datasets of results of the distance
% comparison orientation paradigms
% (Datasets are created using analyze_stat.m)
%
% Plots the results of repeated-measures ANOVA on the data
% 
% receives a cell array of datasets from my experiment (like place_cmp) and 
% a property (like 'condition') and gets the relevant statistics + graphs.
% the dataset given should be as is (including error trials).
% 
% A more advanced version of this script is in plotanova_rm_closerfarther.m

labels=unique([ds{1}.(prop);ds{2}.(prop);ds{3}.(prop)]);
ds_no_err=ds; mn=ones(length(ds),length(labels))*(-1); sd=ones(length(ds),length(labels))*(-1); ergroups=ones(length(ds),length(labels))*(-1);
for i=1:length(ds)
    if isempty(ds{i})~=1
        % removing errors
        ds_no_err{i}(ds_no_err{i}.isCorrectUser=='wrong',:)=[];
        
        % calculating response time statistics
        a=ds_no_err{i}.('RT');
        groups=ds_no_err{i}.(prop);
        for j=1:length(labels)
            mn(i,j)=mean(a(groups==labels(j)));
            sd(i,j)=std(a(groups==labels(j)));
        end
        
        % calculating error-rate statistics
        errors=ds{i}.isCorrectUser;
        errors= (errors=='wrong');
        groups_with_errors=ds{i}.(prop);
        for j=1:length(labels)
            ergroups(i,j)=mean(errors(groups==labels(j)));
        end
    end
end

szmn=size(mn); i=1;
while i<szmn(1)
    if sum(mn(i,:)==-1)>0
        mn(i,:)=[];
        sd(i,:)=[];
        ergroups(i,:)=[];
    end
    szmn=size(mn);
    i=i+1;
end

y=anova1(mn);
mean_mn=nanmean(mn); mean_sd=nanmean(sd); mean_errors=nanmean(ergroups);
subplot(1,3,1); errorbar(mean_mn,mean_sd,'*-'); xlabel(['PV = ',num2str(y)]); ylabel('mean RT');
subplot(1,3,2); plot(mean_sd,'*-'); ylabel('standard error');
subplot(1,3,3); plot(mean_errors,'*-'); ylabel('error rate');


% % old version, for calculating with the old concatenated datasets -
% % ignores the fact that we have separate subjects 
% % removing errors
% ds_no_err=ds; ds_no_err(ds_no_err.isCorrectUser=='wrong',:)=[];
% 
% % calculating response time statistics
% a=ds_no_err.('RT');
% groups=ds_no_err.(prop);
% % removing results above/below 2 standard deviations from the mean
% % mna=mean(a);sda=std(a);
% % b(a>(mna+2*sda))=[]; a(a>(mna+2*sda))=[];
% % b(a<(mna-2*sda))=[]; a(a<(mna-2*sda))=[];
% [mn,sd]=grpstats(a,groups,{'mean','std'});
% y=anova1(a,groups);
% subplot(1,3,1); errorbar(mn,sd,'*-'); xlabel(['PV = ',num2str(y)]); ylabel('mean RT');
% subplot(1,3,2); plot(sd,'*-'); ylabel('standard error');
% 
% % calculating error-rate statistics
% errate=@(x) sum(x)/length(x);
% errors=ds.isCorrectUser;
% groups_with_errors=ds.(prop);
% ergroups=grpstats(errors=='wrong',groups_with_errors,'mean');
% subplot(1,3,3); plot(ergroups,'*-'); ylabel('error rate');

return;