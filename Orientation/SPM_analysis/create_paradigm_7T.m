function create_paradigm_7T(functional_dirname, subj_name, paradigm_filenames, add_mov_regressors, ignore_sessions, time_derivative, dispersion_derivative, output_dir)

% This function creates an SPM.mat file for a subject, estimates it, and
% builds the corresponding contrasts
%
% Input:

% functional_dirname - the directory containing the functional files.
% (FunRaw, FunRawRSD, etc.). We assume the realignment parameters are under
% the ../RealignParameter/ directory.

% subj_name - the subject name. Sessions should be ordered as subj_name_1 /
% 2 / etc. directories.

% paradigm_filenames - a cell array of the filenames of the paradigm files
% in ExpyVR. The log directory is assumed to be c:\ExpyVR\log\. The names
% should contain only the filename itself (the number), not the '.mat' or
% the path. We use this cell array to get the number of sessions.

% add_mov_regressors - add additional movement regressors - Friston 24 and
% spike-specific regressors.

% ignore_sessions - a list of bad sessions to ignore.

% time_derivative - use time derivative for HRF (1/0)

% dispersion_derivative - use dispersion derivative for HRF (1/0)

% output_dir - the directory which will contain the output SPM.mat file.


if ~exist(output_dir,'dir'), mkdir(output_dir); end

expyvr_log_dir = 'c:\ExpyVR\log';
numsess = length(paradigm_filenames);
i=strfind(functional_dirname,'\'); parent_dir = functional_dirname(1:i(end));

% create design matrix
matlabbatch{1}.stats{1}.fmri_spec.bases.hrf.derivs = [time_derivative dispersion_derivative];
matlabbatch{1}.stats{1}.fmri_spec.dir = cellstr(output_dir);

matlabbatch{1}.stats{1}.fmri_spec.timing.units = 'scans';
matlabbatch{1}.stats{1}.fmri_spec.timing.RT = 2.5;
matlabbatch{1}.stats{1}.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.stats{1}.fmri_spec.timing.fmri_t0 = 1;

for i=1:numsess
    % getting the movement parameters
    mov_current_dir=[parent_dir 'RealignParameter\' subj_name '_' num2str(i)];
    rp_filename=dir(fullfile(mov_current_dir, 'rp*.txt')); rp_filename=fullfile(mov_current_dir, rp_filename(1).name);
    if add_mov_regressors
        % add additional movement regressors and detrend regressor
        rp_filename = additional_movement_regressors(rp_filename,1);
    end
    aa=dlmread(rp_filename);
    num_mov_regressors(i)=size(aa,2);   % number of movement regressors
    
    % reading the functional files - taken from DPARSFA
    session_dirname=[functional_dirname '\' subj_name '_' num2str(i)];
    cd(session_dirname);
    DirImg=dir('*.img');
    if isempty(DirImg)  % nii file
        DirImg=dir('*.nii.gz');  % Search .nii.gz and if found unzip;
        if length(DirImg)==1
            gunzip(DirImg(1).name);
            delete(DirImg(1).name);
        end
        DirImg=dir('*.nii');
    end
    if length(DirImg)>1  %3D .img or .nii images.
        FileList=cell(1,length(DirImg));
        for j=1:length(DirImg)
            FileList{j}=fullfile(session_dirname, DirImg(j).name);
        end
    else %4D .nii images
        Nii  = nifti(DirImg(1).name);
        FileList=cell(1,size(Nii.dat,4));
        for j=1:size(Nii.dat,4)
            FileList{j}=[session_dirname '\' DirImg(1).name ',' num2str(j)];
        end
    end
    
    % setting the session parameters
    matlabbatch{1}.stats{1}.fmri_spec.sess(i).scans = FileList;
    matlabbatch{1}.stats{1}.fmri_spec.sess(i).multi = cellstr([expyvr_log_dir '\' paradigm_filenames{i} '_design.mat']);
    matlabbatch{1}.stats{1}.fmri_spec.sess(i).multi_reg{1} = rp_filename;
end


% estimation of the SPM.mat file
spmmat_file=fullfile(output_dir,'SPM.mat');
matlabbatch{1}.stats{2}.fmri_est.spmmat = cellstr(spmmat_file);


% creating the contrasts
basic_contrast_vectors={};  % the basic contrast for each session
basic_contrast_vector_control={};  % the basic contrast for the control session
contrast_names={};
contypes={};    % 1 for t-contrast, 2 for f-contrast

% The basic contrast vectors (per session, without movement regressors)
% (the paradigm in each session is: person, place, time. In each one there are 6 distances)
i=1; contypes{i}=1; contrast_names{i}= 'All domains vs. rest'; basic_contrast_vectors{i}=ones(1,18); basic_contrast_vector_control{i}=zeros(1,18);
i=2; contypes{i}=1; contrast_names{i}= 'All domains and control vs. rest'; basic_contrast_vectors{i}=ones(1,18); basic_contrast_vector_control{i}=ones(1,18);
i=3; contypes{i}=1; contrast_names{i}= 'Person vs. rest'; basic_contrast_vectors{i}=[ones(1,6) zeros(1,12)];basic_contrast_vector_control{i}=zeros(1,18);
i=4; contypes{i}=1; contrast_names{i}= 'Place vs. rest'; basic_contrast_vectors{i}=[zeros(1,6) ones(1,6) zeros(1,6)];basic_contrast_vector_control{i}=zeros(1,18);
i=5; contypes{i}=1; contrast_names{i}= 'Time vs. rest'; basic_contrast_vectors{i}=[zeros(1,12) ones(1,6)];basic_contrast_vector_control{i}=zeros(1,18);
i=6; contypes{i}=1; contrast_names{i}= 'Control vs. rest'; basic_contrast_vectors{i}=zeros(1,18); basic_contrast_vector_control{i}=ones(1,18);

i=7; contypes{i}=1; contrast_names{i}= 'Person vs time and place'; basic_contrast_vectors{i}=[ones(1,6)*2 ones(1,12)*(-1)];basic_contrast_vector_control{i}=zeros(1,18);
i=8; contypes{i}=1; contrast_names{i}= 'Place vs person and time'; basic_contrast_vectors{i}=[ones(1,6)*(-1) ones(1,6)*2 ones(1,6)*(-1)];basic_contrast_vector_control{i}=zeros(1,18);
i=9; contypes{i}=1; contrast_names{i}= 'Time vs person and place'; basic_contrast_vectors{i}=[ones(1,12)*(-1) ones(1,6)*2];basic_contrast_vector_control{i}=zeros(1,18);
i=10; contypes{i}=1; contrast_names{i}= 'Person vs. place'; basic_contrast_vectors{i}=[ones(1,6) ones(1,6)*(-1) zeros(1,6)];basic_contrast_vector_control{i}=zeros(1,18);
i=11; contypes{i}=1; contrast_names{i}= 'Person vs. time'; basic_contrast_vectors{i}=[ones(1,6) zeros(1,6) ones(1,6)*(-1)];basic_contrast_vector_control{i}=zeros(1,18);
i=12; contypes{i}=1; contrast_names{i}= 'Place vs. person'; basic_contrast_vectors{i}=[ones(1,6)*(-1) ones(1,6) zeros(1,6)];basic_contrast_vector_control{i}=zeros(1,18);
i=13; contypes{i}=1; contrast_names{i}= 'Place vs. time'; basic_contrast_vectors{i}=[zeros(1,6) ones(1,6) ones(1,6)*(-1)];basic_contrast_vector_control{i}=zeros(1,18);
i=14; contypes{i}=1; contrast_names{i}= 'Time vs. person'; basic_contrast_vectors{i}=[ones(1,6)*(-1) zeros(1,6) ones(1,6)];basic_contrast_vector_control{i}=zeros(1,18);
i=15; contypes{i}=1; contrast_names{i}= 'Time vs place'; basic_contrast_vectors{i}=[zeros(1,6) ones(1,6)*(-1) ones(1,6)];basic_contrast_vector_control{i}=zeros(1,18);
% i=16; contypes{i}=2; contrast_names{i}= 'Person vs. (time and place)'; basic_contrast_vectors{i}={[ones(1,6) ones(1,6)*(-1) zeros(1,6)],  [ones(1,6) zeros(1,6) ones(1,6)*(-1)]};
% basic_contrast_vector_control{i}={zeros(1,18),  zeros(1,18)};
% i=17; contypes{i}=2; contrast_names{i}= 'Place vs. (time and person)'; basic_contrast_vectors{i}={[ones(1,6)*(-1) ones(1,6) zeros(1,6)],  [zeros(1,6) ones(1,6) ones(1,6)*(-1)]};
% basic_contrast_vector_control{i}={zeros(1,18),  zeros(1,18)};
% i=18; contypes{i}=2; contrast_names{i}= 'Time vs. (place and person)'; basic_contrast_vectors{i}={[ones(1,6)*(-1) zeros(1,6) ones(1,6)], [zeros(1,6) ones(1,6)*(-1) ones(1,6)]};
% basic_contrast_vector_control{i}={zeros(1,18),  zeros(1,18)};
 
i=16; contypes{i}=1; contrast_names{i}= 'Domains vs control'; basic_contrast_vectors{i}=ones(1,18); basic_contrast_vector_control{i}=ones(1,18)*(-1)*(numsess-1);
i=17; contypes{i}=1; contrast_names{i}= 'Person vs control'; basic_contrast_vectors{i}=[ones(1,6) zeros(1,12)]; basic_contrast_vector_control{i}=ones(1,18)*(-1)*(numsess-1)/3;
i=18; contypes{i}=1; contrast_names{i}= 'Place vs control'; basic_contrast_vectors{i}=[zeros(1,6) ones(1,6) zeros(1,6)]; basic_contrast_vector_control{i}=ones(1,18)*(-1)*(numsess-1)/3;
i=19; contypes{i}=1; contrast_names{i}= 'Time vs control'; basic_contrast_vectors{i}=[zeros(1,12) ones(1,6)]; basic_contrast_vector_control{i}=ones(1,18)*(-1)*(numsess-1)/3;
% i=23; contypes{i}=2; contrast_names{i}= 'Person vs control F'; basic_contrast_vectors{i}={[repmat([1 0], 1, 6) zeros(1,24) zeros(1,6) repmat(zeros(1,42), 1, 4) repmat([-1 0], 1, 6) zeros(1,24) zeros(1,6)],...
% [repmat(zeros(1,42), 1, 1) repmat([1 0], 1, 6) zeros(1,24) zeros(1,6) repmat(zeros(1,42), 1, 3) repmat([-1 0], 1, 6) zeros(1,24) zeros(1,6)],...
% [repmat(zeros(1,42), 1, 2) repmat([1 0], 1, 6) zeros(1,24) zeros(1,6) repmat(zeros(1,42), 1, 2) repmat([-1 0], 1, 6) zeros(1,24) zeros(1,6)],...
% [repmat(zeros(1,42), 1, 3) repmat([1 0], 1, 6) zeros(1,24) zeros(1,6) repmat(zeros(1,42), 1, 1) repmat([-1 0], 1, 6) zeros(1,24) zeros(1,6)],...
% [repmat(zeros(1,42), 1, 4) repmat([1 0], 1, 6) zeros(1,24) zeros(1,6) repmat([-1 0], 1, 6) zeros(1,24) zeros(1,6)]};
% i=24; contypes{i}=2; contrast_names{i}= 'Place vs control F'; basic_contrast_vectors{i}={[zeros(1,12) repmat([1 0], 1, 6) zeros(1,12) zeros(1,6) repmat(zeros(1,42), 1, 4) zeros(1,12) repmat([-1 0], 1, 6) zeros(1,12) zeros(1,6)],...
% [repmat(zeros(1,42), 1, 1) zeros(1,12) repmat([1 0], 1, 6) zeros(1,12) zeros(1,6) repmat(zeros(1,42), 1, 3) zeros(1,12) repmat([-1 0], 1, 6) zeros(1,12) zeros(1,6)],...
% [repmat(zeros(1,42), 1, 2) zeros(1,12) repmat([1 0], 1, 6) zeros(1,12) zeros(1,6) repmat(zeros(1,42), 1, 2) zeros(1,12) repmat([-1 0], 1, 6) zeros(1,12) zeros(1,6)],...
% [repmat(zeros(1,42), 1, 3) zeros(1,12) repmat([1 0], 1, 6) zeros(1,12) zeros(1,6) repmat(zeros(1,42), 1, 1) zeros(1,12) repmat([-1 0], 1, 6) zeros(1,12) zeros(1,6)],...
% [repmat(zeros(1,42), 1, 4) zeros(1,12) repmat([1 0], 1, 6) zeros(1,12) zeros(1,6) zeros(1,12) repmat([-1 0], 1, 6) zeros(1,12) zeros(1,6)]};
% i=25; contypes{i}=2; contrast_names{i}= 'Time vs control F'; basic_contrast_vectors{i}={[zeros(1,24) repmat([1 0], 1, 6) zeros(1,6) repmat(zeros(1,42), 1, 4) zeros(1,24) repmat([-1 0], 1, 6) zeros(1,6)],...
% [repmat(zeros(1,42), 1, 1) zeros(1,24) repmat([1 0], 1, 6) zeros(1,6) repmat(zeros(1,42), 1, 3) zeros(1,24) repmat([-1 0], 1, 6) zeros(1,6)],...
% [repmat(zeros(1,42), 1, 2) zeros(1,24) repmat([1 0], 1, 6) zeros(1,6) repmat(zeros(1,42), 1, 2) zeros(1,24) repmat([-1 0], 1, 6) zeros(1,6)],...
% [repmat(zeros(1,42), 1, 3) zeros(1,24) repmat([1 0], 1, 6) zeros(1,6) repmat(zeros(1,42), 1, 1) zeros(1,24) repmat([-1 0], 1, 6) zeros(1,6)],...
% [repmat(zeros(1,42), 1, 4) zeros(1,24) repmat([1 0], 1, 6) zeros(1,6) zeros(1,24) repmat([-1 0], 1, 6) zeros(1,6)]};


i=20; contypes{i}=1; contrast_names{i}= '1-3 vs 4-6'; basic_contrast_vectors{i}=repmat([1 1 1 -1 -1 -1], 1, 3); basic_contrast_vector_control{i}=zeros(1,18);
i=21; contypes{i}=1; contrast_names{i}= '1 vs 6'; basic_contrast_vectors{i}=repmat([1 0 0 0 0 -1], 1, 3);basic_contrast_vector_control{i}=zeros(1,18);
i=22; contypes{i}=1; contrast_names{i}= '1-2 vs 5-6'; basic_contrast_vectors{i}=repmat([1 1 0 0 -1 -1], 1, 3);basic_contrast_vector_control{i}=zeros(1,18);
i=23; contypes{i}=1; contrast_names{i}= '1-2 vs 5-6 person'; basic_contrast_vectors{i}=[1 1 0 0 -1 -1 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=24; contypes{i}=1; contrast_names{i}= '1-2 vs 5-6 place'; basic_contrast_vectors{i}=[zeros(1,6) 1 1 0 0 -1 -1 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=25; contypes{i}=1; contrast_names{i}= '1-2 vs 5-6 time'; basic_contrast_vectors{i}=[zeros(1,12) 1 1 0 0 -1 -1]; basic_contrast_vector_control{i}=zeros(1,18);
i=26; contypes{i}=1; contrast_names{i}= 'Distances_continuous'; basic_contrast_vectors{i}=repmat([-3 -2 -1 1 2 3], 1, 3); basic_contrast_vector_control{i}=zeros(1,18);
i=27; contypes{i}=1; contrast_names{i}= 'Distances_continuous_negative'; basic_contrast_vectors{i}=repmat([3 2 1 -1 -2 -3], 1, 3); basic_contrast_vector_control{i}=zeros(1,18);
% i=31; contypes{i}=2; contrast_names{i}= 'Distances_all (F)'; basic_contrast_vectors{i}={repmat([1 -1 0 0 0 0], 1, 3), repmat([0 1 -1 0 0 0], 1, 3), repmat([0 0 1 -1 0 0], 1, 3), repmat([0 0 0 1 -1 0], 1, 3), repmat([0 0 0 0 1 -1], 1, 3)};
% basic_contrast_vector_control{i}={zeros(1,18), zeros(1,18), zeros(1,18), zeros(1,18), zeros(1,18)};
% i=32; contypes{i}=2; contrast_names{i}= 'Distances_person (F)'; basic_contrast_vectors{i}={[1 -1 0 0 0 0 zeros(1,12)], [0 1 -1 0 0 0 zeros(1,12)], [0 0 1 -1 0 0 zeros(1,12)], [0 0 0 1 -1 0 zeros(1,12)], [0 0 0 0 1 -1 zeros(1,12)]};
% basic_contrast_vector_control{i}={zeros(1,18), zeros(1,18), zeros(1,18), zeros(1,18), zeros(1,18)};
% i=33; contypes{i}=2; contrast_names{i}= 'Distances_place (F)'; basic_contrast_vectors{i}={[zeros(1,6) 1 -1 0 0 0 0 zeros(1,6)], [zeros(1,6) 0 1 -1 0 0 0 zeros(1,6)], [zeros(1,6) 0 0 1 -1 0 0 zeros(1,6)], [zeros(1,6) 0 0 0 1 -1 0 zeros(1,6)], [zeros(1,6) 0 0 0 0 1 -1 zeros(1,6)]};
% basic_contrast_vector_control{i}={zeros(1,18), zeros(1,18), zeros(1,18), zeros(1,18), zeros(1,18)};
% i=34; contypes{i}=2; contrast_names{i}= 'Distances_time (F)'; basic_contrast_vectors{i}={[zeros(1,12) 1 -1 0 0 0 0], [zeros(1,12) 0 1 -1 0 0 0], [zeros(1,12) 0 0 1 -1 0 0], [zeros(1,12) 0 0 0 1 -1 0], [zeros(1,12) 0 0 0 0 1 -1]};
% basic_contrast_vector_control{i}={zeros(1,18), zeros(1,18), zeros(1,18), zeros(1,18), zeros(1,18)};
i=28; contypes{i}=1; contrast_names{i}= 'Person-1 vs others'; basic_contrast_vectors{i}=[5 -1 -1 -1 -1 -1 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=29; contypes{i}=1; contrast_names{i}= 'Person-2 vs others'; basic_contrast_vectors{i}=[-1 5 -1 -1 -1 -1 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=30; contypes{i}=1; contrast_names{i}= 'Person-3 vs others'; basic_contrast_vectors{i}=[-1 -1 5 -1 -1 -1 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=31; contypes{i}=1; contrast_names{i}= 'Person-4 vs others'; basic_contrast_vectors{i}=[-1 -1 -1 5 -1 -1 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=32; contypes{i}=1; contrast_names{i}= 'Person-5 vs others'; basic_contrast_vectors{i}=[-1 -1 -1 -1 5 -1 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=33; contypes{i}=1; contrast_names{i}= 'Person-6 vs others'; basic_contrast_vectors{i}=[-1 -1 -1 -1 -1 5 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=34; contypes{i}=1; contrast_names{i}= 'Person-1+2 vs others'; basic_contrast_vectors{i}=[2 2 -1 -1 -1 -1 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=35; contypes{i}=1; contrast_names{i}= 'Person-3+4 vs others'; basic_contrast_vectors{i}=[-1 -1 2 2 -1 -1 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=36; contypes{i}=1; contrast_names{i}= 'Person-5+6 vs others'; basic_contrast_vectors{i}=[-1 -1 -1 -1 2 2 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=37; contypes{i}=1; contrast_names{i}= 'Place-1 vs others '; basic_contrast_vectors{i}=[zeros(1,6) 5 -1 -1 -1 -1 -1 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=38; contypes{i}=1; contrast_names{i}= 'Place-2 vs others '; basic_contrast_vectors{i}=[zeros(1,6) -1 5 -1 -1 -1 -1 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=39; contypes{i}=1; contrast_names{i}= 'Place-3 vs others '; basic_contrast_vectors{i}=[zeros(1,6) -1 -1 5 -1 -1 -1 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=40; contypes{i}=1; contrast_names{i}= 'Place-4 vs others '; basic_contrast_vectors{i}=[zeros(1,6) -1 -1 -1 5 -1 -1 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=41; contypes{i}=1; contrast_names{i}= 'Place-5 vs others '; basic_contrast_vectors{i}=[zeros(1,6) -1 -1 -1 -1 5 -1 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=42; contypes{i}=1; contrast_names{i}= 'Place-6 vs others '; basic_contrast_vectors{i}=[zeros(1,6) -1 -1 -1 -1 -1 5 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=43; contypes{i}=1; contrast_names{i}= 'Place-1+2 vs others '; basic_contrast_vectors{i}=[zeros(1,6) 2 2 -1 -1 -1 -1 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=44; contypes{i}=1; contrast_names{i}= 'Place-3+4 vs others '; basic_contrast_vectors{i}=[zeros(1,6) -1 -1 2 2 -1 -1 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=45; contypes{i}=1; contrast_names{i}= 'Place-5+6 vs others '; basic_contrast_vectors{i}=[zeros(1,6) -1 -1 -1 -1 2 2 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=46; contypes{i}=1; contrast_names{i}= 'Time-1 vs others'; basic_contrast_vectors{i}=[zeros(1,12) 5 -1 -1 -1 -1 -1]; basic_contrast_vector_control{i}=zeros(1,18);
i=47; contypes{i}=1; contrast_names{i}= 'Time-2 vs others'; basic_contrast_vectors{i}=[zeros(1,12) -1 5 -1 -1 -1 -1]; basic_contrast_vector_control{i}=zeros(1,18);
i=48; contypes{i}=1; contrast_names{i}= 'Time-3 vs others'; basic_contrast_vectors{i}=[zeros(1,12) -1 -1 5 -1 -1 -1]; basic_contrast_vector_control{i}=zeros(1,18);
i=49; contypes{i}=1; contrast_names{i}= 'Time-4 vs others'; basic_contrast_vectors{i}=[zeros(1,12) -1 -1 -1 5 -1 -1]; basic_contrast_vector_control{i}=zeros(1,18);
i=50; contypes{i}=1; contrast_names{i}= 'Time-5 vs others'; basic_contrast_vectors{i}=[zeros(1,12) -1 -1 -1 -1 5 -1]; basic_contrast_vector_control{i}=zeros(1,18);
i=51; contypes{i}=1; contrast_names{i}= 'Time-6 vs others'; basic_contrast_vectors{i}=[zeros(1,12) -1 -1 -1 -1 -1 5]; basic_contrast_vector_control{i}=zeros(1,18);
i=52; contypes{i}=1; contrast_names{i}= 'Time-1+2 vs others'; basic_contrast_vectors{i}=[zeros(1,12) 2 2 -1 -1 -1 -1]; basic_contrast_vector_control{i}=zeros(1,18);
i=53; contypes{i}=1; contrast_names{i}= 'Time-3+4 vs others'; basic_contrast_vectors{i}=[zeros(1,12) -1 -1 2 2 -1 -1]; basic_contrast_vector_control{i}=zeros(1,18);
i=54; contypes{i}=1; contrast_names{i}= 'Time-5+6 vs others'; basic_contrast_vectors{i}=[zeros(1,12) -1 -1 -1 -1 2 2]; basic_contrast_vector_control{i}=zeros(1,18);


matlabbatch{1}.stats{3}.con.spmmat=cellstr(spmmat_file);
matlabbatch{1}.stats{3}.con.delete=1;


contrast_vectors=cell(length(basic_contrast_vectors),1);
for i=1:length(basic_contrast_vectors)
    
    % create full contrasts
    if contypes{i}==1   % t-contrast
        
        % if modeling time and dispersion derivatives, add zeros between contrast elements
        num_zeros_to_add=time_derivative+dispersion_derivative;
        if num_zeros_to_add==1
            b=zeros(1,length(basic_contrast_vectors{i})*2);
            b(1:2:end)=basic_contrast_vectors{i};
            basic_contrast_vectors{i}=b;
            b(1:2:end)=basic_contrast_vector_control{i};
            basic_contrast_vector_control{i}=b;
        elseif num_zeros_to_add==2
            b=zeros(1,length(basic_contrast_vectors{i})*3);
            b(1:3:end)=basic_contrast_vectors{i};
            basic_contrast_vectors{i}=b;
            b(1:3:end)=basic_contrast_vector_control{i};
            basic_contrast_vector_control{i}=b;
        end
        
        for  j=1:numsess-1
            if isempty(find(ignore_sessions==j,1))
                % adding each session's contrast vector and movement regressors
                contrast_vectors{i}=[contrast_vectors{i} basic_contrast_vectors{i} zeros(1,num_mov_regressors(j))];
            else
                contrast_vectors{i}=[contrast_vectors{i} zeros(1,length(basic_contrast_vectors{i})) zeros(1,num_mov_regressors(j))];
            end
        end
        % adding the control session, assuming it is the last one
        contrast_vectors{i}=[contrast_vectors{i} basic_contrast_vector_control{i} zeros(1,num_mov_regressors(numsess))];
        
        matlabbatch{1}.stats{3}.con.consess{i}.tcon.name=contrast_names{i};
        matlabbatch{1}.stats{3}.con.consess{i}.tcon.convec=contrast_vectors{i};
        
    else     % F-contrast
        
        contrast_vectors{i}=cell(size(basic_contrast_vectors{i}));
        for q=1:length(basic_contrast_vectors{i})
            % if modeling time and dispersion derivatives, add zeros between contrast elements
            num_zeros_to_add=time_derivative+dispersion_derivative;
            if num_zeros_to_add==1
                b=zeros(1,length(basic_contrast_vectors{i}{q})*2);
                b(1:2:end)=basic_contrast_vectors{i}{q};
                basic_contrast_vectors{i}{q}=b;
                b(1:2:end)=basic_contrast_vector_control{i}{q};
                basic_contrast_vector_control{i}{q}=b;
            elseif num_zeros_to_add==2
                b=zeros(1,length(basic_contrast_vectors{i}{q})*3);
                b(1:3:end)=basic_contrast_vectors{i}{q};
                basic_contrast_vectors{i}{q}=b;
                b(1:3:end)=basic_contrast_vector_control{i}{q};
                basic_contrast_vector_control{i}{q}=b;
            end
            
            for  j=1:numsess-1
                if isempty(find(ignore_sessions==j,1))
                    contrast_vectors{i}{q}=[contrast_vectors{i}{q} basic_contrast_vectors{i}{q} zeros(1,num_mov_regressors(j))];
                else
                    contrast_vectors{i}{q}=[contrast_vectors{i}{q} zeros(1,length(basic_contrast_vectors{i}{q})) zeros(1,num_mov_regressors(j))];
                end
            end
            % adding the control session, assuming it is the last one
            contrast_vectors{i}{q}=[contrast_vectors{i}{q} basic_contrast_vector_control{i}{q} zeros(1,num_mov_regressors(numsess))];
        end
        
        matlabbatch{1}.stats{3}.con.consess{i}.fcon.name=contrast_names{i};
        matlabbatch{1}.stats{3}.con.consess{i}.fcon.convec=contrast_vectors{i};
    end
    
end

save(fullfile(output_dir,[subj_name '_build_paradigm.mat']), 'matlabbatch');

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);

