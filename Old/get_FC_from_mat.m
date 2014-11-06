function FC_image = get_FC_from_mat(func_matrix, timecourse)
% FC_image = get_FC_from_mat(func_matrix, timecourse)
%
% receives a 4D functional data matrix, and a timecourse vector (from voxel/ROI),
% and computes functional connectivity
% returns a 3D matrix of the correlation of the timecourse to each voxel

s=size(func_matrix);
FC_image=zeros(s(1:3));
for i=1:s(1)
%     if mod(i,20)==0
%         disp(i)
%     end
    for j=1:s(2)
        for q=1:s(3)
            corr_current=corrcoef(timecourse,squeeze(func_matrix(i,j,q,:)));
            FC_image(i,j,q)=corr_current(2);
        end
    end
end
