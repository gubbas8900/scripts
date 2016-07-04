#!/usr/bin/ksh 

USERNAME=$1

cp -r /etc/skel/Maildir /home/${USERNAME}/
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/Maildir
chmod -R 700 /home/${USERNAME}/Maildir
