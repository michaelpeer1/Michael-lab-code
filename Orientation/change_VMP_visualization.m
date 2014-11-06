%% changing VMP visualization

% CREATE VMP FILES BY OPENING THE CONTRAST FILE IN BV, CHOOSING OPTIONS,
% AND CHOOSING CREATE MAPS, AND THEN CTRL+M AND SAVE AS
% (save with '_domains.vmp' ending)


subjects_output_dir = 'F:\Subjects_MRI_data\7T\Analysis_BV_Matlab\';
subject_names=dir(subjects_output_dir); subject_names=subject_names(3:end);


% changing colors and parameters of the domains VMP contrasts, and creating conjunction contrasts
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    vmp_files=[getfullfiles(fullfile(output_dir,'*_domains.vmp')) getfullfiles(fullfile(ACPC_output_dir,'*_domains.vmp'))];
    for i=1:length(vmp_files)
        vmp=xff(vmp_files{i});
        for j=1:length(vmp.Map)
            vmp.Map(j).UseRGBColor = 1;
        end
        vmp.Map(1).RGBLowerThreshPos = [255 0    0  ];        vmp.Map(1).RGBUpperThreshPos = [255 85  0  ]; vmp.Map(1).Name = 'person vs others';
        vmp.Map(2).RGBLowerThreshPos = [0   0    255];        vmp.Map(2).RGBUpperThreshPos = [0   255  255]; vmp.Map(2).Name = 'place vs others';
        vmp.Map(3).RGBLowerThreshPos = [0   170  0  ];        vmp.Map(3).RGBUpperThreshPos = [170 255  0  ]; vmp.Map(3).Name = 'time vs others';
        if length(vmp.Map)>3
            vmp.Map(4).RGBLowerThreshPos = [255 0    0  ];            vmp.Map(4).RGBUpperThreshPos = [255 85  0  ]; vmp.Map(4).Name = 'person vs control';
            vmp.Map(5).RGBLowerThreshPos = [0   0    255];            vmp.Map(5).RGBUpperThreshPos = [0   255  255]; vmp.Map(5).Name = 'place vs control';
            vmp.Map(6).RGBLowerThreshPos = [0   170  0  ];            vmp.Map(6).RGBUpperThreshPos = [170 255  0  ]; vmp.Map(6).Name = 'time vs control';
        end
        if length(vmp.Map)>8
            vmp.Map(7).Name = 'person vs rest'; vmp.Map(8).Name = 'place vs rest'; vmp.Map(9).Name = 'time vs rest'; vmp.Map(10).Name = 'control vs rest';
            vmp.Map(11).Name = 'person vs place'; vmp.Map(12).Name = 'person vs time'; vmp.Map(13).Name = 'place vs person'; 
            vmp.Map(14).Name = 'place vs time'; vmp.Map(15).Name = 'time vs person'; vmp.Map(16).Name = 'time vs place'; 
            vmp.Map(7).RGBLowerThreshPos = [255 0    0  ]; vmp.Map(7).RGBUpperThreshPos = [255 85  0  ]; 
            vmp.Map(8).RGBLowerThreshPos = [0   0    255]; vmp.Map(8).RGBUpperThreshPos = [0   255  255];
            vmp.Map(9).RGBLowerThreshPos = [0   170  0  ]; vmp.Map(9).RGBUpperThreshPos = [170 255  0  ];
            vmp.Map(10).RGBLowerThreshPos = [170 0    255  ]; vmp.Map(10).RGBUpperThreshPos = [170 85  256  ];
            vmp.Map(11).RGBLowerThreshPos = [255 0    0  ]; vmp.Map(11).RGBUpperThreshPos = [255 85  0  ]; 
            vmp.Map(12).RGBLowerThreshPos = [255 0    0  ]; vmp.Map(12).RGBUpperThreshPos = [255 85  0  ];
            vmp.Map(13).RGBLowerThreshPos = [0   0    255]; vmp.Map(13).RGBUpperThreshPos = [0   255  255];
            vmp.Map(14).RGBLowerThreshPos = [0   0    255]; vmp.Map(14).RGBUpperThreshPos = [0   255  255];
            vmp.Map(15).RGBLowerThreshPos = [0   170  0  ]; vmp.Map(15).RGBUpperThreshPos = [170 255  0  ];
            vmp.Map(16).RGBLowerThreshPos = [0   170  0  ]; vmp.Map(16).RGBUpperThreshPos = [170 255  0  ];

            
            vmp.Map(17:length(vmp.Map))=[];
            
            % creating a conjunction of domains vs rest
            mapnum=17;
            % mapnum=length(vmp.Map)+1;
            vmp.Map(mapnum) = vmp.Map(7);
            vmp.Map(mapnum).Name = 'conjunction - domains vs rest';
            vmp.Map(mapnum).VMPData = conjval(vmp.Map(7).VMPData, vmp.Map(8).VMPData);
            vmp.Map(mapnum).VMPData = conjval(vmp.Map(mapnum).VMPData, vmp.Map(9).VMPData);
            vmp.Map(mapnum).RGBLowerThreshPos = [100   0  100  ];             vmp.Map(mapnum).RGBUpperThreshPos = [255   0  255  ];
            
            % creating conjunctions of domains vs others with domains vs rest
            mapnum=18;
            % mapnum=length(vmp.Map)+1;
            vmp.Map(mapnum) = vmp.Map(1); vmp.Map(mapnum+1) = vmp.Map(2); vmp.Map(mapnum+2) = vmp.Map(3);
            vmp.Map(mapnum).Name = 'conjunction - person vs others and above rest';
            vmp.Map(mapnum).VMPData = conjval(vmp.Map(1).VMPData, vmp.Map(7).VMPData);
            vmp.Map(mapnum).RGBLowerThreshPos = [255 0    0  ];         vmp.Map(mapnum).RGBUpperThreshPos = [255 85  0  ];
            vmp.Map(mapnum+1).Name = 'conjunction - place vs others and above rest';
            vmp.Map(mapnum+1).VMPData = conjval(vmp.Map(2).VMPData, vmp.Map(8).VMPData);
            vmp.Map(mapnum+1).RGBLowerThreshPos = [0   0    255];        vmp.Map(mapnum+1).RGBUpperThreshPos = [0   255  255];
            vmp.Map(mapnum+2).Name = 'conjunction - time vs others and above rest';
            vmp.Map(mapnum+2).VMPData = conjval(vmp.Map(3).VMPData, vmp.Map(9).VMPData);
            vmp.Map(mapnum+2).RGBLowerThreshPos = [0   170  0  ];        vmp.Map(mapnum+2).RGBUpperThreshPos = [170 255  0  ];

%             % creating conjunctions of pairs of domains vs the remaining one with domains vs rest
%             mapnum=21;
%             % mapnum=length(vmp.Map)+1;
%             vmp.Map(mapnum) = vmp.Map(12); vmp.Map(mapnum+1) = vmp.Map(11); vmp.Map(mapnum+2) = vmp.Map(13);
%             vmp.Map(mapnum).Name = 'conjunction - person and place vs time and above rest';
%             vmp.Map(mapnum).VMPData = conjval(vmp.Map(12).VMPData, vmp.Map(14).VMPData);
%             vmp.Map(mapnum).VMPData = conjval(vmp.Map(mapnum).VMPData, vmp.Map(7).VMPData);
%             vmp.Map(mapnum).VMPData = conjval(vmp.Map(mapnum).VMPData, vmp.Map(8).VMPData);
%             vmp.Map(mapnum).RGBLowerThreshPos = [170 0    255  ];         vmp.Map(mapnum).RGBUpperThreshPos = [170 85  255  ];
%             vmp.Map(mapnum+1).Name = 'conjunction - person and time vs place and above rest';
%             vmp.Map(mapnum+1).VMPData = conjval(vmp.Map(11).VMPData, vmp.Map(16).VMPData);
%             vmp.Map(mapnum+1).VMPData = conjval(vmp.Map(mapnum+1).VMPData, vmp.Map(7).VMPData);
%             vmp.Map(mapnum+1).VMPData = conjval(vmp.Map(mapnum+1).VMPData, vmp.Map(9).VMPData);
%             vmp.Map(mapnum+1).RGBLowerThreshPos = [255   255    0];        vmp.Map(mapnum+1).RGBUpperThreshPos = [255   255  125];
%             vmp.Map(mapnum+2).Name = 'conjunction - place and time vs person and above rest';
%             vmp.Map(mapnum+2).VMPData = conjval(vmp.Map(13).VMPData, vmp.Map(15).VMPData);
%             vmp.Map(mapnum+2).VMPData = conjval(vmp.Map(mapnum+2).VMPData, vmp.Map(8).VMPData);
%             vmp.Map(mapnum+2).VMPData = conjval(vmp.Map(mapnum+2).VMPData, vmp.Map(9).VMPData);
%             vmp.Map(mapnum+2).RGBLowerThreshPos = [170   0    0  ];        vmp.Map(mapnum+2).RGBUpperThreshPos = [170   0    125];

%             % creating conjunctions of domains vs control
%             mapnum=24;
%             % mapnum=length(vmp.Map)+1;
%             vmp.Map(mapnum) = vmp.Map(4); vmp.Map(mapnum+1) = vmp.Map(4); vmp.Map(mapnum+2) = vmp.Map(4); vmp.Map(mapnum+3) = vmp.Map(5);
%             vmp.Map(mapnum).Name = 'conjunction - domains vs. control';
%             vmp.Map(mapnum).VMPData = conjval(vmp.Map(4).VMPData, vmp.Map(5).VMPData);
%             vmp.Map(mapnum).VMPData = conjval(vmp.Map(mapnum).VMPData, vmp.Map(6).VMPData);
%             vmp.Map(mapnum+1).Name = 'conjunction - person and place vs control';
%             vmp.Map(mapnum+1).VMPData = conjval(vmp.Map(4).VMPData, vmp.Map(5).VMPData);
%             vmp.Map(mapnum+2).Name = 'conjunction - person and time vs control';
%             vmp.Map(mapnum+2).VMPData = conjval(vmp.Map(4).VMPData, vmp.Map(6).VMPData);
%             vmp.Map(mapnum+3).Name = 'conjunction - place and time vs control';
%             vmp.Map(mapnum+3).VMPData = conjval(vmp.Map(5).VMPData, vmp.Map(6).VMPData);
            
            % creating conjunctions of domains vs control with domains vs rest
            mapnum=21;
            % mapnum=length(vmp.Map)+1;
            vmp.Map(mapnum) = vmp.Map(4); vmp.Map(mapnum+1) = vmp.Map(5); vmp.Map(mapnum+2) = vmp.Map(6);
            vmp.Map(mapnum).Name = 'conjunction - person vs control and above rest';
            vmp.Map(mapnum).VMPData = conjval(vmp.Map(4).VMPData, vmp.Map(7).VMPData);
            vmp.Map(mapnum).RGBLowerThreshPos = [255 0    0  ];         vmp.Map(mapnum).RGBUpperThreshPos = [255 85  0  ];
            vmp.Map(mapnum+1).Name = 'conjunction - place vs control and above rest';
            vmp.Map(mapnum+1).VMPData = conjval(vmp.Map(5).VMPData, vmp.Map(8).VMPData);
            vmp.Map(mapnum+1).RGBLowerThreshPos = [0   0    255];        vmp.Map(mapnum+1).RGBUpperThreshPos = [0   255  255];
            vmp.Map(mapnum+2).Name = 'conjunction - time vs control and above rest';
            vmp.Map(mapnum+2).VMPData = conjval(vmp.Map(6).VMPData, vmp.Map(9).VMPData);
            vmp.Map(mapnum+2).RGBLowerThreshPos = [0   170  0  ];        vmp.Map(mapnum+2).RGBUpperThreshPos = [170 255  0  ];

            % creating overlap maps
            pe=vmp.Map(21).VMPData > vmp.Map(21).FDRThresholds(2,2);
            pl=vmp.Map(22).VMPData > vmp.Map(22).FDRThresholds(2,2);
            ti=vmp.Map(23).VMPData > vmp.Map(23).FDRThresholds(2,2);
            mapnum=24;
            for j=1:7
                vmp.Map(mapnum+j-1) = vmp.Map(21);
                vmp.Map(mapnum+j-1).LowerThreshold=0.5;
            end
            vmp.Map(mapnum).Name = 'overlap - person-place-time';
            vmp.Map(mapnum).VMPData = pe & pl & ti;
            vmp.Map(mapnum).RGBLowerThreshPos = [255   255  255  ];             vmp.Map(mapnum).RGBUpperThreshPos = [255   255  255  ];
            vmp.Map(mapnum+1).Name = 'overlap - person-place';
            vmp.Map(mapnum+1).VMPData = pe & pl & ~ti;
            vmp.Map(mapnum+1).RGBLowerThreshPos = [170 0    255  ];         vmp.Map(mapnum+1).RGBUpperThreshPos = [170 0    255  ];
            vmp.Map(mapnum+2).Name = 'overlap - person-time';
            vmp.Map(mapnum+2).VMPData = pe & ~pl & ti;
            vmp.Map(mapnum+2).RGBLowerThreshPos = [255   170    0];        vmp.Map(mapnum+2).RGBUpperThreshPos = [255   170    0];
            vmp.Map(mapnum+3).Name = 'overlap - place-time';
            vmp.Map(mapnum+3).VMPData = ~pe & pl & ti;
            vmp.Map(mapnum+3).RGBLowerThreshPos = [255   255    0  ];        vmp.Map(mapnum+3).RGBUpperThreshPos = [255   255    0];
            vmp.Map(mapnum+4).Name = 'overlap - person only';
            vmp.Map(mapnum+4).VMPData = pe & ~pl & ~ti;
            vmp.Map(mapnum+4).RGBLowerThreshPos = [255 0    0  ];         vmp.Map(mapnum+4).RGBUpperThreshPos = [255 0  0  ];
            vmp.Map(mapnum+5).Name = 'overlap - place only';
            vmp.Map(mapnum+5).VMPData = ~pe & pl & ~ti;
            vmp.Map(mapnum+5).RGBLowerThreshPos = [0   0    255  ];         vmp.Map(mapnum+5).RGBUpperThreshPos = [0   0    255  ];
            vmp.Map(mapnum+6).Name = 'overlap - time only';
            vmp.Map(mapnum+6).VMPData = ~pe & ~pl & ti;
            vmp.Map(mapnum+6).RGBLowerThreshPos = [0   170  0  ];         vmp.Map(mapnum+6).RGBUpperThreshPos = [0   170  0  ];

            
        end
        
        for j=1:length(vmp.Map)
            vmp.Map(j).ClusterSize = 20;
            vmp.Map(j).EnableClusterCheck = 1;
            vmp.Map(j).ShowPositiveNegativeFlag = 1;
        end
        
        vmp.SaveAs(vmp_files{i});
        vmp.ClearObject;
    end
end


%% distances VMPs

% changing colors and parameters of the distances VMP contrasts
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    vmp_files=[getfullfiles(fullfile(output_dir,'*_distances.vmp')) getfullfiles(fullfile(ACPC_output_dir,'*_distances.vmp'))];
    for i=1:length(vmp_files)
        vmp=xff(vmp_files{i});
        
        vmp.Map(1).Name = 'person close vs. far (12 vs. 56)';
        vmp.Map(2).Name = 'place close vs. far (12 vs. 56)';
        vmp.Map(3).Name = 'time close vs. far (12 vs. 56)';
        vmp.Map(4).Name = 'all domains close vs. far (12 vs. 56)';
        vmp.Map(5).Name = 'person and place close vs. far (12 vs. 56)';
        vmp.Map(6).Name = 'person and time close vs. far (12 vs. 56)'; 
        vmp.Map(7).Name = 'place and time close vs. far (12 vs. 56)';
        vmp.Map(8).Name = 'person close vs. far descending';
        vmp.Map(9).Name = 'place close vs. far descending';
        vmp.Map(10).Name = 'time close vs. far descending';
        
        vmp.SaveAs(vmp_files{i});
    end
end

% changing colors and parameters of the distances VMP contrasts in specific domains
for s=1:length(subject_names)
    subj=subject_names(s).name;
    disp(subj);
    output_dir=fullfile(subjects_output_dir, subj);
    ACPC_output_dir=[output_dir '\ACPC'];
    vmp_files=[getfullfiles(fullfile(output_dir,'*_distances_*.vmp')) getfullfiles(fullfile(ACPC_output_dir,'*_distances_*.vmp'))];
    for i=1:length(vmp_files)
        vmp=xff(vmp_files{i});
        
        for j=1:length(vmp.Map)
            vmp.Map(j).UseRGBColor = 1;
            vmp.Map(j).ShowPositiveNegativeFlag = 1;
        end
        
        vmp.SaveAs(vmp_files{i});
        vmp.ClearObject;
    end
end



