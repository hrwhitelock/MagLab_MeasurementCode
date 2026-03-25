function streamDataSCM7(DAQ, targetTemp)
% this function is just to output data from instruments as we mess with the
% PPMS
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


fig = figure('DefaultAxesFontSize',12); 

offcounter = 1; 

while notAtTemp
    %% measure everything
    datacell.Time(ii) = toc(totalTime);

    datacell.bathRes(ii) = LS372_Read_Obj(bath); 
    datacell.field(ii) = DAQ.vi.GetControlValue('Field [T]');
    datacell.currentTemp(ii) = DAQ.vi.GetControlValue('Tppms');
    datacell.coldRes(ii) = LS372_Read_Obj(cold); 
    datacell.hotRes(ii) = LS372_Read_Obj(hot); 
    datacell.heaterVoltage(ii) = read2182aVoltage(heaterVoltage); 
%     datacell.current(ii) = heater_current; 
    
%% check where we are in cycle
    if abs(datacell.currentTemp-targetTemp)<0.01*targetTemp
        offcounter = offcounter+1; 
    end

    %% check and turn off if at end
    if offcounter > 200 % take ten cycles after field reaches final val
        notAtTemp = false;
%         yokoOff(DAQ.Yoko_gpib); 
    end 
    %% do plotting
    if mod(ii, 400) == 0
        save(fname,'-STRUCT','datacell');
        %% do v quick plot --> commented out for speeeeed
    	subplot(2,1,1); hold on; box on; grid on; 
        plot(datacell.Time,datacell.hotRes,'-r.', "DisplayName","hot"); 
        plot(datacell.Time,datacell.coldRes,'-b.', "DisplayName","cold");  
        plot(datacell.Time,datacell.bathRes,'-g.', "DisplayName","bath");  
    	ylabel('resistance (ohm)'); xlabel('Field (T)'); title('therms');
        hold off; 
        
        subplot(2,1,2);
        yyaxis left; 
        plot(datacell.Time, datacell.field, '-b.'); grid on; box on; 
        ylabel('field'); xlabel('time (s)'); title('field'); 
    	yyaxis right; 
        plot(datacell.Time, datacell.currentTemp, '--g');
        ylabel('probe temp'); 
        hold off; 
        drawnow;
    end
    % clear variable when it gets too big

%     if mod(ii,80000)== 0
%         saveCounter = saveCounter+1; 
%         filenamestr = [filenamebase, '_', num2str(saveCounter)];
%         fname = fullfile(fileroot,newFolderName,[filenamestr,'.mat']); 
%         clear('datacell')
%     end
% 
    ii = ii+1; 
end

save(fname,'-STRUCT','datacell');
 
fclose(YGS200_obj);
fclose(bath);
fclose(cold) ;
fclose(hot) ;
fclose(heaterVoltage);
end