function SetEmailPrefs()

MessageEmail='CULeeLabSpamBot@gmail.com';
Password='trumpettrash';
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','E_mail',MessageEmail);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
setpref('Internet','SMTP_Username',MessageEmail);
setpref('Internet','SMTP_Password',Password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', ...
                  'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','587');
end
