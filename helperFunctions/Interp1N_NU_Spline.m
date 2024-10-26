function [yi] = Interp1N_NU_Spline(x,y,xi)
%does 1d interpolation with interp1 for nonunique vector x
%Ben Chapman 9/25/12

[junk uniqueindices] = ismember(unique(x),x); %uniqueindices are the indices of x which index unique values in x
yi = interp1(x(uniqueindices),y(uniqueindices),xi,'spline');

end

