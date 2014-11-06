% This function gets the results from HTML files (result of running the
% VOI-GLM option in BrainVoyager), and parses the files to get the beta values

subjects_output_dir = 'E:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names = dir(subjects_output_dir); subject_names = subject_names(3:end);

cell_names = {'person_par', 'person_pcn', 'place_par', 'place_pcn', 'time_par', 'time_pcn'};
file_names = {'PE_ALL_PAR', 'PE_ALL_PCN', 'PL_ALL_PAR', 'PL_ALL_PCN', 'TI_ALL_PAR', 'TI_ALL_PCN'};

beta_names = {'pe', 'pl', 'ti'};

num_cells = length(cell_names); num_betas = length(beta_names);
num_subjs = 16; 

% Defining the domains+regions  beta matrices
% Inside each cell - a subjects x betas matrix (in this case 22x18)
person_par_betas = nan(num_subjs, num_betas); person_pcn_betas = nan(num_subjs, num_betas);   
place_par_betas = nan(num_subjs, num_betas); place_pcn_betas = nan(num_subjs, num_betas);   
time_par_betas = nan(num_subjs, num_betas); time_pcn_betas = nan(num_subjs, num_betas);

contrasts_names = {'person_vs_others', 'place_vs_others', 'time vs others'};
contrasts = nan(num_cells, length(contrasts_names));

%% getting the data from the html files

for n=1:num_cells   % iterating over all filetypes (domain+region)
    for s=1:num_subjs       % iterating over all subjects
        current_filename = [subjects_output_dir subject_names(s).name '\ACPC\WO2_VOI_' file_names{n} '_vs_others_and_rest.html'];
        
        if exist(current_filename, 'file')
            % reading the file
            data = importdata(current_filename);
            
            % finding the locations of the betas
            starttable_locations = find(cellfun(@(x) ~isempty(strfind(x, '<tbody>')), data));
            endtable_locations = find(cellfun(@(x) ~isempty(strfind(x, '</tbody>')), data));
            starttable_betas = starttable_locations(5); endtable_betas = endtable_locations(5);
            
            % reading the betas
            current_betas = cell(num_betas,1);
            for b=1:num_betas
                for row=starttable_betas+1:endtable_betas-1       % iterating over all the beta table
                    if ~isempty(strfind(data{row}, beta_names{b}))
                        current_line_data = data{row};
                        td_locations = strfind(current_line_data, '<td'); end_td_locations = strfind(current_line_data, '</td');
                        current_betas{b} = [current_betas{b} str2double(current_line_data(td_locations(2)+4 : end_td_locations(2)-1))];
                    end
                end
            end
            % inserting the betas  to their corresponding array
            eval([cell_names{n} '_betas(s,:) = cell2mat(current_betas);']);
            
        end
    end
    
    % contrasts
    [~,p] = ttest(eval([cell_names{n} '_betas(:,1)'])*2 - eval([cell_names{n} '_betas(:,2)']) - eval([cell_names{n} '_betas(:,3)']),[],[],'right');
    contrasts(n,1) = p; % person vs other domains
    [~,p] = ttest(eval([cell_names{n} '_betas(:,2)'])*2 - eval([cell_names{n} '_betas(:,1)']) - eval([cell_names{n} '_betas(:,3)']),[],[],'right');
    contrasts(n,2) = p; % space vs other domains
    [~,p] = ttest(eval([cell_names{n} '_betas(:,3)'])*2 - eval([cell_names{n} '_betas(:,2)']) - eval([cell_names{n} '_betas(:,1)']),[],[],'right');
    contrasts(n,3) = p; % time vs other domains

end


%% Write the results to Excel
output_filename = 'F:\נוירופסיכיאטריה\Projects\Orientation\Results\VOI_GLM_WO2_vs_others.xls';
subjnames = struct2cell(subject_names); subjnames = subjnames(1,:)';

for n=1:num_cells
    sheet = cell_names{n};
    xlswrite(output_filename, {sheet}, sheet, 'A1');
    
    % write contrasts T values
    current_line = 3;
%     xlswrite(output_filename, {'subject'}, sheet, ['A' num2str(current_line)]);
%     xlswrite(output_filename, {'t-value'}, sheet, ['C' num2str(current_line)]);
%     xlswrite(output_filename, contrast_names, sheet, ['C' num2str(current_line+1) ':R' num2str(current_line+1)]);
%     xlswrite(output_filename, subjnames, sheet, ['A' num2str(current_line+2) ':A' num2str(current_line+1+num_subjs)]);
%     xlswrite(output_filename, eval([cell_names{n} '_contrasts{1}']), sheet, ['C' num2str(current_line+2) ':R' num2str(current_line+1+num_subjs)]);
%     xlswrite(output_filename, {'AVERAGE'}, sheet, ['A' num2str(current_line+2+num_subjs)]);
%     xlswrite(output_filename, nanmean(eval([cell_names{n} '_contrasts{1}'])), sheet, ['C' num2str(current_line+2+num_subjs) ':R' num2str(current_line+2+num_subjs)]);
%     xlswrite(output_filename, {'GROUP T-TEST'}, sheet, ['A' num2str(current_line+3+num_subjs)]);
%     [~,p]=ttest(eval([cell_names{n} '_contrasts{1}'])); xlswrite(output_filename, p, sheet, ['C' num2str(current_line+3+num_subjs) ':R' num2str(current_line+3+num_subjs)]);
%     
% 
%     % write contrasts P value
%     current_line = current_line+5+num_subjs;
%     xlswrite(output_filename, {'subject'}, sheet, ['A' num2str(current_line)]);
%     xlswrite(output_filename, {'p-value'}, sheet, ['C' num2str(current_line)]);
%     xlswrite(output_filename, contrast_names, sheet, ['C' num2str(current_line+1) ':R' num2str(current_line+1)]);
%     xlswrite(output_filename, subjnames, sheet, ['A' num2str(current_line+2) ':A' num2str(current_line+1+num_subjs)]);
%     xlswrite(output_filename, eval([cell_names{n} '_contrasts{2}']), sheet, ['C' num2str(current_line+2) ':R' num2str(current_line+1+num_subjs)]);
%     xlswrite(output_filename, {'AVERAGE'}, sheet, ['A' num2str(current_line+2+num_subjs)]);
%     xlswrite(output_filename, nanmean(eval([cell_names{n} '_contrasts{2}'])), sheet, ['C' num2str(current_line+2+num_subjs) ':R' num2str(current_line+2+num_subjs)]);
%     xlswrite(output_filename, {'PERCENT_SIGNIFICANT'}, sheet, ['A' num2str(current_line+3+num_subjs)]);
%     xlswrite(output_filename, sum(eval([cell_names{n} '_contrasts{2}'])<0.05) ./ sum(~isnan(eval([cell_names{n} '_contrasts{2}']))), sheet, ['C' num2str(current_line+3+num_subjs) ':R' num2str(current_line+3+num_subjs)]);

    % write average betas
%     current_line = current_line+5+num_subjs;
    xlswrite(output_filename, {'subject'}, sheet, ['A' num2str(current_line)]);
    xlswrite(output_filename, {'beta'}, sheet, ['C' num2str(current_line)]);
    xlswrite(output_filename, beta_names, sheet, ['C' num2str(current_line+1) ':E' num2str(current_line+1)]);
    xlswrite(output_filename, subjnames, sheet, ['A' num2str(current_line+2) ':A' num2str(current_line+1+num_subjs)]);
    xlswrite(output_filename, eval([cell_names{n} '_betas']), sheet, ['C' num2str(current_line+2) ':E' num2str(current_line+1+num_subjs)]);
    xlswrite(output_filename, {'AVERAGE'}, sheet, ['A' num2str(current_line+2+num_subjs)]);
    xlswrite(output_filename, nanmean(eval([cell_names{n} '_betas'])), sheet, ['C' num2str(current_line+2+num_subjs) ':E' num2str(current_line+2+num_subjs)]);
    xlswrite(output_filename, {'SEM'}, sheet, ['A' num2str(current_line+3+num_subjs)]);
    xlswrite(output_filename, nanstd(eval([cell_names{n} '_betas']))./sqrt(sum(~isnan(eval([cell_names{n} '_betas'])))), sheet, ['C' num2str(current_line+3+num_subjs) ':E' num2str(current_line+3+num_subjs)]);
    
end
