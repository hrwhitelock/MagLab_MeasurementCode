% Ian Leahy
% 5/2/2022
% Heat Capacity Frequency Sweep

function HeatCapacity_TemperatureSweep_WithTSetpoints(DAQ,TemperatureSetPoint,Rate,Tolerance)

% Open GPIB Objects and extract DAQ measurement parameters.
SRS830_Thermometer = OpenGPIBObject_BufferSize(DAQ.SRS830_Thermometer_gpib);
SRS830_Heater      = OpenGPIBObject_BufferSize(DAQ.SRS830_Heater_gpib);
K2182_Thermometer  = OpenGPIBObject(DAQ.K2182_Thermometer_gpib);
% K6220_Thermometer  = OpenGPIBObject(DAQ.K6220_Thermometer_gpib);
K6221_Heater       = OpenGPIBObject(DAQ.K6221_Heater_gpib);
LS340              = OpenGPIBObject(DAQ.LS340_gpib);
K6221_WaveModeSetup(K6221_Heater);
obj_ls370_3_Bath   = OpenGPIBObject(DAQ.LS370_gpib);

TempControlLoop = DAQ.TempControlLoop;
BathChannel = DAQ.BathChannel;
SorbChannel = DAQ.VTIChannel;
VTIChannel = DAQ.VTIChannel;
ProbeChannel = DAQ.ProbeChannel;
SorbHtrRange = DAQ.SorbHtrRange;
ProbeHtrRange = DAQ.ProbeHtrRange;


SetFrequency = DAQ.SetHeaterFrequency;
SetAmplitude = DAQ.SetHeaterCurrent;

CXCell = DAQ.CXCell;
SensitivityCurve = DAQ.SensitivityCurve;
K_unit = 'KRDG?';
R_unit = 'SRDG?';

datacell.Current_Thermometer = DAQ.Current_Thermometer;
Current_Thermometer = datacell.Current_Thermometer;
datacell.Current_Heater      = DAQ.Current_Heater;
% Current_Heater = datacell.Current_Heater;
datacell.LI_Gain = DAQ.LI_Gain;
LI_Gain = datacell.LI_Gain;
% datacell.PointsPerFrequency = PointsPerFrequency;
%
K6221_WaveMode_SetAmplitude(K6221_Heater,SetAmplitude);
K6221_WaveMode_SetFrequency(K6221_Heater,SetFrequency);
K6221_WaveMode_OnOff(K6221_Heater,'On');
pause(15); 
% LI_TimeConstant = SRS830_FindTimeConstant(FrequencySweepVector(1));
% SRS830_Set_Sens_Tau(SRS830_Heater,'',LI_TimeConstant,'Time Constant Only')
% SRS830_Set_Sens_Tau(SRS830_Thermometer,'',LI_TimeConstant,'Time Constant Only');
% % pause(3*5);
vi = DAQ.vi;

% Measure preliminary temperature for filename;
BathResistance = LS372_Read_Obj(obj_ls370_3_Bath);
CurrentTemperature = CXCell{2}(BathResistance);
CurrentField = vi.GetControlValue('Field [T]');
Filename = GenerateFilename(DAQ,CurrentTemperature,CurrentField);

% Calculate a rough sensitivity for to estimate Tosc during measurement.
% Thermometer_Resistance = readonevoltage(K2182_Thermometer)./Current_Thermometer;
% RoughSensitivity = SensitivityCurve(Thermometer_Resistance); % In ohm/K. To get gradient, divide resistance reating by sensitivity.
datacell.Frequency = SetFrequency;
CurrentTemp = read340_obj(LS340,ProbeChannel,K_unit);

% myhandle = msgbox('Stop the measurement?');
% Sweep frequency.
ii = 1;
DataFigure = figure;
MyClock = tic;
while abs(CurrentTemp-TemperatureSetPoint) > Tolerance
    % Measurements as close together as possible.
    datacell.Time(ii) = toc(MyClock);
    [datacell.X_Heater(ii),datacell.Y_Heater(ii)] = ReadSRS860_Maglab_XY(SRS830_Heater);
    [datacell.X_Thermometer(ii),datacell.Y_Thermometer(ii)] = ReadSRS860_Maglab_XY(SRS830_Thermometer);
%     [datacell.X_Thermometer(ii),datacell.Y_Thermometer(ii)] = ReadSRS830_XY(SRS830_Thermometer);
    datacell.Thermometer_Voltage_DC(ii) = readonevoltage(K2182_Thermometer);
    datacell.BathResistance(ii) = LS372_Read_Obj(obj_ls370_3_Bath);
    datacell.VTITemp(ii)=read340_obj(LS340,VTIChannel,K_unit);
    datacell.ProbeTemp(ii)=read340_obj(LS340,ProbeChannel,K_unit);
    if ii==3000
        SorbTemp = read340_obj(LS340,SorbChannel,K_unit);
        ProbeTemp = read340_obj(LS340,ProbeChannel,K_unit);
        
        %Sorb
        setramp_lake340_ML_obj(LS340, TempControlLoop, 0, Rate);
        pause(1);
        set_lake336_ML_obj(LS340,TempControlLoop,SorbTemp,SorbHtrRange);
        pause(1);
        setramp_lake340_ML_obj(LS340, TempControlLoop, 1, Rate);
        pause(1);
        set_lake336_ML_obj(LS340,TempControlLoop,TemperatureSetPoint-.5,SorbHtrRange);
        
        %Probe
        setramp_lake340_ML_obj(LS340, 2, 0, Rate);
        pause(1);
        set_lake336_ML_obj(LS340,2,ProbeTemp,ProbeHtrRange);
        pause(1);
        setramp_lake340_ML_obj(LS340, 2, 1, Rate);
        pause(1);
        set_lake336_ML_obj(LS340,2,TemperatureSetPoint,ProbeHtrRange);
    end
    CurrentTemp = datacell.ProbeTemp(ii);
    % Calculations.
    %         datacell.Heater_LI_Sensitivity(ii) = Heater_LI_Sensitivity;
    %         datacell.Heater_LI_Timeconstant(ii) = LI_TimeConstant;
    %         datacell.Thermometer_LI_Sensitivity(ii) = Thermometer_LI_Sensitivity;
    %         datacell.Thermometer_LI_Timeconstant(ii) = LI_TimeConstant;
    datacell.R_Heater(ii)  = sqrt(datacell.X_Heater(ii).^2+datacell.Y_Heater(ii).^2);
    datacell.R_Thermometer(ii)  = sqrt(datacell.X_Thermometer(ii).^2+datacell.Y_Thermometer(ii).^2);
    datacell.BathTemperature(ii) = CXCell{2}(datacell.BathResistance(ii));
    datacell.Thermometer_Resistance(ii) = datacell.Thermometer_Voltage_DC(ii)./Current_Thermometer;
    datacell.SampleTemperature(ii) = CXCell{1}(datacell.Thermometer_Resistance(ii));
    datacell.TOsc_Rough(ii) = datacell.R_Thermometer(ii).*(abs(SensitivityCurve(datacell.Thermometer_Resistance(ii))))./(Current_Thermometer.*LI_Gain);
    if mod(ii,200)==1
        figure(DataFigure);
        
        subplot(2,2,1); hold on;
        hold on;
        plot(datacell.Time,datacell.SampleTemperature,'-r','DisplayName','Sample T');
        plot(datacell.Time,datacell.BathTemperature,'-b','DisplayName','Bath T');
        xlabel('Time [s]'); ylabel('T [K]'); hold off;
        
        subplot(2,2,2); hold off;
        plot(datacell.Time,datacell.R_Thermometer.*1e6,'-k');
        xlabel('Time [s]'); ylabel('R_{CX} [\muV]');
        
        subplot(2,2,3); hold off;
        plot(datacell.BathTemperature,datacell.TOsc_Rough,'-k');
        xlabel('T_{Bath} [K]'); ylabel('T_{Osc} [K]');
        
        subplot(2,2,4); hold off;
        plot(datacell.BathTemperature,1./datacell.TOsc_Rough,'-k');
        xlabel('T_{Bath} [K]'); ylabel('1/T_{Osc} \propto C_S [K^{-1}]');
        drawnow;
        save(Filename,'-struct','datacell');
    end
    ii = ii+1;
end

jj = 1;
while jj<=3000
    % Measurements as close together as possible.
    datacell.Time(ii) = toc(MyClock);
    [datacell.X_Heater(ii),datacell.Y_Heater(ii)] = ReadSRS860_Maglab_XY(SRS830_Heater);
    [datacell.X_Thermometer(ii),datacell.Y_Thermometer(ii)] = ReadSRS860_Maglab_XY(SRS830_Thermometer);
%     [datacell.X_Thermometer(ii),datacell.Y_Thermometer(ii)] = ReadSRS830_XY(SRS830_Thermometer);
    datacell.Thermometer_Voltage_DC(ii) = readonevoltage(K2182_Thermometer);
    datacell.BathResistance(ii) = LS372_Read_Obj(obj_ls370_3_Bath);
    datacell.VTITemp(ii)=read340_obj(LS340,VTIChannel,K_unit);
    datacell.ProbeTemp(ii)=read340_obj(LS340,ProbeChannel,K_unit);

    datacell.R_Heater(ii)  = sqrt(datacell.X_Heater(ii).^2+datacell.Y_Heater(ii).^2);
    datacell.R_Thermometer(ii)  = sqrt(datacell.X_Thermometer(ii).^2+datacell.Y_Thermometer(ii).^2);
    datacell.BathTemperature(ii) = CXCell{2}(datacell.BathResistance(ii));
    datacell.Thermometer_Resistance(ii) = datacell.Thermometer_Voltage_DC(ii)./Current_Thermometer;
    datacell.SampleTemperature(ii) = CXCell{1}(datacell.Thermometer_Resistance(ii));
    datacell.TOsc_Rough(ii) = datacell.R_Thermometer(ii)./(abs(SensitivityCurve(datacell.Thermometer_Resistance(ii))).*Current_Thermometer.*LI_Gain);
    if mod(ii,200)==1
        figure(DataFigure);
        
        subplot(2,2,1);        
        plot(datacell.Time,datacell.SampleTemperature,'-r','DisplayName','Sample T');
        hold on;
        plot(datacell.Time,datacell.BathTemperature,'-b','DisplayName','Bath T');
        xlabel('Time [s]'); ylabel('T [K]'); hold off;
        
        subplot(2,2,2); hold off;
        plot(datacell.Time,datacell.R_Thermometer.*1e6,'-k');
        xlabel('Time [s]'); ylabel('R_{CX} [\muV]');
        
        subplot(2,2,3); hold off;
        plot(datacell.BathTemperature,datacell.TOsc_Rough,'-k');
        xlabel('T_{Bath} [K]'); ylabel('T_{Osc} [K]');
        
        subplot(2,2,4); hold off;
        plot(datacell.BathTemperature,1./datacell.TOsc_Rough,'-k');
        xlabel('T_{Bath} [K]'); ylabel('1/T_{Osc} \propto C_S [K^{-1}]');
        drawnow;
        save(Filename,'-struct','datacell');
    end
    ii = ii+1;
    jj = jj+1;
end




save(Filename,'-struct','datacell');
% K6221_WaveMode_OnOff(K6221_Heater,'Off');

end

function filename = GenerateFilename(DAQ,CurrentTemperature,CurrentField)
% DAQ is the unaltered DAQ input.
% CurrentTemperature -- String.
CurrentTemperature = num2str(round(CurrentTemperature,2));
filename = [DAQ.Tswpfileroot,regexprep([DAQ.SampleInfoStr,'_',...
    CurrentTemperature,'K_',num2str(round(CurrentField)),...
    'T_',datestr(now,'mm_dd_yyyy_HH_MM_SS')],...
    '\.','p'),'.mat'];
end