% Ian Leahy
% 5/2/2022
% Function to setup wave mode, including phase marker state and correct
% trigger line. 
function K6221_WaveModeSetup(K6221_Obj)
fprintf(K6221_Obj,'SOUR:WAVE:FUNC SIN'); 
fprintf(K6221_Obj,'SOUR:WAVE:OFFS 0');
fprintf(K6221_Obj,'SOUR:WAVE:PMAR:STAT ON');
fprintf(K6221_Obj,'SOUR:WAVE:PMAR 0'); 
fprintf(K6221_Obj,'SOUR:WAVE:PMAR:OLIN 1');
fprintf(K6221_Obj,'SOUR:WAVE:RANG FIXED'); 
end