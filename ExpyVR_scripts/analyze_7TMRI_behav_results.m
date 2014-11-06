% This script analyzes the results of the 7T-MRI results from EPFL scanning
% of subjects performing the orientation distance-comparison paradigm (in
% time, space and person)


load('C:\ExpyVR\Paradigms\Subjects file 7T new.mat');    % subjects filenames list
expyvr_log_dir='C:\ExpyVR\log\';
% num_subjs=size(subjects,1);
num_subjs = 16; % do not use the high-res subjects
num_distances=6;

person_RTs=cell(num_subjs,num_distances); place_RTs=cell(num_subjs,num_distances); time_RTs=cell(num_subjs,num_distances);
means_pe=zeros(num_subjs,num_distances); means_pl=zeros(num_subjs,num_distances);means_ti=zeros(num_subjs,num_distances);
len_stimuli_pe=cell(num_subjs,num_distances); len_stimuli_pl=cell(num_subjs,num_distances); len_stimuli_ti=cell(num_subjs,num_distances); 

betas_pe = cell(num_subjs,1); betas_pl = cell(num_subjs,1); betas_ti = cell(num_subjs,1); betas_all = cell(num_subjs,1); 
person_RTs_regressed=cell(num_subjs,num_distances); place_RTs_regressed=cell(num_subjs,num_distances); time_RTs_regressed=cell(num_subjs,num_distances);
means_pe_regressed=zeros(num_subjs,num_distances); means_pl_regressed=zeros(num_subjs,num_distances);means_ti_regressed=zeros(num_subjs,num_distances);

person_RTs_regressed_alldomains=cell(num_subjs,num_distances); place_RTs_regressed_alldomains=cell(num_subjs,num_distances); time_RTs_regressed_alldomains=cell(num_subjs,num_distances);
means_pe_regressed_alldomains=zeros(num_subjs,num_distances); means_pl_regressed_alldomains=zeros(num_subjs,num_distances);means_ti_regressed_alldomains=zeros(num_subjs,num_distances);

for s=1:num_subjs
    disp(s)
    for f=1:size(subjects,2)-3          % without the first two columns (name, age) and the control run (run 6)
        if ~isempty(subjects{s,2+f})
            [~,~,exp_data]=xlsread([expyvr_log_dir num2str(subjects{s, 2+f}) '_XLS_w_quest_fields.xls']);
            
            for i=2:size(exp_data,1)
                % column 7 is the reaction time, column 9 is the domain, column 10 is the distance
                if strcmp('pe', exp_data{i,9})
                    person_RTs{s, exp_data{i,10}} = [person_RTs{s, exp_data{i,10}} exp_data{i,7}];
                    len_stimuli_pe{s, exp_data{i,10}} = [len_stimuli_pe{s, exp_data{i,10}} exp_data{i,11}*2];
                elseif strcmp('pl', exp_data{i,9})
                    place_RTs{s, exp_data{i,10}} = [place_RTs{s, exp_data{i,10}} exp_data{i,7}];
                    len_stimuli_pl{s, exp_data{i,10}} = [len_stimuli_pl{s, exp_data{i,10}} exp_data{i,11}*2];
                elseif strcmp('ti', exp_data{i,9})
                    time_RTs{s, exp_data{i,10}} = [time_RTs{s, exp_data{i,10}} exp_data{i,7}];
                    len_stimuli_ti{s, exp_data{i,10}} = [len_stimuli_ti{s, exp_data{i,10}} exp_data{i,11}*2];
                end
            end
        end
    end
    
    % thresholding for impossible RTs
    for i=1:num_distances
        len_stimuli_pe{s, i} = len_stimuli_pe{s, i}(person_RTs{s, i}>0.5 & person_RTs{s, i}<2.5);
        len_stimuli_pl{s, i} = len_stimuli_pl{s, i}(place_RTs{s, i}>0.5 & place_RTs{s, i}<2.5);
        len_stimuli_ti{s, i} = len_stimuli_ti{s, i}(time_RTs{s, i}>0.5 & time_RTs{s, i}<2.5);

        person_RTs{s, i} = person_RTs{s, i}(person_RTs{s, i}>0.5 & person_RTs{s, i}<2.5);
        place_RTs{s, i} = place_RTs{s, i}(place_RTs{s, i}>0.5 & place_RTs{s, i}<2.5);
        time_RTs{s, i} = time_RTs{s, i}(time_RTs{s, i}>0.5 & time_RTs{s, i}<2.5);
    end
    
    % regressing the stimulus length from the data, after addition of a constant term
    current_pe_RTs_all = cat(2,person_RTs{s,:}); current_pl_RTs_all = cat(2,place_RTs{s,:}); current_ti_RTs_all = cat(2,time_RTs{s,:});
    current_pe_stimlength_all = cat(2,len_stimuli_pe{s,:}); current_pl_stimlength_all = cat(2,len_stimuli_pl{s,:}); current_ti_stimlength_all = cat(2,len_stimuli_ti{s,:});
    betas_pe{s} = regress(current_pe_RTs_all', [current_pe_stimlength_all' ones(length(current_pe_RTs_all),1)]);
    betas_pl{s} = regress(current_pl_RTs_all', [current_pl_stimlength_all' ones(length(current_pl_RTs_all),1)]);
    betas_ti{s} = regress(current_ti_RTs_all', [current_ti_stimlength_all' ones(length(current_ti_RTs_all),1)]);
    % removing (partialling-out) the effects of stimulus length from the data, in each domain separately
    current_pe_RTs_new = current_pe_RTs_all - betas_pe{s}(1)*current_pe_stimlength_all;
    current_pl_RTs_new = current_pl_RTs_all - betas_pl{s}(1)*current_pl_stimlength_all;
    current_ti_RTs_new = current_ti_RTs_all - betas_ti{s}(1)*current_ti_stimlength_all;
    % removing (partialling-out) the effects of stimulus length from the data, in all domains simultaneously
    current_all_RTs = [current_pe_RTs_all current_pl_RTs_all current_ti_RTs_all];
    current_all_stimlength = [current_pe_stimlength_all current_pl_stimlength_all current_ti_stimlength_all];
    betas_all{s} = regress(current_all_RTs', [current_all_stimlength' ones(length(current_all_RTs),1)]);
    current_pe_RTs_new_alldomains = current_pe_RTs_all - betas_all{s}(1)*current_pe_stimlength_all;
    current_pl_RTs_new_alldomains = current_pl_RTs_all - betas_all{s}(1)*current_pl_stimlength_all;
    current_ti_RTs_new_alldomains = current_ti_RTs_all - betas_all{s}(1)*current_ti_stimlength_all;
    
    pe_counter=1; pl_counter=1; ti_counter=1;
    for i=1:num_distances            % separating again into different distances
        person_RTs_regressed{s, i} = current_pe_RTs_new(pe_counter:pe_counter-1+length(person_RTs{s, i}));
        place_RTs_regressed{s, i} = current_pl_RTs_new(pl_counter:pl_counter-1+length(place_RTs{s, i}));
        time_RTs_regressed{s, i} = current_ti_RTs_new(ti_counter:ti_counter-1+length(time_RTs{s, i}));

        person_RTs_regressed_alldomains{s, i} = current_pe_RTs_new_alldomains(pe_counter:pe_counter-1+length(person_RTs{s, i}));
        place_RTs_regressed_alldomains{s, i} = current_pl_RTs_new_alldomains(pl_counter:pl_counter-1+length(place_RTs{s, i}));
        time_RTs_regressed_alldomains{s, i} = current_ti_RTs_new_alldomains(ti_counter:ti_counter-1+length(time_RTs{s, i}));
        
        pe_counter = pe_counter+length(person_RTs{s, i});
        pl_counter = pl_counter+length(place_RTs{s, i}); 
        ti_counter = ti_counter+length(time_RTs{s, i});
    end
     
    % computing mean of each distance
    for i=1:num_distances
        means_pe(s, i) = nanmean(person_RTs{s, i}); means_pe_regressed(s, i) = nanmean(person_RTs_regressed{s, i}); means_pe_regressed_alldomains(s, i) = nanmean(person_RTs_regressed_alldomains{s, i});
        means_pl(s, i) = nanmean(place_RTs{s, i}); means_pl_regressed(s, i) = nanmean(place_RTs_regressed{s, i}); means_pl_regressed_alldomains(s, i) = nanmean(place_RTs_regressed_alldomains{s, i});
        means_ti(s, i) = nanmean(time_RTs{s, i}); means_ti_regressed(s, i) = nanmean(time_RTs_regressed{s, i}); means_ti_regressed_alldomains(s, i) = nanmean(time_RTs_regressed_alldomains{s, i});
    end
end

for i=1:num_distances
    all_person_RTs{i}=cell2mat(person_RTs(:,i)'); all_person_RTs_regressed{i}=cell2mat(person_RTs_regressed(:,i)'); 
    all_place_RTs{i}=cell2mat(place_RTs(:,i)'); all_place_RTs_regressed{i}=cell2mat(place_RTs_regressed(:,i)');
    all_time_RTs{i}=cell2mat(time_RTs(:,i)'); all_time_RTs_regressed{i}=cell2mat(time_RTs_regressed(:,i)');
    
    all_person_RTs_regressed_alldomains{i}=cell2mat(person_RTs_regressed_alldomains(:,i)');
    all_place_RTs_regressed_alldomains{i}=cell2mat(place_RTs_regressed_alldomains(:,i)');
    all_time_RTs_regressed_alldomains{i}=cell2mat(time_RTs_regressed_alldomains(:,i)');
end


%% Statistics

% ANOVA for domains (not repeated-measures)
% means_pe_alldists=mean(means_pe,2); means_pl_alldists=mean(means_pl,2); means_ti_alldists=mean(means_ti,2);
% means_pe_alldists=mean(means_pe_regressed,2); means_pl_alldists=mean(means_pl_regressed,2); means_ti_alldists=mean(means_ti_regressed,2);
means_pe_alldists=mean(means_pe_regressed_alldomains,2); means_pl_alldists=mean(means_pl_regressed_alldomains,2); means_ti_alldists=mean(means_ti_regressed_alldomains,2);
alldomains = [means_pe_alldists' means_pl_alldists' means_ti_alldists'];
grps = [repmat({'pe'},1,num_subjs) repmat({'pl'},1,num_subjs) repmat({'ti'},1,num_subjs)];
[p, anovatab, stats] = anova1(alldomains, grps);

% ANOVA for distances
% [p_dist_pe, anovatab_dist_pe, stats_dist_pe] = anova1(means_pe);
% [p_dist_pl, anovatab_dist_pl, stats_dist_pl] = anova1(means_pl);
% [p_dist_ti, anovatab_dist_ti, stats_dist_ti] = anova1(means_ti);
% [p_dist_pe, anovatab_dist_pe, stats_dist_pe] = anova1(means_pe_regressed);
% [p_dist_pl, anovatab_dist_pl, stats_dist_pl] = anova1(means_pl_regressed);
% [p_dist_ti, anovatab_dist_ti, stats_dist_ti] = anova1(means_ti_regressed);
[p_dist_pe, anovatab_dist_pe, stats_dist_pe] = anova1(means_pe_regressed_alldomains);
[p_dist_pl, anovatab_dist_pl, stats_dist_pl] = anova1(means_pl_regressed_alldomains);
[p_dist_ti, anovatab_dist_ti, stats_dist_ti] = anova1(means_ti_regressed_alldomains);



%% plotting

% all domains vs others
figure; errorbar([nanmean(nanmean(means_pe)) nanmean(nanmean(means_pl)) nanmean(nanmean(means_ti))],[std(nanmean(means_pe)) std(nanmean(means_pl)) std(nanmean(means_ti))]/sqrt(num_subjs)),ylim([1.4 1.8])
set(gca,'xTickLabels',{'','person','','place','','time'})
% with wordlength regression
figure; errorbar([nanmean(nanmean(means_pe_regressed)) nanmean(nanmean(means_pl_regressed)) nanmean(nanmean(means_ti_regressed))],[std(nanmean(means_pe_regressed)) std(nanmean(means_pl_regressed)) std(nanmean(means_ti_regressed))]/sqrt(num_subjs)),ylim([1 1.8])
set(gca,'xTickLabels',{'','person','','place','','time'})
% with wordlength regression from all domains simultaneously
figure; errorbar([nanmean(nanmean(means_pe_regressed_alldomains)) nanmean(nanmean(means_pl_regressed_alldomains)) nanmean(nanmean(means_ti_regressed_alldomains))],[std(nanmean(means_pe_regressed_alldomains)) std(nanmean(means_pl_regressed_alldomains)) std(nanmean(means_ti_regressed_alldomains))]/sqrt(num_subjs)),ylim([1 1.8])
set(gca,'xTickLabels',{'','person','','place','','time'})

% figure;hist(cell2mat(all_person_RTs),0.5:0.1:2.5),xlabel('RT'),title('person')
% figure;hist(cell2mat(all_place_RTs),0.5:0.1:2.5),xlabel('RT'),title('place')
% figure;hist(cell2mat(all_time_RTs),0.5:0.1:2.5),xlabel('RT'),title('time')
% % with wordlength regression
% figure;hist(cell2mat(all_person_RTs_regressed),0:0.1:2.5),xlabel('RT'),title('person')
% figure;hist(cell2mat(all_place_RTs_regressed),0:0.1:2.5),xlabel('RT'),title('place')
% figure;hist(cell2mat(all_time_RTs_regressed),0:0.1:2.5),xlabel('RT'),title('time')
% % with wordlength regression from all domains simultaneously
% figure;hist(cell2mat(all_person_RTs_regressed_alldomains),0:0.1:2.5),xlabel('RT'),title('person')
% figure;hist(cell2mat(all_place_RTs_regressed_alldomains),0:0.1:2.5),xlabel('RT'),title('place')
% figure;hist(cell2mat(all_time_RTs_regressed_alldomains),0:0.1:2.5),xlabel('RT'),title('time')


% % specific domains
% figure;errorbar(nanmean(means_pe),std(means_pe)/sqrt(num_subjs)),ylim([1.3 1.9]), xlabel('distance'),ylabel('RT'),title('person')
% figure;errorbar(nanmean(means_pl),std(means_pl)/sqrt(num_subjs)),ylim([1.3 1.9]), xlabel('distance'),ylabel('RT'),title('place')
% figure;errorbar(nanmean(means_ti),std(means_ti)/sqrt(num_subjs)),ylim([1.3 1.9]), xlabel('distance'),ylabel('RT'),title('time')
% % with wordlength regression
% figure;errorbar(nanmean(means_pe_regressed),std(means_pe_regressed)/sqrt(num_subjs)),ylim([1 1.9]), xlabel('distance'),ylabel('RT'),title('person')
% figure;errorbar(nanmean(means_pl_regressed),std(means_pl_regressed)/sqrt(num_subjs)),ylim([1 1.9]), xlabel('distance'),ylabel('RT'),title('place')
% figure;errorbar(nanmean(means_ti_regressed),std(means_ti_regressed)/sqrt(num_subjs)),ylim([1 1.9]), xlabel('distance'),ylabel('RT'),title('time')
% % with wordlength regression from all domains simultaneously
% figure;errorbar(nanmean(means_pe_regressed_alldomains),std(means_pe_regressed_alldomains)/sqrt(num_subjs)),ylim([1 1.9]), xlabel('distance'),ylabel('RT'),title('person')
% figure;errorbar(nanmean(means_pl_regressed_alldomains),std(means_pl_regressed_alldomains)/sqrt(num_subjs)),ylim([1 1.9]), xlabel('distance'),ylabel('RT'),title('place')
% figure;errorbar(nanmean(means_ti_regressed_alldomains),std(means_ti_regressed_alldomains)/sqrt(num_subjs)),ylim([1 1.9]), xlabel('distance'),ylabel('RT'),title('time')

% for i=1:6, figure;hist(all_person_RTs{i},0.5:0.1:2.5), end
% for i=1:6, figure;hist(all_place_RTs{i},0.5:0.1:2.5), end
% for i=1:6, figure;hist(all_time_RTs{i},0.5:0.1:2.5), end


%% ANOVA tests
means_all = [mean(means_pe,2) mean(means_pl,2) mean(means_ti,2)];
[p,table,stats] = anova1(means_all);
multcompare(stats,'alpha',0.01);

% difficulty
difficulty = [2	3	8; 7	2	6; 8	7	5; 3	5	6; 2	4	7; ...
    4	6	8; 5	2	8; 1	4	7; 1	7	8; 2	3	8; ...
    2	5	6; 1	2	7; 2	6	7; 1	3	5; 3	3	6; 2	9	7];
[p,table,stats] = anova1(difficulty);
multcompare(stats,'alpha',0.01);
