function thresh = find_func_threshold(func_images)
% thresh = find_func_threshold(func_images)
%
% This function receives a 4d-matrix of functional images, fits a
% gaussian to the intensities, and gives a lower threshold of 2.5 standard
% deviations from the gaussian mean
% This is later used to threshold the images, to find voxels which are
% brain related and avoid using voxels with signal dropout


min_func_intensity=100; % voxels with intensity below this value will not be used during gaussian fitting

% func_images=get_func_matrix(func_dir);

mean_func_image=zeros(size(func_images(:,:,:,1)));
for i=1:size(func_images,1)
    for j=1:size(func_images,2)
        for q=1:size(func_images,3)
            mean_func_image(i,j,q)=round(nanmean(squeeze(func_images(i,j,q,:))));
        end
    end
end
mean_func_image(mean_func_image<1)=1;
mean_func_image(isnan(mean_func_image))=1;

m=zeros(1,max(mean_func_image(:)));
for i=1:size(func_images,1)
    for j=1:size(func_images,2)
        for q=1:size(func_images,3)
            m(mean_func_image(i,j,q))=m(mean_func_image(i,j,q))+1;
        end
    end
end
% figure;hist(mean_func_image(:),0:10:ceil(max(mean_func_image(:))/100)*100)

f=fit((min_func_intensity:length(m))',m(min_func_intensity:end)','gauss1');
thresh = f.b1 - 3*(f.c1/2);

% p=plot(f(100:1000),'r')
% set(p,'LineWidth',3)
% hold on
% plot(m(100:1000),'b')
% title('Sample subject - Gaussian fitting')
% ylabel('Number of voxels')
% xlabel('Intensity')
