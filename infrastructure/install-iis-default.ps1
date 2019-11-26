Import-Module WebAdministration
$iisAppPoolName = "Poolname_Pool"
$iisAppPoolDotNetVersion = "v4.0"
$iisAppName = "Poolname"
$directoryPath = "C:\inetpub\wwwroot\Poolname"
$poolusername="server"
$pooluserpass="PASSWORD"
$bindings = @(
   @{protocol="http";bindingInformation="*:81:"},
   @{protocol="net.tcp";bindingInformation=":808:*"}
)

#navigate to the app pools root
cd IIS:\AppPools\

#check if the app pool exists
if (!(Test-Path $iisAppPoolName -pathType container))
{
    #create the app pool
    $appPool = New-Item $iisAppPoolName
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
    $appPool | Set-ItemProperty -Name processModel -value @{userName="$poolusername";password="$pooluserpass";identitytype=3}
}

#navigate to the sites root
cd IIS:\Sites\

#check if the site exists
if (Test-Path $iisAppName -pathType container)
{
    return
}

#create the site
$iisApp = New-Item $iisAppName -bindings $bindings -physicalPath $directoryPath
$iisApp | Set-ItemProperty -Name "applicationPool" -Value $iisAppPoolName
$iisApp | Set-ItemProperty -Name EnabledProtocols -Value 'http,net.tcp'
