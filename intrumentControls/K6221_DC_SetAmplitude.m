function K6221_DC_SetAmplitude(K6221_Obj,Amplitude)

fprintf(K6221_Obj,['CURR:AMPL ',num2str(Amplitude)]); 

end