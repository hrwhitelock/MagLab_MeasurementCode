% Ian Leahy
% April 23, 2018
% Set current axes to log or linear.

function Set_LogOrLinear(option)
set(gca,'XScale',option); set(gca,'YScale',option);
end