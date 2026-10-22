# New-LabUsers.ps1
# Bulk-create users in Active Directory from a CSV file.
# CSV columns: FirstName,LastName,Username,Password,OU,Department
# Example OU value: OU=Users,DC=lab,DC=local

param(
    [string]$CsvPath = ".\users.csv",
    [string]$Domain  = "lab.local"
)

# Load the Active Directory module
Import-Module ActiveDirectory

# Check that the CSV file exists
if (-not (Test-Path $CsvPath)) {
    Write-Host "CSV file not found: $CsvPath" -ForegroundColor Red
    exit
}

# Read the CSV file
$users = Import-Csv -Path $CsvPath

foreach ($u in $users) {

    # Skip the user if it already exists
    $exists = Get-ADUser -Filter "SamAccountName -eq '$($u.Username)'" -ErrorAction SilentlyContinue
    if ($exists) {
        Write-Host "User already exists, skipping: $($u.Username)" -ForegroundColor Yellow
        continue
    }

    # Convert the plain text password to a secure string
    $securePass = ConvertTo-SecureString $u.Password -AsPlainText -Force

    try {
        # Create the user (user must change the password at first logon)
        New-ADUser `
            -Name "$($u.FirstName) $($u.LastName)" `
            -GivenName $u.FirstName `
            -Surname $u.LastName `
            -SamAccountName $u.Username `
            -UserPrincipalName "$($u.Username)@$Domain" `
            -Department $u.Department `
            -Path $u.OU `
            -AccountPassword $securePass `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "User created: $($u.Username)" -ForegroundColor Green
    }
    catch {
        Write-Host "Error creating $($u.Username): $($_.Exception.Message)" -ForegroundColor Red
    }
}
