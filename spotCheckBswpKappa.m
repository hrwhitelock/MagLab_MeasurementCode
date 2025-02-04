function spotCheckBswpKappa()
    [baseName, folder] = uigetfile();
    fname = fullfile(folder, baseName); 
    datacell = load(fname); 
    
    % make the plots we normally do from data
    figure(); 
    subplot(3,3,1);
    plot(datacell.field,datacell.hotTemp-datacell.coldTemp,'-c.'); grid on; box on;

    ylabel('temp'); xlabel('Field (T)'); title('delta t');

    subplot(3,3,2);
    plot(datacell.field,datacell.bathTemp,'-m.'); grid on; box on;
    ylabel('Temp [K]'); xlabel('Field (T)'); title('bath');

    % plots for K2000 (voltage across heater)
    subplot(3,3,3);
    hold on;
    yyaxis left;
    plot(datacell.field, datacell.heaterVoltage,'-c.'); grid on; box on;
    ylabel('Voltage [V]'); xlabel('Field (T)');
    yyaxis left;
    
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

    subplot(3,3,9); 
    plot(datacell.Time, datacell.field); grid on; box on;
    ylabel('field (T)'); xlabel('Time (s)'); 
    
end