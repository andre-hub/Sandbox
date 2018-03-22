@ECHO OFF
SET FilePath=c:\temp\choco-application-list.txt

del %FilePath%
copy NUL %FilePath%
choco list -lo > %FilePath%