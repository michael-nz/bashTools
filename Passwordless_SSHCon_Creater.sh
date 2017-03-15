#!/bin/bash
###-------------------------------------------------------------------- 
### Version     : 1.0.0.0
### Author      : michael-nz
### Discription : Used For create password less SSH for multiple servers
###--------------------------------------------------------------------


SYSTEM_NAME=`whoami`
SYSTEM_DATE=`date +%Y_%m_%d_%H.%M.%S`
FILE=${HOME}"/ssh_log/"${SYSTEM_NAME}"_ssh_configuration.file"

CheckError(){
        # Paramrters
        # ==========
        # $1 - Command Return Value
        # $2 - Internal Referance Value

        if [ $1 -gt 0 ];then
		echo "CheckError - Error While Executing the Last Command Please look ssh log file! [$1 - $2]"
                echo "CheckError - Error While Executing the Last Command! [$1 - $2] ">>${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
                exit $1
        else
               
		echo "CheckError - Last Command Executed Successfully! [$1 - $2]">>${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
        fi
}


	if [ -d ${HOME}/ssh_log ];
	then
                  echo ""
		  echo "-----------PRECONFIG_SSH_LOGS_AVIALABLE------------"  
	 else
		  mkdir ${HOME}/ssh_log
	          CheckError $? Create_ssh_log_directory

	fi


if [ -f $FILE ];
then

   mv  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file  ${HOME}/ssh_log/${SYSTEM_DATE}_${SYSTEM_NAME}_ssh_configuration.file
   echo " Start Process to Config password less SSH for Distributed Users ">> ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
   CheckError $? back_up_Current_file   

else
   echo "   SSH CONFIG FIRST TIME   ">>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file

fi

echo "Start Date  :"$SYSTEM_DATE >>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
echo ""

#Display GUI
echo "            Display GUI "                    >>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
echo " "                                           >>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
echo "          CONFIGURATION PASSWORDLESS SSH        "
echo "        CONFIGURATION PASSWORDLESS SSH        ">>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
echo " "
echo "------------------------------------------- ">>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
echo -en "\e[32mInsert Number of Disribution Machines    :\e[0m"
read Count
echo "Number of Distributed Machines "${Count}       >>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
echo -en "\e[32mInsert Destination UserID                :\e[0m"
read user
echo "Distributed User Name "$user                 >>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file

echo -en "\e[32mInsert Destination UserPassword          :\e[0m"
read -s userpass
echo
echo "Distributed User password "$userpass             >>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file

#-------------------------------------------------------------------
echo "------------------------------------------- ">>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
#--------------------------------------------------------------------

#Calculate Count
#--------------------------------------------------------------------
Count=`expr ${Count} - 1`
#--------------------------------------------------------------------

#Get Machine IP List
for (( c=0; c<=Count; c++ ))
do
  echo -en "\e[32mInsert Destination User IP               :\e[0m"
  read ip
  array[$c]=$ip
  #echo ${array[c]}
done
#--------------------------------------------------------------------


#--------------------------------------------------------------------
size=${#array[@]}
size=`expr ${size} - 1`
#--------------------------------------------------------------------


echo "">>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
#Display Machine list
for (( c=0; c<=size; c++ ))
do
  echo "Distribution Machine List : "${array[c]}>>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
  
done
#--------------------------------------------------------------------
echo "">>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file


#Check Information 
echo -en "\e[32mPlease press " y " to continue or Ctrl+c exit:\e[0m"
read chk
if [ $chk != "y" ]; then
    exit 1
fi
#--------------------------------------------------------------------
echo -en "\e[32mCreationg SSH directory:\e[0m"
echo " "


	if [ -f ~/.ssh/id_rsa.pub ]
	then
		echo "SSH PUBKEY AVILABLE " >> ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
		cd ~/.ssh
	else

		#Create client machione .ssh directory
		mkdir ~/.ssh
		echo " "
		echo -en "\e[32mConfiguration SSH Started:\e[0m"
		echo " "
		cd .ssh
		#--------------------------------------------------------------------
		#Generate Public key
		echo `ssh-keygen -t rsa -N "" -f id_rsa`>>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
		CheckError $? Generate_SSH_KEY
		cat id_rsa.pub >> authorized_keys
		CheckError $? authorized_keys
		cat id_rsa.pub >> known_hosts
 		CheckError $? known_hosts
		#--------------------------------------------------------------------
		echo " "
		echo -en "\e[32mConfiguration SSH For Client machine Completed:\e[0m">>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
		echo " "

	fi


for (( c=0; c<=size; c++ ))
do
#	ssh $user@${array[$c]} mkdir -p .ssh
         sshpass -p ${userpass} ssh  $user@${array[$c]} -o StrictHostKeyChecking=no 'mkdir -p .ssh && exit'
	 CheckError $? Create_.SSH_Directory	
#	scp id_rsa.pub $user@${array[$c]}:.ssh/known_hosts
	 sleep 1
         sshpass -p ${userpass} scp id_rsa.pub $user@${array[$c]}:.ssh/known_hosts
	 CheckError $? Copy_Pub_Key_to_known_hosts
#	scp id_rsa.pub $user@${array[$c]}:.ssh/authorized_keys
         sleep 1
         sshpass -p ${userpass} scp id_rsa.pub $user@${array[$c]}:.ssh/authorized_keys
         CheckError $? Copy_Pub_Key_to_authorized_keys
	 sleep 1

	
	echo ""
	echo "Successfully Copy Pub key">>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
done

#--------------------------------------------------------------------



#Check connection
Hostname=`hostname`

for (( c=0; c<=size; c++ ))
do
	ssh $Hostname exit
	ssh -q $user@${array[$c]} exit
	CheckError $? Check_SSH_Connection
	CheckError $? Check_SSH_Connection_Hostname

	if [ $? -eq 0 ]
	then
   		 echo "Passwordless SSH configuration Success in :" ${array[$c]}
		 echo "Passwordless SSH configuration Success in :" ${array[$c]}>>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
	else
		    echo "Passwordless SSH configuration Fail in    :" ${array[$c]}
		    echo "Passwordless SSH configuration Fail in    :" ${array[$c]}>>  ${HOME}/ssh_log/${SYSTEM_NAME}_ssh_configuration.file
	fi
done
#--------------------------------------------------------------------
#END
#--------------------------------------------------------------------
