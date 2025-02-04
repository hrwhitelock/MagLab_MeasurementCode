function one_cycle_thermTrans(filename, cycleNum, current, DAQ)

%% initializing all the info that will be needed for the data collection
vi = DAQ.vi; 

cycleFilename = ['Cycle_', num2str(cycleNum), '_', filename];

% initialized variables used later on
data_pts_sofar = 0;

% open lakeshores
scm2LS = OpenGPIBObject(DAQ.SCM2_ls);
bath =OpenGPIBObject(DAQ.gpib_ls370_3_Bath);
hot =OpenGPIBObject(DAQ.gpib_ls370_1_Hot);
cold =OpenGPIBObject(DAQ.gpib_ls370_2_Cold);

heaterVoltage = OpenGPIBObject(DAQ.heaterVoltage_gpib); 

% open current source, change to current mode, set current (but doesn't
% turn output on yet
% in Dr. Caos lab the device is a precision current source
YGS200_gpib = DAQ.Yoko_gpib;
YGS200_obj = OpenMultipleGPIBObjects(YGS200_gpib, 0);
fprintf(YGS200_obj, ':SOURce:FUNCtion CURRent');
fprintf(YGS200_obj, ':OUTPut:STATe OFF');

% updates the current, sends the command and turns output on
heater_current = current * DAQ.current_multipliers(1);
DAQ.current_multipliers(1) = [];
yokoampset(heater_current,DAQ.Yoko_gpib);
yokoOn(DAQ.Yoko_gpib);

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
    fprintf(scm2LS, 'KRDG?C');
    datacell.ChanC(ii) = fscanf(scm2LS, '%f');
    fprintf(scm2LS, 'KRDG?D');
    datacell.ChanD(ii) = fscanf(scm2LS, '%f');

    datacell.bathRes(ii) = LS372_Read_Obj(bath); 
    datacell.bathTemp(ii) = DAQ.CXcell{3}(datacell.bathRes(ii)); 
    datacell.field(ii) = vi.GetControlValue('Field [T]');

    datacell.coldRes(ii) = LS372_Read_Obj(cold); 
    datacell.coldTemp(ii) = DAQ.CXcell{2}(datacell.coldRes(ii));
    datacell.hotRes(ii) = LS372_Read_Obj(hot); 
    datacell.hotTemp(ii) = DAQ.CXcell{1}(datacell.hotRes(ii));
    datacell.heaterVoltage(ii) = read2182aVoltage(heaterVoltage);

	datacell.logicalArray(ii) = false;
    
	% recording the current through the heater
	datacell.current(ii) = heater_current/1000;
	datacell.power(ii) = (heater_current/1000) * datacell.heaterVoltage(ii);
    
	%% changing of the current --> need to rewrite this so that it changes current to produce temp gradient that's 1% of overall temp
	if toc - DAQ.time_since_change > DAQ.seconds_to_wait

    	if data_pts_sofar < DAQ.desired_num_data_pts
        	datacell.logicalArray(ii) = true;
        	data_pts_sofar = data_pts_sofar + 1;

    	else
        	% reset data pts so far
        	data_pts_sofar = 0;
       	 
        	% if all that's left is to set the current to 0 mA, then we
        	% want to wait extra
        	if length(DAQ.current_multipliers) == 1
            	DAQ.time_since_change = toc + 5; % +extra time because toc ticks upwards
           	 
        	elseif isempty(DAQ.current_multipliers)
            	% if we hit this it means we've cycled all the way through
            	% and it's time to break out
            	cycle_completed = true;
            	break;
           	 
        	else % any time that 0 isn't the only multiplier left in current_multipliers
            	DAQ.time_since_change = toc;
        	end

        	% updates the current, sends the command
        	heater_current = current * DAQ.current_multipliers(1);
        	DAQ.current_multipliers(1) = [];
        	yokoampset(heater_current,DAQ.Yoko_gpib)

    	end
	end

	%% if mod ii 50, then we plot
	if mod(ii, 25) == 0
   	 
        % create a new figure for the current cycle


    	% Plots for K2002 (sample voltage and temp gradients)
    	subplot(3,2,1);
    	plot(datacell.Time,datacell.hotTemp-datacell.coldTemp,'-c.'); grid on; box on;

    	ylabel('temp'); xlabel('Time [s]'); title('delta t');

    	subplot(3,2,2);hold on; 
        
    	plot(datacell.Time,datacell.bathTemp,'-m.'); grid on; box on;
    	ylabel('Temp [K]'); xlabel('Time [s]'); title('bath');

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
    	plot(datacell.Time,datacell.hotTemp,'-c.', 'DisplayName', 'hot temp'); grid on; box on;

%         legend()
    	ylabel('temp K]'); xlabel('Time [s]'); title('hot ');
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
    	ylabel('temp K]'); xlabel('Time [s]'); title('Cold');
        yyaxis right
        plot(datacell.Time,datacell.coldRes,'-b.', 'DisplayName', 'cold res'); grid on; box on;
        ylabel('resistance ohm')
        yyaxis left
        hold off; 
        
        
        subplot(3,2,6); 
        yyaxis left; 
        plot(datacell.Time, datacell.field, '-b'); grid on; box on; 
        ylabel('field (T)'); xlabel('Time (s)'); title('Field'); 
        yyaxis right; 
        plot(datacell.Time, datacell.ChanD, '--g')
        ylabel('temp [K]'); 
        
    	drawnow;

	end
	pause(.25);
	ii=ii+1;
	save(cycleFilename,'-STRUCT','datacell');
end

save(cycleFilename,'-STRUCT','datacell');

% make sure current is turned off and close remote connections to each
% device
yokoOff(DAQ.Yoko_gpib);
fclose(scm2LS) 
fclose(bath)
fclose(cold) 
fclose(hot) 
fclose(heaterVoltage)

%% check if the overall file exists. if it doesnt make it, if it does append data
if ~isfile('All cycles data.mat')
    % if it's not a file, this is the first time through and we can just
    % save current data as overall data
    save('All cycles data', '-STRUCT', 'datacell');
else
    % load overall data
    overallData = load('All cycles data');
    fields = fieldnames(overallData);

	for n = 1:length(fields)
        % time is the only field that we don't just want to append, we want
        % the times we are appending to be the recorded times plus the
        % final time of the overall data
        if strcmp(fields{n}, 'Time')
            mostRecentTime = overallData.Time(end);
            overallData.Time = [overallData.Time, datacell.Time + mostRecentTime];
        else
            overallData.(fields{n}) = [overallData.(fields{n}), datacell.(fields{n})];
        end
    end
    
    % save overall data
    save('All cycles data','-STRUCT','overallData');
end

fclose(YGS200_obj)
fclose(scm2LS) 
fclose(bath)
fclose(cold) 
fclose(hot) 
fclose(heaterVoltage)
close(fig);
