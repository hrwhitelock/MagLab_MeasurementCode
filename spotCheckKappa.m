function spotCheckKappa()
    [baseName, folder] = uigetfile();
    fname = fullfile(folder, baseName); 
    datacell = load(fname); 
    
    % make the plots we normally do from data
    figure(); 
    % set(groot, 'fontsize', 16)
    subplot(3,2,1);
    plot(datacell.Time,datacell.hotTemp-datacell.coldTemp,'-c.'); grid on; box on;

    ylabel('temp'); xlabel('Time [s]'); title('delta t');

    subplot(3,2,2);
    plot(datacell.Time,datacell.bathTemp,'-m.'); grid on; box on;
    ylabel('Temp [K]'); xlabel('Time [s]'); title('bath');

    % plots for K2000 (voltage across heater)
    subplot(3,2,3);
    hold on;
    yyaxis left;
    plot(datacell.Time, datacell.heaterVoltage,'-c.'); grid on; box on;
    ylabel('Voltage [V]'); xlabel('Time [s]');
    yyaxis left;
    
    yyaxis right;
    plot(datacell.Time, datacell.current,'-y.'); grid on; box on;
    ylabel('Current [mA]');
    yyaxis right; 
    title('heater');
    hold off;

    % power through heater
    subplot(3,2,4);
    hold on; 
    plot(datacell.Time,datacell.hotTemp,'-c.', 'DisplayName', 'hot temp'); grid on; box on;

%         legend()
    ylabel('temp K]'); xlabel('Time [s]'); title('hot');
    yyaxis right
    plot(datacell.Time,datacell.hotRes,'-r.', 'DisplayName', 'hot res'); grid on; box on;

    ylabel('resistance ohm')
    yyaxis left
    hold off; 
    % power through heater
    subplot(3,2,5);
    hold on; 
    plot(datacell.Time,datacell.coldTemp,'-m.', 'DisplayName', 'cold temp'); grid on; box on;
%         legend()
    ylabel('temp K]'); xlabel('Time [s]'); title('cold');
    yyaxis right
    plot(datacell.Time,datacell.coldRes,'-b.', 'DisplayName', 'cold res'); grid on; box on;
    ylabel('resistance ohm')
    yyaxis left
    hold off; 

end