function setAngle(DAQ, angle)
% hop aug 2025
% current is just recorded for later use, must be hand set by user
    notAtAngle = true; 
vi = DAQ.vi; 

scm2LS = OpenGPIBObject(DAQ.SCM2_ls);
bath =OpenGPIBObject(DAQ.gpib_ls370_3_Bath);
hot =OpenGPIBObject(DAQ.gpib_ls370_1_Hot);
cold =OpenGPIBObject(DAQ.gpib_ls370_2_Cold);

SRS_Obj = OpenGPIBObject(DAQ.srs860); 


fprintf(scm2LS, 'KRDG?D');
currentTemp = fscanf(scm2LS, '%f');
fileroot= DAQ.Testsfileroot;
cd(fileroot);
newFolderName = regexprep([DAQ.SampleInfoStr,'_MRtest_',num2str(round(currentTemp)),'K'],'\.','p');
mkdir(newFolderName);
cd(newFolderName);

format shortg
c = clock;
date='';
for j=1:6
    date = strcat(date,'_',num2str(round(c(j)),'%02d'));
end
filenamestr = regexprep([DAQ.SampleInfoStr,'angleCali_',  date],'\.','p');
fname = fullfile(fileroot,newFolderName,[filenamestr,'.mat']); 

ii = 1; 
totalTime = tic; 

changetime = tic; 
figure(); 
offcounter = 1; 
while notAtAngle
    if ii == 2
        DAQ.Anglevi.SetControlValue('New position',angle);
        DAQ.Anglevi.SetControlValue('menu',2);
    end
    checktime = toc(changetime); 
%     disp(checktime);
    datacell.Time(ii) = toc(totalTime);
    fprintf(scm2LS, 'KRDG?A');
    datacell.ChanC(ii) = fscanf(scm2LS, '%f');
    fprintf(scm2LS, 'KRDG?D');
    datacell.ChanD(ii) = fscanf(scm2LS, '%f');

    datacell.bathRes(ii) = LS372_Read_Obj(bath); 
    datacell.bathTemp(ii) = DAQ.CXcell{3}(datacell.bathRes(ii)); 
    datacell.field(ii) = DAQ.vi.GetControlValue('Field [T]');
    datacell.angle(ii) = DAQ.Anglevi.GetControlValue('BLM Position');

    datacell.coldRes(ii) = LS372_Read_Obj(cold); 
    datacell.coldTemp(ii) = DAQ.CXcell{2}(datacell.coldRes(ii));
    datacell.hotRes(ii) = LS372_Read_Obj(hot); 
    datacell.hotTemp(ii) = DAQ.CXcell{1}(datacell.hotRes(ii));
    [x,y] = ReadSRS860_Maglab_XY(SRS_Obj);
    datacell.srsX(ii) = x;
    datacell.srsY(ii) = y; 
    datacell.logicalArray(ii) = 0; 
    
    if abs(datacell.angle(ii) - angle)<1
        notAtAngle = false;
    end
 
    if mod(ii, 40) == 0
        save(fname,'-STRUCT','datacell');
        %% do v quick plot --> commented out for speeeeed
        subplot(3,2,1);
    	plot(datacell.Time,datacell.hotTemp-datacell.coldTemp); grid on; box on;
    	ylabel('temp'); xlabel('Time (s)'); title('delta t');

    	subplot(3,2,2);
        yyaxis left; 
    	plot(datacell.Time,datacell.bathTemp); grid on; box on;
    	ylabel('Temp [K]'); xlabel('Time (s))'); title('bath');
        yyaxis right; 
        plot(datacell.Time,datacell.bathRes); grid on; box on;
    	ylabel('resistance (ohm)'); xlabel('Time (s))'); title('bath');
        
    	subplot(3,2,3);
        yyaxis left;
    	plot(datacell.Time, datacell.srsX); grid on; box on;
    	ylabel('SRS X'); xlabel('Time (s)');
        yyaxis right; 
        plot(datacell.Time, datacell.srsY);
        ylabel('SRS Y')
        hold off;

        % hot therm
        subplot(3,2,4);
        hold on; 
    	plot(datacell.Time,datacell.hotTemp, 'DisplayName', 'hot temp'); grid on; box on;
    	ylabel('temp K]'); xlabel('Time (s)'); title('hot');
        yyaxis right
        plot(datacell.Time,datacell.hotRes, 'DisplayName', 'hot res'); grid on; box on;
        ylabel('resistance ohm')
        yyaxis left
        hold off; 

        % power through heater
        subplot(3,2,5);
        hold on; 
        plot(datacell.Time,datacell.coldTemp, 'DisplayName', 'cold temp'); grid on; box on;
    	ylabel('temp K]'); xlabel('Time (s)'); title('cold');
        yyaxis right
        plot(datacell.Time,datacell.coldRes, 'DisplayName', 'cold res'); grid on; box on;
        ylabel('resistance ohm')
        yyaxis left
        hold off; 
        
        subplot(3,2,6); 
        plot(datacell.Time, datacell.angle);
        grid on; box on; hold on; 
        ylabel('angle (deg on rotator?)'); xlabel('time (s)'); title('angle');
%         yyaxis right; 
%         plot(datacell.Time, datacell.ChanD)
%         ylabel('probe temp')
        hold off; 
    	drawnow;
    end

    ii = ii+1; 
end
yokoOff(DAQ.Yoko_gpib); 
save(fname,'-STRUCT','datacell');

fclose(scm2LS) ;
fclose(bath);
fclose(cold) ;
fclose(hot) ;

end