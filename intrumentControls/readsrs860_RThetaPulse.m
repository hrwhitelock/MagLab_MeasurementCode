function [Rval,Thval] = readsrs860_RThetaPulse(obj1)
%Reads output of x,y,r, or theta from SRS830


 datanum = 5;
 Rarr= ones(1,datanum);
 Tharr= Rarr;

for i=1:datanum
        fprintf(obj1, sprintf('%s%d%s%d','SNAP? ',2,',',3)); %takes reading from srs830
        c = fscanf(obj1,'%s');
        commaind = find(c==',');     
%         Rval = str2double(c(1:commaind-1));
%         Thval = str2double(c(commaind+1:end));
     
        Rvaltemp = str2double(c(1:commaind-1));
        Thvaltemp = str2double(c(commaind+1:end));
        Rarr(i)=Rvaltemp;
       Tharr(i)=Thvaltemp;
end
    Rval=mean(Rarr);
    Thval=mean(Tharr);

end
