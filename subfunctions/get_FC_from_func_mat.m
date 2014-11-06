function FC_image = get_FC_from_func_mat(func_matrix, timecourse)
% FC_image = get_FC_from_func_mat(func_matrix, timecourse)
%
% receives a 4D functional data matrix, and a timecourse vector (from voxel/ROI),
% and computes functional connectivity 
% returns a 3D matrix (image) of the correlation of the timecourse to each voxel

s=size(func_matrix);
% func_matrix_reshaped=reshape(func_matrix,[],s(4))';
% c=corr(timecourse,func_matrix_reshaped);
% FC_image=reshape(c,s(1),s(2),s(3));
FC_image=zeros(s(1:3));

% for i=1:s(1)
% %     if mod(i,20)==0
% %         disp(i)
% %     end
%     for j=1:s(2)
%         for q=1:s(3)
%             FC_image(i,j,q)=corr(timecourse,squeeze(func_matrix(i,j,q,:)));
%         end
%     end
% end

% this is done slice-wise, since reshaping the whole matrix takes too much
% memory
for i=1:s(1)
    func_slice_temp=reshape(func_matrix(i,:,:,:),[],s(4))';
    FC_temp=corr(timecourse,func_slice_temp);
    FC_image(i,:,:)=reshape(FC_temp,s(2),s(3));
end

