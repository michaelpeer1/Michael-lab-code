person_all=spm_read_vols(spm_vol('spmT_0035.img'));
person_all(:,:,:,2)=spm_read_vols(spm_vol('spmT_0036.img'));
person_all(:,:,:,3)=spm_read_vols(spm_vol('spmT_0037.img'));
person_all(:,:,:,4)=spm_read_vols(spm_vol('spmT_0038.img'));
person_all(:,:,:,5)=spm_read_vols(spm_vol('spmT_0039.img'));
person_all(:,:,:,6)=spm_read_vols(spm_vol('spmT_0040.img'));

place_all=spm_read_vols(spm_vol('spmT_0044.img'));
place_all(:,:,:,2)=spm_read_vols(spm_vol('spmT_0045.img'));
place_all(:,:,:,3)=spm_read_vols(spm_vol('spmT_0046.img'));
place_all(:,:,:,4)=spm_read_vols(spm_vol('spmT_0047.img'));
place_all(:,:,:,5)=spm_read_vols(spm_vol('spmT_0048.img'));
place_all(:,:,:,6)=spm_read_vols(spm_vol('spmT_0049.img'));

time_all=spm_read_vols(spm_vol('spmT_0053.img'));
time_all(:,:,:,2)=spm_read_vols(spm_vol('spmT_0054.img'));
time_all(:,:,:,3)=spm_read_vols(spm_vol('spmT_0055.img'));
time_all(:,:,:,4)=spm_read_vols(spm_vol('spmT_0056.img'));
time_all(:,:,:,5)=spm_read_vols(spm_vol('spmT_0057.img'));
time_all(:,:,:,6)=spm_read_vols(spm_vol('spmT_0058.img'));

mask_person=spm_read_vols(spm_vol('spmT_0007.img'));
mask_place=spm_read_vols(spm_vol('spmT_0008.img'));
mask_time=spm_read_vols(spm_vol('spmT_0009.img'));

[~,I_person]=max(person_all,[],4);
[~,I_place]=max(place_all,[],4);
[~,I_time]=max(time_all,[],4);

for i=1:6
    save_mat_to_nifti('spmT_0035.img',(I_person==i & mask_person>2),['person_dist' num2str(i) '_masked.nii']);
    save_mat_to_nifti('spmT_0035.img',(I_place==i & mask_place>2),['place_dist' num2str(i) '_masked.nii']);
    save_mat_to_nifti('spmT_0035.img',(I_time==i & mask_time>2),['time_dist' num2str(i) '_masked.nii']);
end

I_person_new=I_person; I_person_new(mask_person<2)=0;
I_place_new=I_place; I_place_new(mask_place<2)=0;
I_time_new=I_time; I_time_new(mask_time<2)=0;

save_mat_to_nifti('con_0035.img',(I_person_new),['person_dist_all_masked.nii']);
save_mat_to_nifti('con_0035.img',(I_place_new),['place_dist_all_masked.nii']);
save_mat_to_nifti('con_0035.img',(I_time_new>2),['time_dist_all_masked.nii']);




load('C:\Subjects_MRI_data\7T\Analysis\121123_alex\GLM_with_distances\SPM.mat');
num_columns=size(SPM.xX.X,2);
for i=1:6
    person_dist{i}=find(SPM.xCon(34+i).c==5); person_dist{i}=conv(person_dist{i},spm_hrf(2.5));
end
