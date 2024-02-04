---------- new way as of 4th Feb 2024, latest windows patch stable
to make it work use Hyper-V Networking manager to set WSL network adapter to External
(hyper v might complain - close it and try again, should apply changes)
FYI i have two lan cards - so it can make my life easier as I bind WSL to separate LAN, try it though.



use stertWsl.sh file
in /etc/wsl.conf

[boot]
systemd=true
# Network host settings that enable the DNS server used by WSL 2. This example changes the hostname, sets generateHosts to false, preventing WSL from the default behavior of auto-generating /etc/hosts, and sets generateResolvConf to false, preventing WSL from auto-generating /etc/resolv.conf, so that you can create your own (ie. nameserver 1.1.1.1).
[network]
hostname = WslUbuntu

# generateHosts = false
# generateResolvConf = false

# Set whether WSL supports interop processes like launching Windows apps and adding path variables. Setting these to false will block the launch of Windows processes and block adding $PATH environment variables.
[interop]
#enabled = false
appendWindowsPath = false

# # Set the user when launching a distribution with WSL.
# [user]
# default = DemoUser

# Set a command to run when a new WSL instance launches. This example starts the Docker container service.
[boot]
command = /home/wsluser/startWsl.sh

Should work at least for TCPv4 traffic. Tried http - worked.


_______________this is very old way_______________
How to run WSL2 and Hyper-V VMs as if your Linux was normal VM, with own ip address:
no redirects needed. no *special* software. 
As it should have been from the start. or As if MS decided not to overwrite your config every single reboot.

Linux:
wsl.conf => disable resolv.conf recreation

resolv.conf => set flag to +i so windows will not overwrite the file despite the docs saying wsl.conf is enough. it is not. MS plainly ignores wsl.conf file and its own docs.

put the script (configureWSL2Net.sh) somewhere in your WSL2 instance  and mark executable it to +x.conf

setup the task scheduler on startup AFTER LOGIN - 30 seconds delay to run => start.bat
make sure paths are correct in the files. 
for basic troubleshooting use the log file being created at boot.
Running this before login will cause wsl$ mapping to be broken and will also prevent you from running "code ." inside linux folders. VS Code will still work though, just you will ahve to open it form within remote connection though.

Assumption is you run docker, hyper V, windows 11 latest version (earleir may or may not work)
Docker used here CE native Linux version, not Docker Desktop. Desktop might need another approach. Possibly even simpler as in CE it does not start WSL nor Docker automatically.
Windows network is set to DHCP - you can bind mac for static address or write powershell to give it fixed address.

Keep in mind, if you do wsl --shutdown manually, you need to run sh script again.

