# Disable-LabUser.ps1
# Offboarding: disable the account, remove it from all groups
# and move it to the disabled OU.
# Usage: .\Disable-LabUser.ps1 -Username jdoe

param(
    [Parameter(Mandatory = $true)]
    [string]$Username,

    [string]$DisabledOU = "OU=Disabled,DC=lab,DC=local"
)

# Load the Active Directory module
Import-Module ActiveDirectory

# Get the user and the groups it belongs to
$user = Get-ADUser -Filter "SamAccountName -eq '$Username'" -Properties MemberOf -ErrorAction SilentlyContinue

if (-not $user) {
    Write-Host "User not found: $Username" -ForegroundColor Red
    exit
}

# 1. Disable the account
Disable-ADAccount -Identity $user
Write-Host "Account disabled: $Username" -ForegroundColor Green

# 2. Remove the user from all groups
foreach ($group in $user.MemberOf) {
    Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false
    Write-Host "Removed from group: $group"
}

# 3. Add a note in the description with the date
Set-ADUser -Identity $user -Description "Disabled on $(Get-Date -Format 'yyyy-MM-dd')"

# 4. Move the account to the disabled OU
Move-ADObject -Identity $user.DistinguishedName -TargetPath $DisabledOU
Write-Host "Account moved to: $DisabledOU" -ForegroundColor Green
