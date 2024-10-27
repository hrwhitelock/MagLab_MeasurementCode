function sendEmail(Recipient,Subject,Message,Attachments)


% Recipient=ValidOptionCheck(Recipient);
% switch Recipient
%     case 'hope'
%         Address='hope.whitelock@colorado.edu';
%     otherwise 
%         error('Invalid Recipient');
% end

Address= Recipient; %'hope.whitelock@colorado.edu';

mail = 'zorgath923@gmail.com';
password = 'fgdy mdnk qhuc oteq';
server = 'smtp.gmail.com';  

setpref('Internet','E_mail',mail);
setpref('Internet', 'SMTP_Server', server)
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

sendmail(Address,Subject,Message,Attachments);

end

