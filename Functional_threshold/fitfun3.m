function err = fitfun3(args,t,y)
% v1.0
% Sami Abboud
%FITFUN3 based on FITFUN Used by FITDEMO.
%
%   FITFUN
%   Copyright 1984-2004 The MathWorks, Ic.
%   $Revision: 5.8.4.1 $  $Date: 2004/11/29 23:30:50 $

A = zeros(length(t),4);

A(:,1) = normpdf(t,args(1),args(2));
A(:,2) = normpdf(t,args(3),args(4));
A(:,3) = t;
A(:,4) = 1;

c = A\y;
z = A*c;

err = norm(z-y);