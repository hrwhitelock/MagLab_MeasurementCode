% Ian Leahy
% 2/25/19
% Function to plot temperature profile for furnace run.
% Input in Celcius, plot in K or C. 
% Setpoints
% Dwell time in hours
% Ramp rates in C/hr. 

function []=FurnaceRun(Setpoints,Dwell,RampRates,KorC)

PlotPointsT = [];
for i=1:length(Setpoints)
    PlotPointsT=[PlotPointsT,Setpoints(i),Setpoints(i)];
end

RampTimes = abs(diff(PlotPointsT))./RampRates; 
DwellTimes = [];
for i=1:length(Setpoints)
    DwellTimes=[DwellTimes,0,Dwell(i)];
end

tvec = DwellTimes(2:end)+RampTimes; TimePoints = [0];
for i=2:length(tvec)
TimePoints(i)=TimePoints(i-1)+tvec(i);
end

if strcmp(KorC,'C')
    scale = 0;
    xstr = 'C';
elseif strcmp(KorC,'K')
   scale = 273.15;  
   xstr = 'K';
end

figure; hold on; plot(TimePoints,PlotPointsT(2:end)+scale,...
    '-or','MarkerSize',10,'MarkerFaceColor',brc([1,0,0],.5));
Label_Plot('Time','hr','T',xstr);
title(['Cook Time: ',num2str(max(TimePoints)),' hrs']);

end