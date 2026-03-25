function obj1=OpenGPIBObject(gpibaddress)

%Edited: 
    %MATLAB generated  June 8, 2015
%Function: 
    %Opens any GPIB obect
%Inputs: 
    %gpibaddress = GPIB address of instrument

obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', gpibaddress, 'Tag', '');

% Create the GPIB object if it does not exist otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('NI', 0, gpibaddress);
else
    fclose(obj1);
    obj1 = obj1(1);
end


fopen(obj1);

end