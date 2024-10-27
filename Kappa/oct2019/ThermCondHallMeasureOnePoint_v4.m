function ThermCondHallMeasureOnePoint_v4(DAQ)

%% Store DAQ struct values as local variables

%GPIB
% gpib_ls340_1 = DAQ.gpib_ls340_1;
gpib_ls336_1 = DAQ.gpib_ls336_1;

gpib_ls370_1_Hot = DAQ.gpib_ls370_1_Hot;
gpib_ls370_2_Cold = DAQ.gpib_ls370_2_Cold;
gpib_ls370_3_Transverse = DAQ.gpib_ls370_3_Transverse;
gpib_ls370_4_Bath = DAQ.gpib_ls370_4_Bath;


obj_ls370_1_Hot = OpenGPIBObject(gpib_ls370_1_Hot);
obj_ls370_2_Cold = OpenGPIBObject(gpib_ls370_2_Cold);
obj_ls370_3_Transverse = OpenGPIBObject(gpib_ls370_3_Transverse);
obj_ls370_4_Bath = OpenGPIBObject(gpib_ls370_4_Bath);

CurrentSrc_gpib = DAQ.CurrentSrc_gpib;
vi=DAQ.vi;

%Sequence Parameters
SampleInfoStr = DAQ.SampleInfoStr;
CXcell = DAQ.CXcell;
fileroot = DAQ.Tswpfileroot;
SamplesPerStep = DAQ.SamplesPerStep;
HTRcurrentStopFunc = DAQ.HTRcurrentStopFunc;
HTRcurrentSteps = DAQ.HTRcurrentSteps;
HTRcurrentStart = DAQ.HTRcurrentStart;

%Lakeshore Channel Layout
VTIChannel = DAQ.VTIChannel;
HotChannel = DAQ.HotChannel;
ColdChannel = DAQ.ColdChannel;
TransverseChannel = DAQ.TransverseChannel;
ProbeChannel = DAQ.ProbeChannel;


%% Constants (Do not change)
K_unit = 'KRDG?';
R_unit = 'SRDG?';


%% Get timestap and create filename
format shortg
c = clock;
date='';
for i=1:6
    date = strcat(date,'_',num2str(c(i)));
end
date = date(1:length(date)-4);

if fileroot(end)~='\'
    fileroot = [fileroot '\'];
end

KeithleyVol = Open2182a(DAQ.K2182a_gpib);
currentField = vi.GetControlValue('Field [T]');
currentTemp = read340(gpib_ls336_1,ProbeChannel,K_unit);
filename = regexprep([fileroot SampleInfoStr '_' num2str(currentTemp) 'K_' num2str(round(currentField)) 'T' date],'\.','p');
display(filename)

%% Set Current Sequence
HTRcurrentStop = HTRcurrentStopFunc(currentTemp);
HTRcurrentSqStep = abs((HTRcurrentStop)^2-(HTRcurrentStart)^2)/HTRcurrentSteps;
I(1) = HTRcurrentStart;
for j = 2:(HTRcurrentSteps+1)
    I(j) = sqrt((I(j-1))^2+HTRcurrentSqStep);
end
I(HTRcurrentSteps+2) = 0;

%% Start Measurement Sequence
datacell.SampPerStep=SamplesPerStep;
%     h2 = figure('units','normalized','outerposition',[0 0 1 1]);
h2 = figure('units','pixels','position',[2 42 958 954]);

display(['Measuring Point at ' date]);
current2450set(CurrentSrc_gpib,0)
source2400on(CurrentSrc_gpib);
datacell.Bfield = currentField;



ii =0; tic;

obj_ls340_1 =  open_ls340(gpib_ls336_1);
%obj_ls340_1 =  open_ls340(gpib_ls340_1);

datacell.SorbHtrPower = read340_misc(obj_ls340_1,'HTR? 1');
datacell.ProbeHtrPower = read340_misc(obj_ls340_1,'HTR? 2');


%display(datacell.SorbHtrPower);
%     s = {'A','B','C','D'};
%     for i = 1:4
%         datacell.(['Input' s{i}]) = read340_misc(obj_ls340_1, ['INTYPE? ' s{i}]);
%         %display(datacell.(['Input' s{i}]));
%     end
%
datacell.HotSettings = LS370_Read_Settings(obj_ls370_1_Hot);
datacell.ColdSettings = LS370_Read_Settings(obj_ls370_2_Cold);
datacell.TransverseSettings = LS370_Read_Settings(obj_ls370_3_Transverse);



% for k = 1:round(SamplesPerStep/4)
%     tempVar.HotRes(k) = LS370_Read_Obj(obj_ls370_1_Hot);
%     tempVar.ColdRes(k) = LS370_Read_Obj(obj_ls370_2_Cold);
%     tempVar.TransverseRes(k) = LS370_Read_Obj(obj_ls370_3_Transverse);
% end

fac_H = 1;% mean(tempVar.ColdRes./tempVar.HotRes);
fac_T = 1;% mean(tempVar.ColdRes./tempVar.TransverseRes);

for currentCurrent = I
    current2450set(CurrentSrc_gpib,currentCurrent)

    for k = 1:SamplesPerStep
        ii=ii+1;
        
        datacell.HtrCurrent(ii) = currentCurrent;
        datacell.Time(ii)=toc;
        datacell.BathRes(ii)= LS370_Read_Obj(obj_ls370_4_Bath);
        datacell.BathTemp(ii)=CXcell{4}(datacell.BathRes(ii));
        datacell.VTITemp(ii)=read340_obj(obj_ls340_1,VTIChannel,K_unit);
        datacell.ProbeTemp(ii)=read340_obj(obj_ls340_1,ProbeChannel,K_unit);
        
        
        datacell.HotRes(ii) = LS370_Read_Obj(obj_ls370_1_Hot);
        datacell.ColdRes(ii) = LS370_Read_Obj(obj_ls370_2_Cold);
        datacell.TransverseRes(ii) = LS370_Read_Obj(obj_ls370_3_Transverse);
        
        datacell.HotTemp(ii)=CXcell{1}(datacell.HotRes(ii)*fac_H);
        datacell.ColdTemp(ii)=CXcell{2}(datacell.ColdRes(ii));
        datacell.TransverseTemp(ii)=CXcell{3}(datacell.TransverseRes(ii)*fac_T);
        
        
        %datacell.HotTempLs(ii)=read340(gpib_ls340_1,HotChannel,K_unit);
        %datacell.ColdTempLs(ii)=read340(gpib_ls340_1,ColdChannel,K_unit);
        CurrSqu(ii) = currentCurrent.^2;
        %DeltaT(ii) = datacell.HotTemp(ii) - datacell.ColdTemp(ii);
        DeltaT(ii) = datacell.HotTemp(ii) - datacell.TransverseTemp(ii);
        TransDeltaT(ii) = datacell.ColdTemp(ii) - datacell.TransverseTemp(ii);
        
        
        %Temps
        if mod(ii,SamplesPerStep/2)==0
            %             figure(h2);
            subplot(3,2,1);
            
            plot(datacell.Time,(datacell.HotTemp+datacell.ColdTemp)/2,...
                datacell.Time,datacell.BathTemp,...
                datacell.Time,datacell.ProbeTemp);
            xlabel('Time [sec]'); ylabel('Bath Temp [K]'); grid on
            %legend({'Probe','CXavg','SD1','CX L'});
            
            
%                         subplot(3,2,3); [hAx,~,~] = plotyy(datacell.Time,T1,datacell.Time,datacell.HotRes);
%                         xlabel('Time [sec]'); ylabel(hAx(1),'Hot Temp [K]'); ylabel(hAx(2),'Hot Res [Ohm]'); grid on
%             
%                         subplot(3,2,5); [hAx,~,~] = plotyy(datacell.Time,T2,datacell.Time,datacell.ColdRes);
%                         xlabel('Time [sec]'); ylabel(hAx(1),'Cold Temp [K]'); ylabel(hAx(2),'Cold Res [Ohm]'); grid on
            
                        subplot(3,2,3);hold off;
                        plot(datacell.Time,datacell.HotRes,'r','DisplayName','Hot'); hold on;
                        plot(datacell.Time,datacell.ColdRes,'b','DisplayName','Cold');
                        plot(datacell.Time,datacell.TransverseRes,'g','DisplayName','Trans'); hold off;
                        xlabel('Time [sec]'); ylabel('Res [\Omega]');
            
                        subplot(3,2,5);hold off;
                        plot(datacell.Time,datacell.HotTemp,'r','DisplayName','Hot Temp');hold on;
                        plot(datacell.Time,datacell.ColdTemp,'b','DisplayName','Cold Temp');
                        plot(datacell.Time,datacell.TransverseTemp,'g','DisplayName','Trans Temp');
                        %plot(datacell.Time,datacell.BathTemp,'k','DisplayName','Bath Temp');
                        hold off;
                        xlabel('Time [sec]'); ylabel('T [K]')
            
            %subplot(3,2,2); [hAx,~,~] = plotyy(datacell.Time, datacell.HtrCurrent,datacell.Time,HTRres*power(datacell.HtrCurrent,2));
            subplot(3,2,2); plot(datacell.Time, datacell.HtrCurrent,'r');
            xlabel('Time [sec]'); ylabel('Heater Current [A]');% ylabel(hAx(2),'Heater Power [W]'); grid
            
            
            
            subplot(3,2,4); plot(datacell.Time, DeltaT, '-b');
            xlabel('Time [sec]'); ylabel('\Delta T(xx) [K]'); grid on
            
            %             subplot(3,2,6); plot(CurrSqu,DeltaT,'-o');
            %             xlabel('I^2 [A^2]'); ylabel('Delta T [K]'); grid on;
            %subplot(3,2,6); plot(datacell.Time,TransDeltaT,'-r');
            %xlabel('Time [sec]'); ylabel(' \Delta T(xy) T [K]'); grid on;
            drawnow
        end
    end
    
end

EndHtrCurrent = .001e-3;
current2450set(CurrentSrc_gpib,0)
 source2400on(CurrentSrc_gpib);
for i = 1:20
    volt = readonevoltage(KeithleyVol);
    pause(.1);
    d.HTRres(i) = volt;
end
current2450set(CurrentSrc_gpib,0)
datacell.HTRres = mean(d.HTRres)/EndHtrCurrent;
source2400off(CurrentSrc_gpib);
try
    close(h2)
end
save(filename,'-STRUCT','datacell');
clear('datacell')

fclose(obj_ls340_1);
% fclose(obj_ls340_1);



end