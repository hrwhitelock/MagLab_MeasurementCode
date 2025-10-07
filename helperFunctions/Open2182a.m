function obj1 = Open2182a(gpibaddress)
%Sets measurement parameters for a Keithley 2182A Nanovoltmeter
%1/24/14 Ben Chapman

obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0,...
    'PrimaryAddress', gpibaddress, 'Tag', '');

if isempty(obj1)
    obj1 = gpib('NI', 0, gpibaddress);
else
    fclose(obj1);
    obj1 = obj1(1);
end

fopen(obj1);


end