%IanLeahy
%Sweep Frequencies

function fatcell=TempSweep_HC(filename,freqs,amp,CernoxCurrent,numpoints,CernoxCal,Temps)

BathCal=load('C:\Data\IanL\JixiaDS_CX_67573_ON_62232\JixiaBathCXCal1');
BathCal=BathCal.JixiaBathCX;
% CernoxCal=load('C:\Data\IanL\Cernox0010C_Cal\CernoxCCal1');
% CernoxCal=CernoxCal.CXC_CalCurv1;


if exist([filename '.mat'],'file') == 2
    disp('This filename already exists.  Pick a different name!'); beep; return
end

srs830gpib=9;
% K2400SMBath=24;
K2400Cernox=24;
% K2400SMB=OpenGPIBObject(K2400SMBath);
K2400CX=OpenGPIBObject(K2400Cernox);
srs830=OpenGPIBObject(srs830gpib);

setup2400_Obj(K2400CX);
% Keithley2400SetCurrent(K2400CX,CernoxCurrent);
% Keithley2400SourceControl(K2400CX,1);

h2=figure; 
for i=1:length(freqs)
    srs830=OpenGPIBObject(srs830gpib);
    set_Lakeshore331_NoPID(Temps(i),2);
    [sensitivity,timeconstant]=getsrs830_Obj(srs830);
setsrs830_Obj(srs830,freqs(i),amp,1,0,0,1,13,...
    sensitivity,timeconstant); 
pause(150);
    fatcell{i}.data=FreqCheckNoSave(K2400CX,srs830,CernoxCurrent,numpoints,amp,freqs(i),BathCal,CernoxCal);
    Voltmean(i)=mean(fatcell{i}.data.Rval);
    figure(h2);
    plot(BathCal(Temps(1:i)),freqs(1:i)'.*Voltmean,'-o','Linewidth',3); xlabel('\omega');ylabel('\omega * T');grid on;drawnow; 
    save(filename,'fatcell');
end

save(filename,'fatcell');

end