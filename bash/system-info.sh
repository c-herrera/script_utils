#!bin/bash
# File          : system-info.sh
# Purpose       : Gather as much system info as possible
# Description   : Script will try to get as much system data as posible and save
#                 it a single location where user can pick and seek for whatever
#                 is required
# Version       : 0.0.1
# Date          : 05-03-2018
# Created by    : Carlos Herrera.
# Notes         : To run type sh system-info.sh in a system terminal with root access.
#                 If modified, please contact the autor to add and check the changes
# Scope         : Generic linux info gathering script, works good on red hat 7.5

# Fun times on errors!
set +x
LogDir=SUT_Info_$(date +%Y_%m_%d_%H_%M_%S)
version="0.0.2"

# Setting for a future checkup
if  [ $# -ne 0 ]
then
	echo " Usage : $0"
	exit 1
fi

# Get rid of all the term clutter
clear
# A nice introduction ....
echo -e "-----------------------------------------------------------"
echo -e "Running system gathering script for Linux (generic script) on :"
date
uname -rm
echo "Script version : $version"
# Make our new logging directory
if  [ -d "$LogDir" ]
then
	echo "$LogDir directory exists, will continue"
	touch $LogDir/first.log
	date >> $LogDir/first.log
else
	echo "$LogDir directory not found, creating one"
	mkdir $LogDir
	touch $LogDir/executed_time.log
	echo "Alloted times " >> $LogDir/executed_time.log
	date >> $LogDir/executed_time.log
fi

if [ -d  "/bin" ]
then 
	echo "main directory BIN is present continue ..."
else
	echo "BIN directory is not present at // bailing out..."
	exit 1
fi

# Annnnd proceed with the script ...
echo "-----------------------------------------------------------"
echo "Running (LSHW) : System information"
lshw -html > $LogDir/lshw-system-info.html
lshw -short > $LogDir/lshw-system-info-brief.log
echo "Running (DMIDECODE) : Full System hardware information"
dmidecode > $LogDir/dmidecode-system-dmi-full-hw.log
echo "-----------------------------------------------------------"
echo "Running (LSCPU) : CPU basic & extended info."
lscpu > $LogDir/lscpu-cpu-basic.log
lscpu --extended --all | column -t > $LogDir/lscpu-cpu-extended.log
echo "-----------------------------------------------------------"
echo "Running (LSBLK) : Block devices info."
lsblk --all --ascii --perms --fs > $LogDir/lsblk-block-devices.log
echo "-----------------------------------------------------------"
echo "Running (LSCPI) : PCI devices info"
lspci -t -vmm > $LogDir/lspci-pci-devices-topology-verbose.log
echo "-----------------------------------------------------------"
echo "Running (LSUSB) : USB info."
lsusb -t > $LogDir/lsusb-usb-devices-topology.log
lsusb > $LogDir/lsusb-usb-devices-normal.log
echo "-----------------------------------------------------------"
echo "Running (LSSCSI) : SCSI devices."
lsscsi --size --verbose | column -t > $LogDir/lsssci-scsi-devices-verbose.log
echo "-----------------------------------------------------------"
echo "Running (FDISK) : Filesystem info."
fdisk -l -s > $LogDir/fdisk-fs-sys.log
echo "-----------------------------------------------------------"
echo "Running (DF) : Disk usage stats"
df -h > $LogDir/df-disk-usage.log
echo "-----------------------------------------------------------"
echo "Runnig (MOUNT) : Mounted stats."
mount | column -t > $LogDir/mounted-devices.log
echo "-----------------------------------------------------------"
echo "Running (FREE) : Memory stats."
free -m > $LogDir/free-memory-usage.log
cat /proc/meminfo > $LogDir/proc-meminfo-memory-assigned.log
echo "-----------------------------------------------------------"
echo "Running (LSMOD) : Module information"
lsmod | column -t > $LogDir/lsmod-modules-loaded.log
echo "-----------------------------------------------------------"
echo "Running (DMESG) : Getting DMESG info."
dmesg --reltime > $LogDir/dmesg.log
echo "-----------------------------------------------------------"
echo "Power Mgnt : Getting C-States driver"
cat /sys/devices/system/cpu/cpuidle/current_driver > $LogDir/pwr-cstates-driver.log
echo "-----------------------------------------------------------"
echo "Power Mngt : Getting system idle driver info."
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver > $LogDir/pwr-cstates-current-idle_driver.log
echo "-----------------------------------------------------------"
echo "OS  : System version :"
cat /proc/version > $LogDir/proc-system-version.log
echo "-----------------------------------------------------------"
echo "OS : Getting all system messages"
cat /var/log/messages > $LogDir/messages.log
echo "-----------------------------------------------------------"
echo "OS : Getting SoftIRQs info"
cat /proc/softirqs > $LogDir/softirqs.log
echo "-----------------------------------------------------------"
echo "OS : Gettimg modules information "
cat /proc/modules | column -t > $LogDir/modules.log
echo "-----------------------------------------------------------"
echo "OS : Getting IO-Memory assignation"
cat /proc/iomem > $LogDir/iomem.log
echo "-----------------------------------------------------------"
echo "OS : Getting Partitions assignation"
cat /proc/partitions > $LogDir/partitions.log
echo "-----------------------------------------------------------"
echo "OS : Getting CPU Information"
cat /proc/cpuinfo > $LogDir/cpuinfo.log
echo "-----------------------------------------------------------"
echo "OS : Getting Memory page information"
cat /proc/pagetypeinfo > $LogDir/pagetypeinfo.log
echo "-----------------------------------------------------------"
echo "OS : Getting Network devices stats"
cat /proc/net/dev | column -t > $LogDir/network_devices_stats.log
echo "-----------------------------------------------------------"
echo "OS : Linux boot command line :"
cat /proc/cmdline > $LogDir/linux_os_boot_line.log
echo "-----------------------------------------------------------"
echo "OS : Crytograhpy on OS :"
cat /proc/crypto > $LogDir/linux_os_cryto.log
echo "-----------------------------------------------------------"
echo "OS : Disk stats"
cat /proc/diskstats | column -t > $LogDir/linux_diskstats.log
echo "-----------------------------------------------------------"

echo "Script is done, you may want to check the logs on ${LogDir} "
date  >> $LogDir/executed_time.log







