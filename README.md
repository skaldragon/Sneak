# Sneak
A Powershell WINRM Function Script to run Powershell on a remote target without touching Powershell.exe on the remote host.

# Sneak
* Able to run any powershell function without the use of touching powershell.exe on any local/remote system
* Flexible to add any other ways to connect to a remote system and send commands
* Can give any name to your running process to provide a little more obfuscation


# The WINRM Function Sneaking Script

sneak [-filepath] [-options]

options:
* -[remotemachine]     name of remote machine to sneak(Used with RunRemote)
* -[testconnection]    tests remote box for connectivity
* -[functioncommand]   command from function to run on local box or remote box
* -[localhostran]      run sneak withing the localhost
* -[Spoofname]         Process you want to spoof as(run with spoof switch)
* -[Credential]        User you want to run the command as
* -[RunRemote]         Runs the commands remotely
* -[Spoof]             Spoofs the process as the chosen Spoofname

# SneakV2.0
* Fixed remoting to be able to retrieve files
* added out file parameters for retrieval of files if needed
# SneakV3.0
* Added Session viewing so now all sessions are opened til you close them
* Added Session Removing so now you can have multiple sessions and remove ones you don't need anymore
* More fluid session control
# SneakV4.0
* Compiles on Front end instead of Back end
* Lessens noise on Back end to prevent detection even more
