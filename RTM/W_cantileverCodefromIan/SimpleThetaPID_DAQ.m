function SimpleThetaPID_DAQ(DAQ)
SR830 = DAQ.SRS830; 
A33210 = DAQ.A33210; 
LS331 = DAQ.LS331; 
F_Res = DAQ.FRes_Guess; 
fprintf(A33210,['FREQ 41000']);
pause(.05);
[~,~]=ReadSRS830_XY(SR830);
[~,~]=ReadSRS830_XY(SR830);
[~,~]=ReadSRS830_XY(SR830);
[X0,Y0]=ReadSRS830_XY(SR830);

SaveFilename = MakeFilename();
% CL1_PID = [1 .0005 0];
% CL5_PID_NoVac = [2.5 .0005 0];
Pv = .4; %.65;
Iv = 0.0008;
Iv = 0; 
Dv = .0000;
Data.F_Res = F_Res;
fprintf(A33210,['FREQ ',num2str(F_Res)]);
pause(2);
Data.X0(1) = X0; Data.Y0(1) = Y0;
Data.PID = [Pv,Iv,Dv];
[~,~]=ReadSRS830_XY(SR830);
[Data.X(1),Data.Y(1)]=ReadSRS830_XY(SR830);
msghandle = msgbox('Stop the loop?');
figure;
Data.AdjustedTheta(1) = atan((Data.X(1)-X0)./(Data.Y(1)-Y0));
ii = 2;
tic;
Data.Time(1) = toc;
Data.SetFrequency(1) = F_Res;
Data.ControlFunction(1) = F_Res;
Data.BathTemperature(1) = readLS331_IanSimple(LS331);
IntegralError = 0;
while ishandle(msghandle)
    Data.Time(ii) = toc;
    Data.X0(ii) = X0;
    Data.Y0(ii) = Y0; 
    if mod(ii,1000)==0
        fprintf(A33210,['FREQ 41000']);
        pause(.05);
        [~,~]=ReadSRS830_XY(SR830);
        [~,~]=ReadSRS830_XY(SR830);
        [~,~]=ReadSRS830_XY(SR830);
        [X0,Y0]=ReadSRS830_XY(SR830);
        fprintf(A33210,['FREQ ',num2str(Data.SetFrequency(ii-1))]);
        pause(.05)
    end
    Data.BathTemperature(ii) = readLS331_IanSimple(LS331);
    DeltaT = Data.Time(ii) - Data.Time(ii-1);
    [Data.X(ii),Data.Y(ii)]=ReadSRS830_XY(SR830);
    Data.AdjustedTheta(ii) = atan((Data.X(ii)-X0)./(Data.Y(ii)-Y0));
    EF = Data.AdjustedTheta(ii); CT = Data.Time(ii);
    IntegralError = IntegralError+Iv.*(EF.*DeltaT);
    Data.ControlFunction(ii) = Pv.*((EF)+IntegralError+Dv.*(EF - Data.AdjustedTheta(ii-1)));
    Data.SetFrequency(ii) = Data.SetFrequency(ii-1) - Data.ControlFunction(ii);
    fprintf(A33210,['FREQ ',num2str(Data.SetFrequency(ii))]);
    ii = ii+1;
    if mod(ii,200)==1
            xoffset = 20;
            subplot(2,2,1);
            plot(Data.Time,Data.AdjustedTheta); xlabel('T [s]'); ylabel('\theta_{adj}');
            xlim([CT-xoffset ,CT]);
            subplot(2,2,2);
            plot(Data.Time,Data.SetFrequency); xlabel('T [s]'); ylabel('f_{set} [KHz]');
            xlim([CT-xoffset ,CT]);
            subplot(2,2,4);
            plot(Data.Time,Data.ControlFunction); xlabel('T [s]'); ylabel('CF');
            xlim([CT-xoffset ,CT]);
        
            drawnow;
        save(SaveFilename,'-struct','Data')
    end
end
save(SaveFilename,'-struct','Data')
end


function SaveFilename = MakeFilename()
fileroot = 'C:\Data\Kyle\CL5_Data\ThetaVT\';
SampleInfoStr = 'CL5_300K_Tests_TrackRes_PrePump';
format shortg
c = clock;
date='';
for i=1:6
    date = strcat(date,'_',num2str(round(c(i)),'%02d'));
end
filenamestr = regexprep([SampleInfoStr,'_',date],'\.','p');
SaveFilename = fullfile(fileroot,[filenamestr,'.mat']);

end