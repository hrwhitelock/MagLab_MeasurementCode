function voltage = readonevoltage(obj1)
%Sets measurement parameters for a Keithley 2182A Nanovoltmeter
%1/24/14 Ben Chapman


fprintf(obj1,'FETC?');

vmeanstring = fscanf(obj1, '%s');
voltage = str2double(vmeanstring);





end