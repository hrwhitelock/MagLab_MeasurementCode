function setsrs830_Obj(obj1,freq,amp,fmod,siginp,inpcpl,grnd,samplerate,sensitivity,timeconstant)
%sets parameters for SRS830
%freq is in units of Hz
%amp is in units of volts.  must be between .004 and 5.
%fmod indicates whether lockin uses internal (1) or external (0) wave
%source
%siginp indicates whether signal input is A (0), A-B (1), I (10^6) (2)
%or I (10^8) (3)
%inpcpl is AC (0) or DC (1)
%rate is sample rate (see manual) 1 Hz (4) 2 Hz (5) 4 Hz (6) 8 Hz (7)
%16 Hz (8)
%loop dictates whether to store data in the buffer in a 1 shot method
%(0) or loop (1)

%Sensitivity
% 0 2 nV/fA 13 50 ?V/pA
% 1 5 nV/fA 14 100 ?V/pA
% 2 10 nV/fA 15 200 ?V/pA
% 3 20 nV/fA 16 500 ?V/pA
% 4 50 nV/fA 17 1 mV/nA
% 5 100 nV/fA 18 2 mV/nA
% 6 200 nV/fA 19 5 mV/nA
% 7 500 nV/fA 20 10 mV/nA
% 8 1 ?V/pA 21 20 mV/nA
% 9 2 ?V/pA 22 50 mV/nA
% 10 5 ?V/pA 23 100 mV/nA
% 11 10 ?V/pA 24 200 mV/nA
% 12 20 ?V/pA 25 500 mV/


%timeconstant:
% i time constant 
% 0 10 ?s 
% 1 30 ?s 
% 2 100 ?s 
% 3 300 ?s
% 4 1 ms 
% 5 3 ms 
% 6 10 ms 
% 7 30 ms 
% 8 100 ms 
% 9 300 ms 
% 10 1 s
% 11 3 s
% 12 10 s
% 13 30 s
% 14 100 s
% 15 300 s
% 16 1 ks
% 17 3 ks
% 18 10 ks
% 19 30 ks

%sample rates
% i quantity    i quantity
% 0 62.5 mHz    7 8 Hz
% 1 125 mHz     8 16 Hz
% 2 250 mHz     9 32 Hz
% 3 500 mHz     10 64 Hz
% 4 1 Hz        11 128 Hz
% 5 2 Hz        12 256 Hz
% 6 4 Hz        13 512 Hz

fprintf(obj1,['FMOD' num2str(fmod)]);
fprintf(obj1,['SENS' num2str(sensitivity)]);
fprintf(obj1,['ISRC' num2str(siginp)]);
fprintf(obj1,['ICPL' num2str(inpcpl)]);
fprintf(obj1,['FREQ' num2str(freq)]);
fprintf(obj1,['SLVL' num2str(amp)]);
fprintf(obj1,['IGND' num2str(grnd)]);
fprintf(obj1,['SRAT' num2str(samplerate)]);
fprintf(obj1,['OFLT' num2str(timeconstant)]);
%fprintf(obj1,['SEND' num2str(loop)]);

end
