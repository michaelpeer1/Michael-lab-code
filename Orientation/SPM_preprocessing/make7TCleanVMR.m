% This script is from the Olaf Blanke lab: it is used to combine the
% MP2RAGE images (UNI+INV) from the 7-Tesla magnet into one image
%
%
%make nice anatomy from 7t. this func akes the 2 7t anatomies and brings
%them into one nice one
clear all


path='F:\fingerscrossedFMRI\fMRI\Real_FCE_fMRI_subjects\JOSE\anatomical\'
files=dir([path '*.dcm'])
iso=zeros(256,240,176);%for 8 ch coil matrix size is 256,256,176!!
uni=zeros(256,240,176);
new=zeros(256,240,176);
 aa='mp2rage_UNI_Images';
    bb='mp2rage_INV2';
    
    cc='mp2rage_T1_Images' %some new sequences use this in the header
    
for ii=1:length(files)
    info = dicominfo([path files(ii).name]);
    a=info.SeriesDescription;
   
   g= strcmp(a,aa);
   gg=strcmp(a,cc);
   if g==1 
       
       header=info;
      
  num=info.InstanceNumber;  
   X = dicomread([path files(ii).name]);
   uni(:,:,num)=X;

   elseif gg==1
       
%       num=info.AcquisitionNumber;  
      num=info.InstanceNumber;  
   X = dicomread([path files(ii).name]);
   iso(:,:,num)=X  ;

   else
   end
end

%optional make jaw region zeros to avoid the high intensity values there
%to find exact regions per subject get a middle slice (i.e 88)
ii=88
X = dicomread([path files(ii).name]);
figure, imagesc(X)

%on the matrix find the high intensity regions of the jaw than can be
%cropped without cropping the brain and enter them below



new=uni.*(iso>300);%use 300 for 32 ch 500 for 8ch

%these work for most subjects cropping the jaw and throat till end
new(151:end,1:150,:)=1; %if yoou want occipital lobe then restrict crop to 1:150
% new(205:end,112:end,:)=1;

for ll=1:176  
    y=uint16(new(:,:,ll));
    header.InstanceNumber=ll;
    filename=header.Filename(1:end-19);
    newfilename=([filename 'NewVmr_' num2str(ll) '.dcm'])
    dicomwrite(y, newfilename, header);
end
