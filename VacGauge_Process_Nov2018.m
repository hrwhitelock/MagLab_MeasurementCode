% Ian Leahy
% Feb 8, 2018
% Process vacuum gauge data.

function Mastercell = VacGauge_Process_Nov2018(fileroot,filename,option,newfigure)


Mastercell=VacGauge_Load([filename]);
optionlist={'Skip','Fits'};

combostring='Please select a valid option: \n';
for i=1:length(optionlist)
    combostring=[combostring,'-',optionlist{i},'-\n'];
end
while ~ismember(option,optionlist)
    option=input(sprintf(combostring),'s');
end

if strcmp(newfigure,'New')
    h2=figure; hold on;
    set(h2,'Name',filename,'NumberTitle','off');
end



switch option
    case 'Skip'
        disp('No processing done, exiting...');
    case 'Fits'
        TimeConstantFits(1,Mastercell,'Index');%'Temperature');
end


end

function Mastercell=VacGauge_Load(loadthisfile)
Mastercell{1}= load(loadthisfile);
end

function TimeConstantFits(run,incell,plotopt)

loopnum=floor(length(incell{run}.time)./incell{run}.PulseWidth);%floor(length(incell{run}.BathTemp)./incell{run}.PulseWidth);
pw=incell{run}.PulseWidth;
ft = fittype( 'a*exp(-x./b)+c', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.412849993396933 0.689140873725535 0.17513393978499];
q=1;
for j=2:2:loopnum
    xdat=incell{run}.time((1+(pw*(j-1))):(j*pw))-incell{run}.time((1+(pw*(j-1))));
    ydat=incell{run}.TC_Volt((1+(pw*(j-1))):(j*pw));
    [xData, yData] = prepareCurveData( xdat, ydat );
    [fitresult, gof] = fit( xData, yData, ft, opts );
    tempcoeffs=coeffvalues(fitresult);
    Scales(q)=tempcoeffs(1);
    TimeConstantsUp(q)=tempcoeffs(2);
    OffsetValues(q)=tempcoeffs(3);
    rsqval(q)=gof.rsquare;
    %TemperatureUp(q)=mean(incell{run}.BathTemp((1+(pw*(j-1))):(j*pw)));
    q=q+1;

end
meanvalUp=num2str(mean(TimeConstantsUp),'%.2f');
stddevvalUp=num2str(std(TimeConstantsUp),'%.2f');

q=1;
for j=3:2:loopnum
    xdat=incell{run}.time((1+(pw*(j-1))):(j*pw))-incell{run}.time((1+(pw*(j-1))));
    ydat=incell{run}.TC_Volt((1+(pw*(j-1))):(j*pw));
    [xData, yData] = prepareCurveData( xdat, ydat );
    [fitresult, gof] = fit( xData, yData, ft, opts );
    tempcoeffs=coeffvalues(fitresult);
    Scales(q)=tempcoeffs(1);
    TimeConstantsDown(q)=tempcoeffs(2);
    OffsetValues(q)=tempcoeffs(3);
    rsqval(q)=gof.rsquare;
    %TemperatureDown(q)=mean(incell{run}.BathTemp((1+(pw*(j-1))):(j*pw)));
    q=q+1;
end
meanvalDown=num2str(mean(TimeConstantsDown),'%.2f');
stddevvalDown=num2str(std(TimeConstantsDown),'%.2f');

switch plotopt
    case 'Index'
        plot(TimeConstantsUp,'DisplayName',...
            ['Heater On: ',meanvalUp,'s \pm',stddevvalUp,'s'])
        plot(TimeConstantsDown,'DisplayName',...
            ['Heater Off: ',meanvalDown,'s \pm',stddevvalDown,'s'])
        xlabel('Index'); ylabel('Time Constant [s]');
    case 'Temperature'
        plot(TemperatureUp,TimeConstantsUp,'DisplayName',...
            ['Heater On: ',meanvalUp,'s \pm',stddevvalUp,'s'])
        plot(TemperatureDown,TimeConstantsDown,'DisplayName',...
            ['Heater Off: ',meanvalDown,'s \pm',stddevvalDown,'s'])
        xlabel('Temperature [K]'); ylabel('Time Constant [s]');

    otherwise
        disp('Please select a valid plot parameter.');
end
legend('show');
end
