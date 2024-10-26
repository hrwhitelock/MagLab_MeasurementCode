function [Sensitivity,Timeconstant]=getsrs830_SensTau_Obj(obj1)
fprintf(obj1, 'SENS ?');
Sensitivity = str2num(fscanf(obj1));
fprintf(obj1, 'OFLT ?');
Timeconstant = str2num(fscanf(obj1));
end
