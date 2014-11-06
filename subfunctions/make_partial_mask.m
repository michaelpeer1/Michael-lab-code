function make_partial_mask(original_mask_filename, area_list, output_filename)
% make_partial_mask(original_mask_filename, area_list, output_filename) 
%
% receives a mask (AAL, freesurfer, etc.), and a list of numbers of areas in the mask
% creates a new mask from the specified areas only and saves it as a Nifti file in output_file

original_mask=spm_read_vols(spm_vol(original_mask_filename));
new_mask=zeros(size(original_mask));

for i=1:length(area_list)
    new_mask(original_mask==area_list(i)) = area_list(i);
end

new_mask_file=spm_vol(original_mask_filename);
new_mask_file.fname=output_filename; 
new_mask_file.private.dat.fname =  output_filename;
spm_write_vol(new_mask_file,new_mask);