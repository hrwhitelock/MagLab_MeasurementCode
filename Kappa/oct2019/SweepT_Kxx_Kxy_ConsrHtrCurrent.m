function SweepT_Kxx_Kxy_ConsrHtrCurrent(DAQ, End, Rate, SetCurrent, tol)



%GPIB
gpib_ls340_1 = DAQ.gpib_ls336_1;

gpib_ls370_1_Hot = DAQ.gpib_ls370_1_Hot;
gpib_ls370_2_Cold = DAQ.gpib_ls370_2_Cold;
gpib_ls370_3_Transverse = DAQ.gpib_ls370_3_Transverse;

CurrentSrc_gpib = DAQ.CurrentSrc_gpib;
vi=DAQ.vi;

%Sequence Parameters
SampleInfoStr = DAQ.SampleInfoStr;
CXcell = DAQ.CXcell;
fileroot = [DAQ.Tswpfileroot '_Cont'];
SamplesPerStep = DAQ.SamplesPerStep;
HTRcurrentStopFunc = DAQ.HTRcurrentStopFunc;
HTRcurrentSteps = DAQ.HTRcurrentSteps;
HTRcurrentStart = DAQ.HTRcurrentStart;

TransverseChannel = DAQ.TransverseChannel;

%Lakeshore Channel Layout
BathChannel = DAQ.BathChannel;
VTIChannel = DAQ.VTIChannel;
HotChannel = DAQ.HotChannel;
ColdChannel = DAQ.ColdChannel;
ProbeChannel = DAQ.ProbeChannel;

TempControlLoop = DAQ.TempControlLoop;
    SorbHtrRange = DAQ.SampleHTRRange;
SorbChannel = DAQ.VTIChannel;


obj_ls340_1 =  open_ls340(gpib_ls340_1);

obj_ls370_1_Hot = OpenGPIBObject(gpib_ls370_1_Hot);
obj_ls370_2_Cold = OpenGPIBObject(gpib_ls370_2_Cold);
obj_ls370_3_Transverse = OpenGPIBObject(gpib_ls370_3_Transverse);

datacell.SorbHtrPower = read340_misc(obj_ls340_1,'HTR? 1');
datacell.ProbeHtrPower = read340_misc(obj_ls340_1,'HTR? 2');


%display(datacell.SorbHtrPower);
% s = {'A','B','C','D'};
% for i = 1:3
%     datacell.(['Input' s{i}]) = read340_misc(obj_ls340_1, ['INTYPE? ' s{i}]);
%     %display(datacell.(['Input' s{i}]));
% end


%% Acq Consts (Change as needed)
tol = .001;
L = 100;

%% Constants (Do not change)
K_unit = 'KRDG?';
R_unit = 'SRDG?';


%% Setup file
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

currentTemp = read340_obj(obj_ls340_1,ProbeChannel,K_unit);
currentField = vi.GetControlValue('Field [T]');

filename = regexprep([fileroot SampleInfoStr '_' num2str(currentField) 'T_' date],'\.','p');

display(['Measuring']);

yokoampset(SetCurrent,CurrentSrc_gpib)
yoko_on(CurrentSrc_gpib);
KeithleyVol = Open2182a(DAQ.K2182a_gpib);

bool = 0;


%% Start Measurement
%msghandle=msgbox('Stop the measurement?');

h2 = figure;


ii = 0; tic
SorbTemp = read340(gpib_ls340_1,SorbChannel,K_unit);
ProbeTemp = read340(gpib_ls340_1,ProbeChannel,K_unit);

%Sorb
setramp_lake340(gpib_ls340_1, TempControlLoop, 0, Rate);
pause(1);
set_lake336(gpib_ls340_1,TempControlLoop,SorbTemp,SorbHtrRange);
pause(1);
setramp_lake340(gpib_ls340_1, TempControlLoop, 1, Rate);
pause(1);
set_lake336(gpib_ls340_1,TempControlLoop,End-.5,SorbHtrRange);

%Probe
setramp_lake340(gpib_ls340_1, 2, 0, Rate);
pause(1);
set_lake336(gpib_ls340_1,2,ProbeTemp,SorbHtrRange);
pause(1);
setramp_lake340(gpib_ls340_1, 2, 1, Rate);
pause(1);
set_lake336(gpib_ls340_1,2,End,SorbHtrRange);



while abs(currentTemp-End) > tol
    ii = ii +1;

    datacell.Time(ii)=toc;
    datacell.BathRes(ii)=read340_obj(obj_ls340_1,BathChannel,R_unit);
    datacell.BathTemp(ii)=CXcell{4}(datacell.BathRes(ii));
    datacell.VTITemp(ii)=read340_obj(obj_ls340_1,VTIChannel,K_unit);
    datacell.ProbeTemp(ii)=read340_obj(obj_ls340_1,ProbeChannel,K_unit);
    
    datacell.HotRes(ii) = LS370_Read_Obj(obj_ls370_1_Hot);
    datacell.ColdRes(ii) = LS370_Read_Obj(obj_ls370_2_Cold);
    datacell.TransverseRes(ii) = LS370_Read_Obj(obj_ls370_3_Transverse);
    
    datacell.HotTemp(ii)=CXcell{1}(datacell.HotRes(ii));
    datacell.ColdTemp(ii)=CXcell{2}(datacell.ColdRes(ii));
    datacell.TransverseTemp(ii)=CXcell{3}(datacell.TransverseRes(ii));
    DeltaT(ii) = datacell.HotTemp(ii) - datacell.ColdTemp(ii);
    TransDeltaT(ii) = datacell.ColdTemp(ii) - datacell.TransverseTemp(ii);
    
    currentTemp = datacell.ProbeTemp(ii);
    
    if mod(ii,SamplesPerStep*5)==0
        set(0,'CurrentFigure',h2)
        subplot(3,2,1); plot(datacell.Time,datacell.BathTemp ,'-k',...
            datacell.Time,datacell.ProbeTemp ,'-r')%             datacell.Time,datacell.BareBathTemp,'-g');
        xlabel('Time [sec]'); ylabel('Bath Temp [K]'); grid on
        
        subplot(3,2,3); plot(datacell.Time,datacell.HotRes,'r-',...
            datacell.Time,datacell.ColdRes,'b-',...
            datacell.Time,datacell.TransverseRes,'g-');
        xlabel('Time [sec]'); ylabel('Res [Ohm]'); grid on
        
        subplot(3,2,5); plot(datacell.Time,datacell.HotTemp,'r-',...
            datacell.Time,datacell.ColdTemp,'b-',...
            datacell.Time,datacell.TransverseTemp,'g-'...
            );
        xlabel('Time [sec]'); ylabel('Temp [K]'); grid on
        
        %subplot(3,2,2); [hAx,~,~] = plotyy(datacell.Time, datacell.HtrCurrent,datacell.Time,HTRres*power(datacell.HtrCurrent,2));
        subplot(3,2,4); plot(datacell.Time, DeltaT, datacell.Time, TransDeltaT); %legend({'xx', 'xy'})
        xlabel('Time [sec]'); ylabel('Delta T [K]'); grid on
        
        
        
        drawnow
        
        save(filename,'-STRUCT','datacell');
    end
end
yoko_off(CurrentSrc_gpib);
save(filename,'-STRUCT','datacell');
clear('datacell')
end