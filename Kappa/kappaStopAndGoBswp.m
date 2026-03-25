function kappaStopAndGoBswp(DAQ,current, fieldArr, waitTime, slewRate, stepWidth)
vi = DAQ.vi;
scm2LS = OpenGPIBObject(DAQ.SCM2_ls);
fprintf(scm2LS, 'KRDG?D');
currentTemp = fscanf(scm2LS, '%f');
fileroot= DAQ.StopnGoBswpfileroot;
cd(fileroot);
newFolderName = regexprep([DAQ.SampleInfoStr,'_',num2str(round(currentTemp,2)),'K_'],'\.','p');
mkdir(newFolderName);
cd(newFolderName);
fileroot = fullfile(fileroot, newFolderName); 
for i=1:length(fieldArr)
    % run Bsweep
%     stepWidth = DAQ.seconds_to_wait +10; 
    kappaBswp(DAQ, current*sqrt(2), fieldArr(i), slewRate, stepWidth)
    pause(waitTime) 
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



    %% take data
%     for ii = 1:2
        ii = 1;
        one_cycle_thermTrans(filenamestr, ii, current, DAQ)
%         pause(5); % in s
%     end
    disp([newline 'Done taking data']);
    % turn_off_remote_devices();

    % change directory back to original location
    cd(fileroot);
    close all;
end
close all; 
end