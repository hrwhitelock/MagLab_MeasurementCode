function yoko_off(gpibaddress)

%Turns off output from Yokogawa GS200 source meter

obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0,...
    'PrimaryAddress', gpibaddress, 'Tag', '');

if isempty(obj1)
    obj1 = gpib('NI', 0, gpibaddress);
else
    fclose(obj1);
    obj1 = obj1(1);
end

fopen(obj1);
fprintf(obj1,['OUTPut OFF'])%Sets voltage mode

fclose(obj1)
delete(obj1)
end