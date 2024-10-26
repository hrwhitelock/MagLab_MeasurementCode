% Blake Lee
% September 26, 2022
% My Attempt at modifying Ian's program

function [setSensIndex] = SRS830_MODfindOptimalSens(obj830)
%Finds optimal sensitivity at for measurement 
sensitivities = [5e-9,10e-9,20e-9,50e-9,100e-9,200e-9,500e-9,1e-6,2e-6,5e-6,10e-6,20e-6,...
    50e-6,100e-6,200e-6,500e-6,1e-3,2e-3,5e-3,10e-3,20e-3,50e-3,100e-3,200e-3,500e-3, 1]; %Array of possible LI sensitivity values

[XData,YData] = ReadSRS830_XY(obj830);
Rval = sqrt(XData.^2+YData.^2); 
[~,I] = min(abs(sensitivities - Rval*5/2));
if Rval/sensitivities(I) > 0.4
    if I ~= length(sensitivities)
        I = I + 1;
    end
end
Rval
sensitivities(I)
setSensIndex = I;
end
