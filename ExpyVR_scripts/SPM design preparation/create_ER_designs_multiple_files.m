function create_ER_designs_multiple_files(filenames, times_start_TRs, TR, len_stimulus, len_end_rest, num_removed_volumes)
% create_ER_designs_multiple_files(filenames, times_start_TRs, TR, len_stimulus, len_end_rest, num_removed_volumes)
%
% This is a wrapper for running the create_ER_design_from_log.m and the
% create_ER_domain_design_from_design.m scripts on multiple files
% 
% receives:
% - a cell array of filenames - number only (e.g. for c:\expyvr\log\123456789_keyboard.csv, give the function {'123456789'} )
% - a cell array of times of TR start relative to paradigm start 
%   (if paradigm was started 2 seconds before the scan was started, this would be 2)
% - the TR length in seconds
% - the stimulus length in seconds
% - the end-rest length in seconds (usually 15s)
% - the number of volumes removed at the beginning (sometimes 5)

% 3T distance design: times_start_TRs - changing, TR - 2 or 2.5, 
% len_stimulus - 2.5, len_end_rest - 15, num_removed_volumes - 5

% 7T distance design: times_start_TRs - 0, TR - 2.5, 
% len_stimulus - 2.5, len_end_rest - 15, num_removed_volumes - 0


for i=1:length(filenames)
    create_ER_design_from_log(filenames(i), times_start_TRs, TR, len_stimulus, len_end_rest, num_removed_volumes);
    create_ER_domain_design_from_design(filenames{i});
end

