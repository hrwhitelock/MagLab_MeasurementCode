% Ian Leahy
% April 30, 2018
% Function to convert vec to string made of mean.

function outstr = vec2str(invec,precisionnum)
outstr=num2str(mean(invec),['%.',num2str(precisionnum),'f']);
end
