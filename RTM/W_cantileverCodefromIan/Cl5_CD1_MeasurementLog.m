

DAQ.SRS830=OpenGPIBObjectBSIZE(4);
DAQ.A33210 = OpenGPIBObject(10);
DAQ.LS331 = OpenGPIBObject(15);

DAQ.CenterFrequency = 42.710e3;
DAQ.WindowSize = 50;
DAQ.FrequencyWidth=0.1;
DAQ.Amplitude = 50-3;
MyMessage = msgbox('Stop?');
while ishandle(MyMessage)
DAQ.FrequencyValues = [(DAQ.CenterFrequency-DAQ.WindowSize):DAQ.FrequencyWidth:(DAQ.CenterFrequency+DAQ.WindowSize),repmat(41000,1,20)];
NewCenter = FrequencySweep_FastSRS_Ian(DAQ);
DAQ.CenterFrequency = NewCenter;
close all
end


DAQ.Amplitude = 10e-3;
DAQ.FRes_Guess = 43118;
SimpleThetaPID_DAQ(DAQ);