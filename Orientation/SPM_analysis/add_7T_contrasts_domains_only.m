function add_7T_contrasts_domains_only(spmmat_file, delete_existing_contrasts)
% this function receives an spm.mat filename, from the analysis of the 7T
% orientation paradigm, and adds the important contrasts
% it also receives input on whether to delete all the existing contrasts or
% add to them - (0 - do not delete, 1 - delete)

spm('defaults','fmri'); spm_jobman('initcfg');

contrast_vectors={};
contrast_names={};
contypes={};    % 1 for t-contrast, 2 for f-contrast

% ADD THE CONTRASTS THEMSELVES
i=1; contypes{i}=1; contrast_names{i}= 'All domains vs. rest'; contrast_vectors{i}=[repmat([1 0 1 0 1 0 zeros(1,6)], 1, 5)];
i=2; contypes{i}=1; contrast_names{i}= 'All domains and control vs. rest'; contrast_vectors{i}=[repmat([1 0 1 0 1 0 zeros(1,6)], 1, 6)];
i=3; contypes{i}=1; contrast_names{i}= 'Person vs. rest'; contrast_vectors{i}=[repmat([1 0 0 0 0 0 zeros(1,6)], 1, 5)];
i=4; contypes{i}=1; contrast_names{i}= 'Place vs. rest'; contrast_vectors{i}=[repmat([0 0 1 0 0 0 zeros(1,6)], 1, 5)];
i=5; contypes{i}=1; contrast_names{i}= 'Time vs. rest'; contrast_vectors{i}=[repmat([0 0 0 0 1 0 zeros(1,6)], 1, 5)];
i=6; contypes{i}=1; contrast_names{i}= 'Control vs. rest'; contrast_vectors{i}=[zeros(1,12*5) 1 0 1 0 1 0 zeros(1,6)];

i=7; contypes{i}=1; contrast_names{i}= 'Person vs time and place'; contrast_vectors{i}=[repmat([2 0 -1 0 -1 0 0 0 0 0 0 0 ],1,5)];
i=8; contypes{i}=1; contrast_names{i}= 'Place vs person and time'; contrast_vectors{i}=[repmat([-1 0 2 0 -1 0 0 0 0 0 0 0 ],1,5)];
i=9; contypes{i}=1; contrast_names{i}= 'Time vs person and place'; contrast_vectors{i}=[repmat([-1 0 -1 0 2 0 0 0 0 0 0 0], 1, 5)];
i=10; contypes{i}=1; contrast_names{i}= 'Person vs. place'; contrast_vectors{i}=[repmat([1 0 -1 0 0 0 zeros(1,6)],1,5)];
i=11; contypes{i}=1; contrast_names{i}= 'Person vs. time'; contrast_vectors{i}=[repmat([1 0 0 0 -1 0 zeros(1,6)],1,5)];
i=12; contypes{i}=1; contrast_names{i}= 'Place vs. person'; contrast_vectors{i}=[repmat([-1 0 1 0 0 0 zeros(1,6)],1,5)];
i=13; contypes{i}=1; contrast_names{i}= 'Place vs. time'; contrast_vectors{i}=[repmat([0 0 1 0 -1 0 zeros(1,6)],1,5)];
i=14; contypes{i}=1; contrast_names{i}= 'Time vs. person'; contrast_vectors{i}=[repmat([1 0 0 0 1 0 zeros(1,6)],1,5)];
i=15; contypes{i}=1; contrast_names{i}= 'Time vs place'; contrast_vectors{i}=[repmat([0 0 -1 0 1 0 zeros(1,6)],1,5)];
i=16; contypes{i}=2; contrast_names{i}= 'Person vs. (time and place)'; contrast_vectors{i}={repmat([1 0 -1 0 0 0 zeros(1,6)],1,5),... 
repmat([1 0 0 0 -1 0 zeros(1,6)],1,5)};
i=17; contypes{i}=2; contrast_names{i}= 'Place vs. (time and person)'; contrast_vectors{i}={repmat([-1 0 1 0 0 0 zeros(1,6)],1,5),... 
repmat([0 0 1 0 -1 0 zeros(1,6)],1,5)};
i=18; contypes{i}=2; contrast_names{i}= 'Time vs. (place and person)'; contrast_vectors{i}={repmat([-1 0 0 0 1 0 zeros(1,6)],1,5),... 
repmat([0 0 -1 0 1 0 zeros(1,6)],1,5)};

i=19; contypes{i}=1; contrast_names{i}= 'Domains vs control'; contrast_vectors{i}=[repmat([1 0 1 0 1 0 zeros(1,6)],1,5) -5 0 -5 0 -5 0 zeros(1,6)];
i=20; contypes{i}=1; contrast_names{i}= 'Person vs control'; contrast_vectors{i}=[repmat([1 0 0 0 0 0 zeros(1,6)],1,5) -5 0 0 0 0 0 zeros(1,6)];
i=21; contypes{i}=1; contrast_names{i}= 'Place vs control'; contrast_vectors{i}=[repmat([0 0 1 0 0 0 zeros(1,6)],1,5) 0 0 -5 0 0 0 zeros(1,6)];
i=22; contypes{i}=1; contrast_names{i}= 'Time vs control'; contrast_vectors{i}=[repmat([0 0 0 0 1 0 zeros(1,6)],1,5) 0 0 0 0 -5 0 zeros(1,6)];
i=23; contypes{i}=2; contrast_names{i}= 'Person vs control F'; contrast_vectors{i}={[1 0 0 0 0 0 zeros(1,6) zeros(1,12*4) -1 0 0 0 0 0 zeros(1,6)],...
[zeros(1,12) 1 0 0 0 0 0 zeros(1,6) zeros(1,12*3) -1 0 0 0 0 0 zeros(1,6)],...
[zeros(1,12*2) 1 0 0 0 0 0 zeros(1,6) zeros(1,12*2) -1 0 0 0 0 0 zeros(1,6)],...
[zeros(1,12*3) 1 0 0 0 0 0 zeros(1,6) zeros(1,12) -1 0 0 0 0 0 zeros(1,6)],...
[zeros(1,12*4) 1 0 0 0 0 0 zeros(1,6) -1 0 0 0 0 0 zeros(1,6)]};
i=24; contypes{i}=2; contrast_names{i}= 'Place vs control F'; contrast_vectors{i}={[0 0 1 0 0 0 zeros(1,6) zeros(1,12*4) 0 0 -1 0 0 0 zeros(1,6)],...
[zeros(1,12) 0 0 1 0 0 0 zeros(1,6) zeros(1,12*3) 0 0 -1 0 0 0 zeros(1,6)],...
[zeros(1,12*2) 0 0 1 0 0 0 zeros(1,6) zeros(1,12*2) 0 0 -1 0 0 0 zeros(1,6)],...
[zeros(1,12*3) 0 0 1 0 0 0 zeros(1,6) zeros(1,12) 0 0 -1 0 0 0 zeros(1,6)],...
[zeros(1,12*4) 0 0 1 0 0 0 zeros(1,6) 0 0 -1 0 0 0 zeros(1,6)]};
i=25; contypes{i}=2; contrast_names{i}= 'Time vs control F'; contrast_vectors{i}={[0 0 0 0 1 0 zeros(1,6) zeros(1,12*4) 0 0 0 0 -1 0 zeros(1,6)],...
[zeros(1,12) 0 0 0 0 1 0 zeros(1,6) zeros(1,12*3) 0 0 0 0 -1 0 zeros(1,6)],...
[zeros(1,12*2) 0 0 0 0 1 0 zeros(1,6) zeros(1,12*2) 0 0 0 0 -1 0 zeros(1,6)],...
[zeros(1,12*3) 0 0 0 0 1 0 zeros(1,6) zeros(1,12) 0 0 0 0 -1 0 zeros(1,6)],...
[zeros(1,12*4) 0 0 0 0 1 0 zeros(1,6) 0 0 0 0 -1 0 zeros(1,6)]};


clear matlabbatch;
matlabbatch{1}.spm.stats.con.spmmat=cellstr(spmmat_file);
matlabbatch{1}.spm.stats.con.delete=delete_existing_contrasts;

% all_contrasts=cell(1,length(contrast_vectors));
for i=1:length(contrast_vectors)
    if contypes{i}==1
        matlabbatch{1}.spm.stats.con.consess{i}.tcon.name=contrast_names{i};
        matlabbatch{1}.spm.stats.con.consess{i}.tcon.convec=contrast_vectors{i};
    else
        matlabbatch{1}.spm.stats.con.consess{i}.fcon.name=contrast_names{i};
        matlabbatch{1}.spm.stats.con.consess{i}.fcon.convec=contrast_vectors{i};
    end
end

%matlabbatch={struct('spm',struct('stats',struct('con','')))};
%matlabbatch{1}.spm.stats{1}.con.concess=all_contrasts;

spm_jobman('run',matlabbatch);
