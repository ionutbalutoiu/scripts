Param(
    [Parameter(Mandatory=$true)]
    [string]$IP,
    [string]$User="Administrator",
    [string]$Password="P@ssw0rd"
)

$ErrorActionPreference = "Stop"

$secPassword = ConvertTo-SecureString -asPlainText -Force $Password
$c = New-Object System.Management.Automation.PSCredential($User, $secPassword)

$opt = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$session = New-PSSession -ComputerName $IP -UseSSL -SessionOption $opt -Authentication Basic -Credential $c
Enter-PSSession $session
