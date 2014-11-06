function create_block_designs_multiple_files(filenames, times_start_TRs, TR, len_block, len_end_rest, num_excessive_TRs, num_removed_volumes)
% create_block_designs_multiple_files(filenames, times_start_TRs, TR, len_block, len_end_rest, num_excessive_TRs, num_removed_volumes)
%
% This is a wrapper for running the create_block_design_from_log.m and the
% create_domain_design_from_design.m scripts on multiple files

% receives:
% - a cell array of filenames - number only (e.g. for c:\expyvr\log\123456789_keyboard.csv, give the function {'123456789'} )
% - a cell array of times of TR start relative to paradigm start 
%   (if paradigm was started 2 seconds before the scan was started, this would be 2)
% - the TR length in seconds
% - the block length in seconds
% - the end-rest length in seconds (usually 15s)
% - the number of excessive TRs in the paradigm (sometimes 1)
% - the number of volumes removed at the beginning (sometimes 5)

% 3T distance design: times_start_TRs - changing, TR - 2 or 2.5, len_block
% - 10, len_end_rest - 15, num_excessive_TRs - 1, num_removed_volumes - 5

% 7T distance design: times_start_TRs - 0, TR - 2.5, len_block - 10,
% len_end_rest - 15, num_excessive_TRs - 0, num_removed_volumes - 0


for i=1:length(filenames)
    create_block_design_from_log(filenames(i), times_start_TRs, TR, len_block, len_end_rest, num_excessive_TRs, num_removed_volumes);
    create_domain_design_from_design(filenames{i});
end

