#!/bin/sh
###########################################################
## Script Name: Simple Automated Backup Script
## Script Author: eNkrypt (Christopher S.)
## Script Date: 10/01/2013
## Updated: 02/17/2014
## Script Description: This script backups everything that is in the folder specified by
## $backupPath and uses the highest multi-threaded compression rate to compress the
## backup into a single tar.gz file.
###########################################################
# Dependents
#-------------
# install screen
# install sshpass
# install pigz
# install bc
###########################################################
# If you want, I can TRY to install dependencies for you
# I recommend that you DO NOT run this script as root
# or anything for that matter, for those of you that are
# smart I added the ability to use SUDO for installing
useSudo=true #If you are running script as root DISABLE THIS
# Disable this after the dependencies are installed
installDependencies=false

#Which fork are you using?
#Fedora/Centos = RHEL
#Debian = Ubuntu
debianFork=false
rhelFork=true

#Install screen?
installScreen=true
#Install sshpass?
installSSHpass=true
#Install pigz?
installPigz=true
#Install bc?
installBc=true
###########################################################
startTime=$(date +%s.%N)
date=$(date +"%m-%d-%Y")
timeNow=$(date +"%T")

#-----------------------
#Configurable Variables
#-----------------------

sendScreenCommand=false #Send Commands to the Screen Session? (I.E: Turning saveoff while backing up - Screen needs to be named!)
backupLocal=true #Backup the files to the current machine?
backupRemote=false #Backup the files to a remote machine? (If you turn on you need sshpass installed)
excludeDynmap=false #Exclude the DynMap folder?
usePigz=true #Use the multithreaded zip (only disable if you can't get the dependency installed)
deleteOldFiles=true #Delete files older than $deleteFilesOlderThan?

backupPath="/path/to/what/needs/to/be/backed/up" #NO LEADING FORWARD-SLASH!
storePath="/local/store/path" #ServerName folder will be created in this folder. NO LEADING FORWARD-SLASH!
serverName="SMP"
screenName="MinecraftServer"
fileName="$serverName-$date-$timeNow" #IE: SMP-10-01-2013-01:03:35
dynmapPath="/path/to/dynmap" #NO LEADING FORWARD-SLASH!
deleteFilesOlderThan="+30" #Delete files older than x Days (MUST HAVE + infront of numeric value)

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
# Install Dependencies
######################################
if [ "$installDependencies" == true ]; then
    if [ "$rhelFork" == true ]; then
        if [ "$installScreen" == true ]; then
            if [ "$useSudo" == true ]; then
                sudo yum -y install screen
            else
                yum -y install screen
            fi
        fi
        if [ "$installSSHpass" == true ]; then
            if [ "$useSudo" == true ]; then
                sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/sshpass-1.05-1.el6.x86_64.rpm
            else
                rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/sshpass-1.05-1.el6.x86_64.rpm
            fi
        fi
        if [ "$installPigz" == true ]; then
            if [ "$useSudo" == true ]; then
                sudo yum -y install pigz
            else
                yum -y install pigz
            fi
        fi
        if [ "$installBc" == true ]; then
            if [ "$useSudo" == true ]; then
                sudo yum -y install bc
            else
                yum -y install bc
            fi
        fi
    elif [ "$debianFork" == true ]; then
        if [ "$installScreen" == true ]; then
            if [ "$useSudo" == true ]; then
                sudo apt-get install -y screen
            else
                apt-get install -y screen
            fi
        fi
        if [ "$installSSHpass" == true ]; then
            if [ "$useSudo" == true ]; then
                sudo apt-get install -y sshpass
            else
                apt-get install -y sshpass
            fi
        fi
        if [ "$installPigz" == true ]; then
            if [ "$useSudo" == true ]; then
                sudo apt-get install -y pigz
            else
                apt-get install -y pigz
            fi
        fi
        if [ "$installBc" == true ]; then
            if [ "$useSudo" == true ]; then
                sudo apt-get install -y bc
            else
                apt-get install -y bc
            fi
        fi
    fi
fi

#Set Server command syntax
if [ "$useSlashCommand" == false ]; then
    saveall="save-all"
    saveoff="save-off"
    saveon="save-on"
else
    saveall="/save-all"
    saveoff="/save-off"
    saveon="/save-on"
fi

#------------------------------
#If sendScreenCommand = true
#------------------------------
if [ "$sendScreenCommand" == true ]; then
    #------------------------------
    #Send a message to the user
    #-----------------------------
    screen -S $screenName -X stuff "say Server Backup Initiated. Expect Lag."`echo -ne '\015'`

    #-------------------------------
    #Send save-all command to server
    #-------------------------------
    screen -S $screenName -X stuff "$saveall"`echo -ne '\015'`

    #-------------------------------
    #Send save-off command to server
    #-------------------------------
    screen -S $screenName -X stuff "$saveoff"`echo -ne '\015'`
    #statements
fi
#-------------------
#Ping Statistics Server
#Sends me a unique encrypted server id
#This lets me keep track of how many people are using SABS
#-------------------
encrypted=`hostname -I | md5sum`
curl -ss "www.lodecentral.com/sabs/stats.php?stats=${encrypted}" | >/dev/null 2>&1
#------------------
#Start server backup
#-------------------
echo "----------------------------"
echo "Starting Backup of $serverName..."
echo "----------------------------"

#Make sure that both backupLocal and backupRemote are not false
if [ "$backupLocal" == false ] && [ "$backupRemote" == false ]; then
    echo "No backup directory specified. Both backupRemote and backupLocal can not be false"
    exit
fi

echo "Compressing data...."
if [ "$excludeDynmap" == true ]; then
    echo "Excluding DynMap from backup..."
        if [ "$usePigz" == true ]; then
            tar cvfP - $backupPath* --exclude "$dynmapPath/*" --exclude "$dynmapPath" | pigz -9 - > $fileName.tar.gz
            sleep 1
        else
            tar cvfP - $backupPath* --exclude "$dynmapPath/*" --exclude "$dynmapPath" | gzip -9 - > $fileName.tar.gz
            sleep 1
        fi
else
    if [ "$usePigz" == true ]; then
        tar cvfP - $backupPath* | pigz -9 - > $fileName.tar.gz
        sleep 1
    else
        tar cvfP - $backupPath* | gzip -9 - > $fileName.tar.gz
        sleep 1
    fi
fi

#---------------------
#If backupLocal = true
#---------------------
if [ "$backupLocal" == true ]; then
    echo "Checking if local backup folder exists..."
    if [ ! -d "$storePath/$serverName" ]; then
     mkdir -p $storePath/$serverName;
     echo "Created folder $storePath/$serverName"
    else
     echo "Folder already exists. Proceeding..."
    fi
    mv $serverName* $storePath/$serverName/
fi

if [ "$backupRemote" == true ]; then
    if [ "$backupLocal" == false ]; then
        sshpass -p $remotePassword scp -P $remotePort -o StrictHostKeyChecking=no $serverName* $remoteUsername@$remoteHost:$remoteDirectory
        rm -f $serverName*
    else
        sshpass -p $remotePassword scp -P $remotePort -o StrictHostKeyChecking=no $storePath/$serverName/$serverName* $remoteUsername@$remoteHost:$remoteDirectory
    fi
fi

#------------------------------
#Delete local files
#------------------------------
if [ "$deleteOldFiles" == true ]; then
    echo "Cleaning up files older than $deleteFilesOlderThan days"
    echo "Removing the following files:"
    find /backups/* -type f -mtime $deleteFilesOlderThan
    find $storePath/$serverName/* -type f -mtime $deleteFilesOlderThan -exec rm {} \;
fi

#------------------------------
#If sendScreenCommand = true
#------------------------------
if [ "$sendScreenCommand" == true ]; then
    #-------------------------------
    #Send save-on command to server
    #-------------------------------
    screen -S $screenName -X stuff "$saveon"`echo -ne '\015'`

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
if [ "$backupLocal" == true ]; then
    echo "Local complete path: $storePath/$serverName/$fileName.tar.gz"
fi

#Echo remote backup file location
if [ "$backupRemote" == true ]; then
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
echo "Thanks for using SABS v0.4b!"
echo "-------------------------------"