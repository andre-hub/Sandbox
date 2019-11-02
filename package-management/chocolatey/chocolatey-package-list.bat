@ECHO OFF
SET FilePath=D:\Installer\choco-application-list.txt

del %FilePath%
copy NUL %FilePath%
choco list -lo > %FilePath%