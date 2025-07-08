# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"

# Microsoft 365 Business Premium SKU ID
$businessPremiumSkuId = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"

# Get all users and filter those with the Business Premium license
$licensedUsers = @()
$users = Get-MgUser -All -Property "Id,DisplayName,UserPrincipalName,AssignedLicenses"

foreach ($user in $users) {
    if ($user.AssignedLicenses.SkuId -contains $businessPremiumSkuId) {
        $licensedUsers += [PSCustomObject]@{
        DisplayName = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        }
    }
}

# Output the results
$licensedUsers | Format-Table -AutoSize
