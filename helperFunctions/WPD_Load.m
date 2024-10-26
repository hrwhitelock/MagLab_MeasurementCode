% Ian Leahy
% August 29, 2019
% Import webplot digitizer results:

function [x,y] = WPD_Load(filename)

temp = csvread(filename);
x = temp(:,1); 
y = temp(:,2);

end