function [ROIs_components, segments_components] = get_components_AAL_multiple_files(FILES_PATH)
% [ROIs_components, segments_components] = get_components_AAL_multiple_files(FILES_PATH)
% 
% This script uses Uri Hertz's algorithm for tree dependent components 
% analysis (tree-DCA) - similar to ICA but with dependent components.
% The script calculates the components, and their location relative to AAL 
% ROIs and segmentations (GM, WM, CSF), for multiple subjects.
%
% receives files-path, which is a directory containing the FunRawW
% directory (functional normalized images), masks directory (AAL mask),
% and T1ImgNewSegment directory (segmented and resliced images).
% all these directories are results of pre-processing with DPARSFA.

% getting the functional images
patients=dir([FILES_PATH '\FunRawW\']); patients=patients(3:end);
ROIs_components={};
segments_components={};
for i=1:length(patients)
    images_folder = [FILES_PATH '\FunRawW\' patients(i).name];
    [ff,fvox] = get_volumes_patient(images_folder);
    sizevox = size(ff); numvox = sizevox(1)*sizevox(2)*sizevox(3);
    images_folder
    
    % getting the AAL mask file
    mask_file = [FILES_PATH '\masks\AAL_' patients(i).name '.img'];
    AAL_mask=spm_read_vols(spm_vol([mask_file]));
    AAL_mask_reshaped=reshape(AAL_mask,[1,numvox]);
    mask_file
    
    % getting the normalized + modulated segmentation files
    segmentation_folder = [FILES_PATH '\T1ImgNewSegment\' patients(i).name];
    aa=dir(segmentation_folder);
    for j=1:length(aa)
        if strfind(aa(j).name,'r_wc1')
            GM_segment=spm_read_vols(spm_vol([segmentation_folder '\' aa(j).name]));
            GM_segment=reshape(GM_segment,[1,numvox]);
            GM_segment(isnan(GM_segment))=0;
            GM_segment=GM_segment>0.15;
        elseif strfind(aa(j).name,'r_wc2')
            WM_segment=spm_read_vols(spm_vol([segmentation_folder '\' aa(j).name]));
            WM_segment=reshape(WM_segment,[1,numvox]);
            WM_segment(isnan(WM_segment))=0;
            WM_segment=WM_segment>0.15;
        elseif strfind(aa(j).name,'r_wc3')
            CSF_segment=spm_read_vols(spm_vol([segmentation_folder '\' aa(j).name]));
            CSF_segment=reshape(CSF_segment,[1,numvox]);
            CSF_segment(isnan(CSF_segment))=0;
            CSF_segment=CSF_segment>0.15;
        end
    end
    
    
    NumComponents = 30;
    MeanThresh=1;
    NumIterations = 30;
    Starting_comp=5;
    % getting the components
    components_file_name='';
    ab=dir([FILES_PATH '\']);
    for j=1:length(ab)
        if strfind(ab(j).name,['Grad_' patients(i).name])
            'loading components from file...'
            components_file_name=[FILES_PATH '\' ab(j).name];
            load(components_file_name);
        end
    end
    if isempty(components_file_name)
        % remove first 4 eigenvectors
        EigNumToRemove = 4;
        [WPCA,D] = pca(fvox);
        Components = EigNumToRemove:(NumComponents+EigNumToRemove-1);
        E = (D(Components(1:NumComponents),Components(1:NumComponents))^-.5*WPCA(Components(1:NumComponents),:));
        z = (E*fvox');
        W = pinv(E);
        fvox = (W*z)';
        
        % calculate the components
        components_file_name = [FILES_PATH '\Grad_' patients(i).name '_mean' num2str(MeanThresh) '_Its_' num2str(NumIterations) '_Comps_' num2str(NumComponents) '_eig_' num2str(Starting_comp) '.mat'];
        [W,WPCA,D,E,treeEdges,beta,sds,pis] = learnTreeComponentsUri(fvox,NumComponents,'numIterations',NumIterations,'progressFilename',components_file_name,'first_comp',Starting_comp);
        save(components_file_name, 'ff','fvox','W','WPCA','D','E','treeEdges','beta','sds','pis');
    end
    components_file_name
    
    % Calculate the physical location of the components
    A=W*E;
    for j=1:NumComponents
        Seed = A(j,:);
        [vmpBetaVec(j,:),vmpTVec(j,:)] = vtcRegressTCmat_data(fvox,Seed,'aa',1,1);
        %compVec5(j,:) = vmpTVec(j,:)<0.05 & vmpTVec(j,:)>-0.05;
        %compVec1(j,:) = vmpTVec(j,:)<0.01 & vmpTVec(j,:)>-0.01;
        compVec5(j,:) = vmpTVec(j,:)>5 | vmpTVec(j,:)<-5;
        compVec25(j,:) = vmpTVec(j,:)>2.5 | vmpTVec(j,:)<-2.5;
    end
     
    % save pictures of the components
    mkdir([FILES_PATH '\Comp_images\' patients(i).name]); cd([FILES_PATH '\Comp_images\' patients(i).name]);
    temp_comp_file=dir([FILES_PATH '\FunRawW\' patients(i).name]);
    comp_pic=spm_vol([FILES_PATH '\FunRawW\' patients(i).name '\' temp_comp_file(4).name]);
    for j=1:NumComponents
        comp_pic.fname=['comp0.05_' num2str(j) '.nii'];
        comp_pic.private.dat.fname = comp_pic.fname;
        cmp=compVec5(j,:); cmp=reshape(cmp,sizevox(1),sizevox(2),sizevox(3));
        spm_write_vol(comp_pic,cmp);
        
        comp_pic.fname=['comp0.01_' num2str(j) '.nii'];
        comp_pic.private.dat.fname = comp_pic.fname;
        cmp=compVec25(j,:); cmp=reshape(cmp,sizevox(1),sizevox(2),sizevox(3));
        spm_write_vol(comp_pic,cmp);
    end
    
    % calculate for each component and each ROI if the component exists there
    aal_areas=zeros(116, numvox);
    for j=1:116
        aal_areas(j,:)=ismember(AAL_mask_reshaped,j);
    end
    ROIs_components{end+1}=zeros(NumComponents,116);
    for j=1:NumComponents
        for q=1:116
            a = compVec25(j,:) & aal_areas(q,:);
            ROIs_components{end}(j,q)=sum(a)/sum(compVec25(j,:));
        end
    end
    
    % calculate for each component and each tissue type what is the percent of
    % it in the component
    segments_components{end+1}=zeros(NumComponents,3);
    for j=1:NumComponents
        a = {compVec25(j,:)&GM_segment, compVec25(j,:)&WM_segment, compVec25(j,:)&CSF_segment};
        for q=1:3
            segments_components{end}(j,q)=sum(a{q})/sum(compVec25(j,:));
        end
    end
end

save([FILES_PATH '\ROIs_components.mat'], 'ROIs_components');
save([FILES_PATH '\segments_components.mat'], 'segments_components');
