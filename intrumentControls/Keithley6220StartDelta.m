function Keithley6220StartDelta(object)

%Edited: 
    %Ian and Alex  June 26, 2015
%Function: 
    %Prepare Keithley 6220 and 6221 for delta mode measurement.
%Inputs: 
    %object = Open Keithley 6220 or 6221 object.
    
    fprintf(object,'INIT:IMM');    %{Starts Delta measurements}
end