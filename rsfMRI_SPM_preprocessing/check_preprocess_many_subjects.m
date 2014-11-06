function check_preprocess_many_subjects(preproc_directory)
% check_preprocess_many_subjects(preproc_directory)
% 
% This is a wrapper which runs check_subject_preprocessing on multiple
% subjects, and saves the results to an Excel file

subjects=dir([preproc_directory '\FunRawAR\']); subjects=subjects(3:end);
for i=1:length(subjects)
    disp(subjects(i).name)
    if ~exist([preproc_directory '\preproc_check\' subjects(i).name '\check.xls'],'file')
        check_subject_preprocessing(preproc_directory,subjects(i).name);
    end
end

data_total=cell(1000,1000);
for i=1:length(subjects)
    [~,~,c]=xlsread([preproc_directory '\preproc_check\' subjects(i).name '\check.xls']);
    current_column=i*3-2;
    data_total{1,current_column}=subjects(i).name;
    if ~isnan(c{3,1})
        data_total{2,current_column}='max movement problem';
    elseif ~isnan(c{4,1})
        data_total{2,current_column}='max movement problem';
    end
    if ~isnan(c{7,1})
        data_total{3,current_column}='T1 normalization problem';
    end
    if ~isnan(c{10,1})
        data_total{4,current_column}='EPI normalization problem';
    end
    data_total{5,current_column}='num vox problem';
    data_total{5,current_column+1}='mean value problem';
    data_total{5,current_column+2}='nan problem';
    if(size(c,1))>16
        if ~isnan(c{17,1})
            counter=2;
            while ~isnan(c{17,counter}) && counter<=90
                current_row=4+counter;
                data_total{current_row,current_column}=c{17,counter};
                counter=counter+1;
            end
        end
    end
    if(size(c,1))>17
        if ~isnan(c{18,1})
            counter=2;
            while ~isnan(c{18,counter}) && counter<=90
                current_row=4+counter;
                data_total{current_row,current_column+1}=c{18,counter};
                counter=counter+1;
            end
        end
    end
    if(size(c,1))>18
        if ~isnan(c{19,1})
            counter=2;
            while ~isnan(c{19,counter}) && counter<=90
                current_row=4+counter;
                data_total{current_row,current_column+2}=c{19,counter};
                counter=counter+1;
            end
        end
    end
end



xlswrite([preproc_directory '\subject_check_summary.xlsx'],data_total);