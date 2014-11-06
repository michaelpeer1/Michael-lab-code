function rp_new_filename = additional_movement_regressors(rp_filename, add_detrend_regressor)
% rp_new_filename = additional_movement_regressors(rp_filename, add_detrend_regressor)
%
% Receives the movement parameters of a subject (rp_*.txt inside
% RealignParameter directory) - 6 head motion parameters.
%
% Calculates the Friston-24 model - the regressors, their previous time
% point, and the quadratives - 24 parameters overall.
% In addition, calculates spike-specific regressors.
%
% If add_detrend_regressor is one, adds a straight line regressor
%
% most of the code was taken from DPARSFA - data-processing
% assistant for resting-state fMRI analysis.

rp_old=dlmread(rp_filename);

% calculate the derivatives and quadratics
rp_derivatives= [zeros(1,size(rp_old,2));rp_old(1:end-1,:)];
rp_new=[rp_old, rp_derivatives, rp_old.^2, rp_derivatives.^2];

% % calculate  FD Power
% RPDiff=diff(rp_old);    % the difference between each timepoint and the next
% RPDiff=[zeros(1,6);RPDiff];
% RPDiffSphere=RPDiff;
% RPDiffSphere(:,4:6)=RPDiffSphere(:,4:6)*50;
% FD_Power=sum(abs(RPDiffSphere),2);
% % calculate spike regressors
% BadTimePointsIndex=find(FD_Power>0.5);
% BadTimePointsRegressor = zeros(length(FD_Power),length(BadTimePointsIndex));
% for i = 1:length(BadTimePointsIndex)
%     BadTimePointsRegressor(BadTimePointsIndex(i),i) = 1;
% end
% rp_new=[rp_new, BadTimePointsRegressor];

% add detrending regressor
if add_detrend_regressor
    rp_new=[rp_new, (1:size(rp_old,1))'];
end

[a,b,c]=fileparts(rp_filename);
rp_new_filename=[a '\new_' b c];
dlmwrite(rp_new_filename, rp_new,' ');

