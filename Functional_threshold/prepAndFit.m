function [thresh,r] = prepAndFit
% [thresh,r] = prepAndFit
%
% This function request .hdr files from the user, prepared a 4-D
% matrix and calls find_func_threshold for finding the threshold

    %folder_name = uigetdir();

    % Load hdrs
    [FileNames,Path] = uigetfile('*.hdr','Please select all hdrs of acquisition','Multiselect','on');

    loadedDim = xff(strcat(Path,FileNames{1}));

    xDim = size(loadedDim.VoxelData,1);
    yDim = size(loadedDim.VoxelData,2);
    zDim = size(loadedDim.VoxelData,3);
    tDim = length(FileNames);
    
    func_images = zeros(xDim,yDim,zDim,tDim);
    
    for i= 1:length(FileNames)
        
        loadedHDR = xff(strcat(Path,FileNames{i}));
        func_images(:,:,:,i)= loadedHDR.VoxelData;
        
    end
    
    [thresh,r] = find_func_threshold(func_images);

end