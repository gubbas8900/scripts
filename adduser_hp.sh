#!/usr/bin/ksh 
#new comment
N[0]="SEARS_Business_User";	    I[0]="ddotts"
N[1]="SEARS_Business_User";	    I[1]="smireck"
#N[1]="Sandeep Dubey";                  I[1]="sdubey"
#N[2]="Balasubramanyam Venkata Vogoti"; I[2]="bvenkat"
#N[3]="Reshmi Ramachandaran";           I[3]="rramac02"
#N[4]="Leo Thangaraj";                  I[4]="lthanga"
#N[5]="Rohan Vaidya";                   I[5]="rvaidy1"
#N[6]="Murthy Avadhanula";              I[6]="mavadha"
#N[7]="Mandadapu Prabhakara";           I[7]="mprabha"
#N[8]="Kanthimathi Santhikumar";        I[8]="ksanthi"

PACMAN="05094120"
HOME="/home"                       # Sometime its "/home1"
PGRP="simiuser"
GRPS="simiuser,staff"
PROFILE=""                         # Copy this .profile
SA_EMAIL="jcarlin@searshc.com"
REMOVE_HOME_DIR="0"                # Normally set to "0" 

# Start from here:
NEXTID=10001

#----------------------FILL OUT THE ABOVE-----------------------------------#

PATH=/usr/bin:/usr/lbin:/usr/sbin:


Return_Random_Element () {

   STRING=$1
   NUMBER=$(($RANDOM%(${#STRING}+1)))
   echo "$STRING $NUMBER" | awk '{print substr($1, $2, 1)}'

}

Generate_Random_Password () {
   set -A C 0 0 0 0 0 0 0

   UPPER="ABCDEFGHJKLMNPQWSTUVWXYZ"
   LOWER="abcdefghjkmnpqrstuvwxyz"
   NUMBER="123456789"

   NUM_POS=$(Return_Random_Element "123456")
   CAP_POS=$NUM_POS
   while [[ $CAP_POS -eq $NUM_POS ]]; do
      CAP_POS=$(Return_Random_Element "01234567")
   done
   
   COUNT=0
   while [[ $COUNT -lt 8 ]]; do

      case $COUNT in

        $NUM_POS ) C[${COUNT}]=$(Return_Random_Element $NUMBER);;
        $CAP_POS ) C[${COUNT}]=$(Return_Random_Element $UPPER);;
        *        ) C[${COUNT}]=$(Return_Random_Element $LOWER);;

      esac

      COUNT=$((COUNT + 1))

   done

   echo ${C[*]} | tr -d " "
}

Message_User () {
   sub_USER="$1"
   sub_NAME="$2"
   sub_HOST="$3"
   sub_PASS="$4"

        sendmail -t << EOF
TO: ${sub_USER}@searshc.com
BCC: ${SA_EMAIL}
Subject: System Access to ${sub_HOST}

THIS IS AN AUTOMATED MESSAGE - PLEASE DO NOT REPLY

${sub_NAME}:
   You have been given access to: ${sub_HOST}

   USER ID : ${sub_USER}
   PASSWORD: ${sub_PASS}

   Please sign on as soon as possible and set your
   permanent password.

If you have any questions, please contact the UNIX administration staff.
.
EOF
}


COUNT=0
while [[ $COUNT -lt ${#N[*]} ]]; do
if [[ -z $(cat /etc/passwd | cut -d: -f3 | grep $NEXTID) ]]; then

   if id ${I[$COUNT]} 2>/dev/null; then
      print "SKIPPED: User already on system!!!\n"
   else

   INITPW=$(Generate_Random_Password)
   CRYPPW=$(echo "${INITPW}$(date +%S)"|/usr/lbin/makekey)
     
   STRING="-u ${NEXTID} -g ${PGRP} -G ${GRPS} -d ${HOME}/${I[$COUNT]} -s /usr/bin/ksh -c '${N[$COUNT]} - PACMAN${PACMAN}' -m -k /etc/skel -p ${CRYPPW} ${I[$COUNT]}"

   eval /usr/sam/lbin/useradd.sam $STRING

   if [[ $PROFILE != "" ]]; then
      cp ${PROFILE}/.profile ${HOME}/${I[$COUNT]}
      chown ${I[$COUNT]} ${HOME}/${I[$COUNT]}/.profile
   elif [[ $REMOVE_HOME_DIR -eq 1 ]]; then
      rm -Rf ${HOME}/${I[$COUNT]}
   fi

   Message_User "${I[$COUNT]}" "${N[$COUNT]}" "$(hostname)" "${INITPW}"

   fi

   COUNT=$((COUNT + 1))

fi
NEXTID=$((NEXTID + 1))

done
