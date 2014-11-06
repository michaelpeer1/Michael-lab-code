% This is a script for pre-processing of all the resting-state scans of 
% orientation-experiments subjects run in 3-Tesla
% (Currently only Ro_Sc)
%
% Runs the normalization, smoothing, filtering, and FD calculation
%
% THIS IS THE FIRST STAGE - FOLLOW THIS BY DPARSFA - NUISANCE COVARIATES REGRESSION


start_from_stage=1; end_stage=4;
preproc_scripts_dir = 'C:\Users\Michael\Dropbox\Michael_scripts\preproc_jobs\';
path='C:\Subjects_MRI_data\3T\130913_ro_sc\nifti';
output_dir='C:\Subjects_MRI_data\3T\Preprocessing_new\RoSc\Resting state';
% a=dir([path '1211*']); a=a(2:end); num_subjs=length(a);
subject_name='130913_ro_sc';

% pre-processing with script
% parfor i=1:num_subjs
%     disp(i)
%     b=dir([path a(i).name '\Nifti\*rest*']);
%     func_dirname=fullfile([path a(i).name '\Nifti\'], b.name);
%     T1_UNI_dirname=dir([path a(i).name '\Nifti\*UNI*']); T1_UNI_dirname=fullfile([path a(i).name '\Nifti\'], T1_UNI_dirname.name);
%     T1_INV_dirname=dir([path a(i).name '\Nifti\*INV2*']); T1_INV_dirname=fullfile([path a(i).name '\Nifti\'], T1_INV_dirname.name);
%     subject_name=a(i).name;
%     % running the script
%     pre_process_7T_subject_rest(func_dirname, T1_UNI_dirname, T1_INV_dirname, output_dir, subject_name, start_from_stage, end_stage);
% end


% run DARTEL - create template
disp('Running DARTEL - create template');
rc1files={}; rc2files={};
rc1=dir([output_dir '\T1IMG\' subject_name '\rc1*']);
rc2=dir([output_dir '\T1IMG\' subject_name '\rc2*']);
    rc1files{end+1}=fullfile([output_dir '\T1IMG\' subject_name], rc1(1).name); 
    rc2files{end+1}=fullfile([output_dir '\T1IMG\' subject_name], rc1(1).name);
spm('defaults','fmri');
spm_jobman('initcfg');
load([preproc_scripts_dir 'DARTEL_create_template.mat']);
matlabbatch{1}.spm.tools.dartel.warp.images{1}=rc1files;
matlabbatch{1}.spm.tools.dartel.warp.images{2}=rc1files;

spm_jobman('run', matlabbatch);
clear matlabbatch

% run DARTEL - normalize
disp('Running DARTEL - normalize');
load([preproc_scripts_dir 'DARTEL_normalize.mat']);
% for i=1:num_subjs
%     disp(i);
%     subject_name=a(i).name;
    T1IMGdir=[output_dir '\T1IMG\' subject_name];
    FunRawRDir=[output_dir '\FunRawR\' subject_name];
    RealignParametersDir=[output_dir '\RealignParameter\' subject_name];

    files_to_normalize={};
    aa=dir(FunRawRDir); aa=aa(3:end);
    for j=1:length(aa)
        files_to_normalize{end+1} = fullfile(FunRawRDir,aa(j).name);
    end
%     files_to_normalize{end+1}=fullfile(T1IMGdir, 'Anatomical_corrected.img');
    curr_file=dir(fullfile(T1IMGdir, 'm*.nii'));
    files_to_normalize{end+1}=fullfile(T1IMGdir, curr_file(1).name);
    curr_file=dir(fullfile(T1IMGdir, 'c1*.nii'));
    files_to_normalize{end+1}=fullfile(T1IMGdir, curr_file(1).name);
    curr_file=dir(fullfile(T1IMGdir, 'c2*.nii'));
    files_to_normalize{end+1}=fullfile(T1IMGdir, curr_file(1).name);
    curr_file=dir(fullfile(T1IMGdir, 'c3*.nii'));
    files_to_normalize{end+1}=fullfile(T1IMGdir, curr_file(1).name);
%     files_to_normalize{end+1}=fullfile(T1IMGdir, 'c1Anatomical_corrected.nii');
%     files_to_normalize{end+1}=fullfile(T1IMGdir, 'c2Anatomical_corrected.nii');
%     files_to_normalize{end+1}=fullfile(T1IMGdir, 'c3Anatomical_corrected.nii');
    mean_func_image=dir([RealignParametersDir '\mean*.img']); 
    files_to_normalize{end+1}=fullfile(RealignParametersDir,mean_func_image(1).name);
    
    flow_field_file=dir([T1IMGdir '\u_*']);
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(1).flowfield={fullfile(T1IMGdir, flow_field_file(1).name)};
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(1).images=files_to_normalize;
% end

template_file=dir([output_dir '\T1IMG\' subject_name '\Template_6.*']);
matlabbatch{1}.spm.tools.dartel.mni_norm.template={[output_dir '\T1IMG\' subject_name '\' template_file(1).name]};

matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj=matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(1);

spm_jobman('run', matlabbatch);

% smoothing by 4mm
matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [4 4 4];
spm_jobman('run', matlabbatch);
clear matlabbatch

% moving files
disp('Moving files...');
% for i=1:num_subjs
%     disp(i)
%     subject_name=a(i).name;
    FunRawRDir=[output_dir '\FunRawR\' subject_name];
    FunRawRWDir=[output_dir '\FunRawRW\' subject_name];
    FunRawRWSDir=[output_dir '\FunRawRWS\' subject_name];

    mkdir(FunRawRWDir);
    aa=dir(fullfile(FunRawRDir,'w*'));
    for j=1:length(aa)
        movefile(fullfile(FunRawRDir, aa(j).name),FunRawRWDir);
    end
    mkdir(FunRawRWSDir);
    aa=dir(fullfile(FunRawRDir,'sw*'));
    for j=1:length(aa)
        movefile(fullfile(FunRawRDir, aa(j).name),FunRawRWSDir);
    end
% end

% Filtering using dparsfa's y_bandpass
disp('Filtering...');
TR=2.5;
mkdir([output_dir '\FunRawRF\']); %mkdir([output_dir '\FunRawRWSF\']); 
% for i=1:num_subjs
%     disp(i)
%     subject_name=a(i).name;
    FunRawRDir=[output_dir '\FunRawR\' subject_name];
    FunRawRWSDir=[output_dir '\FunRawRWS\' subject_name];
    FunRawRFDir=[output_dir '\FunRawRF\' subject_name];
    FunRawRWSFDir=[output_dir '\FunRawRWSF\' subject_name];
    
    y_bandpass(FunRawRDir, TR, 0.15, 0.01, 'Yes', '');
    movefile([FunRawRDir '_filtered'], FunRawRFDir);
    
     y_bandpass(FunRawRWSDir, TR, 0.15, 0.01, 'Yes', '');
     movefile([FunRawRWSDir '_filtered'], FunRawRWSFDir);
% end

% calculate FD_Power and FD_VanDijk, for covariates regression
% for i=1:num_subjs
%     subject_name=a(i).name;
    RealignParametersDir=[output_dir '\RealignParameter\' subject_name];
    
    rpname=dir([RealignParametersDir '\rp*']);
    RP=load(fullfile(RealignParametersDir,rpname.name));        
    
    %Calculate FD Van Dijk (Van Dijk, K.R., Sabuncu, M.R., Buckner, R.L., 2012. The influence of head motion on intrinsic functional connectivity MRI. Neuroimage 59, 431-438.)
    RPRMS = sqrt(sum(RP(:,1:3).^2,2));
    FD_VanDijk = abs(diff(RPRMS));
    FD_VanDijk = [0;FD_VanDijk];
    save([RealignParametersDir,'\FD_VanDijk_',subject_name,'.txt'], 'FD_VanDijk', '-ASCII', '-DOUBLE','-TABS');
    
    %Calculate FD Power (Power, J.D., Barnes, K.A., Snyder, A.Z., Schlaggar, B.L., Petersen, S.E., 2012. Spurious but systematic correlations in functional connectivity MRI networks arise from subject motion. Neuroimage 59, 2142-2154.)
    RPDiff=diff(RP);
    RPDiff=[zeros(1,6);RPDiff];
    RPDiffSphere=RPDiff;
    RPDiffSphere(:,4:6)=RPDiffSphere(:,4:6)*50;
    FD_Power=sum(abs(RPDiffSphere),2);
    save([RealignParametersDir,'\FD_Power_',subject_name,'.txt'], 'FD_Power', '-ASCII', '-DOUBLE','-TABS');
% end

% THIS MUST BE CONTINUED BY DPARSFA  - NUISANCE COVARIATES REGRESSION,
% AFTER CHANGING T1IMG TO T1IMGNEWSEGMENT

