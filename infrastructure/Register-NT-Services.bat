@echo off

sc delete "TestNtAppname"

sc create "TestNtAppname" binpath= "C:\Test.exe" start= auto DisplayName= "DISPLAYNAME"  obj= "WINUSER" password= "PASSWORD"
