function kappaStopAndGoBswp(DAQ,fieldArr, waitTime, slewRate)
vi = DAQ.vi;
scm2LS = OpenGPIBObject(DAQ.SCM2_ls);
fprintf(scm2LS, 'KRDG?D');
currentTemp = fscanf(scm2LS, '%f');
fileroot= DAQ.StopAndGoBswpfileroot;
cd(fileroot);
newFolderName = regexprep([DAQ.SampleInfoStr,'_',num2str(round(currentTemp,2)),'K_'],'\.','p');
mkdir(newFolderName);
cd(newFolderName);
fileroot = fullfile(fileroot, newFolderName); 
for i=1:length(fieldArr)
    vi.SetControlValue('Slew Rate [T/min]',slewRate);
    vi.SetControlValue('menu',3);
    vi.SetControlValue('Setpoint [T]',fieldArr(i));
    vi.SetControlValue('menu',2);
    pause(waitTime) % CHANGE THIS TO SOMETHING BETTTERS
    scm2LS = OpenGPIBObject(DAQ.SCM2_ls);
    fprintf(scm2LS, 'KRDG?D');
    currentTemp = fscanf(scm2LS, '%f');
    currentField = vi.GetControlValue('Field [T]');
    %% create filename
    SampleInfoStr = DAQ.SampleInfoStr;
%     fileroot = DAQ.StopAndGoTswpfileroot;
    format shortg
    c = clock;
    date='';
    for j=1:6
        date = strcat(date,'_',num2str(round(c(j)),'%02d'));
    end
    filenamestr = regexprep([SampleInfoStr,'_',num2str(round(currentTemp,2)),'K_',num2str(round(currentField,2)),'T',date],'\.','p');
    filename = fullfile(fileroot,[filenamestr,'.mat']);
    display(filename)

    %% creating new directory to store all the files that will be created

    newFolderName = ['Cycles', filenamestr];
    cd(fileroot);
    mkdir(newFolderName);
    cd(newFolderName);

    %% init vars    
    % DAQ.currentLookup = currentLookup;% in mA
    % DAQ.tempLookup = tempLookup;% in mA
    DAQ.seconds_to_wait = 40;
    DAQ.extra_waiting_at_end = 50; % to allow current to return from highest current value all the way to no current
    DAQ.desired_num_data_pts = 20;
    DAQ.time_since_change = -20;

    %% take data
    for ii = 1:3
        one_cycle_thermTrans(filenamestr, ii, DAQ.current, DAQ)
        pause(5); % in s
    end
    disp([newline 'Done taking data']);
    % turn_off_remote_devices();

    % change directory back to original location
    cd(fileroot);
    close all;
end
close all; 
end