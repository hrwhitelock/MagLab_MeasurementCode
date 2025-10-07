% Ian Leahy
% February 8, 2018
% Vacuum Cell Test Measurement Function

function datacell = VacCell_GaugeTest_Nov2018(fileroot,namestring,HtrCurrent)

%% Filename, Variable, and Function Initialization
filename=[namestring,datestr(clock,'dd_mm_yy_HH_MM_SS'),];
MaxPoints=5e5;
% h2=figure('Name',filename,'units','normalized','position',[-0.7458 -0.0250 0.7417 0.7806]);
h2=figure; 
% GPIB Initialization
gpib_K2400 = 24; %Current Source
gpib_K2400_TC = 24; %Measure voltage of thermocouple

current2400set(gpib_K2400,0);
source2400on(gpib_K2400);

current2400set(gpib_K2400_TC,0);
source2400on(gpib_K2400_TC);


%% Measurement Loop
i=1;
CurrentCompliance(HtrCurrent);
datacell.HeaterCurrent=HtrCurrent;
datacell.PulseWidth=35;
msghandle=msgbox('Stop the measurement?');
tic;
z=0;
while i<=50000 && ishandle(msghandle)
    if mod(i,datacell.PulseWidth)==0
        if z==0
            current2400set(gpib_K2400,HtrCurrent);
            z=1;
        elseif z==1
            current2400set(gpib_K2400,0);
            z=0;
        end
    end
    datacell.time(i)=toc;
    datacell.HeaterVoltage(i)=read2400justvolt(gpib_K2400);
    datacell.TC_Volt(i)=read2400justvolt(gpib_K2400_TC);
    
    % Calculation
    datacell.HeaterRes(i)=datacell.HeaterVoltage(i)./datacell.HeaterCurrent;
    
    if mod(i,1)==0
        figure(h2);
        subplot(2,2,1:2); plot(datacell.time,datacell.HeaterRes,'.'); xlabel('Time [s]'); ylabel('Heater Res [\Omega]');
        subplot(2,2,3:4); plot(datacell.time,datacell.TC_Volt,'-'); xlabel('Time [s]'); ylabel('Thermocouple Voltage [V]'); 
        drawnow
    end
    
    i=i+1;
    save([fileroot,filename],'-STRUCT','datacell');
end
source2400off(gpib_K2400);
save([fileroot,filename],'-STRUCT','datacell');




end


% Checks that the current is below some threshold value.
function CurrentCompliance(Current)
Compliance=3e-3;
if Current>Compliance
    error('Current exceeds 3mA, please change compliance and be careful!');
end
end
