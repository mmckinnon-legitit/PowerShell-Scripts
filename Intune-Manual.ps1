# Define the registry path
$registryPath = "HKLM:\Software\Microsoft\Enrollments"

# Check if the registry key exists
if (Test-Path $registryPath) {
    # Get all subkeys under the Enrollments key
    $subKeys = Get-ChildItem -Path $registryPath

    # Remove each subkey
    foreach ($subKey in $subKeys) {
        Remove-Item -Path $subKey.PSPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Output "All subkeys under the Enrollments key have been removed successfully."
} else {
    Write-Output "Registry key does not exist."
}

# Set MDM Enrollment URL's

$key = 'SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\*'
$keyinfo = Get-Item "HKLM:$key"
$url = $keyinfo.name
$url = $url.Split("\")[-1]
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\$url"

New-ItemProperty -LiteralPath $path -Name 'MdmEnrollmentUrl' -Value 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath $path  -Name 'MdmTermsOfUseUrl' -Value 'https://portal.manage.microsoft.com/TermsofUse.aspx' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath $path -Name 'MdmComplianceUrl' -Value 'https://portal.manage.microsoft.com/?portalAction=Compliance' -PropertyType String -Force -ea SilentlyContinue;

# Trigger AutoEnroll
& C:\Windows\system32\deviceenroller.exe /c /AutoEnrollMDM

$triggers = @()

$triggers += New-ScheduledTaskTrigger -At (get-date) -Once -RepetitionInterval (New-TimeSpan -Minutes 1)

$User = "SYSTEM"

$Action = New-ScheduledTaskAction -Execute "%windir%\system32\deviceenroller.exe" -Argument "/c /AutoEnrollMDM"

$Null = Register-ScheduledTask -TaskName "TriggerEnrollment" -Trigger $triggers -User $User -Action $Action -Force
Start-ScheduledTask -TaskName "TriggerEnrollment"