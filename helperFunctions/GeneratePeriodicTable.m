% Function to Generate Periodic Table .mat file

temp=importdata('E:\IanComputer\Documents\Physics\Minhyea Lee Research\General Useful Functions\PeriodicTableData.csv',',',2);
for i=3:length(temp.textdata)
    PeriodicTable.Symbol{i-2}=['-',temp.textdata{i},'-'];
end
PeriodicTable.AtomicNumber=temp.data(:,1);
PeriodicTable.AtomicMass=temp.data(:,2);

save('E:\IanComputer\Documents\Physics\Minhyea Lee Research\General Useful Functions\PeriodicTable.mat','-struct','PeriodicTable')
