function K6221_WaveMode_SetFrequency(K6221_Obj,Frequency)

fprintf(K6221_Obj,['SOUR:WAVE:FREQ ',num2str(Frequency)]); 

end