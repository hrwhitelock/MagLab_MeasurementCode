function [Rval,Thval] = readsrs860_RThetaPulse(gpibaddress)
%Reads output of x,y,r, or theta from SRS830

obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0,...
    'PrimaryAddress', gpibaddress, 'Tag', '');

if isempty(obj1)
    obj1 = gpib('NI', 0, gpibaddress);
else
    fclose(obj1);
    obj1 = obj1(1);
end
 datanum = 100;
 Rarr= ones(1,datanum);
 Tharr= Rarr;
fopen(obj1);
for i=1:datanum
        fprintf(obj1, sprintf('%s%d%s%d','SNAP? ',3,',',4)); %takes reading from srs830
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
fclose(obj1);

end
