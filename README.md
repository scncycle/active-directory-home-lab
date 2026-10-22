# Active Directory Home Lab

> A virtualized Windows Server Active Directory environment with automated user management, Group Policy hardening, and PowerShell tooling.

![Status](https://img.shields.io/badge/status-%20done-green)
![Windows Server](https://img.shields.io/badge/Windows%20Server-2022-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE)

## Table of Contents

1. [Overview](#overview)
2. [Objectives](#objectives)
3. [Architecture](#architecture)
4. [Requirements](#requirements)
5. [Setup Guide](#setup-guide)
6. [Group Policy Objects](#group-policy-objects)
7. [PowerShell Automation](#powershell-automation)
8. [Security Hardening](#security-hardening)
9. [Testing & Validation](#testing--validation)
10. [Lessons Learned](#lessons-learned)
11. [Roadmap](#roadmap)
12. [Repository Structure](#repository-structure)

## Overview

This is a Windows Server 2022 virtual lab, built to recreate a corporative enviroment. This project develop skills as identity management, Windows administration, automation and security hardening.

## Objectives

- Deploy a Windows Server domain controller from scratch
-  Join Windows client machines to the domain
-  Design an Organizational Unit (OU) structure that mirrors a real company
-  Apply Group Policy Objects (GPOs) for configuration and security
-  Automate user onboarding/offboarding with PowerShell
-  Document everything so it can be reproduced

## Architecture


![Wserver22.jpg](<_Assets/Wserver22.jpg>)

| Host | Role | OS | IP Address |
|------|------|----|------------|
| DC01 | Domain Controller, DNS, DHCP | Windows Server 2022 | 192.168.10.10 |
| CLIENT01 | Domain-joined workstation | Windows 10/11 Pro | DHCP |
| CLIENT02 | Domain-joined workstation | Windows 10/11 Pro | DHCP |

**Domain name:** `lab.local`
**Virtualization:** VirtualBox
**Network:** Internal/NAT

### OU Structure

```
lab.local
├── Company
│   ├── Users
│   │   ├── IT
│   │   ├── HR
│   │   └── Sales
│   ├── Computers
│   │   ├── Workstations
│   │   └── Servers
│   └── Groups
```

## Requirements

- Host machine with at least 16 GB RAM (8 GB minimum)
- Hypervisor: VirtualBox, VMware Workstation, or Proxmox
- Windows Server 2022 evaluation ISO ([Microsoft Evaluation Center](https://www.microsoft.com/evalcenter))
- Windows 10/11 evaluation or Enterprise ISO

## Setup Guide

### 1. Domain Controller

1. Install Windows Server and set a static IP in the internal network adapter.

![Pasted image 20261011193343.png](<_Assets/Pasted image 20261011193343.png>)

![Pasted image 20261011193313.png](<_Assets/Pasted image 20261011193313.png>)

2. Rename the host to `DC01`. Right-click the Start button → **System** → **Rename this PC** (on Server 2022 it may read "Rename this PC (advanced)" or "Change settings") → in the System Properties window, click **Change...** → type `DC01` in **Computer name** → **OK** → restart when prompted.

![Pasted image 20261011193041.png](<_Assets/Pasted image 20261011193041.png>)

3. Install the AD DS, DHCP and DNS roles. Server Manager>Manage>Add Roles and Features.
![Pasted image 20261011224356.png](<_Assets/Pasted image 20261011224356.png>)

![Pasted image 20261011224442.png](<_Assets/Pasted image 20261011224442.png>)

![Pasted image 20261011224622.png](<_Assets/Pasted image 20261011224622.png>)

4. Promote the server to a domain controller (new forest `lab.local`).

![Pasted image 20261011225345.png](<_Assets/Pasted image 20261011225345.png>)

![Pasted image 20261011225528.png](<_Assets/Pasted image 20261011225528.png>)

![Pasted image 20261011230240.png](<_Assets/Pasted image 20261011230240.png>)

![Pasted image 20261011230422.png](<_Assets/Pasted image 20261011230422.png>)
5. Configure the DHCP scope and authorize it.
		First we have to authorize the DHCP server

![Pasted image 20261012142407.png](<_Assets/Pasted image 20261012142407.png>)

![Pasted image 20261012142500.png](<_Assets/Pasted image 20261012142500.png>)

![Pasted image 20261012142549.png](<_Assets/Pasted image 20261012142549.png>)

		Now lets make the DHCP configuration

![Pasted image 20261012143049.png](<_Assets/Pasted image 20261012143049.png>)

![Pasted image 20261012143215.png](<_Assets/Pasted image 20261012143215.png>)

![Pasted image 20261012143318.png](<_Assets/Pasted image 20261012143318.png>)

![Pasted image 20261012143450.png](<_Assets/Pasted image 20261012143450.png>)

![Pasted image 20261012143930.png](<_Assets/Pasted image 20261012143930.png>)

![Pasted image 20261012144119.png](<_Assets/Pasted image 20261012144119.png>)

![Pasted image 20261012144222.png](<_Assets/Pasted image 20261012144222.png>)

![Pasted image 20261012144304.png](<_Assets/Pasted image 20261012144304.png>)
### 2. Joining Clients to the Domain

Open the W10 client and the first step is to make sure the client and server can comunicate on the same network.

![Pasted image 20261020131452.png](<_Assets/Pasted image 20261020131452.png>)

Now on the W10 system settings, click on rename this PC (Advanced) and find the option "rename or change domain"

![Pasted image 20261020132114.png](<_Assets/Pasted image 20261020132114.png>)

Put your domain here, click "ok" and type your domain credentials
![Pasted image 20261020134456.png](<_Assets/Pasted image 20261020134456.png>)

![Pasted image 20261020134726.png](<_Assets/Pasted image 20261020134726.png>)

![Pasted image 20261020134835.png](<_Assets/Pasted image 20261020134835.png>)

Now you have to rebbot your device and check if the client joined to the domain sucesssfully 

![Pasted image 20261020140448.png](<_Assets/Pasted image 20261020140448.png>)

![Pasted image 20261020140522.png](<_Assets/Pasted image 20261020140522.png>)
### 3. OUs, Users and Groups

We go to ServerManager>Tools>Active Directory Users and Computers. Now we have to recreate this structure.

```
lab.local
├── Company
│   ├── Users
│   │   ├── IT
│   │   ├── HR
│   │   └── Sales
│   ├── Computers
│   │   ├── Workstations
│   │   └── Servers
│   └── Groups
```


To do it manually you have to right click on your domain tree, new>Organizational Unit

![Pasted image 20261020141624.png](<_Assets/Pasted image 20261020141624.png>)

![Pasted image 20261020142556.png](<_Assets/Pasted image 20261020142556.png>)

You can also make this with a powershell script

```powershell
# Create OU structure for the domain
# Run on the DC as Domain Admin

Import-Module ActiveDirectory

# Get the domain DN (example: DC=lab,DC=local)
$domain = (Get-ADDomain).DistinguishedName

# Function to create an OU only if it doesn't exist yet
function New-OUIfMissing {
    param (
        [string]$Name,
        [string]$Path
    )

    # Check if the OU is already there
    $exists = Get-ADOrganizationalUnit -Filter "Name -eq '$Name'" -SearchBase $Path -SearchScope OneLevel

    if ($exists) {
        Write-Host "Ya existe: OU=$Name,$Path"
    }
    else {
        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $true
        Write-Host "Creada: OU=$Name,$Path"
    }
}

# Top level OU
New-OUIfMissing -Name "Company" -Path $domain

$company = "OU=Company,$domain"

# Second level
New-OUIfMissing -Name "Users" -Path $company
New-OUIfMissing -Name "Computers" -Path $company
New-OUIfMissing -Name "Groups" -Path $company

# Inside Users
$users = "OU=Users,$company"
New-OUIfMissing -Name "IT" -Path $users
New-OUIfMissing -Name "HR" -Path $users
New-OUIfMissing -Name "Sales" -Path $users

# Inside Computers
$computers = "OU=Computers,$company"
New-OUIfMissing -Name "Workstations" -Path $computers
New-OUIfMissing -Name "Servers" -Path $computers

# Show the result to check everything is ok
Get-ADOrganizationalUnit -Filter * -SearchBase $company | Select-Object Name, DistinguishedName
```

![Pasted image 20261020143849.png](<_Assets/Pasted image 20261020143849.png>)
## Group Policy Objects

| GPO Name            | Linked To    | Purpose                                                         |
| ------------------- | ------------ | --------------------------------------------------------------- |
| Password Policy     | Domain       | Minimum length 12, complexity enabled, lockout after 5 attempts |
| Disable USB Storage | Workstations | Block removable storage                                         |
| Desktop Wallpaper   | Users        | Corporate branding                                              |
| Map Network Drives  | Users/Sales  | Shared folder mapping                                           |
| Windows Firewall    | Workstations | Enforce firewall profiles                                       |
To create a new Group Policy go to "Server Manager>Group Policy Management". In the domain tree select the OU where do you want to apply the GPO.

![Pasted image 20261020170526.png](<_Assets/Pasted image 20261020170526.png>)

Once it's finished, it would look something like this.

![Pasted image 20261020191144.png](<_Assets/Pasted image 20261020191144.png>)

## PowerShell Automation

| Script | Description |
|--------|-------------|
| `New-LabUsers.ps1` | Bulk-create users from a CSV file |
| `Disable-LabUser.ps1` | Offboarding: disable account, move to a disabled OU, remove groups |
| `Get-InactiveAccounts.ps1` | Report accounts with no logon in N days |
| `Export-ADReport.ps1` | Export users, groups and OU membership to CSV/HTML |

## Security Hardening

- Separate admin and standard accounts (least privilege)
- Strong password and lockout policies
- Audit policy enabled for logons and account changes
- SMBv1 disabled
- Local administrator password handling (LAPS)

## Testing & Validation

| Test                         | Expected Result            | Result |
| ---------------------------- | -------------------------- | ------ |
| New user logs in on CLIENT01 | Success, policies applied  | ✅      |
| 5 failed logons              | Account locked out         | ✅      |
| Password Policy              | Follow the GPO of lenth    | ✅      |

- New user logs in on CLIENT01: 

![Pasted image 20261021173610.png](<_Assets/Pasted image 20261021173610.png>)

![Pasted image 20261021173645.png](<_Assets/Pasted image 20261021173645.png>)

- 5 failed logons:

![Pasted image 20261021174107.png](<_Assets/Pasted image 20261021174107.png>)

- Password Policy

![Pasted image 20261022140407.png](<_Assets/Pasted image 20261022140407.png>)

## Lessons Learned

### Problems and fixes

**1. Client could not join the domain**
- **Symptom:** "An Active Directory Domain Controller for lab.local could not be contacted".
- **Cause:** the client was using the NAT/router DNS instead of DC01.
- **Fix:** set the client DNS to `192.168.10.10` (or fix the DHCP scope option 006). Verified with `nslookup lab.local` and `ping DC01`.

**2. GPOs linked to Workstations were not applied**
- **Cause:** new computers join the domain into the default `Computers` container, not into `OU=Workstations`.
- **Fix:** moved the computer objects to the right OU (`Move-ADObject`) and ran `gpupdate /force`. Checked with `gpresult /r`.
- **Improvement:** `redircmp` changes the default container for new computers.

**3. Clients did not get an IP from DHCP**
- **Cause:** the DHCP server was not authorized in AD / the scope was not activated.
- **Fix:** authorized the server and activated the scope. Checked leases in the DHCP console.

**4. Kerberos / logon errors caused by time difference**
- **Cause:** more than 5 minutes of clock skew between client and DC.
- **Fix:** synced the time with DC01 (`w32tm /resync`) and enabled time sync in VirtualBox.

### How I troubleshot
- DNS first: `nslookup`, `ipconfig /all`.
- Policies: `gpresult /r`, `gpupdate /force`, Event Viewer.
- Domain health: `dcdiag`, `Get-ADDomainController`.

### What I would do differently
- Take VirtualBox snapshots before every big change (promotion, GPOs).
- Create the OU structure before joining the clients.
- Plan the IP addressing and naming in a table before starting.
- Automate the DC promotion and the OU creation with PowerShell from the start.

## Author

**Francisco Carmona**
[LinkedIn](https://www.linkedin.com/in/francisco-carmona-cuevas-9827a3396/?isSelfProfile=true) · [GitHub](https://github.com/scncycle)

