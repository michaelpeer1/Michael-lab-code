function add_distance_contrasts_to_7T_paradigm(spmmat_file, ignore_sessions)

% creating the contrasts
basic_contrast_vectors={};  % the basic contrast for each session
basic_contrast_vector_control={};  % the basic contrast for the control session
contrast_names={};
contypes={};    % 1 for t-contrast, 2 for f-contrast

% find number of movement regressors
aaa=load(spmmat_file);
contrast2=aaa.SPM.xCon(2).c;   % all domains+control vs. rest
numsess=6;
num_mov_regressors(1)=find(contrast2(37:end),1)-1;
num_mov_regressors(2)=find(contrast2(37+36+num_mov_regressors(1):end),1)-1;
num_mov_regressors(3)=find(contrast2(37+36*2+num_mov_regressors(1)+num_mov_regressors(2):end),1)-1;
num_mov_regressors(4)=find(contrast2(37+36*3+num_mov_regressors(1)+num_mov_regressors(2)+num_mov_regressors(3):end),1)-1;
num_mov_regressors(5)=find(contrast2(37+36*4+num_mov_regressors(1)+num_mov_regressors(2)+num_mov_regressors(3)+num_mov_regressors(4):end),1)-1;
num_mov_regressors(6)=length(contrast2)-(37+36*5+num_mov_regressors(1)+num_mov_regressors(2)+num_mov_regressors(3)+num_mov_regressors(4)+num_mov_regressors(5));


% The basic contrast vectors (per session, without movement regressors)
% (the paradigm in each session is: person, place, time. In each one there are 6 distances)
i=1; contypes{i}=1; contrast_names{i}= '1 vs others'; basic_contrast_vectors{i}=repmat([5 -1 -1 -1 -1 -1], 1, 3); basic_contrast_vector_control{i}=zeros(1,18);
i=2; contypes{i}=1; contrast_names{i}= '1 vs others person'; basic_contrast_vectors{i}=[5 -1 -1 -1 -1 -1 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=3; contypes{i}=1; contrast_names{i}= '1 vs others place'; basic_contrast_vectors{i}=[zeros(1,6) 5 -1 -1 -1 -1 -1 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=4; contypes{i}=1; contrast_names{i}= '1 vs others time'; basic_contrast_vectors{i}=[zeros(1,12) 5 -1 -1 -1 -1 -1]; basic_contrast_vector_control{i}=zeros(1,18);
i=5; contypes{i}=1; contrast_names{i}= '1+2 vs others'; basic_contrast_vectors{i}=repmat([2 2 -1 -1 -1 -1], 1, 3); basic_contrast_vector_control{i}=zeros(1,18);
i=6; contypes{i}=1; contrast_names{i}= '1+2 vs others person'; basic_contrast_vectors{i}=[2 2 -1 -1 -1 -1 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=7; contypes{i}=1; contrast_names{i}= '1+2 vs others place'; basic_contrast_vectors{i}=[zeros(1,6) 2 2 -1 -1 -1 -1 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=8; contypes{i}=1; contrast_names{i}= '1+2 vs others time'; basic_contrast_vectors{i}=[zeros(1,12) 2 2 -1 -1 -1 -1]; basic_contrast_vector_control{i}=zeros(1,18);
i=9; contypes{i}=1; contrast_names{i}= '6 vs others'; basic_contrast_vectors{i}=repmat([-1 -1 -1 -1 -1 5], 1, 3); basic_contrast_vector_control{i}=zeros(1,18);
i=10; contypes{i}=1; contrast_names{i}= '6 vs others person'; basic_contrast_vectors{i}=[-1 -1 -1 -1 -1 5 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=11; contypes{i}=1; contrast_names{i}= '6 vs others place'; basic_contrast_vectors{i}=[zeros(1,6) -1 -1 -1 -1 -1 5 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=12; contypes{i}=1; contrast_names{i}= '6 vs others time'; basic_contrast_vectors{i}=[zeros(1,12) -1 -1 -1 -1 -1 5]; basic_contrast_vector_control{i}=zeros(1,18);
i=13; contypes{i}=1; contrast_names{i}= '5+6 vs others'; basic_contrast_vectors{i}=repmat([-1 -1 -1 -1 2 2], 1, 3); basic_contrast_vector_control{i}=zeros(1,18);
i=14; contypes{i}=1; contrast_names{i}= '5+6 vs others person'; basic_contrast_vectors{i}=[-1 -1 -1 -1 2 2 zeros(1,12)]; basic_contrast_vector_control{i}=zeros(1,18);
i=15; contypes{i}=1; contrast_names{i}= '5+6 vs others place'; basic_contrast_vectors{i}=[zeros(1,6) -1 -1 -1 -1 2 2 zeros(1,6)]; basic_contrast_vector_control{i}=zeros(1,18);
i=16; contypes{i}=1; contrast_names{i}= '5+6 vs others time'; basic_contrast_vectors{i}=[zeros(1,12) -1 -1 -1 -1 2 2]; basic_contrast_vector_control{i}=zeros(1,18);

matlabbatch{1}.stats{1}.con.spmmat=cellstr(spmmat_file);
matlabbatch{1}.stats{1}.con.delete=0;


contrast_vectors=cell(length(basic_contrast_vectors),1);
for i=1:length(basic_contrast_vectors)
    
    % create full contrasts
    if contypes{i}==1   % t-contrast
        
        % if modeling time and dispersion derivatives, add zeros between contrast elements
        num_zeros_to_add=1; % time derivative
        if num_zeros_to_add==1
            b=zeros(1,length(basic_contrast_vectors{i})*2);
            b(1:2:end)=basic_contrast_vectors{i};
            basic_contrast_vectors{i}=b;
            b(1:2:end)=basic_contrast_vector_control{i};
            basic_contrast_vector_control{i}=b;
        elseif num_zeros_to_add==2
            b=zeros(1,length(basic_contrast_vectors{i})*3);
            b(1:3:end)=basic_contrast_vectors{i};
            basic_contrast_vectors{i}=b;
            b(1:3:end)=basic_contrast_vector_control{i};
            basic_contrast_vector_control{i}=b;
        end
        
        for  j=1:numsess-1
            if isempty(find(ignore_sessions==j,1))
                % adding each session's contrast vector and movement regressors
                contrast_vectors{i}=[contrast_vectors{i} basic_contrast_vectors{i} zeros(1,num_mov_regressors(j))];
            else
                contrast_vectors{i}=[contrast_vectors{i} zeros(1,length(basic_contrast_vectors{i})) zeros(1,num_mov_regressors(j))];
            end
        end
        % adding the control session, assuming it is the last one
        contrast_vectors{i}=[contrast_vectors{i} basic_contrast_vector_control{i} zeros(1,num_mov_regressors(numsess))];
        
        matlabbatch{1}.stats{1}.con.consess{i}.tcon.name=contrast_names{i};
        matlabbatch{1}.stats{1}.con.consess{i}.tcon.convec=contrast_vectors{i};
        
    else     % F-contrast
        
        contrast_vectors{i}=cell(size(basic_contrast_vectors{i}));
        for q=1:length(basic_contrast_vectors{i})
            % if modeling time and dispersion derivatives, add zeros between contrast elements
            num_zeros_to_add=time_derivative+dispersion_derivative;
            if num_zeros_to_add==1
                b=zeros(1,length(basic_contrast_vectors{i}{q})*2);
                b(1:2:end)=basic_contrast_vectors{i}{q};
                basic_contrast_vectors{i}{q}=b;
                b(1:2:end)=basic_contrast_vector_control{i}{q};
                basic_contrast_vector_control{i}{q}=b;
            elseif num_zeros_to_add==2
                b=zeros(1,length(basic_contrast_vectors{i}{q})*3);
                b(1:3:end)=basic_contrast_vectors{i}{q};
                basic_contrast_vectors{i}{q}=b;
                b(1:3:end)=basic_contrast_vector_control{i}{q};
                basic_contrast_vector_control{i}{q}=b;
            end
            
            for  j=1:numsess-1
                if isempty(find(ignore_sessions==j,1))
                    contrast_vectors{i}{q}=[contrast_vectors{i}{q} basic_contrast_vectors{i}{q} zeros(1,num_mov_regressors(j))];
                else
                    contrast_vectors{i}{q}=[contrast_vectors{i}{q} zeros(1,length(basic_contrast_vectors{i}{q})) zeros(1,num_mov_regressors(j))];
                end
            end
            % adding the control session, assuming it is the last one
            contrast_vectors{i}{q}=[contrast_vectors{i}{q} basic_contrast_vector_control{i}{q} zeros(1,num_mov_regressors(numsess))];
        end
        
        matlabbatch{1}.stats{1}.con.consess{i}.fcon.name=contrast_names{i};
        matlabbatch{1}.stats{1}.con.consess{i}.fcon.convec=contrast_vectors{i};
    end
    
end

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);
