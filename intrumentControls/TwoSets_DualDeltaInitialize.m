
function TwoSets_DualDeltaInitialize(DAQ)
% Set One
Keithley6220InitializeDelta(DAQ.Primary_Left,DAQ.VoltRange,DAQ.Current_Left,...
    DAQ.PointsPerPulse,DAQ.Pulses+1); 
Keithley6220InitializeDelta(DAQ.Secondary_Left,DAQ.VoltRange,DAQ.Current_Left,...
    DAQ.PointsPerPulse,DAQ.Pulses);
pause(2);
% Set Two
Keithley6220InitializeDelta(DAQ.Primary_Right,DAQ.VoltRange,DAQ.Current_Right,...
    DAQ.PointsPerPulse,DAQ.Pulses+1);
Keithley6220InitializeDelta(DAQ.Secondary_Right,DAQ.VoltRange,DAQ.Current_Right,...
    DAQ.PointsPerPulse,DAQ.Pulses);
pause(3)
end