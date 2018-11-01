SET echo @off;
SET backupFolder="chocolatey-setup-backup"
chocolatey list -localonly > D:\Downloads\ApplicationSetups\choco-packagelist.txt
mkdir %backupFolder%
robocopy %AppData%\..\Local\Temp\chocolatey %backupFolder% /s
robocopy C:\Windows\Temp\chocolatey %backupFolder% /s