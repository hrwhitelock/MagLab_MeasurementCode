function V = TwoSets_DualDeltaMeasurePoint(DAQ)
% Primary_Left=DAQ.Primary_Left;
% Secondary_Left=DAQ.Secondary_Left;
% Primary_Right=DAQ.Primary_Right;
% Secondary_Right=DAQ.Secondary_Right;
% Current_Left=DAQ.Current_Left;
% Current_Right=DAQ.Current_Right;
% PointsPerPulse=DAQ.PointsPerPulse=5;
% Pulses=DAQ.Pulses=5; 
% DeltaPauseTimes=DAQ.DeltaPauseTime=.5; 
% VoltRange=DAQ.VoltRange=0.001; 
% DAQ.Left_Sample='';
% DAQ.Right_Sample=''
% DAQ.Left_Primary_Contacts=''
% DAQ.Left_Secondary_Contacts=''
% DAQ.Left_Primary_Contacts=''
% DAQ.Left_Secondary_Contacts=''

pausetime=1.5;
Keithley6220StartDelta(DAQ.Primary_Left);
Keithley6220StartDelta(DAQ.Secondary_Left); 
Keithley6220StartDelta(DAQ.Primary_Right);
Keithley6220StartDelta(DAQ.Secondary_Right);
pause(pausetime+.3); 

V.Primary_Left=Keithley6220QueryDelta(DAQ.Primary_Left);
V.Secondary_Left=Keithley6220QueryDelta(DAQ.Secondary_Left);
V.Primary_Right=Keithley6220QueryDelta(DAQ.Primary_Right);
V.Secondary_Right=Keithley6220QueryDelta(DAQ.Secondary_Right);
pause(pausetime-.3); 

end
