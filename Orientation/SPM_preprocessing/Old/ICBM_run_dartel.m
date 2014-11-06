
% create dartel templates
load('C:\spm8\toolbox\DPARSF_V2.2PRE_120905\Jobmats\Dartel_CreateTemplate.mat')

subjs=dir('c:\INDI\host\ICBM\FunRawAR\'); subjs=subjs(3:end);

c1images=cell(1,length(subjs));
c2images=cell(1,length(subjs));
for i=1:length(subjs)
    c1images{i}=['c:\INDI\host\ICBM\T1ImgNewSegment\' subjs(i).name '\c1mprage_anonymized.nii'];
    c2images{i}=['c:\INDI\host\ICBM\T1ImgNewSegment\' subjs(i).name '\c2mprage_anonymized.nii'];
end

matlabbatch{1}.spm.tools.dartel.warp.images{1,1}=c1images;
matlabbatch{1}.spm.tools.dartel.warp.images{1,2}=c2images;

spm_jobman('run', matlabbatch);

