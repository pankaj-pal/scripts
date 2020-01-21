Import-Module ActiveDirectory

#The Below function will take 2 parameters: username and computername. Domain is hardcoded  as ecb.com
# It will check if the user exists in AD or not(Error output if not exists). If exists, then will add the user to the Administrators group

function Add-userAdminGroup ( [string] $user, $computerName )
{
	$domain = "ecb.com"
	$domainuser = $domain+"/"+$user
	$Userexists = Get-ADUser $user 
	$Remotegroup = "Administrators"

	if ($Userexists) {([ADSI]"WinNT://$ComputerName/$Remotegroup,group").psbase.Invoke("Add",([ADSI]"WinNT://$domainuser").path)}

  Else {Write-host "User does not exist!" -ForegroundColor Yellow}
}


#The below function will call the above function.
# To execute the function we need to input the computername and the dir name where we have the userlist.txt file
# Usage : Add-MultiAdminUsers server1 c:\users\ADministrator\Desktop

function Add-multiAdminUsers  ( [string] $computerName, [string] $dir)
{
	$users = get-content $dir\userlist.txt
	foreach ($user in $users )
	{	
		write-Host "Adding" $user "as local Admin"
		Add-userAdminGroup  -user $user -computerName $computerName 
	}
}	

# Adding a new branch feature
