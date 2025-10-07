function read372 = LS372_Read_Obj(obj1)

fprintf(obj1,'RDGR? 1'); %takes temp controller reading
c = fscanf(obj1,'%s');
c = str2double(c);
read372 = c;

end