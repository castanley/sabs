#!/bin/sh
###########################################################
## Script Name: Simple Automated Backup Script
## Script Author: eNkrypt (Christopher S.)
## Script Date: 10/01/2013
## Script Description: This script backups everything that is in the folder specified by
## $backupPath and uses the highest multi-threaded compression rate to compress the
## backup into a single tar.gz file.
###########################################################
startTime=$(date +%s.%N)
date=$(date +"%m-%d-%Y")
timeNow=$(date +"%T")
 
#-----------------------
#Configurable Variables
#-----------------------
backupPath="/path/to/Minecraft/server" #NO LEADING FORWARD-SLASH!
storePath="/path/to/store/backups" #ServerName folder will be created in this folder. NO FORWARD-SLASH!
serverName="SMP"
screenName="MinecraftServer"
fileName="$serverName-$timeNow-$date" #IE: SMP-01:03:35-10-01-2013

#------------------------------
#Send a message to the users
#-----------------------------
screen -S $screenName -X stuff "say Server Backup Initiated. Expect Lag."`echo -ne '\015'`
 
#-------------------------------
#Send save-all command to server
#-------------------------------
screen -S $screenName -X stuff "/save-all"`echo -ne '\015'`
 
#-------------------------------
#Send save-off command to server
#-------------------------------
screen -S $screenName -X stuff "/save-off"`echo -ne '\015'`
 
#-------------------
#Start server backup
#-------------------
echo "----------------------------"
echo "Starting Back of $serverName..."
echo "----------------------------"
echo "Checking if backup folder exists..."
 
if [ ! -d $storePath/$serverName ];
  then
    mkdir -p $storePath/$serverName;
    echo "Created folder $storePath/$serverName"
  else
    echo "Folder already exists. Proceeding..."
fi;
 
echo "Compressing data...."
tar cvfP - $backupPath* | pigz -9 - > $fileName.tar.gz
sleep 1
mv $serverName* $storePath/$serverName/
 
#-------------------------------
#Send save-on command to server
#-------------------------------
screen -S $screenName -X stuff "/save-on"`echo -ne '\015'`
 
#------------------------------
#Send a message to the users
#-----------------------------
screen -S $screenName -X stuff "say Server Backup Completed. Have a nice day."`echo -ne '\015'`
endTime=$(date +%s.%N)
seconds=$(echo "$endTime - $startTime" | bc)
minutes=$(echo "($endTime - $startTime) / 60" | bc)
echo "-------------------------------"
echo "Backup Complete for $serverName...."
echo "Created file $fileName.tar.gz"
echo "In folder $storePath/$serverName/"
echo "Complete Path: $storePath/$serverName/$fileName.tar.gz"
if [ "$minutes" -le  "0" ];
  then
    echo "Time Taken: $seconds seconds"
  else
    echo "Time Taken: $minutes minute(s)"
fi;
filePath=$storePath/$serverName/$fileName.tar.gz
fileSize=$(stat -c%s "$filePath")
echo "Size of $fileName.tar.gz is $fileSize bytes."
echo "-------------------------------"
 