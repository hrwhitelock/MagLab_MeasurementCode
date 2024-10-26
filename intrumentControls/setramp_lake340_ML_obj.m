function setramp_lake340_ML_obj(obj1, loop, onoff, rate)
% Setpoint is the set temperature.
% Heater_range is the heater range: 0 is Off, 1 is low, 2 is medium, and
% 3 is high.


%Set the desired heater range in [W] and the setpoint on a given loop in
%[K]

%chan 'A','AB','CD',ABC' etc
%sens 'SENS?' for ohms, 'KDRG? in kelvin

fprintf(obj1, ['RAMP ' num2str(loop) ', ' num2str(onoff) ', ' num2str(rate)]);
        
end