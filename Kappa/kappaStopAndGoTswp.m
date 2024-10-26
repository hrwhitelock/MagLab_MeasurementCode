function kappaStopAndGoTswp(DAQ, tempArr, numCycles)
    scm2LS = OpenGPIBObject(DAQ.SCM2_ls);
    fprintf(scm2LS, 'KRDG?D');
    currentTemp = fscanf(scm2LS, '%f');
    vi = DAQ.vi; 
    currentField = vi.GetControlValue('Field [T]');
    
    for i=1:length(tempArr)
        %% create filename
        SampleInfoStr = DAQ.SampleInfoStr;
        fileroot = DAQ.StopAndGoTswpfileroot;
        format shortg
        c = clock;
        date='';
        for i=1:6
            date = strcat(date,'_',num2str(round(c(i)),'%02d'));
        end
        filenamestr = regexprep([SampleInfoStr,'_',num2str(round(currentTemp,2)),'K_',num2str(round(currentField,2)),'T',date],'\.','p');
        filename = fullfile(fileroot,[filenamestr,'.mat']);
        display(filename)




        %% creating new directory to store all the files that will be created

        newFolderName = ['Cycles', filenamestr];
        cd(fileroot);
        mkdir(newFolderName);
        cd(newFolderName);


        %% take data
        for i = 1:numCycles
            current = 
            one_cycle_thermTrans(filenamestr, i, current, DAQ)
            pause(5); % in s
        end
        disp([newline 'Done taking data']);
        % turn_off_remote_devices();

        % change directory back to original location
        cd(fileroot);
    end
end