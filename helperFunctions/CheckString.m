% Ian Leahy
% March 28, 2018
% Check if input is a valid string in a list of acceptable options
% (optionlist). If invalid string is entered, wait for valid input after
% listing options. 
% option     - Selected option, can be input if invalid selection.
% optionlist - List of valid options. 
function option=CheckString(option,optionlist)

combostring='Please select a valid option, ya jabroni!  \n';
for i=1:length(optionlist)
    combostring=[combostring,'-',optionlist{i},'-\n'];
end
while ~ismember(option,optionlist)
    option=input(sprintf(combostring),'s');
end

end