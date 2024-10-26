function SRS830_Set_Sens_Tau(obj1,Sensitivity,TimeConstant,option)
%sets parameters for SRS830

%timeconstant:
% i time constant
% 0 10 ?s
% 1 30 ?s
% 2 100 ?s
% 3 300 ?s
% 4 1 ms
% 5 3 ms
% 6 10 ms
% 7 30 ms
% 8 100 ms
% 9 300 ms
% 10 1 s
% 11 3 s
% 12 10 s
% 13 30 s
% 14 100 s
% 15 300 s
% 16 1 ks
% 17 3 ks
% 18 10 ks
% 19 30 ks


%Sensitivity
% 0 2 nV/fA 13 50 ?V/pA
% 1 5 nV/fA 14 100 ?V/pA
% 2 10 nV/fA 15 200 ?V/pA
% 3 20 nV/fA 16 500 ?V/pA
% 4 50 nV/fA 17 1 mV/nA
% 5 100 nV/fA 18 2 mV/nA
% 6 200 nV/fA 19 5 mV/nA
% 7 500 nV/fA 20 10 mV/nA
% 8 1 ?V/pA 21 20 mV/nA
% 9 2 ?V/pA 22 50 mV/nA
% 10 5 ?V/pA 23 100 mV/nA
% 11 10 ?V/pA 24 200 mV/nA
% 12 20 ?V/pA 25 500 mV/
switch option
    case 'Both'
        fprintf(obj1,['OFLT' num2str(TimeConstant)]);
        fprintf(obj1,['SENS' num2str(Sensitivity)]);
    case 'Time Constant Only'
        fprintf(obj1,['OFLT' num2str(TimeConstant)]);
%         fprintf(obj1,['SENS' num2str(Sensitivity)]);
end
end
