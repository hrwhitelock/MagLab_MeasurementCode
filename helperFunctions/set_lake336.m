function set_lake336(gpibaddress,loop,setpoint,htrrange, ramprate)
%Set the desired heater range in [W] and the setpoint on a given loop in
%[K]

%chan 'A','AB','CD',ABC' etc
%sens 'SENS?' for ohms, 'KDRG? in kelvin

obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0,...
    'PrimaryAddress', gpibaddress, 'Tag', '');

if isempty(obj1)
    obj1 = gpib('NI', 0, gpibaddress);
else
    fclose(obj1);
    obj1 = obj1(1);
end

fopen(obj1);
% fprintf(obj1,'INTYPE C,8,2,1,5,'); %sets temp controller input C type to cernox
% fprintf(obj1,['INCRV C,'  sprintf('%d',curv_num)]); %sets temp controller input C to use curve_num

        fprintf(obj1, ['RANGE ' num2str(loop) ' ' num2str(htrrange)]);
        fprintf(obj1, ['SETP ' num2str(loop) ', ' num2str(setpoint)]);
        fprintf(obj1, ['RAMP ' num2str(loop) ', ' num2str(1) ', ' num2str(ramprate)]); 
        
end