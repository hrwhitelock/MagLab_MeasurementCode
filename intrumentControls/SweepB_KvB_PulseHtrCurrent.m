function SweepB_KvB_PulseHtrCurrent(DAQ, End, Rate, SetCurrent)



%GPIB
gpib_ls340_1 = DAQ.gpib_ls340_1;
gpib_ls340_2 = DAQ.gpib_ls340_2;
CurrentSrc_gpib = DAQ.CurrentSrc_gpib;
vi=DAQ.vi;

%Sequence Parameters
SampleInfoStr = DAQ.SampleInfoStr;
CXcell = DAQ.CXcell;
fileroot = DAQ.Bswpfileroot;
SamplesPerStep = DAQ.SamplesPerStep;
HTRcurrentStopFunc = DAQ.HTRcurrentStopFunc;
HTRcurrentSteps = DAQ.HTRcurrentSteps;
HTRcurrentStart = DAQ.HTRcurrentStart;

%Lakeshore Channel Layout
BathChannel = DAQ.BathChannel;
VTIChannel = DAQ.VTIChannel;
HotChannel = DAQ.HotChannel;
ColdChannel = DAQ.ColdChannel;
ProbeChannel = DAQ.ProbeChannel;
He3VTIChannel = DAQ.He3VTIChannel;

obj_ls340_1 =  open_ls340(gpib_ls340_1);
obj_ls340_2 =  open_ls340(gpib_ls340_2);
datacell.SorbHtrPower = read340_misc(obj_ls340_2,'HTR? 1');
datacell.ProbeHtrPower = read340_misc(obj_ls340_2,'HTR? 2');


%display(datacell.SorbHtrPower);
s = {'A','B','C','D'};
for i = 1:4
    datacell.(['Input' s{i}]) = read340_misc(obj_ls340_1, ['INTYPE? ' s{i}]);
    %display(datacell.(['Input' s{i}]));
end


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
filename = regexprep([fileroot SampleInfoStr '_' date],'\.','p');

display(['Measuring']);
currentCurrent = 0;
currentField = vi.GetControlValue('Field [T]');
yokoampset(currentCurrent,CurrentSrc_gpib)
yoko_on(CurrentSrc_gpib);
KeithleyVol = Open2182a(DAQ.K2182a_gpib);
datacell.SamplesPerStep = DAQ.SamplesPerStep;

bool = 0;

%% Start Measurement
%msghandle=msgbox('Stop the measurement?');

h2 = figure;
%     set(h2,'visible','off');
vi.SetControlValue('Slew Rate [T/min]',Rate);
vi.SetControlValue('menu',2);
vi.SetControlValue('Slew Rate [T/min]',Rate);
vi.SetControlValue('menu',2);

L = 200;
cond1 = 0; cond2 = 0;

jj = 0;
ii = 0; tic
while not(cond1) && not(cond2)
    cond1 = abs(currentField-End)<tol ;
    ii = ii+1;
    
    if cond1
        jj = jj+1;
        cond2 = jj>L;
    end
    
    if mod(ii,SamplesPerStep)==0
        bool = not(bool);
        currentCurrent = SetCurrent*bool;
        yokoampset(currentCurrent,CurrentSrc_gpib)
    end
    
    if ii == L
        vi.SetControlValue('Setpoint [T]',End);
        vi.SetControlValue('menu',1);
        vi.SetControlValue('Setpoint [T]',End);
        vi.SetControlValue('menu',1);
    end
    
    currentField = vi.GetControlValue('Field [T]');
    datacell.Bfield(ii) = currentField;
    datacell.HtrCurrent(ii) = currentCurrent;
    datacell.Time(ii)=toc;
    datacell.BathRes(ii)=read340_obj(obj_ls340_1,BathChannel,R_unit);
    datacell.BathTemp(ii)=CXcell{3}(datacell.BathRes(ii));
    datacell.VTITemp(ii)=read340_obj(obj_ls340_2,VTIChannel,K_unit);
    datacell.ProbeTemp(ii)=read340_obj(obj_ls340_2,ProbeChannel,K_unit);
    datacell.HotRes(ii)=read340_obj(obj_ls340_1,HotChannel,R_unit);
    datacell.ColdRes(ii)=read340_obj(obj_ls340_1,ColdChannel,R_unit);
    datacell.HotTemp(ii)=CXcell{1}(datacell.HotRes(ii));
    datacell.ColdTemp(ii)=CXcell{2}(datacell.ColdRes(ii));
    T1 =  datacell.HotTemp;
    T2 =  datacell.ColdTemp;
    DeltaT = T1-T2;
    
    if currentCurrent ~= 0
        volt = readonevoltage(KeithleyVol);
        datacell.HTRres(ii) = volt/SetCurrent;
    else
        datacell.HTRres(ii) = NaN;
    end
    
    if mod(ii,20)==0
        set(0,'CurrentFigure',h2)
        subplot(3,2,1); plot(datacell.Time,datacell.BathTemp ,'-k',datacell.Time,datacell.ProbeTemp ,'-r');
        xlabel('Time [sec]'); ylabel('Bath Temp [K]'); grid on
        
        subplot(3,2,3); [hAx,~,~] = plotyy(datacell.Time,T1,datacell.Time,datacell.HotRes);
        xlabel('Time [sec]'); ylabel(hAx(1),'Hot Temp [K]'); ylabel(hAx(2),'Hot Res [Ohm]'); grid on
        
        subplot(3,2,5); [hAx,~,~] = plotyy(datacell.Time,T2,datacell.Time,datacell.ColdRes);
        xlabel('Time [sec]'); ylabel(hAx(1),'Cold Temp [K]'); ylabel(hAx(2),'Cold Res [Ohm]'); grid on
        
        %subplot(3,2,2); [hAx,~,~] = plotyy(datacell.Time, datacell.HtrCurrent,datacell.Time,HTRres*power(datacell.HtrCurrent,2));
        subplot(3,2,2); plot(datacell.Time, datacell.HtrCurrent,'r');
        xlabel('Time [sec]'); ylabel('Heater Current [A]');% ylabel(hAx(2),'Heater Power [W]'); grid
        
        subplot(3,2,4); plot(datacell.Time, DeltaT, '-b');
        xlabel('Time [sec]'); ylabel('Delta T [K]'); grid on
        
        subplot(3,2,6); plot(datacell.Time,datacell.Bfield,'-g');
        xlabel('Time [sec]'); ylabel('Field [T]'); grid on
        
        save(filename,'-STRUCT','datacell');
        drawnow
    end
end
yoko_off(CurrentSrc_gpib);
save(filename,'-STRUCT','datacell');
clear('datacell')
end