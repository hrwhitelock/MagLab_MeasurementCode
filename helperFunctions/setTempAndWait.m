function setTempAndWait(DAQ, targetTemp, loop, htrrange, ramprate)
    temptol = 0.001*targetTemp; 
    probetol = 0.0003*targetTemp; % for probe
    bathtol = 0.0005*targetTemp; % the .02 comes from the time between steps being ~0.2s
    timeout = 15*60; %15 min settle time out. No time out for never reaching temp
    % this is on purpose - > if we don't get to the temp we want on the probe,
    % then we probably don't want to take data if we're not here
    disp(['temp tol is ', num2str(temptol)]); 
    disp(['bath rate tol is', num2str(bathtol), 'K/5s']); 
    disp(['probe rate tol is', num2str(probetol), 'K/5s']);
    
    settleWindow = 36; % 3 min 
    set_lake336(DAQ.SCM2_ls,loop,targetTemp,htrrange, ramprate)
    set_lake336(DAQ.SCM2_ls,DAQ.TailControlLoop,targetTemp*.9,htrrange, ramprate)
%     fileroot = DAQ.Testsfileroot; 
    scm2LS = OpenGPIBObject(DAQ.SCM2_ls);
    bath =OpenGPIBObject(DAQ.gpib_ls370_3_Bath);
    hot =OpenGPIBObject(DAQ.gpib_ls370_1_Hot);
    cold =OpenGPIBObject(DAQ.gpib_ls370_2_Cold);
    currentTemp = fscanf(scm2LS, '%f');
    giveUp = abs(targetTemp - currentTemp)/ramprate*60 + 20*60; % if we're really stuck then i don't want to keep trying
%     cd(fileroot);

    format shortg
    c = clock;
    date='';
    for j=1:6
        date = strcat(date,'_',num2str(round(c(j)),'%02d'));
    end
    filenamestr = regexprep([DAQ.SampleInfoStr,'watchSettle', num2str(targetTemp), date],'\.','p');
    fname = filenamestr; %fullfile(fileroot,filenamestr); 

    notAtTemp = true; 
    fig = figure(); 
    ii = 1; 
    tic; 
    startTimeout = false; 

    while notAtTemp % takes points every 5s
        fprintf(scm2LS, 'KRDG?D');
        currentTemp = fscanf(scm2LS, '%f');

        datacell.Time(ii) = toc;

        fprintf(scm2LS, 'KRDG?A');
        datacell.ChanC(ii) = fscanf(scm2LS, '%f');
        datacell.ChanD(ii) = currentTemp; 
        datacell.probeTempMovMean = movmean(datacell.ChanD, settleWindow); 

        datacell.bathRes(ii) = LS372_Read_Obj(bath); 
        datacell.bathTemp(ii) = DAQ.CXcell{3}(datacell.bathRes(ii)); 

        datacell.coldRes(ii) = LS372_Read_Obj(cold); 
        datacell.coldTemp(ii) =  DAQ.CXcell{2}(datacell.coldRes(ii));
        datacell.hotRes(ii) = LS372_Read_Obj(hot); 
        datacell.hotTemp(ii) =  DAQ.CXcell{1}(datacell.hotRes(ii));

        datacell.bathrate = movmean(abs(gradient(datacell.bathTemp)), settleWindow);%rate is K/5s
        datacell.proberate = movmean(abs(gradient(datacell.ChanD)), settleWindow);  

        if mod(ii, 3) == 0
            % create a new figure for the current cycle

            subplot(3,2,1);
            plot(datacell.Time,datacell.ChanC,'-g.'); grid on; box on;
            title('VTI tail');%ylim([0 100]);
            ylabel('Temp (K)'); xlabel('time(s)');

            subplot(3,2,2);
            plot(datacell.Time,datacell.ChanD,'-b.'); grid on; box on;
            title('Probe');%ylim([0 160]);
            ylabel('Temp (K)'); xlabel('time(s)');

            subplot(3,2,3);
            yyaxis left; 
            plot(datacell.Time,datacell.bathTemp,'-b.'); grid on; box on;
            title('bath');%ylim([0 160]); 
            ylabel('resistance'); xlabel('time (s)');
            yyaxis right; 
            plot(datacell.Time,datacell.bathRes,'-m.'); grid on; box on;
            ylabel('resistance')

            subplot(3,2,4);
            yyaxis('left')
            plot(datacell.Time,datacell.coldTemp,'-b.'); grid on; box on;
            title('cold')
            ylabel('temp'); xlabel('time');
            yyaxis('right'); 
            hold on; 
            plot(datacell.Time, datacell.coldRes', '-m.');
            ylabel('resistance');


            subplot(3,2,5);
            yyaxis('left')
            plot(datacell.Time,datacell.hotTemp,'-c.'); grid on; box on
            title('hot'); ylabel('temp (K)'); xlabel('time(s)'); 
            yyaxis('right'); 
            hold on; 
            plot(datacell.Time, datacell.hotRes', '-m.');
            ylabel('resistance'); 

            subplot(3,2,6);
            yyaxis left;
            plot(datacell.Time,datacell.proberate/5*60,'-c.'); grid on; box on
            ylabel('temperature per min');
            yyaxis right; 
            plot(datacell.Time,datacell.bathrate/5*60,'-m.'); grid on; box on
            ylabel('temperature per min'); xlabel('Time [s]'); title('abs Rate K/min');
            drawnow(); 
            save([fname, '.mat'], 'datacell');

        end

        if abs(datacell.probeTempMovMean(ii)-targetTemp) <temptol  && ii> settleWindow
            if startTimeout == false 
                startTimeout = true; 
                timeOutTimer = tic; 
            end
            if datacell.bathrate(ii) <bathtol && datacell.proberate(ii)<probetol
                notAtTemp = false; 
                disp(['settled at', num2str(datacell.bathRes(ii)), 'Ohm']);
                disp(['setteld at', num2str(datacell.bathTemp(ii)), 'K'])
            end
            settleTime = toc(timeOutTimer); 
            if settleTime > timeout
                notAtTemp = false; 
                disp(['temp did not setttle, starting measurement at', num2str(datacell.bathTemp(ii)), 'K']); 
            end
        end
        if datacell.Time(ii) > giveUp
            disp(['temp did not setttle, starting measurement at', num2str(datacell.bathTemp(ii)), 'K']); 
            break
        end
        pause(5);
        ii = ii+1; 
    end
    save([fname, '.mat'], 'datacell');
    savefig([fname, '.fig']); 
    close(fig); 
end