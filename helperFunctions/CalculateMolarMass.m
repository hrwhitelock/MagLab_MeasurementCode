% Ian Leahy
% 11/20/17
% Function to calculate the molar mass of a compound. 
% ElementCell should be a cell where each entry is an element in the
% chemical formula. 
% FormulaVec is a vector with the numbers of each element per formula unit.

function MolarMass = CalculateMolarMass(ElementCell,FormulaVec)
PTable=load('E:\IanComputer\Documents\Physics\Minhyea Lee Research\General Useful Functions\PeriodicTable.mat');
MolarMass=0;
for i=1:length(ElementCell)
    MolarMass=MolarMass+PTable.AtomicMass(find(strcmp(PTable.Symbol,['-',ElementCell{i},'-']))).*FormulaVec(i);
end
end
