RvTfunction voltageresult = Keithley6220QueryDelta(object)

%Edited: 
    %Ian and Alex  June 26, 2015
%Function: 
    %Prepare Keithley 6220 and 6221 for delta mode measurement.
%Inputs: 
    %object = Open Keithley 6220 or 6221 object.
%Outputs:
    %output = Voltage
    
    fprintf(object,'CALC2:IMMediate');      %Sends a calculate mean command to the object.
    fprintf(object, 'CALC2:DATA?');     %Assigns the calculated value to voltageresult. 
    voltageresult=str2double(fscanf(object));
end 