function [names, onsets, durations]=create_ER_domain_design_from_design(design_filename)
% [names, onsets, durations]=create_domain_design_from_design(design_filename)
%
% This function creates a domain design (which uses one predictor for space, 
% time or person, instead of separating the distances), from a design file
% with distances. The original design matrix is an ER design
% (uses the results of the create_ER_design functions)
%
% receives a filename and the TR in seconds
% (filename - number only (e.g. for c:\expyvr\log\123456789_keyboard.csv, give the function {'123456789'} ))

load(['c:\expyvr\log\' design_filename '_ER_design.mat']);
names_new={'pe','pl','ti'};
onsets_new=cell(3,1); durations_new=cell(1,3);
for i=1:length(names)
    for j=1:length(names_new)
        if strcmp(names{i}(1:2),names_new{j})
            onsets_new{j}=[onsets_new{j} onsets{i}];
            durations_new{j}=[durations_new{j} durations{i}];     % length of block/stimulus
        end
    end
end

onsets=onsets_new; durations=durations_new; names=names_new;
save(['c:\expyvr\log\' design_filename '_ER_domain_design.mat'],'names','onsets','durations');