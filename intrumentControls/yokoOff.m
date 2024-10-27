function yokoOff(gpibaddress)
%DC current output from Yokogawa GS200 source meter
%Sets output current level to current (amps)
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0,...
    'PrimaryAddress', gpibaddress, 'Tag', '');
if isempty(obj1)
    obj1 = gpib('NI', 0, gpibaddress);
else
    fclose(obj1);
    obj1 = obj1(1);
end

fopen(obj1);
fprintf(obj1, ':OUTPut:STATe OFF');
fclose(obj1); 


end