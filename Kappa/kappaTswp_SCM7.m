function kappaTswp_SCM7(DAQ, targetTemp, ramprate, stepWidth)
% hope aug 2025
% extra time is in minutes

% currentArr should be passed in to calculate the current based on
% temperature. tempArr is for the same thing and should be same length
%

currentArr = DAQ.currDataArr; 
tempArr = DAQ.TdataArr;
saveCounter = 0; 
notAtTemp = true; 
vi = DAQ.vi; 

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
    currentTemp = DAQ.vi.GetControlValue('Tppms');
    if ii ==3
        vi.SetControlValue('set T',targetTemp);
        vi.SetControlValue('menu',4);
        vi.SetControlValue('rate T',ramprate);
        vi.SetControlValue('menu',5);
    end
    
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
    datacell.PPMSTemp(ii) = currentTemp; 
    
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
    if offcounter > 3 % take ten cycles after field reaches final val
        notAtTemp = false;
        yokoOff(DAQ.Yoko_gpib); 
    end 
    %% do plotting
    if mod(ii, 4000) == 0
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
%         plot(datacell.Time, datacell.PPMSTemp, '--g');
%         ylabel('PPMS temp'); 
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

% msg = '\fontsize{25}Bswp finished'; 
% popup = msgbox(msg, "done"); % uses built in ! icon (usually res for errors) to get my attention at maglab 
fclose(YGS200_obj);
fclose(bath);
fclose(cold) ;
fclose(hot) ;
fclose(heaterVoltage);
end