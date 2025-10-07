function [tau, tau_u, amp_u, off_u, tau_d, amp_d, off_d] = VacCellTimeConst(file,plotYN)


d = load(file);

loopnum=floor(length(d.HeaterRes)./d.PulseWidth);
pw=d.PulseWidth;
ft = fittype( 'a*exp(-x./b)+c', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [-.00016 .63 .000161];
opts.Lower = [-1 0 -1];
opts.Upper = [1 9999 1];
opts.TolFun = 1e-8;
%opts.StartPoint = [-.16 1/1.4 0.16];
q=1;
if plotYN
    figure; hold on;
end
xdatcumUp = [];
ydatcumUp = [];
for j=2:2:loopnum
    xdat=d.time((1+(pw*(j-1))):(j*pw))-d.time((1+(pw*(j-1))));
    ydat=d.TC_Volt((1+(pw*(j-1))):(j*pw));
    xdatcumUp = [xdatcumUp xdat];
    ydatcumUp = [ydatcumUp ydat];
    if plotYN
    plot(xdat,ydat,'sq')
    end
    [xData, yData] = prepareCurveData( xdat, ydat );
    [fitresult, gof] = fit( xData, yData, ft, opts );
    tempcoeffs=coeffvalues(fitresult);
    Scales(q)=tempcoeffs(1);
    TimeConstantsUp(q)=tempcoeffs(2);
    %OffsetValues(q)=tempcoeffs(3);
    rsqval(q)=gof.rsquare;
%    TemperatureUp(q)=mean(d.BathTemp((1+(pw*(j-1))):(j*pw)));
    q=q+1;
    %plot(fitresult,'-')

end
meanvalUp=num2str(mean(TimeConstantsUp),'%.2f');
stddevvalUp=num2str(std(TimeConstantsUp),'%.2f');
[xData, yData] = prepareCurveData( xdatcumUp, ydatcumUp );
[fitresult, gof] = fit( xData, yData, ft, opts );
tempcoeffs=coeffvalues(fitresult);

tau_u = tempcoeffs(2);
amp_u = tempcoeffs(1);
off_u = tempcoeffs(3);
if plotYN
plot(fitresult,'k--')
end

q=1;
xdatcumDown = [];
ydatcumDown = [];
for j=3:2:loopnum
    xdat=d.time((1+(pw*(j-1))):(j*pw))-d.time((1+(pw*(j-1))));
    ydat=d.TC_Volt((1+(pw*(j-1))):(j*pw));
    xdatcumDown = [xdatcumUp xdat];
    ydatcumDown = [ydatcumUp ydat];
    [xData, yData] = prepareCurveData( xdat, ydat );
    [fitresult, gof] = fit( xData, yData, ft, opts );
    tempcoeffs=coeffvalues(fitresult);
    Scales(q)=tempcoeffs(1);
    TimeConstantsDown(q)=tempcoeffs(2);
    %OffsetValues(q)=tempcoeffs(3);
    rsqval(q)=gof.rsquare;
%    TemperatureDown(q)=mean(d.BathTemp((1+(pw*(j-1))):(j*pw)));
    q=q+1;
end
meanvalDown=num2str(mean(TimeConstantsDown),'%.2f');
stddevvalDown=num2str(std(TimeConstantsDown),'%.2f');
[xData, yData] = prepareCurveData( xdatcumDown, ydatcumDown );
[fitresult, gof] = fit( xData, yData, ft, opts );
tempcoeffs=coeffvalues(fitresult);

tau_d = tempcoeffs(2);
amp_d = tempcoeffs(1);
off_d = tempcoeffs(3);


if plotYN
        figure; hold on
        plot(TimeConstantsUp,'DisplayName',...
            ['Heater On: ',meanvalUp,'s \pm',stddevvalUp,'s'])
        plot(TimeConstantsDown,'DisplayName',...
            ['Heater Off: ',meanvalDown,'s \pm',stddevvalDown,'s'])
        xlabel('Index'); ylabel('Time Constant [s]');
        L = length(TimeConstantsUp);
        plot(1:L,tau_u*ones(L),'r--')
        plot(1:L,tau_d*ones(L),'b--')
        
end



tau = (tau_u+tau_d)/2;

end