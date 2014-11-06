function make_dirs_for_DPARSFA(subject_nifti_dir, output_dir)
% make_dirs_for_DPARSFA(subject_nifti_dir, output_dir)
%
% Receives a directory with nifti directories of T1 and bold images of a 
% subject (result of applying MRIconvert on dicoms), and an output directory
%
% Creates adequate FunRaw and T1Img directories in the output directory 


[~,subj_name]=fileparts(subject_nifti_dir);

t1_original_dir=dir(fullfile(subject_nifti_dir,'*t1*')); t1_original_dir=fullfile(subject_nifti_dir,t1_original_dir(1).name);
bold_original_dir=dir(fullfile(subject_nifti_dir,'*bold*')); bold_original_dir=fullfile(subject_nifti_dir,bold_original_dir(1).name);

t1_files_img=dir(fullfile(t1_original_dir,'*.img'));
t1_files_hdr=dir(fullfile(t1_original_dir,'*.hdr'));
t1_files_nii=dir(fullfile(t1_original_dir,'*.nii'));
bold_files_img=dir(fullfile(bold_original_dir,'*.img'));
bold_files_hdr=dir(fullfile(bold_original_dir,'*.hdr'));
bold_files_nii=dir(fullfile(bold_original_dir,'*.nii'));

t1_output_dir=fullfile(output_dir,'T1Img'); t1_output_dir=fullfile(t1_output_dir,subj_name);
bold_output_dir=fullfile(output_dir,'FunRaw'); bold_output_dir=fullfile(bold_output_dir,subj_name);
if ~exist(t1_output_dir)
    mkdir(t1_output_dir);
end
if ~exist(bold_output_dir)
    mkdir(bold_output_dir);
end

for i=1:length(t1_files_img)
    copyfile(fullfile(t1_original_dir, t1_files_img(i).name), t1_output_dir);
    copyfile(fullfile(t1_original_dir, t1_files_hdr(i).name), t1_output_dir);
end
for i=1:length(t1_files_nii)
    copyfile(fullfile(t1_original_dir, t1_files_nii(i).name), t1_output_dir);
end

for i=1:length(bold_files_img)
    copyfile(fullfile(bold_original_dir, bold_files_img(i).name), bold_output_dir);
    copyfile(fullfile(bold_original_dir, bold_files_hdr(i).name), bold_output_dir);
end
for i=1:length(bold_files_nii)
    copyfile(fullfile(bold_original_dir, bold_files_nii(i).name), bold_output_dir);    
end


% changing filenames starting with A or C
a=dir(bold_output_dir); cd(bold_output_dir);
for i=3:length(a)
    if a(i).name(1)=='A' || a(i).name(1)=='C'
        movefile(a(i).name,['B_' a(i).name])
    end
end
a=dir(t1_output_dir); cd(t1_output_dir);
for i=3:length(a)
    if a(i).name(1)=='A' || a(i).name(1)=='C'
        movefile(a(i).name,['B_' a(i).name])
    end
end


