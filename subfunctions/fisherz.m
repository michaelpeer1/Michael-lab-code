function z_vector=fisherz(r_vector)
% z_vector=fisherz(r_vector)
%
% does the fisher r-to-z transform for correlation coefficients

z_vector=0.5*log((1+r_vector)./(1-r_vector));
