function NewCenter = FrequencySweep_FastSRS_Ian(DAQ)

SaveFilename = MakeFilename();
h2 = figure('Position',[10 67 920 924]);
% iFreq= linspace(43200,44200,3000);
% iFreq = 43200:.33:47000;
SRS830 = DAQ.SRS830; 
A33210 = DAQ.A33210; 
LS331 = DAQ.LS331; 
FrequencyValues = DAQ.FrequencyValues; 
tic;
Data.Amplitude = DAQ.Amplitude; 
disp(['Measuring at: ',num2str(readLS331_IanSimple(LS331))]);
for t=1:length(FrequencyValues)
    iFreqS = num2str(FrequencyValues(t));
    Data.Freq(t) = FrequencyValues(t);
    iFreqS = ['FREQ ',iFreqS];
    Data.BathTemperature(t) = readLS331_IanSimple(LS331);
    fprintf(A33210,iFreqS);
    [Data.X(t),Data.Y(t)]=ReadSRS830_XY(SRS830);
    Data.Time(t) = toc;
%     iFreq=iFreq+2;
    if mod(t,50)==1
        subplot(2,4,1:2); plot(Data.Freq./1000,Data.X.*1e6,'.k');
        xlabel('f [KHz]'); ylabel('X [\muV]');
        subplot(2,4,5:6); plot(Data.Freq./1000,Data.Y.*1e6,'.g');
        xlabel('f [KHz]'); ylabel('Y [\muV]');
        subplot(2,4,[3,4,7,8]); plot(Data.X.*1e6,Data.Y.*1e6,'.b');
        xlabel('X [\muV]'); ylabel('Y [\muV]');
        drawnow;
        save(SaveFilename,'-struct','Data')
    end
end
save(SaveFilename,'-struct','Data')
[~,MaxInd] = max(Data.X); 
[~,MinInd] = min(Data.X); 
NewCenter = mean([Data.Freq(MaxInd),Data.Freq(MinInd)]);
close(h2);
end

function SaveFilename = MakeFilename()
fileroot = 'C:\Data\Kyle\CL5_Data\Cooldown\';
SampleInfoStr = 'CL5_300K_Tests_Pumped_50mV_Cooldown';
format shortg
c = clock;
date='';
for i=1:6
    date = strcat(date,'_',num2str(round(c(i)),'%02d'));
end
filenamestr = regexprep([SampleInfoStr,'_',date],'\.','p');
SaveFilename = fullfile(fileroot,[filenamestr,'.mat']);

end