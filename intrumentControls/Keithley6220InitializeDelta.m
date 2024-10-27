function Keithley6220InitializeDelta(object,setvoltagerange,setcurrent,DeltaPointsPerPulse,DeltaPulses)

%Edited: 
    %Ian and Alex  June 26, 2015
%Function: 
    %Prepare Keithley 6220 and 6221 for delta mode measurement.
%Inputs: 
    %object = Open Keithley 6220 or 6221 object.
    %setvoltagerange = The set voltage sensitivity range.
    %setcurrent = The delta mode set current.
    %DeltaPointsPerPulse = Number of points inside of a delta pulse.
    %DeltaPulses = Number of total pulses.
    

    fprintf(object, '*RST');
%    fprintf(object, 'SYSTem:COMMunicate:SERial:SEND "VOLT:RANG .1"') ;  % {SET VOLT RANGE}
    fprintf(object, ['SYSTem:COMMunicate:SERial:SEND "VOLT:RANG ', sprintf('%.12g',setvoltagerange),'"']) ;  % {SET VOLT RANGE}
    fprintf(object, 'TRACe:CLEar');
    fprintf(object, ['SOUR:DELT:HIGH ', sprintf('%.12g',setcurrent)]);  % {Sets high source value to 12 decimal places}  //units are Amps
    fprintf(object, 'SOUR:DELT:DELay 10e-3');    % {Sets Delta delay}
    fprintf(object, 'UNIT VOLTS');               % {Sets units}
    fprintf(object, 'SENS:AVER:TCON REP');
    fprintf(object, ['SENS:AVER:COUN ', sprintf('%i',DeltaPointsPerPulse)]);
    fprintf(object, 'SENS:AVER ON');
    fprintf(object, ['SOUR:DELT:COUN ', sprintf('%i',DeltaPulses)]); % {Sets Delta pulses}
    fprintf(object, 'SOUR:DELT:CAB ON');            % {Enables Compliance Abort}
    fprintf(object, ['TRAC:POIN ', sprintf('%i',DeltaPulses)]);      % {buffer: SAME AS DELTA COUNT}
    fprintf(object, 'CALC2:FORM MEAN');
    fprintf(object, 'CALC2:STATE ON');              % {enables buffer calcualtion}
    fprintf(object, 'SOUR:DELT:ARM');               % {Arms Delta}
end 