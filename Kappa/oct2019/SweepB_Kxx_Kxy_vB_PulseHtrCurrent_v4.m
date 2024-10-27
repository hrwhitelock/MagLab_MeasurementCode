function SweepB_Kxx_Kxy_vB_PulseHtrCurrent_v4(DAQ, End, Rate, SetCurrent)



%GPIB
gpib_ls340_1 = DAQ.gpib_ls336_1;

gpib_ls370_1_Hot = DAQ.gpib_ls370_1_Hot;
gpib_ls370_2_Cold = DAQ.gpib_ls370_2_Cold;
gpib_ls370_3_Transverse = DAQ.gpib_ls370_3_Transverse;
gpib_ls370_4_Bath = DAQ.gpib_ls370_4_Bath;


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

TransverseChannel = DAQ.TransverseChannel;

%Lakeshore Channel Layout

VTIChannel = DAQ.VTIChannel;
HotChannel = DAQ.HotChannel;
ColdChannel = DAQ.ColdChannel;
ProbeChannel = DAQ.ProbeChannel;



obj_ls340_1 =  open_ls340(gpib_ls340_1);

obj_ls370_1_Hot = OpenGPIBObject(gpib_ls370_1_Hot);
obj_ls370_2_Cold = OpenGPIBObject(gpib_ls370_2_Cold);
obj_ls370_3_Transverse = OpenGPIBObject(gpib_ls370_3_Transverse);
obj_ls370_4_Bath = OpenGPIBObject(gpib_ls370_4_Bath);

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
filename = regexprep([fileroot SampleInfoStr '_' num2str(currentTemp) 'K_' date],'\.','p');

display(['Measuring']);
currentCurrent = 0;
currentField = vi.GetControlValue('Field [T]');
%yokoampset(currentCurrent,CurrentSrc_gpib)
yoko_on(CurrentSrc_gpib);

current2450set(CurrentSrc_gpib,currentCurrent);
 source2400on(CurrentSrc_gpib);

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

L = 2*SamplesPerStep;
cond1 = 0; cond2 = 0;

jj = 0; kk = 0;
ii = 0; tic
while not(cond1) || not(cond2)
    cond1 = abs(currentField-End)<tol ;
    ii = ii+1;
    
    if cond1
        jj = jj+1;
        cond2 = jj>4*SamplesPerStep;
        %if cond2
        %    kk = kk+1;
        %    cond3 = jj>10*SamplesPerStep;
        %end
    end
    
    if mod(ii,SamplesPerStep)==0
        bool = not(bool);
        currentCurrent = SetCurrent*bool;
        %yokoampset(currentCurrent,CurrentSrc_gpib)
        current2450set(CurrentSrc_gpib,currentCurrent);
    end
    
    if ii == 4*SamplesPerStep
        vi.SetControlValue('Setpoint [T]',End);
        vi.SetControlValue('menu',1);
        vi.SetControlValue('Setpoint [T]',End);
        vi.SetControlValue('menu',1);
    end
    
    currentField = vi.GetControlValue('Field [T]');
    datacell.Bfield(ii) = currentField;
    datacell.HtrCurrent(ii) = currentCurrent;
    datacell.Time(ii)=toc;
    %datacell.BathRes(ii)=read340_obj(obj_ls340_1,BathChannel,R_unit);
    %datacell.BathTemp(ii)=CXcell{4}(datacell.BathRes(ii));
    
    datacell.BathRes(ii)= LS370_Read_Obj(obj_ls370_4_Bath);
    datacell.BathTemp(ii)=CXcell{4}(datacell.BathRes(ii));
    
    datacell.VTITemp(ii)=read340_obj(obj_ls340_1,VTIChannel,K_unit);
    datacell.ProbeTemp(ii)=read340_obj(obj_ls340_1,ProbeChannel,K_unit);
%     
%     if  currentField < 1
%         vi.SetControlValue('Slew Rate [T/min]',.1);
%         vi.SetControlValue('menu',2);
%     elseif currentField < 3
%         vi.SetControlValue('Slew Rate [T/min]',.2);
%         vi.SetControlValue('menu',2);
%     else
%         vi.SetControlValue('Slew Rate [T/min]',Rate);
%         vi.SetControlValue('menu',2);
%     end
%         
    
    datacell.HotRes(ii) = LS370_Read_Obj(obj_ls370_1_Hot);
    datacell.ColdRes(ii) = LS370_Read_Obj(obj_ls370_2_Cold);
    datacell.TransverseRes(ii) = LS370_Read_Obj(obj_ls370_3_Transverse);
    
    datacell.HotTemp(ii)=CXcell{1}(datacell.HotRes(ii));
    datacell.ColdTemp(ii)=CXcell{2}(datacell.ColdRes(ii));
    datacell.TransverseTemp(ii)=CXcell{3}(datacell.TransverseRes(ii));
    DeltaT(ii) = datacell.HotTemp(ii) - datacell.ColdTemp(ii);
    TransDeltaT(ii) = datacell.ColdTemp(ii) - datacell.TransverseTemp(ii);
    
    
    if 0%currentCurrent ~= 0
        volt = readonevoltage(KeithleyVol);
        datacell.HTRres(ii) = volt/SetCurrent;
    else
        datacell.HTRres(ii) = NaN;
    end
    
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
        subplot(3,2,2); plot(datacell.Time, datacell.HtrCurrent,'r');
        xlabel('Time [sec]'); ylabel('Heater Current [A]');% ylabel(hAx(2),'Heater Power [W]'); grid
        
        subplot(3,2,4); plot(datacell.Time, DeltaT, datacell.Time, TransDeltaT); %legend({'xx', 'xy'})
        xlabel('Time [sec]'); ylabel('Delta T [K]'); grid on
        
        subplot(3,2,6); plot(datacell.Time,datacell.Bfield,'-g');
        xlabel('Time [sec]'); ylabel('Field [T]'); grid on
        
        
        drawnow
        
        save(filename,'-STRUCT','datacell');
    end
end
source2400off(CurrentSrc_gpib);
save(filename,'-STRUCT','datacell');
clear('datacell')
end