function [results] = analyze_results(filename)
% [results] = analyze_results(filename)
%
% this is a wrapper for the analysis functions for specific paradigms
% runs analyze_comparison.m, analyze_estimation.m, or analyze_interference.m

LOGPATH = 'C:\ExpyVR\log\';

% reading the paradigm type and the subject's name from the XML
xmlfile=xmlread(strcat(LOGPATH,'subjects.xml'));
childNodes = xmlfile.getFirstChild;
for i=0:childNodes.getLength-1
    if childNodes.item(i).hasAttributes
        expt=char(childNodes.item(i).getAttribute('exptime'));
        if strcmp(expt(1:end-2),filename(1:end-2))
            subj_paradigm = char(childNodes.item(i).getAttribute('paradigm'));
            subj_name = char(childNodes.item(i).getAttribute('name'));
        end
    end
end

if strfind(subj_paradigm, 'MRI')
    disp('please use analyze_MRI instead, with a file list...')
elseif strfind(subj_paradigm, 'omparison')
    %[mnn_abs_dist_including_zero, mnn_abs_dist_far, mnn_between_dist, mnn_isCorrect] = analyze_comparison(LOGPATH, filename, subj_name);
    analyze_comparison(LOGPATH, filename, subj_name);
    %results={mnn_abs_dist_including_zero, mnn_abs_dist_far, mnn_between_dist, mnn_isCorrect};
    results=[];
elseif strfind(subj_paradigm, 'stimation')
    %[mnn_stimulus_RTs, mnn_keysPressed_RTs, mnn_stimulus_keysPressed] = analyze_estimation(LOGPATH, filename, subj_name);
    analyze_estimation(LOGPATH, filename, subj_name);
    %results=[mnn_stimulus_RTs, mnn_keysPressed_RTs, mnn_stimulus_keysPressed];
    results=[];
elseif strfind(subj_paradigm, 'nterference')
    if strfind(subj_paradigm,'Local-time_place')
        [isSameTime_RTs, isClosestStimulusEarly_RTs, isCongruent_RTs, isleftLocationFront_RTs]=analyze_interference_local_time_place(LOGPATH,filename, subj_name);
        results=[isSameTime_RTs, isClosestStimulusEarly_RTs, isCongruent_RTs, isleftLocationFront_RTs];
    elseif strfind(subj_paradigm,'Local-place_time')
        a=analyze_interference_local_place_time(LOGPATH,filename, subj_name);
    end
end

