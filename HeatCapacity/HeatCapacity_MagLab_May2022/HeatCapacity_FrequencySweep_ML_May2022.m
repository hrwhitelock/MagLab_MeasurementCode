% Ian Leahy
% 5/2/2022
% Heat Capacity Frequency Sweep

function HeatCapacity_FrequencySweep_ML_May2022(DAQ)

% Open GPIB Objects and extract DAQ measurement parameters.
SRS830_Thermometer = OpenGPIBObject_BufferSize(DAQ.SRS830_Thermometer_gpib);
SRS830_Heater      = OpenGPIBObject_BufferSize(DAQ.SRS830_Heater_gpib);
K2182_Thermometer  = OpenGPIBObject(DAQ.K2182_Thermometer_gpib);
% K6220_Thermometer  = OpenGPIBObject(DAQ.K6220_Thermometer_gpib);
K6221_Heater       = OpenGPIBObject(DAQ.K6221_Heater_gpib);
obj_ls340_1              = OpenGPIBObject(DAQ.LS340_gpib);
obj_ls370_3_Bath   = OpenGPIBObject(DAQ.LS370_gpib);
K6221_WaveModeSetup(K6221_Heater);
vi=DAQ.vi;
SamplesPerStep = DAQ.SamplesPerStep;
BathChannel = DAQ.BathChannel;
VTIChannel = DAQ.VTIChannel;
ProbeChannel = DAQ.ProbeChannel;

FrequencySweepVector = DAQ.FrequencySweepVector;
PointsPerFrequency = DAQ.PointsPerFrequency;

CXCell = DAQ.CXCell;
SensitivityCurve = DAQ.SensitivityCurve;
ProbeChannel = DAQ.ProbeChannel;
K_unit = 'KRDG?';
R_unit = 'SRDG?';

datacell.Current_Thermometer = DAQ.Current_Thermometer;
Current_Thermometer = datacell.Current_Thermometer;
datacell.SetHeaterCurrent      = DAQ.SetHeaterCurrent;
Current_Heater = datacell.SetHeaterCurrent;
datacell.LI_Gain = DAQ.LI_Gain;
LI_Gain = datacell.LI_Gain;
datacell.PointsPerFrequency = PointsPerFrequency;

K6221_WaveMode_SetAmplitude(K6221_Heater,Current_Heater);
K6221_WaveMode_SetFrequency(K6221_Heater,FrequencySweepVector(1));
K6221_WaveMode_OnOff(K6221_Heater,'On');
% LI_TimeConstant = SRS830_FindTimeConstant(FrequencySweepVector(1));
% SRS830_Set_Sens_Tau(SRS830_Heater,'',LI_TimeConstant,'Time Constant Only')
% SRS830_Set_Sens_Tau(SRS830_Thermometer,'',LI_TimeConstant,'Time Constant Only');
% pause(3*5);
pause(5);

% Measure preliminary temperature for filename;
BathResistance = LS372_Read_Obj(obj_ls370_3_Bath);
CurrentTemperature = CXCell{2}(BathResistance);
CurrentField = vi.GetControlValue('Field [T]');

Filename = GenerateFilename(DAQ,CurrentTemperature,CurrentField);
display(Filename)

% Calculate a rough sensitivity for to estimate Tosc during measurement.
Thermometer_Resistance = readonevoltage(K2182_Thermometer)./Current_Thermometer;
RoughSensitivity = SensitivityCurve(Thermometer_Resistance); % In ohm/K. To get gradient, divide resistance reating by sensitivity.

datacell.Field = CurrentField; 
% Sweep frequency.
ii = 1;
DataFigure = figure;
MyClock = tic;
for i=1:length(FrequencySweepVector)
    SetFrequency = FrequencySweepVector(i);
    SetAmplitude = Current_Heater;
    %     K6221_WaveMode_SetAmplitude(K6221_Heater,SetAmplitude);
    K6221_WaveMode_SetFrequency(K6221_Heater,SetFrequency);
    %     LI_TimeConstant = SRS830_FindTimeConstant(SetFrequency);
    %     Heater_LI_Sensitivity = SRS830_findOptimalSens(SRS830_Heater);
    Heater_LI_Sensitivity = NaN;
    Thermometer_LI_Sensitivity = NaN;
    LI_TimeConstant = 3;
    %     Thermometer_LI_Sensitivity = SRS830_findOptimalSens(SRS830_Thermometer);
    %     SRS830_Set_Sens_Tau(SRS830_Heater,Heater_LI_Sensitivity,LI_TimeConstant,'Time Constant Only')
    %     SRS830_Set_Sens_Tau(SRS830_Thermometer,Heater_LI_Sensitivity,LI_TimeConstant,'Time Constant Only')
    %     pause(20);
    for j=1:PointsPerFrequency
        % Measurements as close together as possible.
        datacell.Time(ii) = toc(MyClock);
        [datacell.X_Heater(ii),datacell.Y_Heater(ii)] = ReadSRS860_Maglab_XY(SRS830_Heater);
        [datacell.X_Thermometer(ii),datacell.Y_Thermometer(ii)] = ReadSRS860_Maglab_XY(SRS830_Thermometer);
        datacell.Thermometer_Voltage_DC(ii) = readonevoltage(K2182_Thermometer);
        datacell.BathResistance(ii) = LS372_Read_Obj(obj_ls370_3_Bath);
        datacell.VTITemp(ii)=read340_obj(obj_ls340_1,VTIChannel,K_unit);
        datacell.ProbeTemp(ii)=read340_obj(obj_ls340_1,ProbeChannel,K_unit);
        
        
        
        % Calculations.
        datacell.Heater_LI_Sensitivity(ii) = Heater_LI_Sensitivity;
        datacell.Heater_LI_Timeconstant(ii) = LI_TimeConstant;
        datacell.Thermometer_LI_Sensitivity(ii) = Thermometer_LI_Sensitivity;
        datacell.Thermometer_LI_Timeconstant(ii) = LI_TimeConstant;
        datacell.Frequency(ii) = SetFrequency;
        datacell.HeaterAmplitude(ii) = SetAmplitude;
        datacell.R_Heater(ii)  = sqrt(datacell.X_Heater(ii).^2+datacell.Y_Heater(ii).^2);
        datacell.R_Thermometer(ii)  = sqrt(datacell.X_Thermometer(ii).^2+datacell.Y_Thermometer(ii).^2);
        datacell.BathTemperature(ii) = CXCell{2}(datacell.BathResistance(ii));
        datacell.Thermometer_Resistance(ii) = datacell.Thermometer_Voltage_DC(ii)./Current_Thermometer;
        datacell.SampleTemperature(ii) = CXCell{1}(datacell.Thermometer_Resistance(ii));
        datacell.TOsc_Rough(ii) = datacell.R_Thermometer(ii)./(RoughSensitivity.*Current_Thermometer.*LI_Gain);
        datacell.VOsc_Times_Frequency(ii) = datacell.R_Thermometer(ii).*datacell.Frequency(ii)./LI_Gain;
        
        if mod(ii,100)==1
            figure(DataFigure);
            
            subplot(2,2,1); hold on;
            plot(datacell.Time,datacell.BathTemperature,'-b','DisplayName','Bath T');
            plot(datacell.Time,datacell.SampleTemperature,'-r','DisplayName','Sample T');
            xlabel('Time [s]'); ylabel('T [K]'); hold off;
            
            subplot(2,2,2); hold off;
            plot(datacell.Time,datacell.R_Thermometer.*1e6,'-k');
            xlabel('Time [s]'); ylabel('R_{CX}.*Gain [\muV]');
            
            subplot(2,2,3:4); hold off;
            plot(datacell.Frequency,datacell.VOsc_Times_Frequency.*1e6,'-ok');
            xlabel('f [Hz]'); ylabel('V_{Osc}\cdotf [\muV\cdotHz]');
            
            drawnow;
        end
        
        
        
        ii = ii+1;
    end
    save(Filename,'-struct','datacell');
end
save(Filename,'-struct','datacell');
K6221_WaveMode_OnOff(K6221_Heater,'Off');

end


function filename = GenerateFilename(DAQ,CurrentTemperature,CurrentField)
% DAQ is the unaltered DAQ input.
% CurrentTemperature -- String.
CurrentTemperature = num2str(round(CurrentTemperature,2));
filename = [DAQ.Fswpfileroot,regexprep([DAQ.SampleInfoStr,'_',...
    CurrentTemperature,'K_',num2str(round(CurrentField)),...
    'T_',datestr(now,'mm_dd_yyyy_HH_MM_SS')],...
    '\.','p'),'.mat'];
end

