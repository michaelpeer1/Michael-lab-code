function [thresh, r] = find_func_threshold_sami(func_images)
% [thresh,r] = find_func_threshold(func_images)
%
% This function receives a 4d-matrix of functional images, fits a
% two normal distibutions to the histogram of mean intensities,
% and gives a lower threshold and goodness of fit using r-value.
% This is later used to threshold the image and avoid using voxels 
% with signal dropout

    % Discard voxels under cutoff intensity value
    cutoff = 25;
    
    % Graph scale, depends on number of voxels per intensity
    scale = 10000;

    % First iteration parameters
    %           Mu1; s1;Mu2;s2;
    start_args = [0;100;600;200;];
    
    fi_mean_array(1,:,:,:) = mean(func_images,4);

    [nelements,xcenters] = hist(fi_mean_array(fi_mean_array>cutoff),100);
    
    y = nelements';
    t = xcenters';
    
    fig = figure(1);
    plot(t,y,'ro'); hold on; h = plot(t,y,'b'); hold off;
    title('Input data'); ylim([0 scale])

    outputFcn = @(x,optimvalues,state) fitoutputfun3(x,optimvalues,state,t,y,h);
    options = optimset('OutputFcn',outputFcn,'TolX',0.05);
    estimated_args = fminsearch(@(x)fitfun3(x,t,y),start_args,options);

    % Calculate estimated function
    A = zeros(length(t),4);

    A(:,1) = normpdf(t,estimated_args(1),estimated_args(2));
    A(:,2) = normpdf(t,estimated_args(3),estimated_args(4));
    A(:,3) = t;
    A(:,4) = 1;

    c = A\y;
    z = A*c;
    
% Result values:
%     Mu1 estimated_args(1);
%     S1 = estimated_args(2);
%     Mu2 = estimated_args(3);
%     S2 = estimated_args(4);
%     r-value of fit = corr(y,z);
    
    % 3.s.d left to mean of second signal distribution
     thresh = estimated_args(3)-estimated_args(4)*3;
    
    % 3.s.d right to mean of first signal distribution
    % thresh = estimated_args(1)+estimated_args(2)*3;
    
    r = corr(y,z);
    
end
