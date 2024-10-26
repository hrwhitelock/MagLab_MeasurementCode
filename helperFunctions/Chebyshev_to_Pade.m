% Ian Leahy
% August 31, 2017
% Pade approximant function. For R v T calibration curves. First, fit RvT
% curves with a Chebyshev. The resulting chebyshev is computationally
% costly, so approximate it as the ratio of two taylor series. Much faster
% computationally. Notice, computing the approximant at order greater than
% 8 takes a significant amount of time (5-10 minutes). Anything lower is
% fast. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%INPUTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inputcheby - Input chebyshev fit. 
% PadeOrder  - The order of Pade Approximant. The default setting sets the
%              order of the numerator and denominator equivalent. 
% ExpansionPoint - What point should the expansion start?

function PadeApproximant=Chebyshev_to_Pade(inputcheby,PadeOrder,ExpansionPoint)
syms x;
s = sym( formula(inputcheby ) );
cn = coeffnames( inputcheby );
cv = coeffvalues( inputcheby );
for i = 1:length( cn )
    s = subs( s, cn{i}, cv(i) );
end
PadeApproximant=pade(s,x,ExpansionPoint,'Order',[PadeOrder PadeOrder]);
PadeApproximant=matlabFunction(PadeApproximant);
end
