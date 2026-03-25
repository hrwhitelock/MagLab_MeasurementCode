function watchCooldown(DAQ)
    % generate filename
    fileroot= DAQ.Testsfileroot;
    cd(fileroot);

    format shortg
    c = clock;
    date='';
    for j=1:6
        date = strcat(date,'_',num2str(round(c(j)),'%02d'));
    end
    filenamestr = regexprep([DAQ.SampleInfoStr,'watchCooldown', date],'\.','p');
    fname = fullfile(fileroot,[filenamestr,'.mat']); 
    LSTempControl_gpib = DAQ.SCM2_ls;
    LSTempControl_obj = OpenMultipleGPIBObjects(LSTempControl_gpib, 0);
    bath =OpenGPIBObject(DAQ.gpib_ls370_3_Bath);
    cold =OpenGPIBObject(DAQ.gpib_ls370_2_Cold);
    hot =OpenGPIBObject(DAQ.gpib_ls370_1_Hot);
%     heater = DAQ.heaterVoltage_gpib; 
    
%     nernst = OpenGPIBObject(4);
%     TEP =OpenGPIBObject(11);

    ColdFit = DAQ.CXcell{2};
    HotFit =DAQ.CXcell{1};
    BathFit = DAQ.CXcell{3};

    % DAQ.CXcell = {M Cal, N Cal, SD1}
%     DAQ.CXcell = {HotFit, ColdFit, BathFit};

    
    
    mymsg = msgbox('stop?');
    ii = 1; 
    tic;
    figure(); 
    while ishandle(mymsg)
        datacell.Time(ii) = toc;
        fprintf(LSTempControl_obj, 'KRDG?C');
        datacell.ChanC(ii) = fscanf(LSTempControl_obj, '%f');
        fprintf(LSTempControl_obj, 'KRDG?D');
        datacell.ChanD(ii) = fscanf(LSTempControl_obj, '%f');
        
        datacell.bathRes(ii) = LS372_Read_Obj(bath); 
        datacell.bathTemp(ii) = BathFit(datacell.bathRes(ii)); 
        
        datacell.coldRes(ii) = LS372_Read_Obj(cold); 
        datacell.coldTemp(ii) = ColdFit(datacell.coldRes(ii));
        datacell.hotRes(ii) = LS372_Read_Obj(hot); 
        datacell.hotTemp(ii) = HotFit(datacell.hotRes(ii));
%         datacell.nernst = read2182aVoltage(nernst);
%         datacell.TEP =  read2182aVoltage(TEP);
%         datacell.heater = read2182aVoltage(heater);
%         datacell.field(ii) = field;

        if mod(ii, 2) == 0
            % create a new figure for the current cycle

            % Plots for K2002 (sample voltage and temp gradients)
            subplot(3,3,1);
            plot(datacell.Time,datacell.ChanC,'-c.'); grid on; box on;
            title('chan C');%ylim([0 100]);

            subplot(3,3,2);
            plot(datacell.Time,datacell.ChanD,'-m.'); grid on; box on;
            title('chan D');%ylim([0 160]);
            subplot(3,3,3);
            yyaxis left;
            plot(datacell.Time,datacell.bathTemp,'-c.'); grid on; box on;
            title('bath');%ylim([0 160]);
            yyaxis right; 
            plot(datacell.Time,datacell.bathRes,'-m.'); grid on; box on

            subplot(3,3,4);
            plot(datacell.Time,datacell.coldTemp,'-c.'); grid on; box on;
            title('cold')
            yyaxis('right'); 
            hold on; 
            plot(datacell.Time, datacell.coldRes', '-m.');
            yyaxis('left')
            subplot(3,3,5);
            plot(datacell.Time,datacell.hotTemp,'-c.'); grid on; box on
            title('hot')
            yyaxis('right'); 
            hold on; 
            plot(datacell.Time, datacell.hotRes', '-m.');
            yyaxis('left')
            subplot(3,3,6);
            plot(datacell.Time,gradient(datacell.ChanD)*6,'-c.'); grid on; box on
            title('probe rate per min');
            ylabel('temperature per min'); xlabel('Time [s]'); title('Rate K/min');
            
%             subplot(3,3,7);
%             plot(datacell.Time,datacell.nernst,'-c.'); grid on; box on
% %             title('probe rate per min');
%             ylabel('nernst (V)'); xlabel('Time [s]'); title('Rate K/min');
%             
%             subplot(3,3,8);
%             plot(datacell.Time,datacell.TEP,'-c.'); grid on; box on
% %             title('probe rate per min');
%             ylabel('TEP (V)'); xlabel('Time [s]'); title('Rate K/min');
            
            drawnow(); 
            save(fname, 'datacell');
            
        end
        ii = ii+1;
%         pause(10); 
    end
  