load('C:\Subjects_MRI_data\7T\121119_Chrystany\Analysis\GLM_normalized\SPM.mat');
%load('C:\Subjects_MRI_data\7T\2nd-level\New\matlabbatch.mat')

cons=SPM.xCon;
for i=1:length(cons)
    % creating the new directory
    dirname=['C:\Subjects_MRI_data\7T\2nd-level\New\' num2str(i) '_' cons(i).name];
    mkdir(dirname);
    matlabbatch{1}.stats{1}.factorial_design.dir = {dirname};
    
    % finding the contrast file name
    contrast_filename=cons(i).Vcon.fname;
    
    % getting the contrast files from all subjects
    subjnames={'121119_Chrystany','121119_Sergey','121123_alex','121126_achilleas','121126_dorian','121126_george','121126_wietske','121127_Killroi','121129_Jeane','121129_Thibault'};
    scans={};
    for j=1:length(subjnames)
        scans{end+1}=['C:\Subjects_MRI_data\7T\' subjnames{j} '\Analysis\GLM_normalized\' contrast_filename];
    end
    matlabbatch{1}.stats{1}.factorial_design.des.t1.scans = scans;
    
    % adding estimation to matlabbatch
    spmmat_file=fullfile(dirname,'SPM.mat');
    matlabbatch{1}.stats{2}.fmri_est.spmmat = cellstr(spmmat_file);
    
    % adding a contrast of 1/0 to the paradigm
    matlabbatch{1}.stats{3}.con.spmmat=cellstr(spmmat_file);
    matlabbatch{1}.stats{3}.con.delete=1;
    matlabbatch{1}.stats{3}.con.consess{1}.tcon.name='1';
    matlabbatch{1}.stats{3}.con.consess{1}.tcon.convec=[1];
    
    % running the contrasts
    spm('defaults', 'FMRI');
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end

