% Ian Leahy
% May 25, 2018
% Impose a current limit and error if current is exceeded.

function CurrentLimitCheck(inpcurr,currlim)
if sum(inpcurr>currlim)
    error(['Current exceeds ' num2str(currlim) ' Amps! Check your current limit before proceeding!']);
end
end