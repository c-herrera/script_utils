#!bin/bash
# File          : system-info.sh
# Purpose       : Gather as much system info as possible
# Description   : Script will try to get as much system data as posible and save
#                 it a single location where user can pick and seek for whatever
#                 is required
# Version       : 0.0.5
# Date          : 05-03-2018
# Created by    : Carlos Herrera.
# Notes         : To run type sh system-info.sh in a system terminal with root access.
#                 If modified, please contact the autor to add and check the changes
# Scope         : Generic linux info gathering script, works good on red hat 7.5
#               : Do not remove this header, thanks!

# Fun times on errors!
set +x
# set otherwise for fun !!!


# Setting some vars to use :

#Script related
arch=-1
kernel=-1
distroname=1
distroshortname=1
distrovar=1
distrotype=1
currenthost=$(cat /etc/hostname)
LogDir=sut_Info_$(date +%Y_%m_%d_%H_%M_%S)
logfile=scriptlog.txt
version="0.0.5"
errorlog=errors.txt

#script folders

hw_dir=hw_logs
os_dir=os_logs
net_dir=net_logs
power_dir=power_logs
storage_dir=storage_logs
io_dir=io_logs
memory_dir=memory_logs
modules_dir=modules_logs


#Pause function
function pause(){
	echo "Press the Enter key to continue..."
	read -p "$*"
}

# Prototype 1 command 2 arguments (opt) 3 path to save 4 log filename
function RunCmdandLog() {
	if [ -n "$(command -v $1)" ]; then
		echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $1 running ] "
		echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $1 running ] " >> $3/$4
		$1 $2 >> $3/$4
		echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $1 done ] " >> $3/$4
	fi
}


# Detecting OS and Distrotype
function OS_detect() {
	arch=$(uname -m)
	kernel=$(uname -r)
	if [ -n "$(command -v lsb_release)" ]; then
		distroname=$(lsb_release -s -d)
	elif [ -f "/etc/os-release" ]; then
		distroname=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="')
		distroshortname=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
	elif [ -f "/etc/debian_version" ]; then
		distroname="Debian $(cat /etc/debian_version)"
	elif [ -f "/etc/redhat-release" ]; then
		distroname=$(cat /etc/redhat-release)
	else
		distroname="$(uname -s) $(uname -r)"
	fi

	case ${distroshortname} in
		"Red" )
		distrovar=RED_HAT
		;;
		"Ubuntu" )
		distrovar=UBUNTU
		;;
		"SUSE" )
		distrovar=SUSE
		;;	
	esac

	case $(uname) in 
		Linux )
		if  [ -x "$(command -v yum)" ]; then
			distrotype=RED_HAT_LIKE
		fi
		
		if  [ -x "$(command -v zypper)" ]; then
			distrotype=SUSE_LIKE
		fi
		
		if  [ -x "$(command -v apt-get)" ]; then
			distrotype=DEBIAN_LIKE
		fi
		;;
		
		MacOS )
		#nothing here
		;;
		
		* )
		# Nothing here
		;;
	esac
}

#Main folders setup
function folderSetup(){
	mkdir --parents $LogDir/$hw_dir
	mkdir --parents $LogDir/$os_dir
	mkdir --parents $LogDir/$net_dir
	mkdir --parents $LogDir/$power_dir
	mkdir --parents $LogDir/$storage_dir
	mkdir --parents $LogDir/$memory_dir
	mkdir --parents $LogDir/$modules_dir
	mkdir --parents $LogDir/$io_dir
}


# Setting for a future command line checkup
if  [ $# -ne 0 ]
then
	echo "Tool to gather Linux OS information for testing cases or debug triage"
	echo " Usage : $0"
	echo "Type : $0 with more than one argument to get this help."
	exit 1
fi

#Start here :

#Linux distro detection
OS_detect
# Make our new logging directory
if  [ -d "$LogDir" ]
then
	echo "$LogDir directory exists, will continue"
	touch $LogDir/$logfile
	echo "Current username : $(whoami)" >> $LogDir/$logfile
	echo "Logged as        : $(logname)" >> $LogDir/$logfile
	echo "Hostname  is     : $currenthost" >> $LogDir/$logfile
	echo "OS : ${distroname} Arch : ${arch} Kernel : ${kernel}" >> $LogDir/$logfile
	echo "Distrotype ${distrotype}" >> $LogDir/$logfile
	echo "Script version : $version" >> $LogDir/$logfile
	echo "Starup time : " >> $LogDir/$logfile
	date >> $LogDir/$logfile
	# Create folder for logs
	folderSetup
else
	echo "$LogDir directory not found, creating one"
	mkdir $LogDir
	touch $LogDir/$logfile
	echo "Current username : $(whoami)" >> $LogDir/$logfile
	echo "Logged as        : $(logname)" >> $LogDir/$logfile
	echo "Hostname  is     : $currenthost" >> $LogDir/$logfile
	echo "OS : ${distroname} Arch : ${arch} Kernel : ${kernel}" >> $LogDir/$logfile
	echo "Distrotype ${distrotype}" >> $LogDir/$logfile
	echo "Script version : $version" >> $LogDir/$logfile
	echo "Starup time : " >> $LogDir/$logfile
	# Create folder for logs
	date >> $LogDir/$logfile
	folderSetup
fi

# Checking this does not hurt
if [ -d  "/bin" ]
then 
	echo "main directory BIN is present continue ..."
else
	echo "BIN directory is not present at // bailing out..."
	exit 1
fi

# Get rid of all the term clutter
clear

# A nice introduction ....

echo ""
echo "************************************************************"
echo ""
echo "System Report for $(cat /etc/hostname) ($(hostname -I | awk '{print $1}'))"
echo "Generated at $(date)"
echo "************************************************************"
echo " Uptime:         $(uptime p)"
echo " Kernel Version: $(uname -r)"
echo " Load info:      $(cat /proc/loadavg)"
echo " Disk status:    $(df -h / | awk 'FNR == 2 {print $5 " used (" $4 " free)"}')"
echo " Memory status:  $(free -h | awk 'FNR == 2 {print $3 " used (" $4 " free)"}')"
echo " OS : ${distroname} "
echo " Arch : ${arch}"
echo " Kernel : ${kernel}"
echo " Distrotype ${distrotype}"
echo " Script version : $version"

# Annnnd proceed with the script ...
echo "- Starting the recolletion " >> $LogDir/$logfile
echo "- Process started at $(date +%Y:%m:%d:%H:%M:%S) " >> $LogDir/$logfile

#RunandLog lshw -html $LogDir/$hw_dir/ lshw_system-specs.html
#RunandLog lshw -short $LogDir/$hw_dir/ lshw_system-info.html
#RunandLog hwinfo "-all --log=$LogDir/$hw_dir/hwinfo.log" $LogDir/$hw_dir/hwinfodone.log
#pause


# Hardware logs section
echo "- Hardware section starts :" >> $LogDir/$logfile

stringcommand=lshw

if [ -x "$(command -v lshw)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	lshw -html > $LogDir/$hw_dir/lshw-system-info.html
	lshw -short >$LogDir/$hw_dir/lshw-system-info-brief.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand=hwinfo

if [ -x "$(command -v hwinfo)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	hwinfo --all --log=$LogDir/$hw_dir/hwinfo-log.txt
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand=dmidecode

if [ -x "$(command -v dmidecode)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	dmidecode > $LogDir/$hw_dir/dmidecode-system-dmi-full-hw.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand=lspci

if [ -x "$(command -v lspci)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	lspci -t -vmm > $LogDir/$hw_dir/lspci-pci-devices-topology-verbose.log
	lspci -vvvxxx > $LogDir/$hw_dir/lspci-pci-devices-extra-Verbose.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand=lscpu


if [ -x "$(command -v lscpu)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	lscpu > $LogDir/$hw_dir/lscpu-cpu-basic.log
	lscpu --extended --all | column -t > $LogDir/$hw_dir/lscpu-cpu-extended.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi 

stringcommand="processor info /proc/cpuinfo"

if [ -f /proc/cpuinfo  ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/cpuinfo > $LogDir/$hw_dir/cpuinfo.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

echo "- Hardware section ends " >> $LogDir/$logfile


# Storage logs section

echo "- Storage section begins " >> $LogDir/$logfile
stringcommand=lsblk
if [ -f /proc/cpuinfo  ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	lsblk --all --ascii --perms --fs > $LogDir/$storage_dir/lsblk-block-devices.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi 

stringcommand=lsscsi
if [ -x "$(command -v lsscsi)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	lsscsi --size --verbose | column -t > $LogDir/$storage_dir/lsssci-scsi-devices-verbose.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand=fdisk
if [ -x "$(command -v fdisk)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	fdisk -l > $LogDir/$storage_dir/fdisk-fs-sys.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand=df
if [ -x "$(command -v df)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	df -h > $LogDir/$storage_dir/df-disk-usage.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand="Partition specs"
if [ -f /proc/partitions  ];then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/partitions > $LogDir/$storage_dir/partitions.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand="mounted partitions"
if [ -x "$(command -v mount)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	mount | column -t > $LogDir/$storage_dir/mounted-devices.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand=SCSI
if [ -f /proc/scsi  ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/scsi/scsi >> $LogDir/$storage_dir/scsi_devices.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand="SCSSI Mounts"
if [ -f /proc/scsi/mounts ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/scsi/mounts >> $LogDir/$storage_dir/scsi-mounts.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand=DiskStats
if [ -f /proc/diskstats ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/diskstats | column -t >> $LogDir/$storage_dir/linux_diskstats.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

echo "- Storage section ends " >> $LogDir/$logfile

#IO section

echo "- IO section begins " >> $LogDir/$logfile

stringcommand=IOPORTS
if [ -f /proc/ioports ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/ioports > $LogDir/$io_dir/ioports.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi 

stringcommand=LSUSB
if [ -x "$(command -v lsusb)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	lsusb -t > $LogDir/$hw_dir/lsusb-usb-devices-topology.log
	lsusb > $LogDir/$hw_dir/lsusb-usb-devices-normal.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand=SoftwareIRQ
if [ -f /proc/softirqs ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/softirqs > $LogDir/$hw_dir/softirqs.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

echo "- IO section ends " >> $LogDir/$logfile

#Memory section

echo "- Memory section begins " >> $LogDir/$logfile
stringcommand=PAGETYPEINFO
if [ -f /proc/pagetypeinfo ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/pagetypeinfo > $LogDir/$memory_dir/pagetypeinfo.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand=FREEMEM
if [ -x "$(command -v free)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	free -m > $LogDir/$memory_dir/free-memory-usage.log
	cat /proc/meminfo > $LogDir/$memory_dir/proc-meminfo-memory-assigned.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand=IOMEM
if [ -f /proc/iomem ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/iomem > $LogDir/$memory_dir/io_mem_address.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

echo "- Memory section ends " >> $LogDir/$logfile

#Modules section

echo "- Modules section begins" >> $LogDir/$logfile
stringcommand=LSMOD
if [ -x "$(command -v lsmod)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	lsmod | column -t > $LogDir/$modules_dir/lsmod-modules-loaded.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand="System loaded modules"
if [ -f /proc/modules ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/modules | column -t > $LogDir/$modules_dir/modules.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

echo "- Modules section ends " >> $LogDir/$logfile

#Power Mngt Section

echo "- PowerMngt section begins" >> $LogDir/$logfile
stringcommand=POWERDRIVER
if [ -d /sys/devices/system/cpu ]; then 

	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	echo "CPU idle current driver :" > $LogDir/$power_dir/pwr-cstates-driver.log
	cat /sys/devices/system/cpu/cpuidle/current_driver >> $LogDir/$power_dir/pwr-cstates-driver.log
	echo "CPU Scaling driver :" >> $LogDir/$power_dir/pwr-cstates-driver.log
	cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver >> $LogDir/$power_dir/pwr-cstates-driver.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

echo "- PowerMngt section ends" >> $LogDir/$logfile
#Network section

echo "- Network section begins" >> $LogDir/$logfile
stringcommand="Network devices statistics"
if [ -f /proc/net/dev ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/net/dev | column -t > $LogDir/$net_dir/network_devices_stats.log 2>> $errorlog
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand="Ifconfig "
if [ -x "$(command -v ifconfig)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	ifconfig  > $LogDir/$net_dir/ifconfig.log 2>> $errorlog
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi 

stringcommand="Ip Address"
if [ -x "$(command -v ip)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	ip  addr > $LogDir/$net_dir/network_ips.log 2>> $errorlog
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi 

stringcommand="Hosts conf"
if [ -f /proc/hosts ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cp /etc/hosts $LogDir/$net_dir/network_hosts 2>> $errorlog
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand="IP Route"
if [ -x "$(command -v route)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	route > $LogDir/$net_dir/route.txt  2>> $errorlog
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi


echo "- Network section ends" >> $LogDir/$logfile

#OS Enviroment section

echo "- OS Enviroment logs" >> $LogDir/$logfile

stringcommand="System version"
if [ -f /proc/version ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/version > $LogDir/$os_dir/proc-system-version.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand="System messages"
if [ -f /var/log/messages ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cp /var/log/messages $LogDir/$os_dir/messages.log 2>> $errorlog
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand="Dmesg ..."
if [ -x "$(command -v dmesg)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	dmesg --level=warn > $LogDir/$os_dir/dmesg-warnings.log
	dmesg --level=err > $LogDir/$os_dir/dmesg-errors.log
	dmesg --level=crit > $LogDir/$os_dir/dmesg-critial.log
	dmesg --level=debug > $LogDir/$os_dir/dmesg-debug.log
	dmesg > $LogDir/$os_dir/dmesg.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi


stringcommand="OS Boot commandline"
if [ -f /proc/cmdline ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/cmdline > $LogDir/$os_dir/linux_os_boot_line.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi


stringcommand="OS Cryptography"
if [ -f /proc/crypto ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	cat /proc/crypto > $LogDir/$os_dir/linux_os_crypto.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi


stringcommand="System units"
if [ -x "$(command -v systemctl)" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	systemctl list-unit-files > $LogDir/$os_dir/system_units.log
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand="Modules conf"
if [ -d "/etc/modprobe.d" ]; then 
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
	mkdir --parents $LogDir/$os_dir/etc/
	cp -R /etc/modprobe.d* $LogDir/$os_dir/etc/ 2>> $errorlog
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi

stringcommand="Driver modules info"
echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
if [ -f $LogDir/$os_dir/drivers.txt ]; then 
	rm $LogDir/$os_dir/drivers.txt; 
fi
lsmod | sed 's/ .*//g' | sort | sed '/Module/d' > $LogDir/$os_dir/lsmod.txt
cat $LogDir/$os_dir/lsmod.txt | while read line
do
	modinfo $line | grep -w "version:" > $LogDir/$os_dir/version.txt
	VERSION=$LogDir/$os_dir/version.txt
	if [[ -s $VERSION ]]; then
		modinfo $line >> $LogDir/$os_dir/alldriverinfo.txt
		modinfo $line | grep -e "description:"  >> $LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "filename:   " | sed 's/\/.*\///g' >> $LogDir/$os_dir/drivers.txt
		modinfo $line | grep -w "version:    "  >> $LogDir/$os_dir/drivers.txt
		echo >> $LogDir/$os_dir/drivers.txt
	else
		continue
	fi
done
echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile


stringcommand="OS Packages info"
echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
if [ -x "$(command -v yum)" ]; then 
	yum list all > $LogDir/$os_dir/yum_list_all_pkgs.log
	yum list installed > $LogDir/$os_dir/yum_list_only_installed_pkgs.log
	rpm -qa | sort > $LogDir/$os_dir/installed_rpms.txt
fi 

if [ -x "$(command -v zypper)" ]; then 
	zypper pa > $LogDir/$os_dir/zypper_pkgs_avail.log
	rpm -qa | sort > $LogDir/$os_dir/installed_rpms.txt
fi

if [ -x "$(command -v apt-get)" ]; then 
	echo "0"
fi
echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile


stringcommand="OS command history"
echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] "
echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand running ] " >> $LogDir/$logfile
if [ -x "$(command -v yum)" ]; then 
	history > $LogDir/$os_dir/history.txt 2>>$errorlog
	echo "- [ $(date +%Y:%m:%d:%H:%M:%S) $stringcommand done ] " >> $LogDir/$logfile
fi


echo "- OS Enviroment logs ends" >> $LogDir/$logfile





# end 
echo "Script is done, you may want to check the logs on ${LogDir} "
echo "End time : " >> $LogDir/$logfile
date  >> $LogDir/$logfile
exit
