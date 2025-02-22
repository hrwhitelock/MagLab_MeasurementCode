function datacell = one_cycle_kappa_home(current)

%% initializing all the info that will be needed for the data collection
% this is justa  quick function for at home
% uses 1 ls 340, 1 k2000, and 1 yoko

% initialized variables used later on
data_pts_sofar = 0;
desired_num_data_pts = 75; 
% open lakeshores
lakeshore = OpenGPIBObject(13);
% bath =OpenGPIBObject(DAQ.gpib_ls370_3_Bath);
% hot =OpenGPIBObject(DAQ.gpib_ls370_1_Hot);
% cold =OpenGPIBObject(DAQ.gpib_ls370_2_Cold);

heaterVoltage = OpenGPIBObject(3); 

% open current source, change to current mode, set current (but doesn't
% turn output on yet
% in Dr. Caos lab the device is a precision current source
YGS200_gpib = 11;
YGS200_obj = OpenMultipleGPIBObjects(YGS200_gpib, 0);
fprintf(YGS200_obj, ':SOURce:FUNCtion CURRent');
fprintf(YGS200_obj, ':OUTPut:STATe OFF');

% updates the current, sends the command and turns output on
Yoko_gpib = 11; 
current_multipliers = [0,1, 1.414, 0];
heater_current = current * current_multipliers(1);
current_multipliers(1) = [];
yokoampset(heater_current,Yoko_gpib);
yokoOn(Yoko_gpib);

time_since_change = 0; 

% set plot sizes to our default;
set(groot, 'defaultAxesFontSize', 16);
set(groot, 'defaultTextFontSize', 16);
set(groot, 'defaultLineMarkerSize', 'remove');

% Doesn't actually get used to break the loop but does keep the loop
% running while this is false
cycle_completed = false;

ii=1;
tic;
fig = figure('WindowState', 'maximized', 'DefaultAxesFontSize',12);
%% DATA COLLECTION BEGINS HERE'
while ~cycle_completed

    
    %first record data
    datacell.Time(ii) = toc;
    fprintf(lakeshore, 'SRDG?A');
    datacell.hotRes(ii) = fscanf(lakeshore, '%f');
    fprintf(lakeshore, 'SRDG?B');
    datacell.coldRes(ii) = fscanf(lakeshore, '%f');
    datacell.heaterVoltage(ii) = read2182aVoltage(heaterVoltage);

	datacell.logicalArray(ii) = false;
    
	% recording the current through the heater
	datacell.current(ii) = heater_current/1000;
	datacell.power(ii) = (heater_current/1000) * datacell.heaterVoltage(ii);
    
	%% changing of the current --> need to rewrite this so that it changes current to produce temp gradient that's 1% of overall temp
	if toc - time_since_change > 15

    	if data_pts_sofar < desired_num_data_pts
        	datacell.logicalArray(ii) = true;
        	data_pts_sofar = data_pts_sofar + 1;

    	else
        	% reset data pts so far
        	data_pts_sofar = 0;
       	 
        	% if all that's left is to set the current to 0 mA, then we
        	% want to wait extra
        	if length(current_multipliers) == 1
            	time_since_change = toc + 5; % +extra time because toc ticks upwards
           	 
        	elseif isempty(current_multipliers)
            	% if we hit this it means we've cycled all the way through
            	% and it's time to break out
            	cycle_completed = true;
            	break;
           	 
        	else % any time that 0 isn't the only multiplier left in current_multipliers
            	time_since_change = toc;
        	end

        	% updates the current, sends the command
        	heater_current = current * current_multipliers(1);
        	current_multipliers(1) = [];
        	yokoampset(heater_current,Yoko_gpib)

    	end
	end

	%% if mod ii 50, then we plot
	if mod(ii, 25) == 0
   	 
        % create a new figure for the current cycle

    	% plots for K2000 (voltage across heater)
    	subplot(3,2,3);
        yyaxis left;
    	plot(datacell.Time, datacell.heaterVoltage,'-c.'); grid on; box on;
    	ylabel('Voltage [V]'); xlabel('Time [s]');
        yyaxis left;
        hold on;
        yyaxis right;
        plot(datacell.Time, datacell.current*1000,'--g.'); grid on; box on;
        ylabel('Current [mA]');
        yyaxis right; 
        title('heater');
        subtitle([ num2str(current), 'mA']);
        hold off;

        % power through heater
        subplot(3,2,4);
        hold on; 
        grid on; box on; xlabel('Time [s]'); title('hot ');
        plot(datacell.Time,datacell.hotRes,'-r.', 'DisplayName', 'hot res'); grid on; box on;

        ylabel('resistance ohm')
        yyaxis left
        hold off; 
        % power through heater
        subplot(3,2,5);
        hold on; 
        xlabel('Time [s]'); title('Cold');
        plot(datacell.Time,datacell.coldRes,'-b.', 'DisplayName', 'cold res'); grid on; box on;
        ylabel('resistance ohm')
        yyaxis left
        hold off; 
        
        
    	drawnow;

	end
	pause(.25);
	ii=ii+1;
end


% make sure current is turned off and close remote connections to each
% device
yokoOff(Yoko_gpib);
fclose(lakeshore);
fclose(heaterVoltage);

