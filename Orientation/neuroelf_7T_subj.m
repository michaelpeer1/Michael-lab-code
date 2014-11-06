subj_names=dir('e:\Subjects_MRI_data\7T\Analysis'); subj_names=subj_names(3:end);

% importing functional data (un-normalized)
for s=1:length(subj_names)
    subj_name=subj_names(s).name;
    
    % create vtc from each session
    for i=1:6
        imgs=getfullfiles(['e:\Subjects_MRI_data\7T\New_subjs_prep_2013\FunRawRS\' subj_name '_' num2str(i) '\*.hdr']);
        vtc = importvtcfromanalyze(imgs);
        vtc.SaveAs(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\spm7T' subj_name '_' num2str(i) '.vtc']);
    end
end



% importing anatomy and design matrices+protocols
for s=1:length(subj_names)
    subj_name=subj_names(s).name;

    spmmat2sdm(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\GLM_domains_only\SPM.mat'], ['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\spm1.sdm']);
    spmmat2prt(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\GLM_domains_only\SPM.mat'], ['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\spm1.prt']);
    spmmat2sdm(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\GLM_with_distances\SPM.mat'], ['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\spm1_distances.sdm']);
    spmmat2prt(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\GLM_with_distances\SPM.mat'], ['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\spm1_distances.prt']);
    
    vmr = importvmrfromanalyze(['e:\Subjects_MRI_data\7T\New_subjs_prep_2013\T1IMG\' subj_name '\mAnatomical_corrected.nii']);
    vmr.SaveAs(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\spm7T' subj_name '_anatomy.vmr']);
end

% importing statistical maps
for s=1:length(subj_names)
    subj_name=subj_names(s).name;
    
    spmTfiles=getfullfiles(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\GLM_domains_only\spmT*.hdr']);
    spmTfiles_distances=getfullfiles(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\GLM_with_distances\spmT*.hdr']);
    spmTfiles_nonsmoothed=getfullfiles(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\GLM_domains_only_nonsmoothed\spmT*.hdr']);
    
    vmp = importvmpfromspms(spmTfiles,'a',[1 1 1;256 256 256],2);
    vmp.Map(4).RGBUpperThreshPos=[52 198 205]; vmp.Map(4).RGBLowerThreshPos=[29 112 116];
    vmp.Map(5).RGBUpperThreshPos=[182 246 62]; vmp.Map(5).RGBLowerThreshPos=[132 178 45];
    vmp.Map(8).RGBUpperThreshPos=[52 198 205]; vmp.Map(8).RGBLowerThreshPos=[29 112 116];
    vmp.Map(9).RGBUpperThreshPos=[182 246 62]; vmp.Map(9).RGBLowerThreshPos=[132 178 45];
    vmp.Map(18).RGBUpperThreshPos=[52 198 205]; vmp.Map(18).RGBLowerThreshPos=[29 112 116];
    vmp.Map(19).RGBUpperThreshPos=[182 246 62]; vmp.Map(19).RGBLowerThreshPos=[132 178 45];
    
    vmp_dist = importvmpfromspms(spmTfiles_distances,'a',[1 1 1;256 256 256],2);  
    vmp_dist.Map(4).RGBUpperThreshPos=[52 198 205]; vmp_dist.Map(4).RGBLowerThreshPos=[29 112 116];
    vmp_dist.Map(5).RGBUpperThreshPos=[182 246 62]; vmp_dist.Map(5).RGBLowerThreshPos=[132 178 45];
    vmp_dist.Map(8).RGBUpperThreshPos=[52 198 205]; vmp_dist.Map(8).RGBLowerThreshPos=[29 112 116];
    vmp_dist.Map(9).RGBUpperThreshPos=[182 246 62]; vmp_dist.Map(9).RGBLowerThreshPos=[132 178 45];
    vmp_dist.Map(18).RGBUpperThreshPos=[52 198 205]; vmp_dist.Map(18).RGBLowerThreshPos=[29 112 116];
    vmp_dist.Map(19).RGBUpperThreshPos=[182 246 62]; vmp_dist.Map(19).RGBLowerThreshPos=[132 178 45];

    vmp_nonsmoothed = importvmpfromspms(spmTfiles_nonsmoothed,'a',[1 1 1;256 256 256],2);  
    vmp_nonsmoothed.Map(4).RGBUpperThreshPos=[52 198 205]; vmp_nonsmoothed.Map(4).RGBLowerThreshPos=[29 112 116];
    vmp_nonsmoothed.Map(5).RGBUpperThreshPos=[182 246 62]; vmp_nonsmoothed.Map(5).RGBLowerThreshPos=[132 178 45];
    vmp_nonsmoothed.Map(8).RGBUpperThreshPos=[52 198 205]; vmp_nonsmoothed.Map(8).RGBLowerThreshPos=[29 112 116];
    vmp_nonsmoothed.Map(9).RGBUpperThreshPos=[182 246 62]; vmp_nonsmoothed.Map(9).RGBLowerThreshPos=[132 178 45];
    vmp_nonsmoothed.Map(18).RGBUpperThreshPos=[52 198 205]; vmp_nonsmoothed.Map(18).RGBLowerThreshPos=[29 112 116];
    vmp_nonsmoothed.Map(19).RGBUpperThreshPos=[182 246 62]; vmp_nonsmoothed.Map(19).RGBLowerThreshPos=[132 178 45];

    vmp.SaveAs(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\spmTmaps_' subj_name '.vmp']);
    vmp_dist.SaveAs(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\spmTmaps_distances_' subj_name '.vmp']);
    vmp_nonsmoothed.SaveAs(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\spmTmaps_nonsmoothed_' subj_name '.vmp']);
end


% changing PRT colors
for s=1:length(subj_names)
    subj_name=subj_names(s).name;
    prt_files=getfullfiles(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\*.prt']);
    for i=1:length(prt_files)
        a=regexp(fileread(prt_files{i}),'\n','split');
        a{25}='Color:              255 0 0';
        a{35}='Color:              52 198 205';
        a{45}='Color:              182 246 62';
        fid=fopen(prt_files{i},'w');
        fprintf(fid,'%s\n',a{:});
        fclose(fid);
    end
end


% % linking VTCs and PRTs
% for s=1:length(subj_names)
%      subj_name=subj_names(s).name;
%      vtc_files=getfullfiles(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\*.vtc']);
%      prt_files=getfullfiles(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\*.prt']);
%      
%     for i=1:(length(vtc_files)-1)
%         vtc=xff(vtc_files{i});
%         vtc.NrOfLinkedPRTs = 1;
%         vtc.NameOfLinkedPRT = prt_files{i};
%         vtc.Save;
%         vtc.ClearObject;
%     end
% end




%     for i=1:6
%         vtc=xff(['C:\Subjects_MRI_data\7T\Analysis\' subj_name '\spm7T' subj_name '_' num2str(i) '.vtc']);
%         sdm=xff(['C:\Subjects_MRI_data\7T\Analysis\' subj_name '\spm1_run' num2str(i) '.sdm']);
%         glm=vtc.CreateGLM(sdm);
%         glm.SaveAs(['C:\Subjects_MRI_data\7T\Analysis\' subj_name '\spm1_' num2str(i) '.glm']);
%     end


% importing resting-state functional data (un-normalized, filtered, covariates removed)
for s=1:length(subj_names)
    subj_name=subj_names(s).name;
    imgs=getfullfiles(['e:\Subjects_MRI_data\7T\New_subjs_prep_2013\Resting state\FunRawRFC\' subj_name '\*.nii']);
    vtc = importvtcfromanalyze(imgs);
    vtc.SaveAs(['e:\Subjects_MRI_data\7T\Analysis\' subj_name '\spm7T_rest_' subj_name  '.vtc']);
end

    
    