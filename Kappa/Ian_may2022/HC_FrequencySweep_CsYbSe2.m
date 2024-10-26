% Ian Leahy
% 5/9/22
% Frequency Sweep Driver
function HC_FrequencySweep_CsYbSe2(LoadOption,PlotOption)

[MS,ProcessParameters] = LoadHeatCapacityData(LoadOption);
[MS] = AddColumns_HeatCapacity(MS,ProcessParameters);

switch PlotOption
    case 'Signal Times Frequency vs Frequency'
        figure; hold on;
        for i=1:length(MS)
            plot(MS(i).UniqueFrequency,MS(i).UniqueFrequency.*MS(i).MeanR,...
                '-o','Color',MS(i).UColor,'DisplayName',MS(i).TLegend,...
                'MarkerFaceColor',brc(MS(i).UColor,.5));
        end
        xlabel('f [Hz]'); ylabel('f*V_{R,CX} [V\cdotHz]');
    case 'Signal Times Frequency vs Frequency Normalized'
        figure; hold on;
        for i=1:length(MS)
            plot(MS(i).UniqueFrequency,MS(i).UniqueFrequency.*MS(i).MeanR./...
                max(MS(i).MeanR.*MS(i).UniqueFrequency),...
                '-o','Color',MS(i).UColor,'DisplayName',MS(i).TLegend,...
                'MarkerFaceColor',brc(MS(i).UColor,.5));
        end
        xlabel('f [Hz]'); ylabel('f*V_{R,CX}./V_{Max} [V\cdotHz]');
        
    case 'Signal vs Frequency'
        
end

end

function [outstruct,ProcessParameters] = LoadHeatCapacityData(LoadOption)

switch LoadOption
    case 'CD1 CsYbSe2'
        fileroot = 'C:\Users\LeeLabLaptop\Documents\Maglab_May2022\HeatCapacity\HomeMeasurements_WithSample\FrequencySweeps\';
    case 'CD1 BG'
        fileroot = 'C:\Users\LeeLabLaptop\Documents\Maglab_May2022\HeatCapacity\HomeMeasurements\FrequencySweeps\';
    otherwise
        disp('Invalid LoadOption')
end

ProcessParameters = [];
cd(fileroot);
DStore = dir('*.mat');
for i=1:length(DStore)
    outstruct(i) = load(DStore(i).name);
end

for i=1:length(DStore)
    outstruct(i).name = DStore(i).name;
end


end

function outstruct = AddColumns_HeatCapacity(instruct,ProcessParameters)
outstruct = instruct;

colorz = jet(length(outstruct));
for i=1:length(outstruct)
    
    
    % Clip FS data after stability...take last xx percent.
    CutPercentage = 0.8;
    outstruct(i).UniqueFrequency = unique(outstruct(i).Frequency);
    try
        ToleranceValue = round(outstruct(i).PointsPerFrequency.*CutPercentage);
    catch
        ToleranceValue = round(CutPercentage.*length(outstruct(i).Time)./length(outstruct(i).UniqueFrequency));
    end
    
    for j=1:length(outstruct(i).UniqueFrequency)
        Kinds = outstruct(i).Frequency==outstruct(i).UniqueFrequency(j);
        TempR = outstruct(i).R_Thermometer(Kinds);
        TempR = TempR(ToleranceValue:end);
        outstruct(i).MeanR(j) = mean(TempR);
        outstruct(i).StdR(j)  = std(TempR);
    end
    outstruct(i).UColor = colorz(i,:);
    outstruct(i).TLegend = [num2str(round(mean(outstruct(i).BathTemperature))),' K; I_{Htr} = ',...
        num2str(mean(outstruct(i).HeaterAmplitude.*1000)),' mA'];
    
end

end