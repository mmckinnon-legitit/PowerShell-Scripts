param(
    [Parameter(
        Mandatory = $true,
        HelpMessage = "Enter the UNC Path for folder location eg: \\hodc01\folder redirection"
    )]
    [string]$uncpath
)

$OneDrive = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1").UserFolder

# Remove specific registry keys
$keysToRemove = @(
    "{F42EE2D3-909F-4907-8871-4C22FC0BF756}",
    "{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}",
    "{A0C69A99-21C8-4671-8703-7934162FCF1D}",
    "{0DDD015D-B06C-45D5-8C4C-F59713854639}",
    "{35286a68-3c57-41a1-bbb1-0eae73d76c95}",
    "{3B193882-D3AD-4EAB-965A-69829D1FB59F}",
    "{AB5FB87B-7CE2-4F83-915D-550846C9537B}",
    "{B7BEDE81-DF94-4682-A7D8-57A52620B86F}",
    "{24D89E24-2F19-4534-9DDE-6A6671FBB8FE}",
    "{767E6811-49CB-4273-87C2-20F355E1085B}",
    "{31C0DD25-9439-4F12-BF41-7FF4EDA38722}",
    "{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}",
    "{374DE290-123F-4565-9164-39C4925E467B}",
    "{bfb9d5e0-c6a9-404c-b2b2-ae6db6af4968}"
)

foreach ($key in $keysToRemove) {
    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "$key" -ErrorAction SilentlyContinue
}

# Set specific registry values
$valuesToSet = @{
    "AppData" = "%USERPROFILE%\AppData\Roaming"
    "Cache" = "%USERPROFILE%\AppData\Local\Microsoft\Windows\INetCache"
    "Cookies" = "%USERPROFILE%\AppData\Local\Microsoft\Windows\INetCookies"
    "Desktop" = "$OneDrive\Desktop"
    "Favorites" = "%USERPROFILE%\Favorites"
    "History" = "%USERPROFILE%\AppData\Local\Microsoft\Windows\History"
    "Local AppData" = "%USERPROFILE%\AppData\Local"
    "My Music" = "%USERPROFILE%\Music"
    "My Pictures" = "$OneDrive\Pictures"
    "My Video" = "%USERPROFILE%\Videos"
    "NetHood" = "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Network Shortcuts"
    "Personal" = "$OneDrive\Documents"
    "PrintHood" ="%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Printer Shortcuts"
    "Programs" = "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
    "Recent" = "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Recent"
    "SendTo" = "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\SendTo"
    "Start Menu" = "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu"
    "Startup" = "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    "Templates" = "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Templates"
    "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" = "$OneDrive\Documents"
    "{0DDD015D-B06C-45D5-8C4C-F59713854639}" = "$OneDrive\Pictures"
    "{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}" = "$OneDrive\Desktop"
}

foreach ($name in $valuesToSet.Keys) {
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $name -Value $valuesToSet[$name]
}

$folders = @(
    "Documents",
    "Pictures",
    "Music",
    "Videos"
)

foreach ($folder in $folders) {
    New-Item -Path "$env:USERPROFILE\$Folder" -ItemType Directory -ErrorAction SilentlyContinue
}



$User = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$UserName = [System.IO.Path]::GetFileName($User)

Copy-Item "$uncpath\$Username\Documents\*" "$env:USERPROFILE\Documents\" -Recurse -Force -Verbose
Get-ChildItem "$env:USERPROFILE\Documents" -Recurse | Where-Object { $_.Name -like "*$RECYCLE.BIN*" } | Remove-Item -Recurse -Force -Verbose
Remove-Item "$env:USERPROFILE\Documents\Outlook Files" -Recurse -Force -Verbose -ErrorAction SilentlyContinue

If (Test-Path "$env:USERPROFILE\Documents\My Music") {
    Get-ChildItem "$env:USERPROFILE\Documents\My Music" -Recurse | Move-Item -Destination "$env:USERPROFILE\Music" -Force -Verbose -ErrorAction SilentlyContinue
    Remove-Item "$env:USERPROFILE\Documents\My Music" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}

If (Test-Path "$env:USERPROFILE\Documents\Music") {
    Get-ChildItem "$env:USERPROFILE\Documents\Music" -Recurse | Move-Item -Destination "$env:USERPROFILE\Music" -Force -Verbose -ErrorAction SilentlyContinue
    Remove-Item "$env:USERPROFILE\Documents\Music" -Recurse -Force -Verbose -ErrorAction SilentlyContinue

}

If (Test-Path "$env:USERPROFILE\Documents\My Pictures") {
    Get-ChildItem "$env:USERPROFILE\Documents\My Pictures" -Recurse | Move-Item -Destination "$OneDrive\Pictures" -Force -Verbose -ErrorAction SilentlyContinue
    Remove-Item "$env:USERPROFILE\Documents\My Pictures" -Recurse -Force -Verbose -ErrorAction SilentlyContinue

}

If (Test-Path "$env:USERPROFILE\Documents\Pictures") {
    Get-ChildItem "$env:USERPROFILE\Documents\Pictures" -Recurse | Move-Item -Destination "$OneDrive\Pictures" -Force -Verbose -ErrorAction SilentlyContinue
    Remove-Item "$env:USERPROFILE\Documents\Pictures" -Recurse -Force -Verbose -ErrorAction SilentlyContinue

}

If (Test-Path "$env:USERPROFILE\Documents\My Videos") {
    Get-ChildItem "$env:USERPROFILE\Documents\My Videos" -Recurse | Move-Item -Destination "$env:USERPROFILE\Videos" -Force -Verbose -ErrorAction SilentlyContinue
    Remove-Item "$env:USERPROFILE\Documents\My Videos" -Recurse -Force -Verbose -ErrorAction SilentlyContinue

}

If (Test-Path "$env:USERPROFILE\Documents\Videos") {
    Get-ChildItem "$env:USERPROFILE\Documents\Videos" -Recurse | Move-Item -Destination "$env:USERPROFILE\Videos" -Force -Verbose -ErrorAction SilentlyContinue
    Remove-Item "$env:USERPROFILE\Documents\Videos" -Recurse -Force -Verbose -ErrorAction SilentlyContinue

}

If (Test-Path "$env:USERPROFILE\Documents") {
    Get-ChildItem "$env:USERPROFILE\Documents" -Recurse | Move-Item -Destination "$OneDrive\Documents" -Force -Verbose -ErrorAction SilentlyContinue
    Remove-Item "$env:USERPROFILE\Documents" -Recurse -Force -Verbose -ErrorAction SilentlyContinue

}

If (Test-Path "$env:USERPROFILE\Pictures") {
    Get-ChildItem "$env:USERPROFILE\Pictures" -Recurse | Move-Item -Destination "$OneDrive\Pictures" -Force -Verbose -ErrorAction SilentlyContinue
    Remove-Item "$env:USERPROFILE\Pictures" -Recurse -Force -Verbose -ErrorAction SilentlyContinue

}

If (Test-Path "$env:USERPROFILE\Desktop") {
    Get-ChildItem "$env:USERPROFILE\Desktop" -Recurse | Move-Item -Destination "$OneDrive\Desktop" -Force -Verbose -ErrorAction SilentlyContinue
    Remove-Item "$env:USERPROFILE\Desktop" -Recurse -Force -Verbose -ErrorAction SilentlyContinue

}

Write-Host "==== Script Finished =====" -ForegroundColor Green




