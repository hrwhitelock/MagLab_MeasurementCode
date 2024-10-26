function [yi] = Interp1NonUnique(x,y,xi)
% doeas 1d interpolations with interp1 for nonunique vector x
% Ben Chapman 9/25/12

[junk uniqueindices] = ismember(unique(x),x);
% unique idx are idx of x which index unique vals in x
yi = interp1(x(uniqueindices), y(uniqueindices), xi,'linear', 'extrap');
end