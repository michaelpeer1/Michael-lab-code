% This function gets the results from HTML files (result of running the
% VOI-GLM option in BrainVoyager), and parses the files to get the results
% of the pre-defined  contrasts (t-values and p-values)

subjects_output_dir = 'F:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end);

% Defining the domains+regions contrast matrices - each one includes a cell, t-values and p-values
% Inside each cell - a subjects x contrasts matrix (in this case 22x16)
person_frn_contrasts = cell(2,1); person_tmp_contrasts = cell(2,1); person_par_contrasts = cell(2,1); person_pcn_contrasts = cell(2,1);   
place_frn_contrasts = cell(2,1); place_tmp_contrasts = cell(2,1); place_par_contrasts = cell(2,1); place_pcn_contrasts = cell(2,1);   
time_frn_contrasts = cell(2,1); time_tmp_contrasts = cell(2,1); time_par_contrasts = cell(2,1); time_pcn_contrasts = cell(2,1);

% Defining the domains+regions beta matrices
% Inside each cell - a subjects x contrasts matrix (in this case 22x16)
person_frn_contrasts = cell(2,1); person_tmp_contrasts = cell(2,1); person_par_contrasts = cell(2,1); person_pcn_contrasts = cell(2,1);   
place_frn_contrasts = cell(2,1); place_tmp_contrasts = cell(2,1); place_par_contrasts = cell(2,1); place_pcn_contrasts = cell(2,1);   
time_frn_contrasts = cell(2,1); time_tmp_contrasts = cell(2,1); time_par_contrasts = cell(2,1); time_pcn_contrasts = cell(2,1);


cell_names = {'person_frn', 'person_tmp', 'person_par', 'person_pcn',...
    'place_frn', 'place_tmp', 'place_par', 'place_pcn',...
    'time_frn', 'time_tmp', 'time_par', 'time_pcn'};
file_names = {'PE_ALL_FRN', 'PE_ALL_TMP', 'PE_ALL_PAR', 'PE_ALL_PCN',...
    'PL_ALL_FRN', 'PL_ALL_TMP', 'PL_ALL_PAR', 'PL_ALL_PCN',...
    'TI_ALL_FRN', 'TI_ALL_TMP', 'TI_ALL_PAR', 'TI_ALL_PCN'};

contrast_names = {'person close vs. far (12 vs. 56)', 'place close vs. far (12 vs. 56)', 'time close vs. far (12 vs. 56)', 'all domains close vs. far (12 vs. 56)', ...
    'person and place close vs. far (12 vs. 56)', 'person and time close vs. far (12 vs. 56)', 'place and time close vs. far (12 vs. 56)',...
    'person close vs. far descending', 'place close vs. far descending', 'time close vs. far descending', ...
    'person close vs. medium (12 vs. 34)', 'person medium vs. far (34 vs. 56)',...
    'place close vs. medium (12 vs. 34)', 'place medium vs. far (34 vs. 56)',...
    'time close vs. medium (12 vs. 34)', 'time medium vs. far (34 vs. 56)'};

beta_names = {'pe_1', 'pe_2', 'pe_3', 'pe_4', 'pe_5', 'pe_6', 'pl_1', 'pl_2', 'pl_3', 'pl_4', 'pl_5', 'pl_6', 'ti_1', 'ti_2', 'ti_3', 'ti_4', 'ti_5', 'ti_6'};

num_cells = length(cell_names); num_subjs = length(subject_names); num_contrasts = length(contrast_names); num_betas = length(beta_names);

% Defining the domains+regions  beta matrices
% Inside each cell - a subjects x betas matrix (in this case 22x18)
person_frn_betas = nan(num_subjs, num_betas); person_tmp_betas = nan(num_subjs, num_betas); person_par_betas = nan(num_subjs, num_betas); person_pcn_betas = nan(num_subjs, num_betas);   
place_frn_betas = nan(num_subjs, num_betas); place_tmp_betas = nan(num_subjs, num_betas); place_par_betas = nan(num_subjs, num_betas); place_pcn_betas = nan(num_subjs, num_betas);   
time_frn_betas = nan(num_subjs, num_betas); time_tmp_betas = nan(num_subjs, num_betas); time_par_betas = nan(num_subjs, num_betas); time_pcn_betas = nan(num_subjs, num_betas);


%% getting the data from the html files

for n=1:num_cells   % iterating over all filetypes (domain+region)
    
    % filling the matrices with NaNs
    eval([cell_names{n} '_contrasts{1} = nan(num_subjs, num_contrasts);']);
    eval([cell_names{n} '_contrasts{2} = nan(num_subjs, num_contrasts);']);
    
    for s=1:num_subjs       % iterating over all subjects
%         current_filename = [subjects_output_dir subject_names(s).name '\ACPC\' file_names{n} '.html'];
%         current_filename = [subjects_output_dir subject_names(s).name '\ACPC\' file_names{n} '_vs_control_and_rest.html'];
        current_filename = [subjects_output_dir subject_names(s).name '\ACPC\' file_names{n} '_vs_others_and_rest.html'];
        
        if exist(current_filename, 'file')
            
            % reading the file  
            data = importdata(current_filename);
            % finding the locations of the contrasts and betas
            starttable_locations = find(cellfun(@(x) ~isempty(strfind(x, '<tbody>')), data));
            endtable_locations = find(cellfun(@(x) ~isempty(strfind(x, '</tbody>')), data));
            starttable_betas = starttable_locations(6); endtable_betas = endtable_locations(6);
            starttable_contrasts = starttable_locations(7); endtable_contrasts = endtable_locations(7);
            
            % reading and averaging betas
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
            % averaging while removing last run (control)
            eval([cell_names{n} '_betas(s,:) = cellfun(@(x) sum(x(1:end-1)), current_betas);']);
            
            % reading the contrasts
            for c = 1:num_contrasts
                current_line_data = data{starttable_contrasts+c};
                td_locations = strfind(current_line_data, '<td'); end_td_locations = strfind(current_line_data, '</td');
                current_tvalue = str2double(current_line_data(td_locations(4)+4 : end_td_locations(4)-1));
                current_pvalue = str2double(current_line_data(td_locations(5)+4 : end_td_locations(5)-1));
                % enter t+p values into matrix (cell S, contrast)
                eval([cell_names{n} '_contrasts{1}(s,c) = current_tvalue;']);
                eval([cell_names{n} '_contrasts{2}(s,c) = current_pvalue;']);
            end
            
        end
    end
end


%% Write the results to Excel
output_filename = 'H:\נוירופסיכיאטריה\Projects\Orientation\Results\distances_VOI_GLM_vs_others.xls';
subjnames = struct2cell(subject_names); subjnames = subjnames(1,:)';

for n=1:num_cells
    sheet = cell_names{n};
    xlswrite(output_filename, {sheet}, sheet, 'A1');
    
    % write contrasts T values
    current_line = 3;
    xlswrite(output_filename, {'subject'}, sheet, ['A' num2str(current_line)]);
    xlswrite(output_filename, {'t-value'}, sheet, ['C' num2str(current_line)]);
    xlswrite(output_filename, contrast_names, sheet, ['C' num2str(current_line+1) ':R' num2str(current_line+1)]);
    xlswrite(output_filename, subjnames, sheet, ['A' num2str(current_line+2) ':A' num2str(current_line+1+num_subjs)]);
    xlswrite(output_filename, eval([cell_names{n} '_contrasts{1}']), sheet, ['C' num2str(current_line+2) ':R' num2str(current_line+1+num_subjs)]);
    xlswrite(output_filename, {'AVERAGE'}, sheet, ['A' num2str(current_line+2+num_subjs)]);
    xlswrite(output_filename, nanmean(eval([cell_names{n} '_contrasts{1}'])), sheet, ['C' num2str(current_line+2+num_subjs) ':R' num2str(current_line+2+num_subjs)]);
    xlswrite(output_filename, {'GROUP T-TEST'}, sheet, ['A' num2str(current_line+3+num_subjs)]);
    [~,p]=ttest(eval([cell_names{n} '_contrasts{1}'])); xlswrite(output_filename, p, sheet, ['C' num2str(current_line+3+num_subjs) ':R' num2str(current_line+3+num_subjs)]);
    

    % write contrasts P value
    current_line = current_line+5+num_subjs;
    xlswrite(output_filename, {'subject'}, sheet, ['A' num2str(current_line)]);
    xlswrite(output_filename, {'p-value'}, sheet, ['C' num2str(current_line)]);
    xlswrite(output_filename, contrast_names, sheet, ['C' num2str(current_line+1) ':R' num2str(current_line+1)]);
    xlswrite(output_filename, subjnames, sheet, ['A' num2str(current_line+2) ':A' num2str(current_line+1+num_subjs)]);
    xlswrite(output_filename, eval([cell_names{n} '_contrasts{2}']), sheet, ['C' num2str(current_line+2) ':R' num2str(current_line+1+num_subjs)]);
    xlswrite(output_filename, {'AVERAGE'}, sheet, ['A' num2str(current_line+2+num_subjs)]);
    xlswrite(output_filename, nanmean(eval([cell_names{n} '_contrasts{2}'])), sheet, ['C' num2str(current_line+2+num_subjs) ':R' num2str(current_line+2+num_subjs)]);
    xlswrite(output_filename, {'PERCENT_SIGNIFICANT'}, sheet, ['A' num2str(current_line+3+num_subjs)]);
    xlswrite(output_filename, sum(eval([cell_names{n} '_contrasts{2}'])<0.05) ./ sum(~isnan(eval([cell_names{n} '_contrasts{2}']))), sheet, ['C' num2str(current_line+3+num_subjs) ':R' num2str(current_line+3+num_subjs)]);

    % write average betas
    current_line = current_line+5+num_subjs;
    xlswrite(output_filename, {'subject'}, sheet, ['A' num2str(current_line)]);
    xlswrite(output_filename, {'beta'}, sheet, ['C' num2str(current_line)]);
    xlswrite(output_filename, beta_names, sheet, ['C' num2str(current_line+1) ':T' num2str(current_line+1)]);
    xlswrite(output_filename, subjnames, sheet, ['A' num2str(current_line+2) ':A' num2str(current_line+1+num_subjs)]);
    xlswrite(output_filename, eval([cell_names{n} '_betas']), sheet, ['C' num2str(current_line+2) ':T' num2str(current_line+1+num_subjs)]);
    xlswrite(output_filename, {'AVERAGE'}, sheet, ['A' num2str(current_line+2+num_subjs)]);
    xlswrite(output_filename, nanmean(eval([cell_names{n} '_betas'])), sheet, ['C' num2str(current_line+2+num_subjs) ':T' num2str(current_line+2+num_subjs)]);
    xlswrite(output_filename, {'SEM'}, sheet, ['A' num2str(current_line+3+num_subjs)]);
    xlswrite(output_filename, nanstd(eval([cell_names{n} '_betas']))/sqrt(sum(~isnan(eval([cell_names{n} '_betas'])))), sheet, ['C' num2str(current_line+3+num_subjs) ':T' num2str(current_line+3+num_subjs)]);
    
end
