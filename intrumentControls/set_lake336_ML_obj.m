function set_lake336_ML_obj(obj1,loop,setpoint,htrrange)
%Set the desired heater range in [W] and the setpoint on a given loop in
%[K]

%chan 'A','AB','CD',ABC' etc
%sens 'SENS?' for ohms, 'KDRG? in kelvin

% fprintf(obj1,'INTYPE C,8,2,1,5,'); %sets temp controller input C type to cernox
% fprintf(obj1,['INCRV C,'  sprintf('%d',curv_num)]); %sets temp controller input C to use curve_num
        fprintf(obj1, ['RANGE ' num2str(loop) ' ' num2str(htrrange)]);
        fprintf(obj1, ['SETP ' num2str(loop) ', ' num2str(setpoint)]);
        
end