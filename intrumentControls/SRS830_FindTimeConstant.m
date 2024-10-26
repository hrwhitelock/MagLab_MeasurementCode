% Ian Leahy
% 5/2/2022
% Find Appropriate Time Constant for SRS830 lockin based off of an input
% frequency. 

function Tau = SRS830_FindTimeConstant(MeasurementFrequency)

TauList = [10e-6,30e-6,100e-6,300e-6,1e-3,3e-3,10e-3,30e-3,100e-3,...
300e-3,1,3,10,30,100,300,1e3,3e3,10e3,30e3];
MachineTauValues = 0:1:(length(TauList)-1);

Tau = MachineTauValues(find(10./MeasurementFrequency<=TauList,1)); 
end