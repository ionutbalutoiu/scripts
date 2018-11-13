#import-module ".\Out-Minidump.ps1"
$TEMP_DIR_FOR_LOGS = "c:\temp_dir"
$openstack_logs = "C:\Openstack\Log"
$openstack_config = "C:\Program Files\Cloudbase Solutions\Openstack\Nova\etc"
mkdir $TEMP_DIR_FOR_LOGS

Function Get-WmiCustom($computername=$env:COMPUTERNAME,$namespace,$class,$timeout=1)
{
$ConnectionOptions = new-object System.Management.ConnectionOptions
$EnumerationOptions = new-object System.Management.EnumerationOptions

$timeoutseconds = new-timespan -seconds $timeout
$EnumerationOptions.set_timeout($timeoutseconds)

$assembledpath = "\" + $computername + "" + $namespace
#write-host $assembledpath -foregroundcolor yellow
$Scope = new-object System.Management.ManagementScope
$Scope.Path = "\\.\$namespace"
#$Scope.Options = $ConnectionOptions
$Scope.Connect()

$querystring = "SELECT * FROM " + $class
#write-host $querystring

$query = new-object System.Management.ObjectQuery $querystring
$searcher = new-object System.Management.ManagementObjectSearcher
$searcher.set_options($EnumerationOptions)
$searcher.Query = $querystring
$searcher.Scope = $Scope

trap { $_ } $result = $searcher.get()

return $result
}

function exporthtmleventlog($path = $null, $services = $null, $date = $null){

    #$css = Get-Content $eventlogcsspath -Raw

    #$js = Get-Content $eventlogjspath -Raw
	
	if ($path -eq $null) {
		$path=$pwd
	}

	
	if ($date -eq $null ) {
		$event_start = (((Get-Date).addDays(-3)).date)
	} else {
		$event_start = $date
	}
	$event_end = (Get-Date)
	
	if ($services -eq $null) {
		$criteria = @{StartTime=$event_start; EndTime=$event_end}
	} else {
		$criteria = @{LogName = $names; StartTime=$event_start; EndTime=$event_end}
	}

    $HTMLHeader = @"

<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

"@

    foreach ($i in (get-winevent -ListLog * -ErrorAction SilentlyContinue |  ? {$_.RecordCount -gt 0 })) {
	
		$criteria = @{LogName = $i.LogName; StartTime=$event_start; EndTime=$event_end}

        $Report = (get-winevent -FilterHashTable $criteria  -ErrorAction SilentlyContinue)
		if ($Report.Count -le 0) {
			continue;
		}

        $logName = "eventlog_" + $i.LogName + ".html"

        $logName = $logName.replace(" ","-").replace("/", "-").replace("\", "-")

        Write-Host "exporting "$i.LogName" as "$logName

        $Report = $Report | ConvertTo-Html -Title "${i}" -Head $HTMLHeader -As Table

        $Report = $Report | ForEach-Object {$_ -replace "<body>", '<body id="body">'}

        $Report = $Report | ForEach-Object {$_ -replace "<table>", '<table class="sortable" id="table" cellspacing="0">'}

        $bkup = Join-Path $path $logName

        $Report = $Report | Set-Content $bkup

    }

}
systeminfo >> "$TEMP_DIR_FOR_LOGS\systeminfo.log"

#wmic Path CIM_DataFile WHERE Name='c:\\windows\\system32\\vmms.exe' Get Version >> "$TEMP_DIR_FOR_LOGS\systeminfo.log"

pip freeze >> "$TEMP_DIR_FOR_LOGS\pip_freeze.log"

ipconfig /all >> "$TEMP_DIR_FOR_LOGS\ipconfig.log"



get-netadapter | Select-object * >> "$TEMP_DIR_FOR_LOGS\get_netadapter.log"

#get-vmswitch | Select-object * >> "$TEMP_DIR_FOR_LOGS\get_vmswitch.log"

get-WmiObject win32_logicaldisk | Select-object * >> "$TEMP_DIR_FOR_LOGS\disk_free.log"

get-netfirewallprofile | Select-Object * >> "$TEMP_DIR_FOR_LOGS\firewall.log"

get-process | Select-Object * >> "$TEMP_DIR_FOR_LOGS\get_process.log"

get-service | Select-Object * >> "$TEMP_DIR_FOR_LOGS\get_service.log"

exporthtmleventlog($TEMP_DIR_FOR_LOGS)

ovs-vsctl show >> "$TEMP_DIR_FOR_LOGS\ovs_vsctl.log"

ovs-dpctl show >> "$TEMP_DIR_FOR_LOGS\ovs-dpctl.log"

#get-vmswitchextension * >> "$TEMP_DIR_FOR_LOGS\get_vmswitchextension.log"

cp -Recurse -Force "$env:OVS_LOGDIR\*" "$TEMP_DIR_FOR_LOGS\"

cp -Recurse -Force "$openstack_logs\*" "$TEMP_DIR_FOR_LOGS\"

cp -Recurse -Force "$openstack_config\*" "$TEMP_DIR_FOR_LOGS\"

#get-wmicustom -namespace "root\virtualization\v2" -class msvm_computersystem >> "$TEMP_DIR_FOR_LOGS\msvm_computersystem.log"

#Get-Process 'vmms' | Out-Minidump -DumpFilePath "$TEMP_DIR_FOR_LOGS\"

#$a = Get-Process 'vmwp'

#foreach ($i in $a) {
#	$i | Out-Minidump -DumpFilePath "$TEMP_DIR_FOR_LOGS\"
#}

Compress-Archive -Path "$TEMP_DIR_FOR_LOGS" -DestinationPath C:\logs.zip