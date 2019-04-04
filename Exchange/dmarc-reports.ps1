Add-Type -assembly “system.io.compression"
Import-Module gShell - https://github.com/squid808/gShell/

$Desktop = $env:USERPROFILE + "\Desktop"

function ExtractGzAttachmentToXml ([byte[]]$ByteArray){
    try {
        $CompressedStream = New-Object System.IO.MemoryStream -ArgumentList @(,$Bytes)

        $ZipStream = New-Object System.IO.Compression.GZipStream `
            -ArgumentList $CompressedStream, ([IO.Compression.CompressionMode]::Decompress)

        #$ResultStream = New-Object System.IO.MemoryStream

        #$ZipStream.CopyTo($ResultStream)

        #$result = $ResultStream.ToArray()

        $SR = New-Object System.IO.StreamReader -ArgumentList @(,$ZipStream)

        [xml]$SR.ReadToEnd()
    } finally {
        #if ($ResultStream) {$ResultStream.Dispose()}

        if ($SR) {$SR.Dispose()}

        if ($ZipStream) {$ZipStream.Dispose()}

        if ($CompressedStream) {$CompressedStream.Dispose()}
    }
}

function ExtractZipAttachmentToXml ([byte[]]$ByteArray){
    try {
        $CompressedStream = New-Object System.IO.MemoryStream -ArgumentList @(,$Bytes)

        $ZipArchive = New-Object System.IO.Compression.ZipArchive `
            -ArgumentList @(,$CompressedStream) #, ([IO.Compression.ZipArchiveMode]::Read)

        foreach ($E in $ZipArchive.Entries){
            try {
                $Stream = $E.Open()

                $SR = New-Object System.IO.StreamReader -ArgumentList @(,$Stream)
            
                [xml]$SR.ReadToEnd()
            } finally {
                if ($SR) {$SR.Dispose()}

                if ($Stream) {$Stream.Dispose()}
            }
        }
    } finally {
        if ($ResultStream) {$ResultStream.Dispose()}

        if ($ZipArchive) {$ZipArchive.Dispose()}

        if ($CompressedStream) {$CompressedStream.Dispose()}
    }
}

function DownloadAndExtractAttachment ($MessageId, $Payload){

    $Extension = [System.IO.Path]::GetExtension($Payload.Filename)

    $Data = Get-GGmailAttachment -UserId me -MessageId $MessageId `
        -Id $Payload.Body.AttachmentId

    $Bytes = [gShell.dotNet.Utilities.Utils]::UrlTokenDecode($Data.Data)


    switch ($Extension) {
        ".zip" {
            ExtractZipAttachmentToXml $Bytes
        }

        ".gzip" {
            ExtractGzAttachmentToXml $Bytes
        }

        ".gz" {
            ExtractGzAttachmentToXml $Bytes
        }
    }
}

function Get-DmarcReports($Days) {
    $Days*= -1

    #Get all dmarc from yesterday
    $today = get-date -format "yyyy/M/d"
    $yesterday = get-date (get-date).AddDays($Days) -Format "yyyy/M/d"

    $Emails = Get-GGmailMessage -All -UserId me -Query `
        "(`"Report Domain`" AND `"Submitter`" AND `"Report-ID`") has:attachment (dmarc OR dmarcrep) after:$yesterday before:$today"

    $Messages = New-Object System.Collections.ArrayList

    foreach ($Email in $Emails) {
        $M = Get-GGmailMessage -UserId me -Id $Email.Id
        $Messages.Add($M) | Out-Null
    }

    $Reports = New-Object System.Collections.ArrayList

    foreach ($M in $Messages) {
        if ($M.Payload.Body.AttachmentId -ne $null) { #likely multipart/mixed
            $result = DownloadAndExtractAttachment $M.Id $M.Payload
            $Reports.Add($result.feedback) | Out-Null
        } 
    
        #usually either application/zip or application/gzip
        foreach ($p in $M.Payload.Parts) {
            if ($p.Body.AttachmentId -ne $null) {
                $result = DownloadAndExtractAttachment $M.Id $p

                $Reports.Add($result.feedback) | Out-Null
            }
        }
    }

    return $Reports
}

function ConvertRecord($Record, $Report){
    $O = New-Object psobject -Property ([ordered]@{
        SourceIp = $Record.row.source_ip
        Count = [int]::Parse($Record.row.count)
        Disposition = $Record.row.policy_evaluated.disposition
        DkimDomain = $null;
        DkimResult = $Record.row.policy_evaluated.dkim
        SpfDomain = $Record.auth_results.spf.domain
        SpfResult = $Record.row.policy_evaluated.spf
        BeginDate = $Report.report_metadata.date_range.begin
        EndDate = $Report.report_metadata.date_range.end
        HeaderFrom = $Record.identifiers.header_from
        ReportFrom = $Report.report_metadata.org_name
        OriginatingDomain = $Report.policy_published.domain
    })

    if ($Record.auth_results.dkim.domain -ne $null) {
        if ($Record.auth_results.dkim.domain.GetType().Name -eq "Object[]"){
            $O.DkimDomain = $Record.auth_results.dkim.domain -join "|"
        } else {
            $O.DkimDomain = $Record.auth_results.dkim.domain
        }
    }

    return $O
}

function CompileReports($Reports){
    $ReportObjs = New-Object System.Collections.ArrayList

    foreach ($r in $Reports) {
        if (($r.record.GetType()).Name -eq "Object[]") {
            foreach ($rec in $r.record){
                $ReportObjs.Add((ConvertRecord $rec $r)) | Out-Null
            }
        } elseif(($r.record.GetType()).Name -eq "XmlElement"){
            $ReportObjs.Add((ConvertRecord $r.record $r)) | Out-Null
        }
    }

    return $ReportObjs
}

function SendReportEmail($To, $CsvData, $Body){
    $FilePath = "$Desktop\DmarcReport_" + (Get-Date).ToString("yyyyMMdd") + ".csv"

    $CsvData | Export-Csv -NoTypeInformation -Path $FilePath

    Send-MailMessage -SmtpServer smtp.sjcny.edu -To $To -From DmarcReport@noreply.sjcny.edu `
        -Subject ("DMARC Report: " + (Get-Date).ToString("yyyyMMdd") )`
        -Body $Body -BodyAsHtml -Attachments $FilePath

    Remove-Item -Path $FilePath -Force
}

function Run-DMarcReport($Days, $EmailRecipients){
    $Reports = Get-DmarcReports -Hours $Days

    $Compiled = CompileReports $Reports

    $Failures = $Compiled | where {$_.DkimResult -ne "pass" -OR $_.SpfResult -ne "pass"}
    $SpfFail = $Failures | where {$_.SpfResult -ne "pass"}
    $SpfPass = $Failures | where {$_.SpfResult -eq "pass"}
    $DkimFail = $Failures | where {$_.DkimResult -ne "pass"}
    $DkimPass = $Failures | where {$_.DkimResult -eq "pass"}
    $HeaderFroms = $Failures | select -ExpandProperty HeaderFrom -Unique

    $Body = @"
<h1>Summary</h1>
There were a total of <b>{0}</b> failures, <b>{1}</b> of which failed on SPF and <b>{2}</b> of which failed on DKIM.

Here is a list of the unique HeaderFrom values in the failures:<br>
{3}

<p><h1>SPF Failures</h1>
Here are the top 5 most numerous SPF failures by total count (including success):<br>
{4}

<p><h1>DKIM Failures</h1>
Here are the top 5 most numerous DKIM failures by total count (including success):<br>
{5}

<p>Please find attached the full report of all failures in today's reports.<br>
Any records that only offer full successes were omitted for brevity.
"@ -f `
        $Failures.Count, `
        $SpfFail.Count, `
        $DkimFail.Count, `
        (($HeaderFroms | % {$_ + ": " + ($Compiled | where HeaderFrom -eq $_).Count.ToString()}) -join "<br>"), `
        ($SpfFail | Sort-Object -Property Count -Descending| select Count,DkimDomain,SpfDomain,HeaderFrom,SourceIp `
            | select -First 5 | ConvertTo-Html -Fragment | Out-String), `
        ($DkimFail | Sort-Object -Property Count -Descending| select Count,DkimDomain,SpfDomain,HeaderFrom,SourceIp `
            | select -First 5 | ConvertTo-Html -Fragment | Out-String)

    SendReportEmail -To $EmailRecipients -CsvData $Failures -Body $Body
}

Run-DMarcReport 24 "user1@domain.com","user2@domain.com"