% This is an obsolete function, using datasets of results of the distance
% comparison orientation paradigms
% (Datasets are created using analyze_stat.m)

% this is for adding additional fields to the dataset

% I first manually added 'gender' to each participant, by this sample code:
% i=8; sz=size(person_est{i}); person_est{i}.gender='F';person_est{i}.gender(1:sz(1))='F';
% (repeated for each domain and subject, for comparison and estimation paradigms)

% adding relative gender
for i=1:length(person_cmp)
    person_cmp{i}.relative_gender_L=nominal(); person_cmp{i}.relative_gender_R=nominal();
    person_cmp{i}.Closer_stimulus_gender=nominal(); person_cmp{i}.Farther_stimulus_gender=nominal();
    person_est{i}.relative_gender=nominal();
    
    if person_cmp{i}.gender(1)=='M'
        for j=1:length(person_cmp{i})
            % comparison databases
            if person_cmp{i}.stimulus_field7_L(j)=='male'
                person_cmp{i}.relative_gender_L(j) = 'equal';
            else
                person_cmp{i}.relative_gender_L(j) = 'different';
            end
            
            if person_cmp{i}.stimulus_field7_R(j)=='male'
                person_cmp{i}.relative_gender_R(j) = 'equal';
            else
                person_cmp{i}.relative_gender_R(j) = 'different';
            end
            
            if person_cmp{i}.CloserStimulusUser(j)=='Left'
                person_cmp{i}.Closer_stimulus_gender(j) = person_cmp{i}.relative_gender_L(j);
                person_cmp{i}.Farther_stimulus_gender(j) = person_cmp{i}.relative_gender_R(j);
            elseif person_cmp{i}.CloserStimulusUser(j)=='Right'
                person_cmp{i}.Closer_stimulus_gender(j) = person_cmp{i}.relative_gender_R(j);
                person_cmp{i}.Farther_stimulus_gender(j) = person_cmp{i}.relative_gender_L(j);
            else
                person_cmp{i}.Closer_stimulus_gender(j) = 'equal_dist';
                person_cmp{i}.Farther_stimulus_gender(j) = 'equal_dist';
            end
        end
        for j=1:length(person_est{i})
            % estimation databases
            if person_est{i}.stimulus_field7(j)=='male'
                person_est{i}.relative_gender(j) = 'equal';
            else
                person_est{i}.relative_gender(j) = 'different';
            end
        end
        
    else    % subject is female
        for j=1:length(person_cmp{i})
            % comparison databases
            if person_cmp{i}.stimulus_field7_L(j)=='female'
                person_cmp{i}.relative_gender_L(j) = 'equal';
            else
                person_cmp{i}.relative_gender_L(j) = 'different';
            end
            
            if person_cmp{i}.stimulus_field7_R(j)=='female'
                person_cmp{i}.relative_gender_R(j) = 'equal';
            else
                person_cmp{i}.relative_gender_R(j) = 'different';
            end
            
            if (person_cmp{i}.CloserStimulusUser(j)=='Left')
                person_cmp{i}.Closer_stimulus_gender(j) = person_cmp{i}.relative_gender_L(j);
                person_cmp{i}.Farther_stimulus_gender(j) = person_cmp{i}.relative_gender_R(j);
            elseif person_cmp{i}.CloserStimulusUser(j)=='Right'
                person_cmp{i}.Closer_stimulus_gender(j) = person_cmp{i}.relative_gender_R(j);
                person_cmp{i}.Farther_stimulus_gender(j) = person_cmp{i}.relative_gender_L(j);
            else
                person_cmp{i}.Closer_stimulus_gender(j) = 'equal_dist';
                person_cmp{i}.Farther_stimulus_gender(j) = 'equal_dist';
            end
        end
        for j=1:length(person_est{i})
            % estimation databases
            if (person_est{i}.stimulus_field7(j)=='female')
                person_est{i}.relative_gender(j) = 'equal';
            else
                person_est{i}.relative_gender(j) = 'different';
            end
        end
    end
end



% adding closer / farther emotion and know
for i=1:length(person_cmp)
    person_cmp{i}.Closer_stimulus_emotion=nominal(); person_cmp{i}.Farther_stimulus_emotion=nominal();
    person_cmp{i}.Closer_stimulus_know=nominal(); person_cmp{i}.Farther_stimulus_know=nominal();
    place_cmp{i}.Closer_stimulus_emotion=nominal(); place_cmp{i}.Farther_stimulus_emotion=nominal();
    place_cmp{i}.Closer_stimulus_know=nominal(); place_cmp{i}.Farther_stimulus_know=nominal();
    time_cmp{i}.Closer_stimulus_emotion=nominal(); time_cmp{i}.Farther_stimulus_emotion=nominal();
    time_cmp{i}.Closer_stimulus_know=nominal(); time_cmp{i}.Farther_stimulus_know=nominal();
    for j=1:length(person_cmp{i})
        if person_cmp{i}.CloserStimulusUser(j)=='Left'
            person_cmp{i}.Closer_stimulus_emotion(j) = num2str(person_cmp{i}.emotionL(j));
            person_cmp{i}.Closer_stimulus_know(j) = num2str(person_cmp{i}.knowL(j));
            person_cmp{i}.Farther_stimulus_emotion(j) = num2str(person_cmp{i}.emotionR(j));
            person_cmp{i}.Farther_stimulus_know(j) = num2str(person_cmp{i}.knowR(j));
        elseif person_cmp{i}.CloserStimulusUser(j)=='Right'
            person_cmp{i}.Closer_stimulus_emotion(j) = num2str(person_cmp{i}.emotionR(j));
            person_cmp{i}.Closer_stimulus_know(j) = num2str(person_cmp{i}.knowR(j));
            person_cmp{i}.Farther_stimulus_emotion(j) = num2str(person_cmp{i}.emotionL(j));
            person_cmp{i}.Farther_stimulus_know(j) = num2str(person_cmp{i}.knowL(j));
        else
            person_cmp{i}.Closer_stimulus_emotion(j) = 'equal_dist';
            person_cmp{i}.Farther_stimulus_emotion(j) = 'equal_dist';
            person_cmp{i}.Closer_stimulus_know(j) = 'equal_dist';
            person_cmp{i}.Farther_stimulus_know(j) = 'equal_dist';
        end
    end
    for j=1:length(place_cmp{i})
        if place_cmp{i}.CloserStimulusUser(j)=='Left'
            place_cmp{i}.Closer_stimulus_emotion(j) = num2str(place_cmp{i}.emotionL(j));
            place_cmp{i}.Farther_stimulus_emotion(j) = num2str(place_cmp{i}.emotionR(j));
            place_cmp{i}.Closer_stimulus_know(j) = num2str(place_cmp{i}.knowL(j));
            place_cmp{i}.Farther_stimulus_know(j) = num2str(place_cmp{i}.knowR(j));
        elseif place_cmp{i}.CloserStimulusUser(j)=='Right'
            place_cmp{i}.Closer_stimulus_emotion(j) = num2str(place_cmp{i}.emotionR(j));
            place_cmp{i}.Farther_stimulus_emotion(j) = num2str(place_cmp{i}.emotionL(j));
            place_cmp{i}.Closer_stimulus_know(j) = num2str(place_cmp{i}.knowR(j));
            place_cmp{i}.Farther_stimulus_know(j) = num2str(place_cmp{i}.knowL(j));
        else
            place_cmp{i}.Closer_stimulus_emotion(j) = 'equal_dist';
            place_cmp{i}.Farther_stimulus_emotion(j) = 'equal_dist';
            place_cmp{i}.Closer_stimulus_know(j) = 'equal_dist';
            place_cmp{i}.Farther_stimulus_know(j) = 'equal_dist';
        end
    end
    for j=1:length(time_cmp{i})
        if time_cmp{i}.CloserStimulusUser(j)=='Left'
            time_cmp{i}.Closer_stimulus_emotion(j) = num2str(time_cmp{i}.emotionL(j));
            time_cmp{i}.Farther_stimulus_emotion(j) = num2str(time_cmp{i}.emotionR(j));
            time_cmp{i}.Closer_stimulus_know(j) = num2str(time_cmp{i}.knowL(j));
            time_cmp{i}.Farther_stimulus_know(j) = num2str(time_cmp{i}.knowR(j));
        elseif time_cmp{i}.CloserStimulusUser(j)=='Right'
            time_cmp{i}.Closer_stimulus_emotion(j) = num2str(time_cmp{i}.emotionR(j));
            time_cmp{i}.Farther_stimulus_emotion(j) = num2str(time_cmp{i}.emotionL(j));
            time_cmp{i}.Closer_stimulus_know(j) = num2str(time_cmp{i}.knowR(j));
            time_cmp{i}.Farther_stimulus_know(j) = num2str(time_cmp{i}.knowL(j));
        else
            time_cmp{i}.Closer_stimulus_emotion(j) = 'equal_dist';
            time_cmp{i}.Farther_stimulus_emotion(j) = 'equal_dist';
            time_cmp{i}.Closer_stimulus_know(j) = 'equal_dist';
            time_cmp{i}.Farther_stimulus_know(j) = 'equal_dist';
        end
    end
end


% adding number of letters for each stimulus
a={};
[~,~,a{end+1}]=xlsread('c:\ExpyVR\Paradigms\Stimuli\Person\Heb\all_person_michael_peer_new\all_person_michael_peer.xls');
[~,~,a{end+1}]=xlsread('c:\ExpyVR\Paradigms\Stimuli\Person\Heb\yonatan_dar\all_person.xls');
[~,~,a{end+1}]=xlsread('c:\ExpyVR\Paradigms\Stimuli\Person\Heb\assaf_Michaely\all_person.xls');
[~,~,a{end+1}]=xlsread('c:\ExpyVR\Paradigms\Stimuli\Person\Heb\clementine_Haddad\all_person.xls');
[~,~,a{end+1}]=xlsread('c:\ExpyVR\Paradigms\Stimuli\Person\Heb\lihi_gur_arie\all_person.xls');
[~,~,a{end+1}]=xlsread('c:\ExpyVR\Paradigms\Stimuli\Person\Heb\eitan_Kaminer\all_person.xls');
[~,~,a{end+1}]=xlsread('c:\ExpyVR\Paradigms\Stimuli\Person\Heb\shiri_Eshar\all_person.xls');
[~,~,a{end+1}]=xlsread('c:\ExpyVR\Paradigms\Stimuli\Person\Heb\ayala_Byron\all_person.xls');
[~,~,a{end+1}]=xlsread('c:\ExpyVR\Paradigms\Stimuli\Person\Heb\nurit_Yaffe\all_person.xls');
[~,~,b]=xlsread('c:\ExpyVR\Paradigms\Stimuli\Place\Heb\Neighborhoods_old\Neighborhoods.xls');
[~,~,c]=xlsread('c:\ExpyVR\Paradigms\Stimuli\time\heb\all_time_heb_new\all_time_heb.xls');
person_lengths=cell(length(a),1);
for i=1:length(a)
    person_lengths{i}=zeros(length(a{i})-1,1);
    for j=2:length(a{i})
        person_lengths{i}(j-1)=length(a{i}{j,2});
    end
end
place_lengths=zeros(length(b)-1,1);
for j=2:length(b)
    place_lengths(j-1)=length(b{j,2});
end
time_lengths=zeros(length(c)-1,1);
for j=2:length(c)
    time_lengths(j-1)=length(c{j,2});
end

for i=1:length(person_cmp)
    person_cmp{i}.wordlength_L=0; person_cmp{i}.wordlength_R=0;
    person_cmp{i}.Closer_wordlength=nominal(); person_cmp{i}.Farther_wordlength=nominal();
    for j=1:length(person_cmp{i})
        person_cmp{i}.wordlength_L(j)=person_lengths{i}(person_cmp{i}.indexL(j)+1);
        person_cmp{i}.wordlength_R(j)=person_lengths{i}(person_cmp{i}.indexR(j)+1);
        if person_cmp{i}.CloserStimulusUser(j)=='Left'
            person_cmp{i}.Closer_wordlength(j) = num2str(person_cmp{i}.wordlength_L(j));
            person_cmp{i}.Farther_wordlength(j) = num2str(person_cmp{i}.wordlength_R(j));
        elseif person_cmp{i}.CloserStimulusUser(j)=='Right'
            person_cmp{i}.Closer_wordlength(j) = num2str(person_cmp{i}.wordlength_R(j));
            person_cmp{i}.Farther_wordlength(j) = num2str(person_cmp{i}.wordlength_L(j));
        else
            person_cmp{i}.Closer_wordlength(j) = 'equal_dist';
            person_cmp{i}.Farther_wordlength(j) = 'equal_dist';
        end
    end
end
for i=1:length(person_est)
    person_est{i}.wordlength=0;
    for j=1:length(person_est{i})
        person_est{i}.wordlength(j)=person_lengths{i}(person_est{i}.indexPic(j)+1);
    end
end

for i=1:length(place_cmp)
    place_cmp{i}.wordlength_L=0; place_cmp{i}.wordlength_R=0;
    place_cmp{i}.Closer_wordlength=nominal(); place_cmp{i}.Farther_wordlength=nominal();
    for j=1:length(place_cmp{i})
        place_cmp{i}.wordlength_L(j)=place_lengths(place_cmp{i}.indexL(j)+1);
        place_cmp{i}.wordlength_R(j)=place_lengths(place_cmp{i}.indexR(j)+1);
        if place_cmp{i}.CloserStimulusUser(j)=='Left'
            place_cmp{i}.Closer_wordlength(j) = num2str(place_cmp{i}.wordlength_L(j));
            place_cmp{i}.Farther_wordlength(j) = num2str(place_cmp{i}.wordlength_R(j));
        elseif place_cmp{i}.CloserStimulusUser(j)=='Right'
            place_cmp{i}.Closer_wordlength(j) = num2str(place_cmp{i}.wordlength_R(j));
            place_cmp{i}.Farther_wordlength(j) = num2str(place_cmp{i}.wordlength_L(j));
        else
            place_cmp{i}.Closer_wordlength(j) = 'equal_dist';
            place_cmp{i}.Farther_wordlength(j) = 'equal_dist';
        end
    end
end
for i=1:length(place_est)
    place_est{i}.wordlength=0;
    for j=1:length(place_est{i})
        place_est{i}.wordlength(j)=place_lengths(place_est{i}.indexPic(j)+1);
    end
end

for i=1:length(time_cmp)
    time_cmp{i}.wordlength_L=0; time_cmp{i}.wordlength_R=0;
    time_cmp{i}.Closer_wordlength=nominal(); time_cmp{i}.Farther_wordlength=nominal();
    for j=1:length(time_cmp{i})
        time_cmp{i}.wordlength_L(j)=time_lengths(time_cmp{i}.indexL(j)+1);
        time_cmp{i}.wordlength_R(j)=time_lengths(time_cmp{i}.indexR(j)+1);
        if time_cmp{i}.CloserStimulusUser(j)=='Left'
            time_cmp{i}.Closer_wordlength(j) = num2str(time_cmp{i}.wordlength_L(j));
            time_cmp{i}.Farther_wordlength(j) = num2str(time_cmp{i}.wordlength_R(j));
        elseif time_cmp{i}.CloserStimulusUser(j)=='Right'
            time_cmp{i}.Closer_wordlength(j) = num2str(time_cmp{i}.wordlength_R(j));
            time_cmp{i}.Farther_wordlength(j) = num2str(time_cmp{i}.wordlength_L(j));
        else
            time_cmp{i}.Closer_wordlength(j) = 'equal_dist';
            time_cmp{i}.Farther_wordlength(j) = 'equal_dist';
        end
    end
end
for i=1:length(time_est)
    time_est{i}.wordlength=0;
    for j=1:length(time_est{i})
        time_est{i}.wordlength(j)=time_lengths(time_est{i}.indexPic(j)+1);
    end
end


% adding participants' ages
ages=[30,29,28,27,31,27,32,32,32];
for i=1:length(ages)
    person_est{i}.age=0; person_est{i}.age(1:length(person_est{i}))=ages(i);
    place_est{i}.age=0; place_est{i}.age(1:length(place_est{i}))=ages(i);
    time_est{i}.age=0; time_est{i}.age(1:length(time_est{i}))=ages(i);
    place_cmp{i}.age=0; place_cmp{i}.age(1:length(place_cmp{i}))=ages(i);
    person_cmp{i}.age=0; person_cmp{i}.age(1:length(person_cmp{i}))=ages(i);
    time_cmp{i}.age=0; time_cmp{i}.age(1:length(time_cmp{i}))=ages(i);
end


% computing relative past / future for each stimulus
for i=1:length(time_cmp)
    time_cmp{i}.user_year_from_age_L=0; time_cmp{i}.user_year_from_age_R=0;
    time_cmp{i}.relative_future_L=0; time_cmp{i}.relative_future_R=0;
    time_cmp{i}.Closer_relative_future=nominal(); time_cmp{i}.Farther_relative_future=nominal();
    time_cmp{i}.same_absolute_future=0; time_cmp{i}.same_relative_future=0;
    for j=1:length(time_cmp{i})
        time_cmp{i}.user_year_from_age_L(j)=2012-time_cmp{i}.age(j)+time_cmp{i}.questionnaire_field8_L(j);
        time_cmp{i}.user_year_from_age_R(j)=2012-time_cmp{i}.age(j)+time_cmp{i}.questionnaire_field8_R(j);
        if time_cmp{i}.user_year_from_age_L(j)>time_cmp{i}.condition(j)
            time_cmp{i}.relative_future_L(j)=1;
        else
            time_cmp{i}.relative_future_L(j)=-1;
        end
        if time_cmp{i}.user_year_from_age_R(j)>time_cmp{i}.condition(j)
            time_cmp{i}.relative_future_R(j)=1;
        else
            time_cmp{i}.relative_future_R(j)=-1;
        end
        if time_cmp{i}.CloserStimulusUser(j)=='Left'
            time_cmp{i}.Closer_relative_future(j) = num2str(time_cmp{i}.relative_future_L(j));
            time_cmp{i}.Farther_relative_future(j) = num2str(time_cmp{i}.relative_future_R(j));
        elseif time_cmp{i}.CloserStimulusUser(j)=='Right'
            time_cmp{i}.Closer_relative_future(j) = num2str(time_cmp{i}.relative_future_R(j));
            time_cmp{i}.Farther_relative_future(j) = num2str(time_cmp{i}.relative_future_L(j));
        else
            time_cmp{i}.Closer_relative_future(j) = 'equal_dist';
            time_cmp{i}.Farther_relative_future(j) = 'equal_dist';
        end
        if time_cmp{i}.questionnaire_field7_L(j)==time_cmp{i}.questionnaire_field7_R(j)
            time_cmp{i}.same_absolute_future(j)=1;
        else
            time_cmp{i}.same_absolute_future(j)=0;
        end
        if time_cmp{i}.relative_future_L(j)==time_cmp{i}.relative_future_R(j)
            time_cmp{i}.same_relative_future(j)=1;
        else
            time_cmp{i}.same_relative_future(j)=0;
        end
    end
end
for i=1:length(time_est)
    time_est{i}.user_year_from_age=0; time_est{i}.relative_future=0; 
    for j=1:length(time_est{i})
        time_est{i}.user_year_from_age(j)=2012-time_est{i}.age(j)+time_est{i}.questionnaire_field8(j);
        if time_est{i}.user_year_from_age(j)>time_est{i}.condition(j)
            time_est{i}.relative_future(j)=1;
        else
            time_est{i}.relative_future(j)=-1;
        end
    end
end

