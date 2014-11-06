function [] = plotanova_rm(ds, prop)
% plotanova_rm(ds, prop)
% 
% This is an obsolete function, using datasets of results of the distance
% comparison orientation paradigms
% (Datasets are created using analyze_stat.m)
% 
% Plots the results of repeated-measures ANOVA on the data
% 
% receives a cell array of datasets from my experiments (like place_cmp - 
% datasets created using analyze_stat.m) and a property of the dataset (like 
% 'condition'), and gets the relevant statistics + graphs.
% the dataset given should be as is (including error trials).

labels=[];
entries_to_remove=[];
for i=1:length(ds)
    labels=unique([labels; ds{i}.(prop)]);
    if isempty(ds{i})
        entries_to_remove=[entries_to_remove i];
    end
end
ds(entries_to_remove)=[];

ds_no_err=ds; mn=ones(length(ds),length(labels))*(-1); sd=ones(length(ds),length(labels))*(-1); ergroups=ones(length(ds),length(labels))*(-1); sm=ones(length(ds),length(labels))*(-1);
for i=1:length(ds)
    if isempty(ds{i})~=1
        % removing errors
        ds_no_err{i}(ds_no_err{i}.isCorrectUser=='wrong',:)=[];
        
        % normalizing distance results
        if strcmp(prop,'Closest_dist_user') || strcmp(prop,'Farthest_dist_user')
            labels=1:10;
        %    ds_no_err{i}.(prop) = round(ds_no_err{i}.(prop)*(10/max(ds_no_err{i}.(prop))));
        end
        
        % calculating response time statistics
        a=ds_no_err{i}.('RT');
        groups=ds_no_err{i}.(prop);
        for j=1:length(labels)
            mn(i,j)=mean(a(groups==labels(j)));
            sd(i,j)=std(a(groups==labels(j)));
            sm(i,j)=std(a(groups==labels(j)))/sqrt(size(a(groups==labels(j)),1));
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
while i<=szmn(1)
    if sum(mn(i,:)==-1)>0
        mn(i,:)=[];
        sd(i,:)=[];
        sm(i,:)=[];
        ergroups(i,:)=[];
    end
    szmn=size(mn);
    i=i+1;
end

if szmn(1)>1
    mean_mn=nanmean(mn); mean_sd=nanmean(sd); mean_errors=nanmean(ergroups); mean_sm=nanmean(sm);
else
    mean_mn=mn; mean_sd=sd; mean_errors=ergroups; mean_sm=sm;
end

% this is to correct for NaN values - NEED TO CHANGE THIS-WRONG CORRECTION
szmn=size(mn);
for i=1:szmn(1)
    for j=1:szmn(2)
        if isnan(mn(i,j))
            mn(i,j)=mean_mn(j);
            sd(i,j)=mean_sd(j);
            sm(i,j)=mean_sm(j);
            ergroups(i,j)=mean_errors(j);
        end
    end
end

% plot the mean RT values
[a,b]=anova_rm(mn,'off');
if a(1)<0.0001
    PV='<0.0001';
else
    PV=['=',num2str(a(1))];
    if length(PV)>7
        PV=PV(1:7);
    end
end
%subplot(1,3,1); 
errorbar(mean_mn,mean_sm,'*-'); xlabel(['F(',num2str(b{2,3}),',',num2str(b{4,3}),') = ',num2str(b{2,5}),', PV',PV]); ylabel('mean RT');

% plot the standard-deviation values
% [a,b]=anova_rm(sd,'off');
% if a(1)<0.0001
%     PV='<0.0001';
% else
%     PV=['=',num2str(a(1))];
%     if length(PV)>7
%         PV=PV(1:7);
%     end
% end
% subplot(1,3,2); plot(mean_sd,'*-'); xlabel(['F(',num2str(b{2,3}),',',num2str(b{4,3}),') = ',num2str(b{2,5}),', PV',PV]); ylabel('standard error');
% 
% % plot the error rates
% [a,b]=anova_rm(ergroups,'off');
% if a(1)<0.0001
%     PV='<0.0001';
% else
%     PV=['=',num2str(a(1))];
%     if length(PV)>7
%         PV=PV(1:7);
%     end
% end
% subplot(1,3,3); plot(mean_errors,'*-'); xlabel(['F(',num2str(b{2,3}),',',num2str(b{4,3}),') = ',num2str(b{2,5}),', PV',PV]); ylabel('error rate');


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