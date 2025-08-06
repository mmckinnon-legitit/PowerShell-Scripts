<# 
.SYNOPSIS
    Prepare Monthly Server Report Data

.DESCRIPTION 
    This scrip will connect to remove Altaro Server and pull backup reports. It will  then connect to the remaining servers and pull HDD Storage Data and Windows Update Data.
 
.NOTES 

.COMPONENT 
    PSWindowsUpdate Module is required.

.EXAMPLE
PS> AltaroReport.ps1 -DAYS 30 -SMTP queenstmed-com-au.mail.protection.outlook.com -EMAIL alerts@legitit.com.au

.Parameter AltaroServer
    Altaro Server Name or IP Address

.Parameter Username
    Altaro Server Username

.Parameter Domain
    FQDN for the Active Directory Domain

.Parameter SMTP
    SMTP Server Address to use to send the report data via email

.Parameter EMAIL
    EMAIL to send the report data to


#>
# Function to write the HTML Header to the file
[cmdletbinding()]
Param(
    [Parameter(ParameterSetName = 'Altaro', Mandatory = $false)][Parameter()][string[]]$SMTP,
    [Parameter(ParameterSetName = 'Altaro', Mandatory = $false)][Parameter()][string[]]$EMAIL,
    [Parameter(ParameterSetName = 'Altaro', Mandatory = $false)][Parameter()][string[]]$FROM,
    [Parameter(ParameterSetName = 'Altaro', Mandatory = $false)][Parameter()][string[]]$DAYS
)

$null = Get-PSSession | Remove-PSSession
$global:date = ( get-date ).ToString('yyyy-MM-dd')
$global:ReportName = "$ENV:Temp\Server-Report-$date.htm"
$global:pdfPath = "$ENV:Temp\Backup-Report-$date.pdf"


if (-not(Test-Path -Path $ReportName  -PathType Leaf)) {
    try {
        $null = New-Item -ItemType File -Path $ReportName  -Force -ErrorAction Stop
        Write-Host "The file [$ReportName] is created." -ForegroundColor Green
    }
    catch {
        throw $_.Exception.Message
    }
}
else {
    Write-Host "Removing old [$ReportName] because it is already available." -ForegroundColor Red
    Remove-Item -Path $ReportName -Force -Recurse
    Write-Host "The file [$ReportName] is created." -ForegroundColor Green
    $null = New-Item -ItemType File -Path $ReportName  -Force -ErrorAction Stop

}

if (-not(Test-Path -Path $pdfPath  -PathType Leaf)) {
    try {
        $null = New-Item -ItemType File -Path $pdfPath  -Force -ErrorAction Stop
        Write-Host "The file [$pdfPath] is created." -ForegroundColor Green
    }
    catch {
        throw $_.Exception.Message
    }
}
else {
    Write-Host "Removing old [$pdfPath] because it is already available." -ForegroundColor Red
    Remove-Item -Path $pdfPath -Force -Recurse
    Write-Host "The file [$pdfPath] is created." -ForegroundColor Green
    $null = New-Item -ItemType File -Path $pdfPath  -Force -ErrorAction Stop

}

Function ConvertToPDF {

   
    

    $null = Start-Process "msedge.exe" -ArgumentList @(
        "--headless",
        "--print-to-pdf=$pdfPath",
        "--disable-extensions",
        "--print-to-pdf-no-header",
        "--disable-popup-blocking",
        "--run-all-compositor-stages-before-draw",
        "--disable-checker-imaging",
        "file:///$ReportName",
        "| Out-Null"
    )

}





Function writeHtmlHeader {
    param($fileName)
    Add-Content $fileName @('<html>
	<head>
	<title>Report</title>
	<STYLE TYPE="text/css">
	<!--
	td {
	font-family: Verdana;
	font-size: 11px;
	border-top: 1px solid #999999;
	border-right: 1px solid #999999;
	border-bottom: 1px solid #999999;
	border-left: 1px solid #999999;
	padding-top: 0px;
	padding-right: 0px;
	padding-bottom: 0px;
	padding-left: 0px;
	}
	body {
	margin-left: 5px;
	margin-top: 5px;
	margin-right: 0px;
	margin-bottom: 10px;
	
	-->
	</style>
	</head>
	<body>
	')
}

Function writeTableSubject {
    param($filename, $Subject)
    Add-Content $filename @('
	<table width="100%">
	<tr bgcolor="#5F9EA0">
	<td colspan="9" height="25"  width=5% align="left">
	<font face="tahoma" color="#000000" size="5"><center><strong>' + $Subject + ' - ' + $date + '</strong></center></font>
	</td>
	</tr>
	')

}

Function writeHtmlFooter {
    param($fileName)

    Add-Content $fileName @('
	</body>
	</html>
	')
}

Function writeCloseTable {
    param($fileName)
    Add-Content $ReportName "</table>" 
}

Function writeTableBackup {
    param($fileName)

    Add-Content $fileName @('
	<tr bgcolor=#5F9EA0>
	<td><b>Server</b></td>
	<td><b>Time</b></td>
	<td><b>Message</b></td>
	<td><b>Status</b></td>
	</tr>')
}

Function writeBackupInfo {
    param($fileName, $Server, $TimeGen, $Version, $Status)
	
    Add-Content $fileName @('
	<tr>
	<td >' + $Server + '</td>
	<td >' + $TimeGen + '</td>
	<td >' + $Version + '</td>')
		
    if ($Status -like '*Warning*') {
        Add-Content $fileName @('<td bgcolor="yellow">' + $Status + '</td>
	</tr>')
    }
    elseif ($Status -like '*Failed*') {
        Add-Content $fileName @('<td bgcolor="red"><b><font color="white">' + $Status + '</font></b></td>
	</tr>')
    }
    elseif ($Status -like '*Successful*') {
        Add-Content $fileName @('<td bgcolor="#33FF00">' + $Status + '</td>
	</tr>')
    }
}



writeHtmlHeader $ReportName
writeTableSubject $ReportName "Altaro Backup Report"
writeTableBackup $ReportName

Write-Host "Please wait getting data..." -foregroundcolor Yellow

$LOG = Get-EventLog -LogName "Application" | Where-Object { $_.EventID -eq 5000 -or $_.EventID -eq 5001 -or $_.EventID -eq 5002 -or $_.EventID -eq 5003 -or $_.EventID -eq 5004 -or $_.EventID -eq 5005 -or $_.EventID -eq 5006 -or $_.EventID -eq 5007 -and (Get-Date $_.TimeWritten) -gt ((Get-Date).AddDays(-"$days")) } | Select-Object MachineName, EventID, Source, TimeGenerated, Message 

$LOG | ForEach-Object {
    if ($_.EventID -eq '5000' -or $_.EventID -eq '5005' -or $_.EventID -eq '5003') {
        $Status = "Successful"
    }
    ElseIf ($_.EventID -eq '5002' -or $_.EventID -eq '5004' -or $_.EventID -eq '5007') {
        $Status = "Failed"
    }
    ElseIf ($_.EventID -eq '5001') {
        $Status = "Warning"
    }

    $Server = ((($_.Message -split '\n')[0]) -split ":")[1]
    $TimeGen = Get-Date $_.TimeGenerated -Format "dd/MM/yyyy hh:mm:sstt"
    $Message = ((($_.Message -split '\n')[1]) -split "Result:")[1]

    #write-host $Server $TimeGen $Version $Status
    writeBackupInfo $ReportName $Server $TimeGen $Message $Status

}

writeCloseTable $ReportName

$From = "$from"
$To = "$Email"
$Subject = "Backup Report $date"

$SMTPSERVER = "$SMTP"

ConvertToPDF

Start-Sleep 10

#Add "-UseSSL -Credential $mycredentials" for Office 365 Authentication, Remove for Local Exchange
Send-MailMessage -To "$To" -From "$From" -Subject "$Subject" -Body "Backup Report $date" -BodyAsHtml -Priority High -SmtpServer "$SMTPSERVER" -Attachments "$pdfpath"