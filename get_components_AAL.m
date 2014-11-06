function [ROIs_components, segments_components] = get_components_AAL(get_components_from_file)
% [ROIs_components, segments_components] = get_components_AAL(get_components_from_file)
%
% This script uses Uri Hertz's algorithm for tree dependent components 
% analysis (tree-DCA) - similar to ICA but with dependent components.
% The script calculates the components, and their location relative to AAL 
% ROIs and segmentations (GM, WM, CSF)
%
% receives 1 or 0 to decide if to calculate the tree components or get them from file 
% (1 is to get from file, 0 to calculate)

NumComponents = 30;
MeanThresh=1;
NumIterations = 20;

% getting the functional images
images_folder = uigetdir('C:\','Please choose directory with normalized functional images');
[ff,fvox] = get_volumes_patient(images_folder);
sizevox = size(ff); numvox = sizevox(1)*sizevox(2)*sizevox(3);

% getting the AAL mask file
[mask_file,mask_path] = uigetfile('AAL*.img','Please choose AAL mask file');
AAL_mask=spm_read_vols(spm_vol([mask_path '\' mask_file]));
AAL_mask_reshaped=reshape(AAL_mask,[1,numvox]);

% getting the normalized + modulated segmentation files
segmentation_folder = uigetdir('C:\','Please choose directory with RESLICED segmentation files');
aa=dir(segmentation_folder);
for i=1:length(aa)
    if strfind(aa(i).name,'rmwc1')
        GM_segment=spm_read_vols(spm_vol([segmentation_folder '\' aa(i).name]));
        GM_segment=reshape(GM_segment,[1,numvox]);
        GM_segment(isnan(GM_segment))=0;
    elseif strfind(aa(i).name,'rmwc2')
        WM_segment=spm_read_vols(spm_vol([segmentation_folder '\' aa(i).name]));
        WM_segment=reshape(WM_segment,[1,numvox]);
        WM_segment(isnan(WM_segment))=0;
    elseif strfind(aa(i).name,'rmwc3')
        CSF_segment=spm_read_vols(spm_vol([segmentation_folder '\' aa(i).name]));
        CSF_segment=reshape(CSF_segment,[1,numvox]);
        CSF_segment(isnan(CSF_segment))=0;
    end
end

% getting the components
if get_components_from_file==1
    [components_file, components_path] = uigetfile('*.*','Please choose components file');
    load([components_path '\' components_file]);
else
    NumComponents = 30;
    MeanThresh=1;
    NumIterations = 20;
    i=5;
    Suffix = ['Grad_' mask_file '_mean' num2str(MeanThresh) '_Its_' num2str(NumIterations) '_Comps_' num2str(NumComponents) '_eig_' num2str(i)];
    [W,WPCA,D,E,treeEdges,beta,sds,pis] = learnTreeComponentsUri(fvox,NumComponents,'numIterations',NumIterations,'progressFilename',Suffix,'first_comp',i);
end

% Calculate the physical location of the components
A=W*E;
for i=1:NumComponents
    Seed = A(i,:);
    [vmpBetaVec(i,:),vmpTVec(i,:)] = vtcRegressTCmat_data(fvox,Seed,'aa',1,1);
    compVec5(i,:) = vmpTVec(i,:)<0.05 & vmpTVec(i,:)>-0.05;
    compVec1(i,:) = vmpTVec(i,:)<0.01 & vmpTVec(i,:)>-0.01;
end

% calculate for each component and each ROI if the component exists there
aal_areas=zeros(116, numvox);
for i=1:116
    aal_areas(i,:)=ismember(AAL_mask_reshaped,i);
end
ROIs_components=zeros(NumComponents,116);
for i=1:NumComponents
    for j=1:116
        a = compVec1(i,:) & aal_areas(j,:);
        ROIs_components(i,j)=sum(a)/sum(compVec1(i,:));
    end
end


% calculate for each component and each tissue type what is the percent of
% it in the component
segments_components=zeros(NumComponents,3);
for i=1:NumComponents
    a = {compVec1(i,:)&GM_segment, compVec1(i,:)&WM_segment, compVec1(i,:)&CSF_segment};
    for j=1:3
        segments_components(i,j)=sum(a{j})/sum(compVec1(i,:));
    end
end
