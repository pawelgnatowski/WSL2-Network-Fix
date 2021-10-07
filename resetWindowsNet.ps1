# to execute you need to set this up:
# Set-ExecutionPolicy RemoteSigned
# let's check how boot process is going to be
$global:logPath = "C:\Startup\wsl2_boot.log"

# TODO: configureWSL2Net set global variable with path to shell script to configure WSL network interface inside Linux
# this function is used to configure network settings after VMSwitch is ready to be used by wsl instance
function ConfigureWSLNetwork {

     
    Write-Output "Starting WSL..." >> $logPath
    
    $wslStatus = Get-Process -Name "wsl" -ErrorAction Inquire
    if (!($wslStatus)) {
        Start-Job -ScriptBlock { Start-Process -FilePath "wsl.exe" -WindowStyle hidden }
    }   
    
    Do {

        $wslStatus = Get-Process -Name "wsl" -ErrorAction Inquire
    
        If (!($wslStatus)) { Write-Output 'Waiting for WSL2 process to start' >> $logPath ; Start-Sleep 1 }
        
        Else { Write-Output 'WSL Process has started, configuring network' >> $logPath ; $wslStarted = $true }
    
    }
    Until ( $wslStarted )

    $wslStatus 5>> $logPath
    
    # wsl --distribution Ubuntu-20.04 -u root /home/p/configureWSL2Net.sh
    # configureWSL2Net.sh needs to be made executable
    Start-Process -FilePath "wsl.exe" -ArgumentList "-u root /mnt/c/Startup/configureWSL2Net.sh"
    Write-Output "network configuration completed" >> $logPath
    
    Write-Output $wslStatus 5>> $logPath
    
    return 0
    
    
}


#  force launch without going to bash prompt
wsl exit

wsl -l -v *>> $logPath

$started = $false
$err = @()

Do {
    $status = Get-VMSwitch WSL -ErrorAction SilentlyContinue -ErrorVariable +err
    Write-Output "Get-VMSwitch status: $status" >> $logPath
    If ($err[0] -match "do not have the required permission") { Write-Output $err >> $logPath; throw $err }
    If ($err.count -eq 10) {Write-Output '*** Error No WSL VM switch after 10 attempts' >> $logPath; throw $err}

    If (!($status)) { Write-Output 'Waiting for WSL swtich to get registered ', $err.count ; Start-Sleep 1 }
    Else {
        Write-Output  "WSL Network found" ; 
        $started = $true; 
        # manipulate network adapter tickboxes - Adapter cannot be bound because binding to Hyper-V is still there after M$ windows restarts.
        # Get-NetAdapterBinding Ethernet to view components of the interface vms_pp is what we look for
        # Set-NetAdapterBinding -Name "Ethernet" -ComponentID vms_pp -Enabled $False ;

        # identify non-virtual adapters with active network connection
        # $active[0] will be 1st net adapter in list while $active.[-1] will be last one
        $active = Get-NetAdapter | Where-Object Status -eq up | Where-Object InterfaceDescription -NotMatch 'Virtual' ;
  
        # Disable the vm adapter bound to active connection.
        ## Set-NetAdapterBinding -Name "Ethernet" -ComponentID vms_pp -Enabled $False ;
        Set-NetAdapterBinding -Name $active[0].Name -ComponentID vms_pp -Enabled $False ;

        #Set-VMSwitch WSL -NetAdapterName "Ethernet" ;
        Set-VMSwitch WSL -NetAdapterName $active[0].Name ;
        $started = $true ;
        # Hook all Hyper V VMs to WSL network => avoid network performance issues.
        Write-Output  "Getting all Hyper V machines to use WSL Switch" >> $logPath ; 
        Get-VM | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName "WSL" ; 
        # now that host network is configured we can set up wsl network
        Pause
        ConfigureWSLNetwork ;
        # Start All Hyper VMs
        Get-VM | Start-VM ;
    }

}
Until ( $started )
