% Ian Leahy
% 9/22/17
% Turns log space polynomial fit into a function that's analytically
% differentiable.

function tempfitfunc=Poly2FuncHandle(inpoly)


lxs='log(x)';
tempfitfunc=['@(x) exp(' ];
for l=1:length(inpoly.p)
    tempfitfunc=[tempfitfunc,'+',num2str(inpoly.p(l),'%.14f'),'.*',lxs,'.^',num2str(7-l)];
end
tempfitfunc=[tempfitfunc,')'];
tempfitfunc=str2func(tempfitfunc);



end