function create_brain_overlap_picture(pic_underlay, pic_overlay, output_file)
% create_brain_overlap_picture(pic_underlay, pic_overlay, output_file)
% 
% creates pictures of overalpping brains, for checking normalization to template or co-registration
% input: the two pictures' filenames, and the output picture filename
% outpur: a TIFF picture overlaying one image over another

% reading the images
overl=spm_read_vols(spm_vol(pic_overlay));
% reslicing the underlay image
underl = y_Reslice_no_outputfile(pic_underlay,[],0,pic_overlay);

% normalizing the images
underl=(underl-mean(underl(:)))/std(underl(:));
overl=(overl-mean(overl(:)))/std(overl(:));

h=figure;
% x picture
subplot(2,2,1);
middle_slicex=round(size(underl,1)/2);
underlx=underl(middle_slicex,:,:); underlx=squeeze(underlx);
overlx=overl(middle_slicex,:,:); overlx=squeeze(overlx);
% plotting the picture
green = cat(3, zeros(size(underlx)), ones(size(underlx)), zeros(size(underlx)));
imshow(underlx>0); hold on;
x = imshow(green); hold off;
set(x, 'AlphaData', overlx>0.5);

% y picture
subplot(2,2,2);
middle_slicey=round(size(underl,2)/2);
underly=underl(:,middle_slicey,:); underly=squeeze(underly);
overly=overl(:,middle_slicey,:); overly=squeeze(overly);
% plotting the picture
green = cat(3, zeros(size(underly)), ones(size(underly)), zeros(size(underly)));
imshow(underly>0); hold on;
y = imshow(green); hold off;
set(y, 'AlphaData', overly>0.5);

% z picture
subplot(2,2,3);
middle_slicez=round(size(underl,3)/2);
underlz=underl(:,:,middle_slicez); underlz=squeeze(underlz);
overlz=overl(:,:,middle_slicez); overlz=squeeze(overlz);
% plotting the picture
green = cat(3, zeros(size(underlz)), ones(size(underlz)), zeros(size(underlz)));
imshow(underlz>0); hold on;
z = imshow(green); hold off;
set(z, 'AlphaData', overlz>0.5);

print('-dtiff','-r100',output_file,h);
close(h);



% OLD RESLICE CODE
% % reslicing the underlay image
% [under_a,under_b,under_c]=fileparts(pic_underlay);
% pic_underlay_resliced=[under_a '\' under_b '_resliced' under_c];
% y_Reslice(pic_underlay,pic_underlay_resliced,[],0,pic_overlay);
% 
% % reading the images
% underl=spm_read_vols(spm_vol(pic_underlay_resliced));
% overl=spm_read_vols(spm_vol(pic_overlay));
%
%delete(pic_underlay_resliced); %delete(pic_overlay_resliced);



% OLD CODE

% global DPARSF_rest_sliceviewer_Cfg;
% h=DPARSF_rest_sliceviewer;
% set(DPARSF_rest_sliceviewer_Cfg.Config(1).hOverlayFile, 'String', pic_overlay);
% DPARSF_rest_sliceviewer_Cfg.Config(1).Overlay.Opacity=0.2;
% DPARSF_rest_sliceviewer('ChangeOverlay', h);

% reslice underlay picture if needed and put as underlay
% [a,b,c]=fileparts(pic_underlay);
% pic_a=spm_read_vols(spm_vol(pic_underlay)); pic_b=spm_read_vols(spm_vol(pic_overlay));
% if size(pic_a)~=size(pic_b)
%   y_Reslice(pic_underlay,[a b '_resliced' c],[],0,pic_overlay);
%   pic_underlay=[a b '_resliced' c];
% end

% set(DPARSF_rest_sliceviewer_Cfg.Config(1).hUnderlayFile, 'String', pic_underlay_resliced);
% set(DPARSF_rest_sliceviewer_Cfg.Config(1).hMagnify ,'Value',2);
% DPARSF_rest_sliceviewer('ChangeUnderlay', h);

% if exist([a b '_resliced' c],'file')
%   delete([a b '_resliced' c]);
% end
