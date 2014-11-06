AAL_mask=spm_read_vols(spm_vol('C:\spm8\toolbox\DPARSF_V2.2_130309\Templates\AAL_resliced_61x73x61_v2_michael.nii'));
func_directory_to_threshold='C:\Subjects_MRI_data\3T\Preprocessing_rest\FunRawARW\Aya_Porat';
func_directory='C:\Subjects_MRI_data\3T\Preprocessing_rest\FunRawARWSFC\Aya_Porat';
c1mask_filename='C:\Subjects_MRI_data\3T\Preprocessing_rest\T1ImgNewSegment\Aya_Porat\mwc1PORAT_AYA_20121109_120668129+1_005_t1_mprage_32COIL.nii';
c1_threshold=0.5;

f=get_func_matrix(func_directory);

func_c1_mask = get_func_threshold_and_c1_mask(func_directory_to_threshold, c1mask_filename, c1_threshold);

matcorr=cell(1,90);
for AAL_region=1:90    
    % getting only the voxels with AAL=seed_region and func_c1_mask
    AAL_region_mask=func_c1_mask & AAL_mask==AAL_region;
    indices={};
    for i=1:size(AAL_region_mask,1)
        for j=1:size(AAL_region_mask,2)
            for q=1:size(AAL_region_mask,3)
                if AAL_region_mask(i,j,q)==1
                    indices{end+1}=[i,j,q];
                end
            end
        end
    end
    
    % getting the correlation matrix
    numvox=size(indices);
    matcorr{AAL_region}=zeros(numvox);
    for i=1:length(indices)
        for j=1:length(indices)
            m=corrcoef(f(indices{i}(1),indices{i}(2),indices{i}(3),:),f(indices{j}(1),indices{j}(2),indices{j}(3),:));
            matcorr{AAL_region}(i,j)=m(2);
        end
    end
end;

i=1;figure;imagesc(matcorr{i});colorbar
