#!/bin/sh
###########################################################
## Script Name: Simple Automated Backup Script
## Script Author: eNkrypt (Christopher S.)
## Script Date: 10/01/2013
## Updated: 11/20/2013
## Script Description: This script backups everything that is in the folder specified by
## $backupPath and uses the highest multi-threaded compression rate to compress the
## backup into a single tar.gz file.
###########################################################
# Dependents
#-------------
# install screen
# install sshpass
# install pigz
###########################################################
startTime=$(date +%s.%N)
date=$(date +"%m-%d-%Y")
timeNow=$(date +"%T")
 
#-----------------------
#Configurable Variables
#-----------------------
sendScreenCommand=true #Send Commands to the Screen Session?
backupLocal=true #Backup the files to the current machine?
backupRemote=true #Backup the files to a remote machine?
excludeDynmap=false #Exclude the DynMap folder?
 
backupPath="/path/to/what/needs/to/be/backed/up" #NO LEADING FORWARD-SLASH!
storePath="/local/store/path" #ServerName folder will be created in this folder. NO LEADING FORWARD-SLASH!
serverName="SMP"
screenName="MinecraftServer"
fileName="$serverName-$date-$timeNow" #IE: SMP-10-01-2013-01:03:35
dynmapPath="/path/to/dynmap" #NO LEADING FORWARD-SLASH!

#Remote Host Configs
remoteHost="remote.server.com" #This can be an IP address or a URL that points to the IP
remoteUsername="username" #Remote host username
remotePassword="password" #Remote host password
remotePort=22 #Remote host port. This is usually 22.
remoteDirectory="/Remote/Directory" #Exact remote path to store backup. NO LEADING FORWARD-SLASH!

#Using server container like McMyAdmin?
#In otherwords should I issue commands to the screen with /command or simply command
useSlashCommand=false
 
#-------------------------------------
# IF YOU DON'T KNOW WHAT YOU ARE DOING
# DO NOT EDIT BELOW THIS POINT!
#-------------------------------------

#Set Server command syntax
if [[ $useSlashCommand == false ]]; then
save-all="save-all"
save-off="save-off"
else
save-all="/save-all"
save-off="/save-off"
fi
 
#------------------------------
#If sendScreenCommand = true
#------------------------------
if [[ $sendScreenCommand == true ]]; then
#------------------------------
#Send a message to the user
#-----------------------------
screen -S $screenName -X stuff "say Server Backup Initiated. Expect Lag."`echo -ne '\015'`
 
#-------------------------------
#Send save-all command to server
#-------------------------------
screen -S $screenName -X stuff "$save-all"`echo -ne '\015'`
 
#-------------------------------
#Send save-off command to server
#-------------------------------
screen -S $screenName -X stuff "$save-off"`echo -ne '\015'`
#statements
fi
 
#-------------------
#Start server backup
#-------------------
echo "----------------------------"
echo "Starting Back of $serverName..."
echo "----------------------------"
 
#Make sure that both backupLocal and backupRemote are not false
if [[ $backupLocal == false ]] && [[ $backupRemote == false ]]; then
echo "No backup directory specified. Both backupRemote and backupLocal can not be false"
exit
fi
 
echo "Compressing data...."
if [[ $excludeDynmap == true ]]; then
echo "Excluding DynMap from backup..."
tar cvfP - $backupPath* --exclude "$dynmapPath/*" --exclude "$dynmapPath" | pigz -9 - > $fileName.tar.gz
sleep 1
else
tar cvfP - $backupPath* | pigz -9 - > $fileName.tar.gz
sleep 1
fi
 
#---------------------
#If backupLocal = true
#---------------------
if [[ $backupLocal == true ]]; then
echo "Checking if local backup folder exists..."
if [ ! -d $storePath/$serverName ];
then
  mkdir -p $storePath/$serverName;
  echo "Created folder $storePath/$serverName"
else
  echo "Folder already exists. Proceeding..."
fi
mv $serverName* $storePath/$serverName/
fi
 
if [[ $backupRemote == true ]]; then
 
if [[ $backupLocal == false ]]; then
sshpass -p $remotePassword scp -P $remotePort -o StrictHostKeyChecking=no $serverName* $remoteUsername@$remoteHost:$remoteDirectory
rm -f $serverName*
else
sshpass -p $remotePassword scp -P $remotePort -o StrictHostKeyChecking=no $storePath/$serverName/$serverName* $remoteUsername@$remoteHost:$remoteDirectory
fi
fi
 
#------------------------------
#If sendScreenCommand = true
#------------------------------
if [[ $sendScreenCommand == true ]]; then
#-------------------------------
#Send save-on command to server
#-------------------------------
screen -S $screenName -X stuff "$save-on"`echo -ne '\015'`
 
#------------------------------
#Send a message to the users
#-----------------------------
screen -S $screenName -X stuff "say Server Backup Completed. Have a nice day."`echo -ne '\015'`
fi
 
endTime=$(date +%s.%N)
seconds=$(echo "$endTime - $startTime" | bc)
minutes=$(echo "($endTime - $startTime) / 60" | bc)
echo "-------------------------------"
echo "Backup Complete for $serverName...."
echo "Created file $fileName.tar.gz"
 
#Echo local backup file location
if [[ $backupLocal == true ]]; then
echo "Local complete path: $storePath/$serverName/$fileName.tar.gz"
fi
 
#Echo remote backup file location
if [[ $backupRemote == true ]]; then
echo "Remote complete path: $remoteDirectory/$fileName.tar.gz"
fi
 
#Display time in minutes or seconds?
if [ "$minutes" -le  "0" ]; then
    echo "Time Taken: $seconds seconds"
  else
    echo "Time Taken: $minutes minute(s)"
fi
 
#Get the size of the file
filePath=$storePath/$serverName/$fileName.tar.gz
fileSize=$(stat -c%s "$filePath")
echo "Size of $fileName.tar.gz is $fileSize bytes."
echo "Thanks for using SABS v0.3b!"
echo "-------------------------------"