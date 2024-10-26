% Ian Leahy
% February 8, 2018
% Vacuum Cell Test Measurement Function

function datacell = VacCell_GaugeTest_KeithlyYoko(fr,gpib_yoko,gpib_K2182,namestring,HtrCurrent,PulseWidth)
%% Filename, Variable, and Function Initialization
fileroot=fr;
filename=[namestring,'_',datestr(clock,'dd_mm_yy_HH_MM_SS')];

MaxPoints=5e5;
h2=figure('Name',filename);

% GPIB Initialization

%NanoVol1 = Open2182a(gpib_K2182);
NanoVol1 = OpenGPIBObject(gpib_K2182);

yokoampset(0,gpib_yoko)
BathChannel='A';
R_unit = 'SRDG?';
% init_thermo(gpib_ls331);
% current2400set(gpib_K2400,0,2.1);
yoko_on(gpib_yoko);


%% Measurement Loop
i=1;
% CurrentCompliance(HtrCurrent);
datacell.HeaterCurrent=HtrCurrent;
datacell.PulseWidth=PulseWidth; %Recommend 800
msghandle=msgbox('Stop the measurement?');
tic;
z=0;
setcurrent = 0;
fprintf(NanoVol1, ':sens:volt:nplc .1');
while i<=MaxPoints && ishandle(msghandle)
    if mod(i,datacell.PulseWidth)==0
        if z==0
            %             current2400set(gpib_K2400,HtrCurrent,5);
            setcurrent = HtrCurrent;
            yokoampset(setcurrent,gpib_yoko);
            z=1;
        elseif z==1
            %             current2400set(gpib_K2400,0,5);
            setcurrent=0;
            yokoampset(setcurrent,gpib_yoko);
            z=0;
        end
    end
    datacell.time(i)=toc;
    %     datacell.BathRes(i)=read340(gpib_ls331,BathChannel,R_unit);
%     datacell.HeaterVoltage(i)=read2400justvolt(gpib_K2400);
    datacell.HeaterVoltage(i) = setcurrent;
%     datacell.TC_Volt(i)=readonevoltage(NanoVol1);
    datacell.TC_Volt(i) = read2002_volt_IanObj(NanoVol1);
    % Calculation
    datacell.HeaterRes(i)=datacell.HeaterVoltage(i)./datacell.HeaterCurrent;
    %     datacell.BathTemp(i)=BathCal_0010C(datacell.BathRes(i));
    
    if mod(i,10)==0
        %         figure(h2);
        %         subplot(2,2,1); yyaxis left; plot(datacell.time,datacell.BathRes,'-b'); ylabel('R [\Omega]');
        %                         yyaxis right; plot(datacell.time,datacell.BathTemp,'-r'); xlabel('Time [s]'); ylabel('T [K]');
        subplot(2,2,1:2); plot(datacell.time,datacell.HeaterRes,'.'); xlabel('Time [s]'); ylabel('Heater Res [\Omega]');
        subplot(2,2,3:4); plot(datacell.time,datacell.TC_Volt,'-'); xlabel('Time [s]'); ylabel('Thermocouple Voltage [V]');
        drawnow;
    end
    
    i=i+1
    save([fileroot,filename],'-STRUCT','datacell');
end
yokoampset(0,gpib_yoko);
yoko_off(gpib_yoko);
save([fileroot,filename],'-STRUCT','datacell');

display(filename)
VacCellTimeConst(filename,1)


end


% Checks that the current is below some threshold value.
function CurrentCompliance(Current)
Compliance=3e-3;
if Current>Compliance
    error('Current exceeds 3mA, please change compliance and be careful!');
end
end