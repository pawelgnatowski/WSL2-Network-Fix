# Set-VMSwitch : Failed while adding virtual Ethernet switch connections  #9    

Set-VMSwitch : Failed while adding virtual Ethernet switch connections.
Ethernet port '{EC88F1CA-81FD-421B-A395-FD47CD3BD45F}' bind failed: Element not found. (0x80070490).

    At C:\Users\mhwilkie\code\WSL2-Network-Fix\resetWindowsNet.ps1:75 char:9
    +         Set-VMSwitch WSL -NetAdapterName $active[0].Name ;
    +         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : ObjectNotFound: (:) [Set-VMSwitch], VirtualizationException
        + FullyQualifiedErrorId : ObjectNotFound,Microsoft.HyperV.PowerShell.Commands.SetVMSwitch



> *My work around is to remove the Hyper-V feature. Reboot. Re-add the Hyper-V feature. Reboot. The Default switch is now set to "Internal network" and functions properly.*
>
>  *From <*[*https://borncity.com/win/2019/06/18/windows-10-v1903-ip-resolution-bug-in-hyper-v-switch/*](https://borncity.com/win/2019/06/18/windows-10-v1903-ip-resolution-bug-in-hyper-v-switch/)*>* 
>
>  *WORKAROUND: install Windows Sandbox (in addition to Hyper-V, in this case). Having Windows Sandbox installed seems to allow Windows to have what it needs to properly hand out a DHCP address.*
>
> *From* [*https://borncity.com/win/2019/06/18/windows-10-v1903-ip-resolution-bug-in-hyper-v-switch/*](https://borncity.com/win/2019/06/18/windows-10-v1903-ip-resolution-bug-in-hyper-v-switch/)
>
>  *1- ensure you have the WiFi drivers for your NIC. 2- run “netcfg -d” as admin. This will clean up anything in the NIC settings that might cause problems by totally removing all NIC info. 3- reboot 4- try adding the switch again.*
>
>  *From <*[*https://www.reddit.com/r/HyperV/comments/hsn56h/i_cannot_for_the_life_of_me_create_a_virtual/*](https://www.reddit.com/r/HyperV/comments/hsn56h/i_cannot_for_the_life_of_me_create_a_virtual/)*>* 
>
>  *Yeah corrupted drivers seemed to be the problem. It suddenly started working*
>
> *From <*[*https://www.reddit.com/r/HyperV/comments/hsn56h/i_cannot_for_the_life_of_me_create_a_virtual/*](https://www.reddit.com/r/HyperV/comments/hsn56h/i_cannot_for_the_life_of_me_create_a_virtual/)*>* 
>
> 
>
> ## Remedy #1 Cleaning net drivers

    netcfg -d
    shutdown /g

After start up and logon:

    ~~~
    PS C:\Users\mhwilkie\code\WSL2-Network-Fix> Get-NetAdapter
    
    Name                      InterfaceDescription                    ifIndex Status       MacAddress             LinkSpeed
    ----                      --------------------                    ------- ------       ----------             ---------
    vEthernet (WSL)           Hyper-V Virtual Ethernet Adapter #2          22              00-15-5D-D7-FF-55          0 bps
    VirtualBox Host-Only N... VirtualBox Host-Only Ethernet Adapter        19 Up           0A-00-27-00-00-13         1 Gbps
    Wi-Fi                     Qualcomm(R) QCA6174A Extended Range ...      17 Up           10-5B-AD-32-3F-0B     144.4 Mbps
    Ethernet 3                Check Point Virtual Network Adapter ...      13 Disconnected 54-5B-B3-13-42-0F         1 Gbps
    vEthernet (Default Sw...2 Hyper-V Virtual Ethernet Adapter #3          58 Up           00-15-5D-64-10-2C        10 Gbps
    vEthernet (Default Swi... Hyper-V Virtual Ethernet Adapter              8              00-15-5D-AA-CE-BD          0 bps
    ~~~

Interesting that there are 3 hyper-v adapters, 2 of which are disabled.
And the Bridge has been removed too.

...and that after launching a WSL console a new hyper-v adapter appears:

    ~~~
    Name                      InterfaceDescription                    ifIndex Status       MacAddress             LinkSpeed
    ----                      --------------------                    ------- ------       ----------             ---------
    vEthernet (WSL)           Hyper-V Virtual Ethernet Adapter #2          22              00-15-5D-D7-FF-55          0 bps
    VirtualBox Host-Only N... VirtualBox Host-Only Ethernet Adapter        19 Up           0A-00-27-00-00-13         1 Gbps
    Wi-Fi                     Qualcomm(R) QCA6174A Extended Range ...      17 Up           10-5B-AD-32-3F-0B     144.4 Mbps
    Ethernet 3                Check Point Virtual Network Adapter ...      13 Disconnected 54-5B-B3-13-42-0F         1 Gbps
    vEthernet (WSL) 2         Hyper-V Virtual Ethernet Adapter #4          66 Up           00-15-5D-AE-88-1D        10 Gbps
    vEthernet (Default Sw...2 Hyper-V Virtual Ethernet Adapter #3          58 Up           00-15-5D-64-10-2C        10 Gbps
    vEthernet (Default Swi... Hyper-V Virtual Ethernet Adapter              8              00-15-5D-AA-CE-BD          0 bps
    ~~~

Why did it not use the existing one? 
And why is 'Delete' disabled in the Control Panel view of net adapters?

