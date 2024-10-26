function [Sensitivity,Timeconstant,Amplitude,Frequency]=getsrs830_Obj(obj1)



fprintf(obj1, 'SENS ?');
Sensitivity = str2num(fscanf(obj1));
fprintf(obj1, 'OFLT ?');
Timeconstant = str2num(fscanf(obj1));
fprintf(obj1, 'FREQ ?');
Frequency = str2num(fscanf(obj1));
fprintf(obj1, 'SLVL ?');
Amplitude = str2num(fscanf(obj1));


end
