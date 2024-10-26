% Ian Leahy
% May 2, 2022
% Checks lockin sensitivity, can move up at most one or two ranges, but can
% move down several. Good for when sensitivity is close to correct. 

function [setSensIndex] = SRS830_findOptimalSens(obj830)
%Finds optimal sensitivity at for measurement
sensitivities = [2e-9,5e-9,10e-9,20e-9,50e-9,100e-9,200e-9,500e-9,1e-6,2e-6,5e-6,10e-6,20e-6,...
    50e-6,100e-6,200e-6,500e-6,1e-3,2e-3,5e-3,10e-3,20e-3,50e-3,100e-3,200e-3,500e-3, 1]; %Array of possible LI sensitivity values
[XData,YData] = ReadSRS830_XY(obj830);
Rval = sqrt(XData.^2+YData.^2); 
if Rval <= .75
    setSens = sensitivities(find(sensitivities.*.75 >=Rval,1)); %Optimal sensitivity
else
    setSens = 1;
end
setSensIndex = find(sensitivities==setSens); %Index of sesitivity array corresponding to optimal value
end