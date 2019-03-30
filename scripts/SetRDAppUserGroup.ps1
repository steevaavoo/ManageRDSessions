#Grabs all Remote Apps into the variable $remoteapps
$remoteapps = ( Get-RDRemoteApp )

#Executes a loop based on each entry in $remoteapps, using $remoteapp as the operator
ForEach ( $remoteapp in $remoteapps ) {
    #Getting the existing Users and Groups on this Remote App and putting them in $usergroups array
    $usergroups = $remoteapp.usergroups
    #Adding specified user/group to the array $usergroups (change as needed)
    $usergroups += 'GROUP 1', 'GROUP 2', 'USER 1', 'USER 2'
    #Applying the newly created array of Users and Groups to the current Remote App
    Set-RDRemoteApp -CollectionName $($remoteapp.CollectionName) -Alias $($remoteapp.Alias) -UserGroups $usergroups
}