function emailMe(Recipient,Subject,Message,Attachments)


Recipient=ValidOptionCheck(Recipient);
switch Recipient
    case 'Peter'
        Address='7409753451@pm.sprint.com';
    case 'Chris'
        Address='9255196651@vzwpix.com';
    case 'Andrew'
        Address='8645066544@vzwpix.com';
    case 'Ian'
        Address='5703912799@mms.att.net';
    case 'Brant RamGuzzler'
        Address='5082467191@tmomail.net';
    otherwise 
        error('Invalid Recipient');
end


mail = 'culeelabspambot@gmail.com';
password = 'trumpettrash';
server = 'smtp.gmail.com';  

setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

sendmail(Address,Subject,Message,Attachments);

end




function option=ValidOptionCheck(option)
optionlist={'Peter','Ian','Andrew','Chris','Brant RamGuzzler'};
combostring='Please select a valid option: \n';
for i=1:length(optionlist)
    combostring=[combostring,'-',optionlist{i},'-\n'];
end
while ~ismember(option,optionlist)
    option=input(sprintf(combostring),'s');
end
end

