function FC_image = get_FC_from_func_mat_dynamic(func_matrix, timecourse, window_size)
% FC_image = get_FC_from_func_mat_dynamic(func_matrix, timecourse, window_size)
%
% receives a 4D functional data matrix, and a timecourse vector (from voxel/ROI),
% and computes functional connectivity
% returns a 4D matrix of the correlation of the timecourse to each voxel in
% each time-window (fourth dimension is the different windows)

s=size(func_matrix);
FC_image=[];

num_windows = length(timecourse)-window_size+1;

% this is done slice-wise, since reshaping the whole matrix takes too much
% memory
for n=1:num_windows
    for i=1:s(1)
        func_slice_temp=reshape(func_matrix(i,:,:,n:n+window_size-1),[],window_size)';
        FC_temp=corr(timecourse(n:n+window_size-1),func_slice_temp);
        FC_image(i,:,:,n)=reshape(FC_temp,s(2),s(3));
    end
end
