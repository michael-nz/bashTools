# bashTools
Support bash scripts to automate manual tasks 

Using this script users can established Password less SSH connection for multiple servers with same user. This script can establish any number of SSH connection. To use this script your server should support sshpass otherwise you want be able to automated the process. This script will create ssh public key and integrate it to the relevant servers. Finally it will check the connectivity and write all logs to the log file located in “ssh _log”.

NOTE:-
Password of the specific user should be same in all servers.

How to use
Step1- 
Run  ./CreateSSHConnection.sh

Step2-
Give relevant User Inputs
