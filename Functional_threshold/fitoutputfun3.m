function stop = fitoutputfun3(args,optimvalues, state,t,y,handle)
% v1.0
% Sami Abboud

% fitoutputfun3 based on FITOUTPUT Output function used by FITDEMO
%
%   FITOUTPUT
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/11/29 23:30:51 $

stop = false;
% Obtain new values of fitted function at 't'
A = zeros(length(t),4);

A(:,1) = normpdf(t,args(1),args(2));
A(:,2) = normpdf(t,args(3),args(4));
A(:,3) = t;
A(:,4) = 1;

c = A\y;
z = A*c;

switch state
    case 'init'
        set(handle,'ydata',z)
        drawnow
        title('Input data and fitted function');
    case 'iter'
        set(handle,'ydata',z)
        drawnow
    case 'done'
        hold off;
end
pause(.04)