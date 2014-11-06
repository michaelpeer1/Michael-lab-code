% create contrast for interaction in an anova of 3 by 6
con=spm_make_contrasts([3 6]);
a=con(4).c;
aa=zeros(10,36); aa(:,1:2:end)=a;
aa=[aa zeros(10,26)];   % there are 26 motion regressors in each session
aaa=repmat(aa,1,5);
aaa=[aaa zeros(10,62)];

all_subjs = dir('C:\Subjects_MRI_data\7T\Analysis'); all_subjs=all_subjs(3:end);
for s=1:length(all_subjs)
    % loading beta maps for each domain+distance
    disp(s);
    subj_name=all_subjs(s).name;
    SPMmat_dir=['C:\Subjects_MRI_data\7T\Analysis\' subj_name '\GLM_with_distances'];
    load(fullfile(SPMmat_dir, 'SPM.mat'));
    spm_beta_maps=getfullfiles(fullfile(SPMmat_dir,'beta_*.img'));        
    spmTmaps=getfullfiles(fullfile(SPMmat_dir,'spmT*.img'));
%     for i=1:18
%         indexes_betas= find(SPM.xCon(27+i + 3*(ceil(i/6)-1)).c==5);
%         average_beta_map=spm_read_vols(spm_vol(spm_beta_maps{indexes_betas(1)}));
%         for j=2:length(indexes_betas)
%             average_beta_map = average_beta_map + spm_read_vols(spm_vol(spm_beta_maps{indexes_betas(j)}));
%         end
%         average_beta_map=average_beta_map./length(indexes_betas);
%         save_mat_to_nifti(spm_beta_maps{indexes_betas(1)},average_beta_map,fullfile(SPMmat_dir,['average_beta_' num2str(i) '.nii']));
%     end
    
    % making winner beta map
    winner_map=spm_read_vols(spm_vol(spm_beta_maps{1}));
    size_map=size(winner_map); winner_map=winner_map(:);
    for i=2:18
        b=spm_read_vols(spm_vol(fullfile(SPMmat_dir,['average_beta_' num2str(i) '.nii'])));
        winner_map=[winner_map b(:)];
    end
    [~,I]=max(winner_map,[],2); winner_value=max(winner_map,[],2);
    I(isnan(mean(winner_map)))=0; winner_value(isnan(mean(winner_map)))=0;
    winner_map=reshape(I,size_map); winner_value=reshape(winner_value,size_map);
    save_mat_to_nifti(spm_beta_maps{indexes_betas(1)},winner_map,fullfile(SPMmat_dir,['winner_beta_map.nii']));
    save_mat_to_nifti(spm_beta_maps{indexes_betas(1)},winner_value,fullfile(SPMmat_dir,['winner_beta_value_map.nii']));
    
    % making winner beta map - person
    winner_map_person=spm_read_vols(spm_vol(spm_beta_maps{1}));
    size_map=size(winner_map_person); winner_map_person=winner_map_person(:);
    Tmap=spm_read_vols(spm_vol(spmTmaps{3}));
    for i=2:6
        b=spm_read_vols(spm_vol(fullfile(SPMmat_dir,['average_beta_' num2str(i) '.nii'])));
        winner_map_person=[winner_map_person b(:)];
    end
    [~,I]=max(winner_map_person,[],2); winner_value_person=max(winner_map_person,[],2);
    I(isnan(mean(winner_map_person)))=0; winner_value_person(isnan(mean(winner_map_person)))=0;
    winner_map_person=reshape(I,size_map); winner_value_person=reshape(winner_value_person,size_map);
    I(Tmap<3)=0; winner_value_person(Tmap<3)=0;
    save_mat_to_nifti(spm_beta_maps{indexes_betas(1)},winner_map_person,fullfile(SPMmat_dir,['winner_beta_map_person.nii']));
    save_mat_to_nifti(spm_beta_maps{indexes_betas(1)},winner_value_person,fullfile(SPMmat_dir,['winner_beta_value_map_person.nii']));
    
    % making winner beta map - place
    winner_map_place=spm_read_vols(spm_vol(spm_beta_maps{7}));
    size_map=size(winner_map_place); winner_map_place=winner_map_place(:);
    Tmap=spm_read_vols(spm_vol(spmTmaps{4}));
    for i=8:12
        b=spm_read_vols(spm_vol(fullfile(SPMmat_dir,['average_beta_' num2str(i) '.nii'])));
        winner_map_place=[winner_map_place b(:)];
    end
    [~,I]=max(winner_map_place,[],2); winner_value_place=max(winner_map_place,[],2);
    I(isnan(mean(winner_map_place)))=0; winner_value_place(isnan(mean(winner_map_place)))=0;
    winner_map_place=reshape(I,size_map); winner_value_place=reshape(winner_value_place,size_map);
    I(Tmap<3)=0; winner_value_place(Tmap<3)=0;
    save_mat_to_nifti(spm_beta_maps{indexes_betas(1)},winner_map_place,fullfile(SPMmat_dir,['winner_beta_map_place.nii']));
    save_mat_to_nifti(spm_beta_maps{indexes_betas(1)},winner_value_place,fullfile(SPMmat_dir,['winner_beta_value_map_place.nii']));

    % making winner beta map - time
    winner_map_time=spm_read_vols(spm_vol(spm_beta_maps{13}));
    size_map=size(winner_map_time); winner_map_time=winner_map_time(:);
    Tmap=spm_read_vols(spm_vol(spmTmaps{5}));
    for i=14:18
        b=spm_read_vols(spm_vol(fullfile(SPMmat_dir,['average_beta_' num2str(i) '.nii'])));
        winner_map_time=[winner_map_time b(:)];
    end
    [~,I]=max(winner_map_time,[],2); winner_value_time=max(winner_map_time,[],2);
    I(isnan(mean(winner_map_time)))=0; winner_value_time(isnan(mean(winner_map_time)))=0;
    winner_map_time=reshape(I,size_map); winner_value_time=reshape(winner_value_time,size_map);
    I(Tmap<3)=0; winner_value_time(Tmap<3)=0;
    save_mat_to_nifti(spm_beta_maps{indexes_betas(1)},winner_map_time,fullfile(SPMmat_dir,['winner_beta_map_time.nii']));
    save_mat_to_nifti(spm_beta_maps{indexes_betas(1)},winner_value_time,fullfile(SPMmat_dir,['winner_beta_value_map_time.nii']));
end


