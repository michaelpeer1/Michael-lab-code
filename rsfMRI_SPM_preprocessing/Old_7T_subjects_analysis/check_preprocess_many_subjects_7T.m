function check_preprocess_many_subjects_7T(preproc_directory)
% check_preprocess_many_subjects_7T(preproc_directory)
% 
% This is a wrapper which runs check_subject_preprocessing_7T on multiple
% subjects, and saves the results to an Excel file

subjects=dir([preproc_directory '\T1IMG\']); subjects=subjects(3:end);
parfor i=1:length(subjects)
    disp(i)
    if ~exist([preproc_directory '\preproc_check\' subjects(i).name '\check.xls'],'file')
        check_subject_preprocessing_7T(preproc_directory,subjects(i).name);
    end
end

data_total=cell(250,250);
for i=1:length(subjects)
    [~,~,c]=xlsread([preproc_directory '\preproc_check\' subjects(i).name '\check.xls']);
    current_column=(i-1)*18+1;
    data_total{1,current_column}=subjects(i).name;
    for j=1:6
        current_column=(i-1)*18+1+(j-1)*3;
        data_total{2,current_column}=['session ' num2str(j)];
        if ~isnan(c{3,j*2-1})
            data_total{3,current_column}='max movement problem - translation';
        elseif ~isnan(c{4,j*2-1})
            data_total{4,current_column}='max movement problem - rotation';
        end
        if ~isnan(c{7,1})
            data_total{4,current_column}='T1 normalization problem';
        end
        if ~isnan(c{10,1})
            data_total{5,current_column}='EPI normalization problem';
        end
        data_total{6,current_column}='num vox problem';
        data_total{6,current_column+1}='mean value problem';
        data_total{6,current_column+2}='nan problem';
        if ~isnan(c{13+j*6-2,1})
            counter=2;
            while ~isnan(c{13+j*6-2,counter}) && counter<=90
                current_row=5+counter;
                data_total{current_row,current_column}=c{13+j*6-2,counter};
                counter=counter+1;
            end
        end
        if ~isnan(c{13+j*6-1,1})
            counter=2;
            while ~isnan(c{13+j*6-1,counter}) && counter<=90
                current_row=5+counter;
                data_total{current_row,current_column+1}=c{13+j*6-1,counter};
                counter=counter+1;
            end
        end
        if ~isnan(c{13+j*6,1})
            counter=2;
            while ~isnan(c{13+j*6,counter}) && counter<=90
                current_row=5+counter;
                data_total{current_row,current_column+2}=c{13+j*6,counter};
                counter=counter+1;
            end
        end
    end
end



xlswrite([preproc_directory '\subject_check_summary.xlsx'],data_total);