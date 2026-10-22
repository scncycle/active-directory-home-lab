# Get-InactiveAccounts.ps1
# Report enabled user accounts with no logon in the last N days.
# Usage: .\Get-InactiveAccounts.ps1 -Days 60

param(
    [int]$Days = 90,
    [string]$OutputPath = ".\InactiveAccounts.csv"
)

# Load the Active Directory module
Import-Module ActiveDirectory

# Find user accounts that have not logged on in the last N days
$inactive = Search-ADAccount -UsersOnly -AccountInactive -TimeSpan (New-TimeSpan -Days $Days) |
    Where-Object { $_.Enabled -eq $true }

# Keep only the columns we care about
$report = $inactive | Select-Object Name, SamAccountName, LastLogonDate, DistinguishedName

# Show the result on screen
$report | Format-Table -AutoSize

# Export the result to CSV
$report | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

Write-Host "Found $($report.Count) inactive accounts (more than $Days days)." -ForegroundColor Yellow
Write-Host "Report saved to: $OutputPath"
