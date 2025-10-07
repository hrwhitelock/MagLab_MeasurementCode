function v = read2182aVoltage(k2182a)


fprintf(k2182a,'FETC?');
voltage = fscanf(k2182a,'%s');
voltage = strsplit(voltage,',');

% from the 2002 multimeter the data format is as a 'double' (actually it's in scientific notation, but the exponent is always 00), so v_exp
% should always be 0;
% but for the 2000 multimeter the data is actually in scientific notation, and we
% need to convert it to the double

% regular expression gets rid of the non numeric characters at the end of
% the string. ^/d means any non digit character, and *$ means zero or more
% characters at the end of the string
cleaned_str = regexprep(voltage{1}, '[^\d]*$', '');

v_num = str2double(cleaned_str(1:end-4));
v_exp = str2double(cleaned_str(end-2:end));
v = v_num * 10^v_exp;

end