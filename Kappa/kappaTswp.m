function kappaTswp(DAQ, currentArr,tempArr, targetTemp, ramprate, stepWidth, htrrange)
% hope sept 2024
% extra time is in minutes

% currentArr should be passed in to calculate the current based on
% temperature. tempArr is for the same thing and should be same length
%
saveCounter = 0; 
notAtTemp = true; 
vi = DAQ.vi; 

scm2LS = OpenGPIBObject(DAQ.SCM2_ls);
bath =OpenGPIBObject(DAQ.gpib_ls370_3_Bath);
hot =OpenGPIBObject(DAQ.gpib_ls370_1_Hot);
cold =OpenGPIBObject(DAQ.gpib_ls370_2_Cold);

heaterVoltage = OpenGPIBObject(DAQ.heaterVoltage_gpib); 

YGS200_gpib = DAQ.Yoko_gpib;
YGS200_obj = OpenMultipleGPIBObjects(YGS200_gpib, 0);
fprintf(YGS200_obj, ':SOURce:FUNCtion CURRent');
fprintf(YGS200_obj, ':OUTPut:STATe OFF');

heater_current = 0; 
yokoampset(heater_current,DAQ.Yoko_gpib);
yokoOn(DAQ.Yoko_gpib);

currentField =  DAQ.vi.GetControlValue('Field [T]');
fileroot= DAQ.Tswpfileroot;
% fileroot = DAQ.Testsfileroot; 
cd(fileroot);
newFolderName = regexprep([DAQ.SampleInfoStr,'_',num2str(round(currentField)),'T'],'\.','p');
mkdir(newFolderName);
cd(newFolderName);

format shortg
c = clock;
date='';
for j=1:6
    date = strcat(date,'_',num2str(round(c(j)),'%02d'));
end
filenamestr= regexprep([DAQ.SampleInfoStr,'Tsweep_', num2str(round(currentField)),'T', date],'\.','p');

% filenamestr = [filenametrbase, '_', num2str(saveCounter)]
fname = fullfile(fileroot,newFolderName,[filenamestr,'.mat']); 


ii = 1; 
totalTime = tic; 
changetime = tic; 
% htrrange = 1; %default

fig = figure('DefaultAxesFontSize',12); 
oncounter = 1;
offcounter = 1; 
setCounter = 1; 
while notAtTemp
    %% check current temperature
    fprintf(scm2LS, 'KRDG?C');
    datacell.ChanC(ii) = fscanf(scm2LS, '%f');
    fprintf(scm2LS, 'KRDG?D');
    datacell.ChanD(ii) = fscanf(scm2LS, '%f');
    currentTemp = datacell.ChanD(ii);
    if ii ==3
        set_lake336(DAQ.SCM2_ls,DAQ.TempControlLoop,targetTemp,htrrange, ramprate);
        set_lake336(DAQ.SCM2_ls,DAQ.TailControlLoop,targetTemp*.8,htrrange, ramprate);
    end
    
    % determine heater range and set temp initial
%     if ii ==3
%         if (currentTemp <= DAQ.lowHtrTemp )
%             htrrange = 1;
%             set_lake336(DAQ.SCM2_ls,DAQ.TempControlLoop,targetTemp,htrrange, ramprate);
%         elseif (currentTemp > DAQ.lowHtrTemp) && (currentTemp <= DAQ.medHtrTemp) 
%             htrrange = 2;
%             set_lake336(DAQ.SCM2_ls,DAQ.TempControlLoop,targetTemp,htrrange, ramprate);
%         elseif (currentTemp > DAQ.medHtrTemp) 
%             htrrange = 3;
%             set_lake336(DAQ.SCM2_ls,DAQ.TempControlLoop,targetTemp,htrrange, ramprate);
%         else
%         end
%     end
%     % check if heater range is correct and reset
%     if ii > 10 && mod(ii, 400) == 0 % check the heater range
%         if (currentTemp <= DAQ.lowHtrTemp ) && htrrange ~= 1
%             htrrange = 1;
%             set_lake336(DAQ.SCM2_ls,DAQ.TempControlLoop,targetTemp,htrrange, ramprate);
%         elseif (currentTemp > DAQ.lowHtrTemp) && (currentTemp <= DAQ.medHtrTemp) && htrrange ~= 2
%             htrrange = 2;
%             set_lake336(DAQ.SCM2_ls,DAQ.TempControlLoop,targetTemp,htrrange, ramprate);
%         elseif (currentTemp > DAQ.medHtrTemp) && htrrange ~= 3
%             htrrange = 3;
%             set_lake336(DAQ.SCM2_ls,DAQ.TempControlLoop,targetTemp,htrrange, ramprate);
%         else
%         end
%     end
   %% time stamp for current cycle
    checktime = toc(changetime); 
    %% measure everything
    datacell.Time(ii) = toc(totalTime);

    datacell.bathRes(ii) = LS372_Read_Obj(bath); 
    datacell.bathTemp(ii) = DAQ.CXcell{3}(datacell.bathRes(ii)); 
    datacell.field(ii) = DAQ.vi.GetControlValue('Field [T]');

    datacell.coldRes(ii) = LS372_Read_Obj(cold); 
    datacell.coldTemp(ii) = DAQ.CXcell{2}(datacell.coldRes(ii));
    datacell.hotRes(ii) = LS372_Read_Obj(hot); 
    datacell.hotTemp(ii) = DAQ.CXcell{1}(datacell.hotRes(ii));
    datacell.heaterVoltage(ii) = read2182aVoltage(heaterVoltage); 
    datacell.current(ii) = heater_current; 
    
    %% check where we are in cycle
    if ((checktime - stepWidth) <0) && setCounter == 1 % less than stepwidth should be neg
        % first calculate the current
        current = round(interp1(tempArr, currentArr, currentTemp), 3); 
         
        heater_current = 0;
        disp(['off', num2str(heater_current)]);
        yokoampset(heater_current,DAQ.Yoko_gpib);
        setCounter = 2; 
    elseif (checktime - stepWidth) >0 && (checktime-stepWidth*2)<0 && setCounter == 2
        heater_current = current*1; 
        disp(['on', num2str(heater_current)]);
        yokoampset(heater_current,DAQ.Yoko_gpib);
        setCounter =3; 
    elseif (checktime - stepWidth*2) >0 && (checktime-stepWidth*3)<0 && setCounter == 3
        heater_current = current*DAQ.current_multipliers(3); 
        yokoampset(heater_current,DAQ.Yoko_gpib);
    elseif (checktime -stepWidth*3) >0
        setCounter = 1; 
        changetime = tic; 
        oncounter = oncounter+1; 
        if abs(currentTemp-targetTemp)<0.01*targetTemp
            offcounter = offcounter+1; 
        end
    end
    %% check and turn off if at end
    if offcounter > 10 % take ten cycles after field reaches final val
        notAtTemp = false;
        yokoOff(DAQ.Yoko_gpib); 
    end 
    %% do plotting
    if mod(ii, 400) == 0
        save(fname,'-STRUCT','datacell');
%         %% do v quick plot --> commented out for speeeeed
%         subplot(3,2,1);
%     	plot(datacell.Time,datacell.hotTemp-datacell.coldTemp,'-c.'); grid on; box on;
%     	ylabel('temp'); xlabel('Time [s]'); title('delta t');
% 
%     	subplot(3,2,2);
%         yyaxis left; hold on; 
%     	plot(datacell.Time,datacell.bathTemp,'-m.'); grid on; box on;
%     	ylabel('Temp [K]'); xlabel('Time [s]'); title('bath m probe g');
%         yyaxis right; 
%         plot(datacell.Time,datacell.bathRes,'-c.'); grid on; box on;
%     	ylabel('resistance (ohm)'); xlabel('Field (T)'); title('bath');
%         
%     	subplot(3,2,3);
%         yyaxis left;
%     	plot(datacell.Time, datacell.heaterVoltage,'-c.'); grid on; box on;
%     	ylabel('Voltage [V]'); xlabel('time [s]');
%         yyaxis left;
%         hold on;
%         yyaxis right;
%         plot(datacell.Time, datacell.current,'-y.'); grid on; box on;
%         ylabel('Current [mA]');
%         yyaxis right; 
%         title('heater');
%         hold off;
% 
%         % power through heater
%         subplot(3,2,4);
%         hold on; 
%     	plot(datacell.Time,datacell.hotTemp,'-c.', 'DisplayName', 'hot temp'); grid on; box on;
% 
% %         legend()
%     	ylabel('temp K]'); xlabel('Field (T)'); title('hot');
%         yyaxis right
%         plot(datacell.Time,datacell.hotRes,'-r.', 'DisplayName', 'hot res'); grid on; box on;
% 
%         ylabel('resistance ohm')
%         yyaxis left
%         hold off; 
%         % power through heater
%         subplot(3,2,5);
%         hold on; 
%         plot(datacell.Time,datacell.coldTemp,'-m.', 'DisplayName', 'cold temp'); grid on; box on;
% %         legend()
%     	ylabel('temp K]'); xlabel('time'); title('cold');
%         yyaxis right
%         plot(datacell.Time,datacell.coldRes,'-b.', 'DisplayName', 'cold res'); grid on; box on;
%         ylabel('resistance ohm')
%         yyaxis left
%         hold off; 
%         
%         subplot(3,2,6);
%         yyaxis left; 
%         plot(datacell.Time, datacell.field, '-b.'); grid on; box on; 
%         ylabel('field'); xlabel('time (s)'); title('field'); 
%     	yyaxis right; 
%         plot(datacell.Time, datacell.ChanD, '--g');
%         ylabel('probe temp'); 
%         drawnow;
    end
    %% clear variable when it gets too big

%     if mod(ii,80000)== 0
%         saveCounter = saveCounter+1; 
%         filenamestr = [filenamebase, '_', num2str(saveCounter)];
%         fname = fullfile(fileroot,newFolderName,[filenamestr,'.mat']); 
%         clear('datacell')
%     end

    ii = ii+1; 
end

save(fname,'-STRUCT','datacell');

msg = '\fontsize{25}Tswp finished'; 

popup = msgbox(msg, "done", "error"); % uses built in ! icon (usually res for errors) to get my attention at maglab 
fclose(YGS200_obj);
fclose(scm2LS) ;
fclose(bath);
fclose(cold) ;
fclose(hot) ;
fclose(heaterVoltage);
end