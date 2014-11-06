
subjects_output_dir = 'F:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end);

num_subjects_to_use = 16;
% bvqx = actxserver('BrainVoyagerQX.BrainVoyagerQXScriptAccess.1');


%% creating contrasts for event-related averaging without two runs / one run

% creating new contrast files for the first 17 subjects, without runs 2 and
% 4, or 2 only (so they can be used for creation of event-related averaging plots from
% activation clusters)

% nums_runs_to_remove = [2 4];
nums_runs_to_remove = 2;

for s=1:num_subjects_to_use
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    
    CTR_name = fullfile(ACPC_output_dir, [subj '.ctr']);
    MDM_name = fullfile(ACPC_output_dir, [subj '_ACPC.mdm']);
    ctr_xff=xff(CTR_name); mdm_xff=xff(MDM_name);
    num_runs = mdm_xff.NrOfStudies-1;   % getting the number of runs (without the control) from the MDM file
    
    % removing the relevant columns from the CTR file
    for i=1:length(nums_runs_to_remove)
        CTR_column_to_remove = (nums_runs_to_remove(i)-1)*3;
        ctr_xff.ContrastValues(:,CTR_column_to_remove+1:CTR_column_to_remove+3) = 0; % removing the needed runs from the contrast calculation, e.g. columns 4:6 for run 2        
    end
    % balancing the domains vs. control contrasts (4-6) after removal of the runs
    ctr_balance = sum(ctr_xff.ContrastValues(4,1:num_runs*3), 2) / 3;
    ctr_xff.ContrastValues(4:6,num_runs*3+1:num_runs*3+3) = -1 * ctr_balance; 
    
    % identifying the numbers of the removed VTCs, using the MDM file
    nums_of_removed_runs = [];
    for i=1:length(nums_runs_to_remove)
        nums_of_removed_runs = [nums_of_removed_runs mdm_xff.XTC_RTC{nums_runs_to_remove(i),1}(end-4)];
    end
    
    ctr_xff.SaveAs(fullfile(ACPC_output_dir, [subj '_WO' nums_of_removed_runs '.ctr']));
end


%% MANUAL STAGES

% 1. Open GLM and WO2-contrast, create VMPs for all subjects, save as 'subjectX_ACPC_WO2_domains.vmp' or 'subjectX_ACPC_WO24_domains.vmp' etc.
% 2. Run the 'change_VMP_visualization' script
% 3. Create an AVG file for each subject from VTC 2 (or 2 and 4) only, and save it as 'subjX_ACPC_runs2.avg' (or 'subjX_ACPC_runs24.avg')
% 4. Save VOIs from the maps, and change their names accordingly
% (VOIs of overlap regions - saved with threshold of 150)

% 5. OLD - open the VOI, open the timecourse and the AVG file, and save the data as subjectX_ERA_domain_location (e.g. subj1_ERA_pe_pcn)




%% Averaging all the VOI ERA data from all participants

% the script can currently handle averaging from one VTC only

VOI_filenames = {};
VOI_filenames{1} = '_pe_WO2_vs_control_and_rest.voi';
VOI_filenames{2} = '_pe_WO2_vs_others_and_rest.voi';
VOI_filenames{3} = '_pl_WO2_vs_control_and_rest.voi';
VOI_filenames{4} = '_pl_WO2_vs_others_and_rest.voi';
VOI_filenames{5} = '_ti_WO2_vs_control_and_rest.voi';
VOI_filenames{6} = '_ti_WO2_vs_others_and_rest.voi';

VOI_names = {'ALL_PAR', 'ALL_PCN'};

ERA_data = cell(length(VOI_filenames),length(VOI_names));
ERA_missing_clusters = cell(length(VOI_filenames),length(VOI_names));
for i=1:length(ERA_data(:))
    ERA_data{i} = cell(1,3); ERA_missing_clusters{i} = [];
end
nums_runs_to_use = 2;       % the run number from which to take the ERA

for s=1:num_subjects_to_use
    subj=subject_names(s).name;
    disp(subj);
    ACPC_output_dir=[fullfile(subjects_output_dir, subj) '\ACPC'];
    
    % getting the VTC files of the subject and reading the relevant ones for the event-related averaging
    vtc_files=getfullfiles(fullfile(ACPC_output_dir,'*.vtc'));
    vtc_files(cellfun(@(x) ~isempty(strfind(x,'rest')), vtc_files))=[];   % remove rest files, if existing
    % vtc={};
    % for i=1:length(nums_runs_to_use)
    %     vtc{i} = xff(vtc_files{nums_runs_to_use(i)});
    % end
    vtc = xff(vtc_files{nums_runs_to_use});
    
    % reading the relevant event-related averaging file - e.g. subj_runs2.avg or subj_runs24.avg
    nums = ''; for i=1:length(nums_runs_to_use), nums = [nums num2str(nums_runs_to_use(i))]; end
    avg_file = getfullfiles(fullfile(ACPC_output_dir,['*runs' nums '.avg']));
    avg = xff(avg_file{1});
    
    for i=1:length(VOI_filenames)
        voi_current = fullfile(ACPC_output_dir,[subj VOI_filenames{i}]);
        if exist(voi_current, 'file')
            % reading the VOI and its timecourse and averaging from it
            voi = xff(voi_current);
            voitc = vtc.VOITimeCourse(voi);
            plotdata = avg.Average(0, voitc);
            
            for j=1:length(VOI_names)
                % finding the relevant VOI in the list
                for v=1:length(voi.VOI)
                    len_comparison = min([length(voi.VOI(v).Name), length(VOI_names{j})]);
                    if strcmp(voi.VOI(v).Name(1:len_comparison), VOI_names{j}(1:len_comparison))
                        % saving the VOI data in the three domains
                        ERA_data{i,j}{1}(:,s) = plotdata(:,v,1);  % person
                        ERA_data{i,j}{2}(:,s) = plotdata(:,v,2);  % place
                        ERA_data{i,j}{3}(:,s) = plotdata(:,v,3);  % time
                    end
                end
            end
%         else        % if filename doesn't exist, fill with NaNs
%             for j=1:length(VOI_names)
%                 ERA_data{i,j}{1}(:,s) = nan;  % person
%                 ERA_data{i,j}{2}(:,s) = nan;  % place
%                 ERA_data{i,j}{3}(:,s) = nan;  % time
%             end
        end
    end
    
    if exist('vtc','var'), vtc.ClearObject; clear vtc; end
    if exist('voi','var'), voi.ClearObject; clear voi; end
    if exist('avg','var'), avg.ClearObject; clear avg; end
end

% fill in missing files in specific subjects with NaNs
for i=1:length(VOI_filenames)
    for j=1:length(VOI_names)
        for d=1:3
%         if size(ERA_data{i,j}{d},2) < num_subjects_to_use
%             ERA_data{i,j}{d}(:, size(ERA_data{i,j}{d},2):num_subjects_to_use) = nan;
%         end
            for s=1:size(ERA_data{i,j}{d},2)
                if nansum(ERA_data{i,j}{d}(:,s)) == 0
                    ERA_data{i,j}{d}(:,s) = nan;
                end
            end
        end
    end
end


% find missing ERAs
for i=1:size(ERA_data,1)
    for j=1:size(ERA_data,2)
        ERA_missing_clusters{i,j} = find(nansum(ERA_data{i,j}{1})==0);
        disp(['cluster ' VOI_filenames{i}  VOI_names{j} ' is missing from subjects: ' num2str(ERA_missing_clusters{i,j})]);
    end
end

% compute average and standard-error of the mean
means_ERA = cell(size(ERA_data)); sems_ERA = cell(size(ERA_data)); 
for i=1:length(ERA_data(:))
    means_ERA{i} = cell(1,3); sems_ERA{i} = cell(1,3);
    indices_good = find(nansum(ERA_data{i}{1})~=0);
    for j=1:3
        means_ERA{i}{j} = nanmean(ERA_data{i}{j}(:,indices_good),2);
        sems_ERA{i}{j} = nanstd(ERA_data{i}{j}(:,indices_good),[],2) / sqrt(length(indices_good));
    end
end


% saving the new data in an ERA file
% assumes the existence of at least one saved ERA dat file in the first subject's directory
subj=subject_names(1).name;
ACPC_output_dir=[fullfile(subjects_output_dir, subj) '\ACPC'];
% reading the existing file
curr_filename = getfullfiles([ACPC_output_dir '\' subj '*.dat']);
f=fopen(curr_filename{1}); current_file=textscan(f,'%s','delimiter','\n'); fclose(f);   % opening the ERA data file
data_positions = find(strcmp(current_file{1},'<data>'));  % finding the data itself
% saving data into a new ERA file
for i=1:length(VOI_filenames)
    for j=1:length(VOI_names)
        filename_new = [ACPC_output_dir '\' subj VOI_filenames{i}(1:end-4) '_' VOI_names{j} '_all_subjects.dat'];
        f=fopen(filename_new,'w');

        current_file{1}(data_positions(1)+1:data_positions(2)-1) = cellstr(num2str([means_ERA{i,j}{1} sems_ERA{i,j}{1}]));
        current_file{1}(data_positions(3)+1:data_positions(4)-1) = cellstr(num2str([means_ERA{i,j}{2} sems_ERA{i,j}{2}]));
        current_file{1}(data_positions(5)+1:data_positions(6)-1) = cellstr(num2str([means_ERA{i,j}{3} sems_ERA{i,j}{3}]));

        for row=1:length(current_file{1})
            fprintf(f,'%s\n',current_file{1}{row,:});
        end
        fclose(f);
    end
end





% %% Averaging all the ERA data from all participants
% 
% % file endings of ERA files - data
% ERA_names{1} = '_ERA_run2_pe_pcn';
% ERA_names{2} = '_ERA_run2_pl_pcn_pos';
% ERA_names{3} = '_ERA_run2_ti_pcn';
% ERA_names{1} = '_ERA_run2_pe_par';
% ERA_names{2} = '_ERA_run2_pl_par';
% ERA_names{3} = '_ERA_run2_ti_par';
% ERA_data=cell(size(ERA_names));
% ERA_missing_clusters = cell(size(ERA_names));
% 
% for i=1:length(ERA_names)
%     ERA_data{i}=cell(1,3);
%     ERA_missing_clusters{i}=[];
%     
%     for s=1:num_subjects_to_use
%         subj=subject_names(s).name;
%         disp(subj);
%         ACPC_output_dir=[fullfile(subjects_output_dir, subj) '\ACPC'];
%         
%         filename = [ACPC_output_dir '\' subj ERA_names{i} '.dat'];
%         if exist(filename,'file')
%             f=fopen(filename);
%             current_file=textscan(f,'%s','delimiter','\n'); fclose(f);   % opening the ERA data file
%             data_positions = find(strcmp(current_file{1},'<data>'));  % finding the data itself
%             person_temp=[]; place_temp=[]; time_temp=[];
%             for j=1:data_positions(2)-data_positions(1)-1
%                 person_temp = [person_temp; str2num(current_file{1}{data_positions(1)+j})];
%                 place_temp = [place_temp; str2num(current_file{1}{data_positions(3)+j})];
%                 time_temp = [time_temp; str2num(current_file{1}{data_positions(5)+j})];
%             end
%             
%             ERA_data{i}{1} = cat(3, ERA_data{i}{1}, person_temp);
%             ERA_data{i}{2} = cat(3, ERA_data{i}{2}, place_temp);
%             ERA_data{i}{3} = cat(3, ERA_data{i}{3}, time_temp);
%         
%         else
%             ERA_missing_clusters{i} = [ERA_missing_clusters{i} s];
%         end
%     end
%     
%     % calculating average and SEM of the ERA data from all subjects
%     person_all = [mean(ERA_data{i}{1}(:,1,:),3) std(ERA_data{i}{1}(:,1,:),0,3)/sqrt(size(ERA_data{i}{1},3))];
%     place_all = [mean(ERA_data{i}{2}(:,1,:),3) std(ERA_data{i}{2}(:,1,:),0,3)/sqrt(size(ERA_data{i}{2},3))];
%     time_all = [mean(ERA_data{i}{3}(:,1,:),3) std(ERA_data{i}{3}(:,1,:),0,3)/sqrt(size(ERA_data{i}{3},3))];
%     
%     
%     % saving the data into new file in the first subject's directory
%     subj=subject_names(1).name;
%     ACPC_output_dir=[fullfile(subjects_output_dir, subj) '\ACPC'];
%     filename_new = [ACPC_output_dir '\' subj ERA_names{i} '_all_subjects.dat'];
%     f=fopen(filename_new,'w');
%     
%     data_positions = find(strcmp(current_file{1},'<data>'));
%     current_file{1}(data_positions(1)+1:data_positions(2)-1) = cellstr(num2str(person_all));
%     current_file{1}(data_positions(3)+1:data_positions(4)-1) = cellstr(num2str(place_all));
%     current_file{1}(data_positions(5)+1:data_positions(6)-1) = cellstr(num2str(time_all));
%     
%     for row=1:length(current_file{1})
%         fprintf(f,'%s\n',current_file{1}{row,:});
%     end
%     fclose(f);
% end
% 
% for i=1:length(ERA_names)
%     if ~isempty(ERA_missing_clusters{i})
%         disp(['cluster ' ERA_names{i}(6:end) ' is missing from subjects: ' num2str(ERA_missing_clusters{i})]);
%     end
% end
% 
% 



%% OVERLAP BETWEEN REGIONS - EVENT-RELATED AVERAGING

% MANUAL STAGES:
% Save VOIs from the maps (WO2_domains.vmp)
% (VOIs of overlap regions - saved with threshold of 150)
% In each VOI file, create one combined VOI (using a OR b) named OVERLAP_ALL 

VOI_filenames{1} = '_WO2_overlap_all.voi';
VOI_filenames{2} = '_WO2_overlap_pe_pl.voi';
VOI_filenames{3} = '_WO2_overlap_pe_ti.voi';
VOI_filenames{4} = '_WO2_overlap_pl_ti.voi';

VOI_names = {'OVERLAP_ALL'};

ERA_data = cell(length(VOI_filenames),length(VOI_names));
ERA_missing_clusters = cell(length(VOI_filenames),length(VOI_names));
for i=1:length(ERA_data(:))
    ERA_data{i} = cell(1,3); ERA_missing_clusters{i} = [];
end
nums_runs_to_use = 2;       % the run number from which to take the ERA

for s=1:num_subjects_to_use
    subj=subject_names(s).name;
    disp(subj);
    ACPC_output_dir=[fullfile(subjects_output_dir, subj) '\ACPC'];
    
    % getting the VTC files of the subject and reading the relevant ones for the event-related averaging
    vtc_files=getfullfiles(fullfile(ACPC_output_dir,'*.vtc'));
    vtc_files(cellfun(@(x) ~isempty(strfind(x,'rest')), vtc_files))=[];   % remove rest files, if existing
    % vtc={};
    % for i=1:length(nums_runs_to_use)
    %     vtc{i} = xff(vtc_files{nums_runs_to_use(i)});
    % end
    vtc = xff(vtc_files{nums_runs_to_use});
    
    % reading the relevant event-related averaging file - e.g. subj_runs2.avg or subj_runs24.avg
    nums = ''; for i=1:length(nums_runs_to_use), nums = [nums num2str(nums_runs_to_use(i))]; end
    avg_file = getfullfiles(fullfile(ACPC_output_dir,['*runs' nums '.avg']));
    avg = xff(avg_file{1});
    
    for i=1:length(VOI_filenames)
        voi_current = fullfile(ACPC_output_dir,[subj VOI_filenames{i}]);
        if exist(voi_current, 'file')
            % reading the VOI file and its timecourse and averaging from it
            voi = xff(voi_current);
            voitc = vtc.VOITimeCourse(voi);
            plotdata = avg.Average(0, voitc);
            
            for j=1:length(VOI_names)
                % finding the relevant VOI in the list
                for v=1:length(voi.VOI)
                    len_comparison = min([length(voi.VOI(v).Name), length(VOI_names{j})]);
                    if strcmp(voi.VOI(v).Name(1:len_comparison), VOI_names{j}(1:len_comparison))
                        % saving the VOI data in the three domains
                        ERA_data{i,j}{1}(:,s) = plotdata(:,v,1);  % person
                        ERA_data{i,j}{2}(:,s) = plotdata(:,v,2);  % place
                        ERA_data{i,j}{3}(:,s) = plotdata(:,v,3);  % time
                    end
                end
            end
%         else        % if filename doesn't exist, fill with NaNs
%             for j=1:length(VOI_names)
%                 ERA_data{i,j}{1}(:,s) = nan;  % person
%                 ERA_data{i,j}{2}(:,s) = nan;  % place
%                 ERA_data{i,j}{3}(:,s) = nan;  % time
%             end
        end
    end
    
    if exist('vtc','var'), vtc.ClearObject; clear vtc; end
    if exist('voi','var'), voi.ClearObject; clear voi; end
    if exist('avg','var'), avg.ClearObject; clear avg; end
end

% fill in missing files in specific subjects with NaNs
for i=1:length(VOI_filenames)
    for j=1:length(VOI_names)
        for d=1:3
%         if size(ERA_data{i,j}{d},2) < num_subjects_to_use
%             ERA_data{i,j}{d}(:, size(ERA_data{i,j}{d},2):num_subjects_to_use) = nan;
%         end
            for s=1:size(ERA_data{i,j}{d},2)
                if nansum(ERA_data{i,j}{d}(:,s)) == 0
                    ERA_data{i,j}{d}(:,s) = nan;
                end
            end
        end
    end
end

% find missing ERAs
for i=1:size(ERA_data,1)
    for j=1:size(ERA_data,2)
        ERA_missing_clusters{i,j} = find(nansum(ERA_data{i,j}{1})==0);
        disp(['cluster ' VOI_filenames{i}  VOI_names{j} ' is missing from subjects: ' num2str(ERA_missing_clusters{i,j})]);
    end
end

% compute average and standard-error of the mean
means_ERA = cell(size(ERA_data)); sems_ERA = cell(size(ERA_data)); 
for i=1:length(ERA_data(:))
    means_ERA{i} = cell(1,3); sems_ERA{i} = cell(1,3);
    indices_good = find(nansum(ERA_data{i}{1})~=0);
    for j=1:3
        means_ERA{i}{j} = nanmean(ERA_data{i}{j}(:,indices_good),2);
        sems_ERA{i}{j} = nanstd(ERA_data{i}{j}(:,indices_good),[],2) / sqrt(length(indices_good));
    end
end

% saving the new data in an ERA file
% assumes the existence of at least one saved ERA dat file in the first subject's directory
subj=subject_names(1).name;
ACPC_output_dir=[fullfile(subjects_output_dir, subj) '\ACPC'];
% reading the existing file
curr_filename = getfullfiles([ACPC_output_dir '\' subj '*.dat']);
f=fopen(curr_filename{1}); current_file=textscan(f,'%s','delimiter','\n'); fclose(f);   % opening the ERA data file
data_positions = find(strcmp(current_file{1},'<data>'));  % finding the data itself
% saving data into a new ERA file
for i=1:length(VOI_filenames)
    for j=1:length(VOI_names)
        filename_new = [ACPC_output_dir '\' subj VOI_filenames{i}(1:end-4) '_' VOI_names{j} '_all_subjects.dat'];
        f=fopen(filename_new,'w');

        current_file{1}(data_positions(1)+1:data_positions(2)-1) = cellstr(num2str([means_ERA{i,j}{1} sems_ERA{i,j}{1}]));
        current_file{1}(data_positions(3)+1:data_positions(4)-1) = cellstr(num2str([means_ERA{i,j}{2} sems_ERA{i,j}{2}]));
        current_file{1}(data_positions(5)+1:data_positions(6)-1) = cellstr(num2str([means_ERA{i,j}{3} sems_ERA{i,j}{3}]));

        for row=1:length(current_file{1})
            fprintf(f,'%s\n',current_file{1}{row,:});
        end
        fclose(f);
    end
end

