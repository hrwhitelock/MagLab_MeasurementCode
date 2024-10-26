% Ian Leahy
% May 2, 2022
% Set ouput state of keithley to on or off; 
function K6221_WaveMode_OnOff(K6221_Obj,OutputState)

switch OutputState
    case 'On'
        fprintf(K6221_Obj,'SOUR:WAVE:ARM');
        fprintf(K6221_Obj,'SOUR:WAVE:INIT'); 
    case 'Off'
        fprintf(K6221_Obj,'SOUR:WAVE:ABOR'); 
end

end