
<b>Name: </b>Simple Automated Backup Script<br>
<b>Created by: </b>eNkrypt (Christopher S.)<br>
<b>Version: </b>0.5b<br>
<b>Last Updated: </b>03/20/2014<br>
<br>
<b>What this script does:</b><br>
This script backups everything that is in the folder specified by $backupPath and uses the highest multi-threaded compression rate to compress the backup into a single tar.gz file.<br>
<br>
<b>Features:</b><br>
If you are running your server within a screen session this script will connect to that screen session and issue the save-all command which will save the current state of the server. It will then issue the save-off command. This will prevent any corruption while the server is backing up. After the script has finished backing up your server it will issue the command save-on so that your server will continue to save (This is customizable for McMyAdmin Users). It will ill display where the backup was stored, the name of the backup, the time it took to run the backup, and the size of the backup. It will exclude the DynMap folder from the backup, if told to (This significantly decreases the backup time). It will also store your backup to a remote server using the SCP protocol.
<br><br>
<b>Requirements:</b><br>
You must have screen installed on your server, this can be done very easily depending on your distribution of linux. You must also have pigz installed on your server, the advantage of pigz over gzip is that pigz has multithreaded capabilities and will decrease the impact on server performance while the backup is being compressed.
<br>
In version 0.2b I added remote file placement. This requires sshpass to be installed, this allows for a password to be passed though the SCP connection. SCP connection will use SSH credentials. SCP is not to be confused with FTP, they are completely different transfer protocols.
<br>
<i><span style="text-decoration: underline">Note</span>: After many requests, in v0.4b I added the ability for the script to attempt to install dependencies for those of you that are not comfortable using shell commands.</i>
<br>
For RHEL (CentOS) based distributions the commands are:
<ul>
<li><i>yum install screen</i></li>
<li><i>yum install pigz</i></li>
<li><i>wget <a href="http://dl.fedoraproject.org/pub/epel/6/x86_64/sshpass-1.05-1.el6.x86_64.rpm" target="_blank" class="externalLink" rel="nofollow">http://dl.fedoraproject.org/pub/epel/6/x86_64/sshpass-1.05-1.el6.x86_64.rpm</a></i></li>
<li><i>rpm -Uvh ssshpass-1.05-1.el6.x86_64.rpm</i></li>
</ul>
For Debian based distributions the command is:
<ul>
<li><i>apt-get install screen</i></li>
<li><i>apt-get install pigz</i></li>
<li><i>apt-get install sshpass</i></li>
</ul>
For this script to work you must name your screen command before starting your server inside of that screen session. This can easily be done by running the following command:<br>
<ul>
<li><i>screen -S screenName</i></li>
</ul>
<b>Configurable Variables:</b>
<br>
This script has the following configurable variables that you should change. These variables will be server specific.
<ul>
<li>installDependencies - If set to true, the script will attempt to install any dependencies that are required by this script. I suggest turning this off after they have been installed.<br>
</li>
<li>sendScreenCommand - This allows you to toggle if you want the script sending commands to your screen session or not. I recommend using this if you are backing up your minecraft server while it is running.</li>
<li>backupLocal - This allows you to specify if you want the backup to be stored locally or not.</li>
<li>backupRemote - This allows you to specify if you want the backup to be stored remotely or not.</li>
<li>excludeDynmap - This allows you to specify if you want to exclude the dynmap folder your backup. This significantly decreases the backup time since the dynmap foulder has thousands of images in it.</li>
<li>usePigz - enabling this will allow for the server to compress the backup using multiple threads. This significantly decreases the amount of time taken. PIGZ MUST BE INSTALLED.</li>
<li>deleteOldFiles - Enabling this allows the script to delete files older than $deleteFilesOlderThan days.<br>
</li>
<li>deleteFilesOlderThan - This string is the number of days that have gone by before deleting. By default this is set to 30 days. Anything older than 30 days will be delete. MUST HAVE "+" in front of your number.<ul>
<li>Example: deleteFilesOlderThan="+30"</li>
</ul></li>
<li>backupPath - This is going to be the COMPLETE path to what you want to backup. Typically people will want to backup their Minecraft folder. Their should be NO trailing forward-slash "/" in this variable!<ul>
<li>Example: backupPath="/path/to/Minecraft"</li>
</ul></li>
<li>storePath - This is going to be the path where you want your backups stored. No need to make a separate folder in the backup folder. The script will create a folder with the name you specify in the serverName variable.<ul>
<li>Example: storePath="/path/to/store/backups"</li>
</ul></li>
<li>serverName - This variable is going to be the name of the server you want to backup<ul>
<li>Example: serverName="SMP"</li>
</ul></li>
<li>screenName - This is going to be the name of the screen session that you are running your Minecraft server under<ul>
<li>Example: screenName="MinecraftServer"</li>
</ul></li>
<li>fileName - This is going to be the name of the generated compressed archive will be called.<ul>
<li>Example: fileName="$server-$now-$date"</ul>
<ul>
<li>This will produce a filename similar to: SMP-01:03:35-10-01-2013</li>
</ul></li>
<li>dynmapPath - This is going to be the location of your dynmap folder. This is usually located in the plugins directory. Make sure you have NO LEADING FORWARD-SLASH in this variable!<ul>
<li>Example: dynmapPath="/Minecraft/plugins/dynmap/web/tiles"</li>
</ul></li>
<li>remoteHost - This is the remote server IP or URL in which you want your backup to be transferred to.</li>
<li>remoteUsername - This is the username of the remote host you are connecting to.</li>
<li>remotePassword - This is the password of the remote host you are connecting to.</li>
<li>remotePort - This is the port used to connect to for the remote host. This is usually 22.</li>
<li>remoteDirectory - This is the absolute path with no leading "/" on the remote server that you want to store your backup to. This directory MUST exist.</li>
<li>useSlashCommand - If you are using a server container like McMyAdmin, this should be set to true for server containers that use /save-all instead of save-all.</li>
<li>backupMySQL - Enabling this backs up the MySQL database using the configs below.</li>
<li>sqlUser - This is the MySQL DB_Username you want backed up.<br>
</li>
<li>sqlPassword - This is the MySQL Password to the database you want backed up.<br>
</li>
<li>sqlHost - This is the host location of where the MySQL server resides. Usually this is localhost.<br>
</li>
<li>sqlDB - This is the MySQL db_name that you want backed up.<br>
</li>
<li>sqlUmask - This is the permission set to use for the SQL file (umask 177 is equivalent to CHMOD 600)</li>
</ul>

<b>Disclaimer:</b>
<br>
I do not guarantee that this script will work, and will not take any responsibility for anything that may happen as a result of using this script. You should have some basic knowledge of how SSH and BASH scripting works before utilizing this script.
<br>
<b>Running the script:</b><br>
In order to utilize this script you will need to create a new file.<br>
<ul>
<li>vi backup.sh</li>
</ul>
You will then need to copy the contents of the script into that file. Once the contents have been placed into the file you will need to exit out of vi.<br>
You will then need to change the mod of the file to 755 this can be done by issuing the command<br>
<ul>
<li>chmod 755 backup.sh</li>
</ul>
Now in order to run the script you have several options:<br>
<ul>
<li>sh backup.sh</li>
<li>./backup.sh</li>
</ul>
<b>Conclusion:</b><br>
I hope I have helped some of you in some way, I personally am writing this script for me because sometimes I forget to manually save my server. So I setup a chron job in order to save and backup my server every 12 hours. If you find this post helpful at all, please let me know! I like to know if I am helping!<br>
If you have any questions, or requests please feel free to ask me and I will try to answer them to the best of my ability.<br>
<br>
<span style="color: #ff0000"><b>Feel free to modify and change the script to suite your needs. However, all I ask is that you PLEASE credit me!</b></span><br>
<br>
<b>Troubleshooting:</b><br>
For those of you that are having problems (many people have messaged me)<br>
It would appear that a lot of users are editing this script in windows then uploading to their server. This can result in invalid return characters from the lines you have edited (shown by the \r)<br>
Windows formats and saves files weird. If you are going to do it that way I suggest you paste the file into notepad then configure the settings, then copy the text.<br>
Once the text is copied go to your server and vi the bash file and paste the text into the console.<br>
This usually takes away all the messy saves that windows puts in the files.<br>
OR<br>
If you want you could try and run this command to your .sh file<br>
```sed -i -e 's/\r$//' your_backup_script.sh```<br>
This should remove any spurious CR characters.
