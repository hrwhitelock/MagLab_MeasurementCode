%Ian Leahy
%June 13, 2017
%Makes Brighter Colors given some input color and scaleamount. Scale amount
%should be between 0 and 1. QuickName

function brightercolor=brc(inputcolor,scaleamount)
tripletvec=[1,1,1];
diffvec=tripletvec-inputcolor;
scalevec=diffvec*scaleamount;
brightercolor=inputcolor+scalevec;
end
