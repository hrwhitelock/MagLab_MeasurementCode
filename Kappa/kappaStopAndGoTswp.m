% set temp and settle
function kappaStopAndGoTswp(DAQ, Tarr, fileroot, ramprate, highRangeTemp, lowRangeTemp)
    stepWidthArr = interp1(DAQ.TdataArr, DAQ.stepDataArr, Tarr, 'linear'); 
    baseCurrentArr = interp1(DAQ.TdataArr, DAQ.currDataArr, Tarr, 'linear'); 
    for i = 1:length(Tarr)
        target =Tarr(i);
        
        %% folder
        cd(fileroot);
        newFolderName = regexprep([DAQ.SampleInfoStr,'_',num2str(round(target)),'K'],'\.','p');
        mkdir(newFolderName);
        cd(newFolderName);
        newFileRoot = fullfile(fileroot, newFolderName); 
        if target >= highRangeTemp
            htrrange = 3; 
        elseif target < highRangeTemp && target > lowRangeTemp
            htrrange = 2; 
        elseif target<=lowRangeTemp
            htrrange = 1; 
        end
        loop =DAQ.TempControlLoop;% probe loop
        %% set the temp here
%         ramprate =.5; %K/min 
        setTempAndWait(DAQ, target, loop, htrrange, ramprate);
%         pause(settleTime(i)); 
        pause(90); 
        %% set params
        DAQ.seconds_to_wait = (stepWidthArr(i)/4)*2.5; % please change this to a param passed into one cycle function instead 
        current = baseCurrentArr(i); % one mA


        %% cycle 1
        format shortg
        c = clock;
        date='';
        for j=1:6
            date = strcat(date,'_',num2str(round(c(j)),'%02d'));
        end
        filenamestr = regexprep([DAQ.SampleInfoStr,'_',num2str(target),'K_',date],'\.','p');
        numCycles = 1; 

        one_cycle_thermTrans(filenamestr, numCycles, current, DAQ)


    end
end