% this is a script to use an existing GLM which is run on the smoothed data,
% create a similar GLM which uses the normalized functional files, and run
% it
%
% Also creates a 2nd-level fixed-effects design from all subjects


% create normalized design from smoothed design
subject='121129_Thibault';
load(['C:\Subjects_MRI_data\7T\' subject '\analysis\GLM_smoothed_with_time_derivative.mat']);
matlabbatch{1}.spm.stats.fmri_spec.dir={['C:\Subjects_MRI_data\7T\' subject '\analysis\GLM_normalized\']};
for i=1:length(matlabbatch{1}.spm.stats.fmri_spec.sess)
    for j=1:length(matlabbatch{1}.spm.stats.fmri_spec.sess(i).scans)
        a=matlabbatch{1}.spm.stats.fmri_spec.sess(i).scans{j};
        loc_s=strfind(a,'s_d')-1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).scans{j}=[a(1:48) 'W' a(49:loc_s) 'w' a(loc_s+1:end)];
        %loc_s=strfind(a,'detr')-1;
        %matlabbatch{1}.spm.stats.fmri_spec.sess(i).scans{j}=[a(1:51) 'W' a(52:loc_s) 'w' a(loc_s+1:end)];        
    end
end
save(['C:\Subjects_MRI_data\7T\' subject '\analysis\GLM_normalized_with_time_derivative.mat'], 'matlabbatch');

spm_jobman('run', matlabbatch);




% create fixed-effects design from all the normalized designs
subjects={'121119_Chrystany','121119_Sergey','121123_alex','121126_dorian','121126_george','121126_wietske','121126_achilleas','121127_Killroi','121129_Jeane','121129_Thibault'};
subject=subjects{1}
load(['C:\Subjects_MRI_data\7T\' subject '\analysis\GLM_normalized_with_time_derivative.mat']);
sess=matlabbatch{1}.spm.stats.fmri_spec.sess;
for subj=2:length(subjects)
    subject=subjects{subj}
    load(['C:\Subjects_MRI_data\7T\' subject '\Analysis\GLM_normalized_with_time_derivative.mat']);
    sess=[sess matlabbatch{1}.spm.stats.fmri_spec.sess];
end
matlabbatch{1}.spm.stats.fmri_spec.dir={'C:\Subjects_MRI_data\7T\2nd-level\Normalized_FFX\'};
matlabbatch{1}.spm.stats.fmri_spec.sess=sess;
save(['C:\Subjects_MRI_data\7T\2nd-level\GLM_2nd_level_normalized_FFX.mat'], 'matlabbatch');
spm_jobman('run', matlabbatch);
