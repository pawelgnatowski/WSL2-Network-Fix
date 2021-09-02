How to run WSL2 and Hyper-V VMs as if your Linux was normal VM, with own ip address:
no redirects needed. no *special* software. 
As it should have been from the start. or As if MS decided not to overwrite your config every single reboot.

Linux:
wsl.conf => disable resolv.conf recreation

resolv.conf => set flag to +i so windows will not overwrite the file despite the docs saying wsl.conf is enough. it is not. MS plainly ignores wsl.conf file and its own docs.

put the script (configureWSL2Net.sh) somewhere in your WSL2 instance  and mark executable it to +x.conf

setup the task scheduleron startup - 30 seconds delay to run => start.bat
make sure paths are correct in the file.conf
for basic troubleshooting use the log file being created at boot.

Assumption is you run docker, hyper V, windows 11 latest version (earleir may or may not work)
Docker used here CE native Linux version, not Docker Desktop. Desktop might need another approach. Possibly even simpler as in CE it does not start WSL nor Docker automatically.
Windows network is set to DHCP - you can bind mac for static address or write powershell to give it fixed address.

Keep in mind, if you do wsl --shutdown manually, you need to run sh script again.