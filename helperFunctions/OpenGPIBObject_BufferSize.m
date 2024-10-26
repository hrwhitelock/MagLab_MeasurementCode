function obj1=OpenGPIBObject_BufferSize(gpibaddress)
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', gpibaddress, 'Tag', '');
% Create the GPIB object if it does not exist otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('NI', 0, gpibaddress);
else
    fclose(obj1);
    obj1 = obj1(1);
end

obj1.InputBufferSize = 2^10; 
obj1.OutputBufferSize = 2^10; 
fopen(obj1);

end