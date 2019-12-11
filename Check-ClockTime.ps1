    <#
    .SYNOPSIS
         Obtem a hora certa do servidor web e verifica se o horario atual está correto.
    #>

$web = Invoke-WebRequest -Method Get -Uri "https://uol.com" -UseBasicParsing
[datetime]$onlineDate = $web.Headers.Date
$diff = $(get-date) - $onlineDate
$syncTime = $diff.TotalMinutes
if ($syncTime -lt 0){$syncTime = $syncTime *-1}
if ($syncTime -lt 4){
    $horario = $true
}
else{
    $horario = $false
}
$info = [pscustomobject]@{
    "Hostname" = $(Get-ItemProperty -Path HKLM:\SYSTEM\ControlSet001\Services\Tcpip\Parameters).hostname
    "Horario"  = $horario
}
$info | ConvertTo-Json

if ($info.Horario -eq $false) {
    $OUT = w32tm /resync
    $OUT = start-sleep -Seconds 10
    $OUT = w32tm /resync   
}