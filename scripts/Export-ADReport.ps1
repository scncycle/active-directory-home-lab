# Export-ADReport.ps1
# Export users, groups and OU membership to CSV and HTML.
# Usage: .\Export-ADReport.ps1 -OutputFolder C:\Reports

param(
    [string]$OutputFolder = ".\ADReport"
)

# Load the Active Directory module
Import-Module ActiveDirectory

# Create the output folder if it does not exist
if (-not (Test-Path $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory | Out-Null
}

# ---------- Users ----------
$users = Get-ADUser -Filter * -Properties MemberOf, LastLogonDate

$userReport = @()
foreach ($u in $users) {
    # The OU is the Distinguished Name without the "CN=name," part
    $ou = $u.DistinguishedName -replace '^CN=[^,]+,', ''

    # Get only the group names from the MemberOf list
    $groups = @()
    foreach ($g in $u.MemberOf) {
        $groups += ($g -replace '^CN=([^,]+),.*', '$1')
    }

    $userReport += [PSCustomObject]@{
        Name          = $u.Name
        SamAccountName = $u.SamAccountName
        Enabled       = $u.Enabled
        OU            = $ou
        Groups        = $groups -join "; "
        LastLogonDate = $u.LastLogonDate
    }
}

# ---------- Groups ----------
$groups = Get-ADGroup -Filter *

$groupReport = @()
foreach ($g in $groups) {
    $members = Get-ADGroupMember -Identity $g -ErrorAction SilentlyContinue
    $groupReport += [PSCustomObject]@{
        GroupName   = $g.Name
        Scope       = $g.GroupScope
        MemberCount = @($members).Count
        Members     = ($members.SamAccountName) -join "; "
    }
}

# ---------- OUs ----------
$ous = Get-ADOrganizationalUnit -Filter *

$ouReport = @()
foreach ($o in $ous) {
    # Count the users that are directly inside this OU
    $count = @(Get-ADUser -Filter * -SearchBase $o.DistinguishedName -SearchScope OneLevel).Count
    $ouReport += [PSCustomObject]@{
        OUName            = $o.Name
        DistinguishedName = $o.DistinguishedName
        UserCount         = $count
    }
}

# ---------- Export to CSV ----------
$userReport  | Export-Csv "$OutputFolder\Users.csv"  -NoTypeInformation -Encoding UTF8
$groupReport | Export-Csv "$OutputFolder\Groups.csv" -NoTypeInformation -Encoding UTF8
$ouReport    | Export-Csv "$OutputFolder\OUs.csv"    -NoTypeInformation -Encoding UTF8

# ---------- Export to HTML ----------
$html  = $userReport  | ConvertTo-Html -Title "AD Users"  -PreContent "<h2>Users</h2>"  | Out-String
$html += $groupReport | ConvertTo-Html -Title "AD Groups" -PreContent "<h2>Groups</h2>" | Out-String
$html += $ouReport    | ConvertTo-Html -Title "AD OUs"    -PreContent "<h2>OUs</h2>"    | Out-String
$html | Out-File "$OutputFolder\ADReport.html" -Encoding UTF8

Write-Host "Report exported to: $OutputFolder" -ForegroundColor Green
