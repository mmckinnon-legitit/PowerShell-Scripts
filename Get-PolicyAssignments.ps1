param(
    [Parameter()]
    [string]$clientid,
    [string]$tenantid,
    [string]$CertificateThumbprint

)

Connect-MgGraph -ClientId $clientid -TenantId $tenantid -CertificateThumbprint $CertificateThumbprint -NoWelcome
$ConfigurationPolicies = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies?`$expand=assignments" -Method Get
$CompliancePolicies = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceCompliancePolicies?`$expand=assignments" -Method Get
$AppProtectionPolicies = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mdmWindowsInformationProtectionPolicies?`$expand=assignments" -Method Get

foreach ($policy in $ConfigurationPolicies.value) {
    if ($policy.assignments) {
        Write-Host "Configuration Policy: $($policy.Name)" -ForegroundColor Green
        foreach ($assignment in $policy.assignments) {
        if ($assignment.target.groupId) {
            $group = Get-MgGroup -GroupId $assignment.target.groupId
            Write-Host "Assigned to group: $($group.displayName)" -ForegroundColor Yellow
        }
        # Handle other assignment types (e.g., user, device) as needed
        }
    }
}

foreach ($policy in $CompliancePolicies.value) {
    if ($policy.assignments) {
        Write-Host "Compliance Policy: $($policy.displayName)" -ForegroundColor Green
        foreach ($assignment in $policy.assignments) {
        if ($assignment.target.groupId) {
            $group = Get-MgGroup -GroupId $assignment.target.groupId
            Write-Host "Assigned to group: $($group.displayName)" -ForegroundColor Yellow
        }
        # Handle other assignment types (e.g., user, device) as needed
        }
    }
}

foreach ($policy in $AppProtectionPolicies.value) {
    if ($policy.assignments) {
        Write-Host "App Protection Policy: $($policy.displayName)" -ForegroundColor Green
        foreach ($assignment in $policy.assignments) {
        if ($assignment.target.groupId) {
            $group = Get-MgGroup -GroupId $assignment.target.groupId
            Write-Host "Assigned to group: $($group.displayName)" -ForegroundColor Yellow
        }
        # Handle other assignment types (e.g., user, device) as needed
        }
    }
}

Disconnect-MgGraph | Out-Null