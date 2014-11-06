function add_spike_regressors_to_ROISignals(ROISignals_dir, ROISignals_filenames, output_dir, num_regressors_per_subject)
% add_spike_regressors_to_ROISignals(ROISignals_dir, ROISignals_filenames, output_dir, num_regressors_per_subject)
%
% Receives a directory and filenames of ROISignals files (timecourses from
% AAL atlas ROIs), an output directory, and the requiered number of
% spikes (regressors) wanted in each experimental subject
% Saves the timecourses with random spike points 
%
% Rationale: if you have several experimental groups, one of them has 70 spikes
% overall across subjects, five subjects with 140 timepoints each (overall
% 10% of the data is spikes), then you can add random spike points to each
% group to have 10% spikes in each

num_subjs = length(ROISignals_filenames);
all_ROISignals=cell(1,num_subjs); num_timepoints=0;
for i=1:num_subjs
    load(fullfile(ROISignals_dir, ROISignals_filenames{i}));
    all_ROISignals{i}=ROISignals;
    num_timepoints = num_timepoints + size(ROISignals, 1);
end

% num_regressors_to_add = num_timepoints * percent_regressors / 100;
% num_regressors_per_subject = round(num_regressors_to_add / num_subjs);

for i=1:num_subjs
    a = randperm(size(all_ROISignals{i}, 1));
    a = a(1:num_regressors_per_subject);
    all_ROISignals{i}(a, :) = 0;
    ROISignals=all_ROISignals{i};
    save(fullfile(output_dir, ROISignals_filenames{i}), 'ROISignals');
end


