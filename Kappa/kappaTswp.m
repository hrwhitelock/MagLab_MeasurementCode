function kappaTswp(DAQ, targetTemp, ramprate, stepwidth, current)
% hope oct 2024
% extra time is in minutes
notAtField = true; 
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

fprintf(scm2LS, 'KRDG?D');
currentField = fscanf(scm2LS, '%f');
fileroot= DAQ.Twpfileroot;
cd(fileroot);
newFolderName = regexprep([DAQ.SampleInfoStr,'_',num2str(round(currentField)),'K'],'\.','p');
mkdir(newFolderName);
cd(newFolderName);

format shortg
c = clock;
date='';
for j=1:6
    date = strcat(date,'_',num2str(round(c(j)),'%02d'));
end
filenamestr = regexprep([DAQ.SampleInfoStr,'Bsweep_', num2str(targetField), date],'\.','p');
fname = fullfile(fileroot,newFolderName,[filenamestr,'.mat']); 

ii = 1; 
totalTime = tic; 

changetime = tic; 
figure(); 
oncounter = 1;
offcounter = 1; 
while notAtField
    if oncounter == 5
        % turn field on
        vi.SetControlValue('Slew Rate [T/min]',slewRate);
        vi.SetControlValue('menu',3);
        vi.SetControlValue('Setpoint [T]',targetField);
        vi.SetControlValue('menu',2);
    end
   
    checktime = toc(changetime); 
%     disp(checktime);
    
    datacell.Time(ii) = toc(totalTime);
    fprintf(scm2LS, 'KRDG?C');
    datacell.ChanC(ii) = fscanf(scm2LS, '%f');
    fprintf(scm2LS, 'KRDG?D');
    datacell.ChanD(ii) = fscanf(scm2LS, '%f');

    datacell.bathRes(ii) = LS372_Read_Obj(bath); 
    datacell.bathTemp(ii) = DAQ.CXcell{3}(datacell.bathRes(ii)); 
    datacell.field(ii) = DAQ.vi.GetControlValue('Field [T]');

    datacell.coldRes(ii) = LS372_Read_Obj(cold); 
    datacell.coldTemp(ii) = DAQ.CXcell{2}(datacell.coldRes(ii));
    datacell.hotRes(ii) = LS372_Read_Obj(hot); 
    datacell.hotTemp(ii) = DAQ.CXcell{1}(datacell.hotRes(ii));
    datacell.nernst(ii) = read2182aVoltage(nernst);
    datacell.TEP(ii) =  read2182aVoltage(TEP);
    datacell.heaterVoltage(ii) = read2182aVoltage(heaterVoltage);
    datacell.logicalArray(ii) = 0; 
    datacell.current(ii) = heater_current; 
    
%     if ((checktime-5) >0 && (checktime-10<0)) || ((checktime-15) >0 && (checktime-20<0))
%         datacell.logicalArray(ii) = 1; 
%     end
    if (checktime - stepWidth) <0
        heater_current = 0;
        yokoampset(heater_current,DAQ.Yoko_gpib);
    elseif (checktime - stepWidth) >0 && (checktime-stepWidth*2)<0
        heater_current = current; 
        yokoampset(heater_current,DAQ.Yoko_gpib);
    elseif (checktime -stepWidth*2) >0
        changetime = tic; 
        oncounter = oncounter+1; 
        if abs(datacell.field(ii)-targetField)<0.05
            offcounter = offcounter+1; 
        end
    end
    if offcounter == 5 % take ten cycles after field reaches final val
        yokoampset(heater_current,DAQ.Yoko_gpib);
        notAtField = false;
        yokoOff(DAQ.Yoko_gpib); 
    end 
    
    if mod(ii, 400) == 0
        save(fname,'-STRUCT','datacell');
        %% do v quick plot --> commented out for speeeeed
        subplot(3,3,1);
    	plot(datacell.field,datacell.hotTemp-datacell.coldTemp,'-c.'); grid on; box on;
    	ylabel('temp'); xlabel('Field (T)'); title('delta t');

    	subplot(3,3,2);
        yyaxis left; 
    	plot(datacell.field,datacell.bathTemp,'-m.'); grid on; box on;
    	ylabel('Temp [K]'); xlabel('Field (T)'); title('bath');
        yyaxis right; 
        plot(datacell.field,datacell.bathTemp,'-c.'); grid on; box on;
    	ylabel('resistance (ohm)'); xlabel('Field (T)'); title('bath');
        
    	subplot(3,3,3);
        yyaxis left;
    	plot(datacell.field, datacell.heaterVoltage,'-c.'); grid on; box on;
    	ylabel('Voltage [V]'); xlabel('Field (T)');
        yyaxis left;
        hold on;
        yyaxis right;
        plot(datacell.field, datacell.current,'-y.'); grid on; box on;
        ylabel('Current [mA]');
        yyaxis right; 
        title('heater');
        hold off;

        % power through heater
        subplot(3,3,6);
        hold on; 
    	plot(datacell.field,datacell.hotTemp,'-c.', 'DisplayName', 'hot temp'); grid on; box on;

%         legend()
    	ylabel('temp K]'); xlabel('Field (T)'); title('hot');
        yyaxis right
        plot(datacell.field,datacell.hotRes,'-r.', 'DisplayName', 'hot res'); grid on; box on;

        ylabel('resistance ohm')
        yyaxis left
        hold off; 
        % power through heater
        subplot(3,3,7);
        hold on; 
        plot(datacell.field,datacell.coldTemp,'-m.', 'DisplayName', 'cold temp'); grid on; box on;
%         legend()
    	ylabel('temp K]'); xlabel('Field (T)'); title('cold');
        yyaxis right
        plot(datacell.field,datacell.coldRes,'-b.', 'DisplayName', 'cold res'); grid on; box on;
        ylabel('resistance ohm')
        yyaxis left
        hold off; 
        
        subplot(3,3,4);
    	plot(datacell.field, datacell.nernst,'-m.'); grid on; box on;
    	ylabel('voltage'); xlabel('Field (T)'); title('nernst');
        
        subplot(3,3,5);
    	plot(datacell.field, datacell.TEP,'-m.'); grid on; box on;
    	ylabel('voltage'); xlabel('Field (T)'); title('TEP ');
        
        subplot(3,3,8); 
        plot(datacell.Time, datacell.field, '-b.'); grid on; box on; 
        ylabel('field'); xlabel('time (s)'); title('field'); 
    	drawnow;
    end
%     if abs(datacell.field(ii)-targetField)<0.05
%         offcounter = offcounter+1; 
%         if offcounter == 250 % take ten cycles after field reaches final val
%             yokoampset(heater_current,DAQ.Yoko_gpib);
%             notAtField = false; 
%         end
%     end
    ii = ii+1; 
end

save(fname,'-STRUCT','datacell');

msg = '\fontsize{25}Bswp finished'; 

popup = msgbox(msg, "done", "error"); % uses built in ! icon (usually res for errors) to get my attention at maglab 
fclose(YGS200_obj);
fclose(scm2LS) ;
fclose(bath);
fclose(cold) ;
fclose(hot) ;
fclose(heaterVoltage);
end

end

