# Setting user password
$password = (ConvertTo-SecureString -String 'P@ssw0rd' -AsPlainText -Force )

# Getting DN of Users OU
$targetou = Get-ADObject -Filter "Name -eq 'Users'" | Where-Object {$_.ObjectClass -eq "container"} | Select-Object -ExpandProperty DistinguishedName

# Building list of users
$users = 'Steve.Baker', 'Adam.Rush', 'Paul.Austin'


foreach ($user in $users) {
    $params = @{
        'Name' = $user
        'AccountPassword' = $password
        'ChangePasswordAtLogon' = $false
        'Enabled' = $true
        'SamAccountName' = $user
        'Path' = $targetou
    }

    New-ADUser @params
}