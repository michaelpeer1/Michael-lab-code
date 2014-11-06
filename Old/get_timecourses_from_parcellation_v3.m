function [parc_areas, timecourses,parc_vox_num,vectors,r_mat,p_mat,seedmat_r,seedmat_PP]=get_timecourses_from_parcellation_v2(parcellation_filename, functional_directory)
% this script gets a file with a parcellation mask (each number represents
% a different area), and a directory with functional images, and returns
% the areas and the timecourse for each area in a matrix

% the script supports both 3D and 4D image files

% CURRENTLY, THE DIMENSIONS OF THE IMAGES MUST AGREE (THE SCRIPT DOESN'T DO
% RESLICING)


% read the parcellation file
parcellation_filename='C:\Users\ilango\Documents\Resting_Connectivity_Project\NKI\parcelation_freesurfer\res2ARCFWSD_coreg2wc1_C286_parcel.nii';
functional_directory='C:\Users\ilango\Documents\Resting_Connectivity_Project\NKI\Preliminar\RTdominant\FunRawARCFWSD\C286\'

tic;

%[no_use,functional_directory] = uigetfile('*.*','Please select functional file to process...','MultiSelect','off');
%[parcellation_filename,no_use] = uigetfile('*.*','Please select (freesurfer) mask  to use...','MultiSelect','off');

subject= input('name of output files (name.xlsx and name_seeds.xlsx)?','s');

parc_images=spm_read_vols(spm_vol(parcellation_filename));
parc_areas=unique(parc_images);
parc_vox_num=[];

% read the functional images
func_images={};
func_dir_filenames=dir(fullfile(functional_directory,'*.img'));
if isempty(func_dir_filenames)
    func_dir_filenames=dir(fullfile(functional_directory,'*.nii'));
end
if length(func_dir_filenames)>1
    % for 3D files
    for i=1:length(func_dir_filenames)
        func_images{end+1}=spm_read_vols(spm_vol(fullfile(functional_directory,func_dir_filenames(i).name)));
    end
else
    % for one 4D file
    b=spm_read_vols(spm_vol(fullfile(functional_directory,func_dir_filenames(1).name)));
    for i=1:length(b)
        func_images{end+1}=b(:,:,:,i);
    end
end
    
% check that the dimensions of the images agree
if size(func_images{1})~=size(parc_images)
    disp('The sizes of the parcellation and functional images do not agree!!!!!')
    disp('Exiting...')
    return
end

% get the timecourses
timecourses=cell(1,length(parc_areas));
for i=1:length(parc_areas)
    parc_vox_num=[parc_vox_num sum(sum(sum(parc_images==parc_areas(i))))];
    for j=1:length(func_images);
        aaa=func_images{j}(parc_images==parc_areas(i));
        timecourses{i}=[timecourses{i} mean(aaa)];
    end
end
toc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%transpose vector matrix and parcell #voxels
vectors=[];
for i=1:length(parc_areas)
vectors = [vectors timecourses{i}'];
end

parc_vox_num=[parc_vox_num]';

%autocorrelation matrix for all vectors and correspomding pvalues
[r_mat,p_mat]=corrcoef(vectors);

%%provide indices (raw,col)for  matching given values in 'p_mat'
%%[raw,col]=find(p_mat<0.001);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create  Correlation matrix for all seeds  in mask file
%HERE, APARC+ASEG from Freesurfer
%for significant p threshold in p_mat

[r,c]=size(r_mat);
R=zeros(r,c);
PP=zeros(r,c);
        
for i=1:r
    for j=1:c
        if r_mat(i,j)==1;
              PP(i,j)=NaN('single');  
              R(i,j)=NaN('single');
        elseif p_mat(i,j)<=0.001 % SIGNIFICANT THRESHOLD TO SET !!
              PP(i,j)=1;
              R(i,j)=r_mat(i,j);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create output XLS  file with cooresponding wroksheet with input name 

xlswrite([subject '.xlsx'], parc_areas,'ROInames');
xlswrite([subject '.xlsx'], parc_vox_num,'Voxels#'); 
xlswrite([subject '.xlsx'], vectors,'Vectors'); 
xlswrite([subject '.xlsx'], r_mat,'Crosscorrel');
xlswrite([subject '.xlsx'], p_mat,'p-values');
xlswrite([subject '.xlsx'], R,' R-p<0.001'); % SIGNIFICANT THRESHOLD TO COPY !!
xlswrite([subject '.xlsx'], PP,'signif seeds p<0.001');


%SUBmatrix for selected seeds 's' - only for CORTICAL SEGMENTATION =75X2 ROIS
% HERE vector s = 14 seeds from 'parc_areas' NOTE from
%57 58 59 70 71 74 75 = LT hemisph
%132 133 134 145 146 149 150 = RT hemisph
% exemple 57= intensity 11112 from orifinal aparc2009+aseg.nii file

s=[57 58 59 70 71 74 75 132 133 134 145 146 149 150];
%s=[111126 111127];
seedmat_r=zeros(length(s),150);
seedmat_PP=zeros(length(s),150);

for i= 1:length(s)
    for j=c-149:c
              seedmat_r(i,j-(c-150))=R(s(i),j);        
              seedmat_PP(i,j-(c-150))=PP(s(i),j);     
   end
end

%autocorrelation matrix for all vectors and corresponding pvalues
[r_mat,p_mat]=corrcoef(vectors);


xlswrite([subject, '_seeds.xlsx'], seedmat_r,'correlations seeds Matrix');
xlswrite([subject, '_seeds.xlsx'], seedmat_PP,'p<0.001 seeds Matrix'); % SIGNIFICANT THRESHOLD TO COPY !!

toc;