function SweepT_KvT_AcquireContinuous_v4(DAQ, End, Rate, tol)

    %% Set local variables
  %  gpib_ls340_1 = DAQ.gpib_ls340_1;
    gpib_ls336_1 = DAQ.gpib_ls336_1;
    TempControlLoop = DAQ.TempControlLoop;
%    BathChannel = DAQ.BathChannel;
    SorbChannel = DAQ.VTIChannel;
    SorbHtrRange = DAQ.SampleHTRRange;
    ProbeChannel = DAQ.ProbeChannel;
   
    
    %% Constants (Do not change)
    K_unit = 'KRDG?';
    R_unit = 'SRDG?';
    
    %% Start acquisition
    %ThermCondMeasureOnePoint(DAQ)
    currentTemp = read340(gpib_ls336_1,SorbChannel,K_unit);
%     %pause(1);
%     setramp_lake340(gpib_ls336_1, loop, 0, Rate);
%     pause(1);
%     set_lake336(gpib_ls336_1,loop,currentTemp,htrrange);
%     pause(1);
%     setramp_lake340(gpib_ls336_1, loop, 1, Rate);
%     pause(1);
%     set_lake336(gpib_ls336_1,loop,End,htrrange);

%% Set Sorb Setpoint
       SorbTemp = read340(gpib_ls336_1,SorbChannel,K_unit);
       ProbeTemp = read340(gpib_ls336_1,ProbeChannel,K_unit);
       
       %Sorb
       setramp_lake340(gpib_ls336_1, TempControlLoop, 0, Rate);
       pause(1);
       set_lake336(gpib_ls336_1,TempControlLoop,SorbTemp,SorbHtrRange);
       pause(1);
       setramp_lake340(gpib_ls336_1, TempControlLoop, 1, Rate);
       pause(1);
       set_lake336(gpib_ls336_1,TempControlLoop,End-.5,SorbHtrRange);
       
       %Probe
       setramp_lake340(gpib_ls336_1, 2, 0, Rate);
       pause(1);
       set_lake336(gpib_ls336_1,2,ProbeTemp,SorbHtrRange);
       pause(1);
       setramp_lake340(gpib_ls336_1, 2, 1, Rate);
       pause(1);
       set_lake336(gpib_ls336_1,2,End,SorbHtrRange);
    
    
    
    
    while abs(currentTemp-End) > tol
        ThermCondHallMeasureOnePoint_v5(DAQ)
        currentTemp = read340(gpib_ls336_1,ProbeChannel,K_unit);
    end

end