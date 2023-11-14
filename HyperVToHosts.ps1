#Requires -RunAsAdministrator
Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"

$hostsFile = "${env:SystemRoot}\System32\drivers\etc\hosts"
$baseHostFile = "${env:SystemRoot}\System32\drivers\etc\hosts.base"

$datestring = (Get-Date -Format "o") -Replace '[:\-]','-'
$backupHostsFile = "$hostsFile.${datestring}.bak"

echo "Backing up hosts file to $backupHostsFile"
cp $hostsFile $backupHostsFile

try {
  $hostsFileBaseText = (Get-Content "${baseHostFile}")
} catch {
    echo "`nCreating a base host file so we can append to hosts without any damage.`n"

    cp $hostsFile $baseHostFile
    $hostsFileBaseText = (Get-Content "${baseHostFile}")
}

echo "${env:SystemRoot}\System32\drivers\etc\hosts.base"
echo "${env:SystemRoot}\System32\drivers\etc\hosts
"
Set-Content -Path "$hostsFile" -Value $hostsFileBaseText

$content = ''

foreach ($vm in (get-vm | ?{$_.State -eq "Running"} |  Get-VMNetworkAdapter)) {
    #Remove any . or space from the name
    $vmname = $vm.VMName.ToLower() -replace '[. ]',''
    #Here we add a .local to the full vm name
    $hostName = "${vmname}.local"
    # Now Only take the caps letters and create the host entry for that.
    $hostShortName = $($vm.VMName.ToString() -creplace '[a-z]','').ToLower()

    # Search the notes and get any custom defined domains for this vm
    $singleLineNotes =  $(Get-VM  $vm.VMName | Select-Object -Property Notes).Notes.Replace("`n",' ')
    $addDomains = "";
    if ($singleLineNotes -match '##domains## (?<domains>.+) ##domains##') {
        $addDomains = $matches.domains
    }

    if ($vm.IPAddresses -ne $null) {
        echo "Writing hosts entry for $vm"
        $address = $vm.IPAddresses[0]
        $content += "$address $hostName ${hostShortName}.dev ${addDomains}`n"
    } else {
        echo "Ignoring $vm"
    }
}

echo "`n`nCreated the following entries based on the VM's: `n${content}"
Add-Content -Path "$hostsFile" -Value $content

echo "`n`n Outputting of the file for verification."
Get-Content -Path $hostsFile

Read-Host -Prompt "Press Enter to exit"