% Read X,Y simultaneously from SRS830 
% Ian Leahy
% 4/13/22
function [XData,YData] = ReadSRS860_Maglab_XY(SRS_Obj)
fprintf(SRS_Obj,'SNAP? X, Y'); %Send command to read XY simultaneously. 
RS = str2double(split(fscanf(SRS_Obj),',')); 
XData = RS(1); YData = RS(2);
end