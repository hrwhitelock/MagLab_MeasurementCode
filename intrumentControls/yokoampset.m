function yokoampset(current,gpibaddress)
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
fprintf(obj1,'SOURce:FUNCtion CURRent'); 
fprintf(obj1,['SOURce:RANGe ' sprintf('%0.9f',current*1e-3)]); 
fprintf(obj1,['SOURce:LEVel ' sprintf('%0.9f',current*1e-3)]); %Sets current to i
fclose(obj1); 

end