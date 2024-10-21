#!/bin/bash

# Obtain the information about OS version, CPU, memory
# by apr
# Last corrections made on 12/10/2024

#-------------------------------------------------------------------------------
#VM host informtion such as OS, CPU, IP, Memory, Swap space  "
#-------------------------------------------------------------------------------

# Configuration Parameters and values will be displayed in the output file located in /tmp/config_details.txt
#exec > /tmp/config_details.txt 2>&1
if [ -e /tmp/config_details.txt ] ; then
 mv /tmp/config_details.txt /tmp/config_details.txt.backup
fi



if [[ $(dmidecode --string chassis-asset-tag) == '7783-7084-3265-9085-8269-3286-77' ]] ; then
echo "cloudPlatform: Azure" >>/tmp/config_details.txt
else
if [[ $(dmidecode |grep UUID|cut -f2 -d: | cut -c -4) == ' ec2' ]] ; then
echo "cloudPlatform: AWS" >>/tmp/config_details.txt
else
echo "cloudPlatform: Others" >>/tmp/config_details.txt
 fi
fi

OS_PLATFORM=$(uname -s)
OS_ARCHITECTURE=$(uname -m)
OS_DISTRIBUTION=$(cat /etc/os-release | grep -w "NAME" | cut -d '=' -f2 | tr -d '"')
OS_VERSION=$(cat /etc/os-release | grep -w "VERSION" | cut -d '=' -f2 | tr -d '"'| cut -f1 -d-)
OS_PATCH=$(cat /etc/os-release | grep -w "VERSION" | cut -d '=' -f2 | tr -d '"'| cut -f2 -d-)

# Collect Host details
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')
CPU_CORES=$(nproc)
MEMORY=$(free -h | grep Mem | awk '{print $2}')
SWAP=$(free -h | grep Swap | awk '{print $2}')

echo "vmosPlatform: $OS_PLATFORM" >>/tmp/config_details.txt
echo "vmosArchitecture: $OS_ARCHITECTURE" >>/tmp/config_details.txt
echo "vmosDistribution: $OS_DISTRIBUTION" >>/tmp/config_details.txt
echo "vmosVersion: $OS_VERSION" >>/tmp/config_details.txt
if [[ $OS_DISTRIBUTION == "SLES" ]]; then
echo "vmosPatch: $OS_PATCH" >>/tmp/config_details.txt
fi
echo "vmHostname: $HOSTNAME" >>/tmp/config_details.txt
# Is Secondary IP address assigned
interface="eth0"

# Get all IP addresses assigned to the interface and count the number of IP addresses found
ip_addresses=$(ip -4 addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Count the number of IP addresses found
num_ips=$(echo "$ip_addresses" | wc -l)


# Check if more than one IP address is found, indicating a secondary IP
if [[ $num_ips -gt 1 ]]; then
    primary_ip=$(echo "$ip_addresses" | head -n 1)
    echo "secondaryIpAssigned: Yes" >>/tmp/config_details.txt
    secondary_ip=$(echo "$ip_addresses" | tail -n +2)

    echo "primaryIp: $primary_ip" >>/tmp/config_details.txt
    echo "secondaryIp: $secondary_ip" >>/tmp/config_details.txt
else
    echo "primaryIp: $ip_addresses" >>/tmp/config_details.txt
    echo "secondaryIpAssigned: No" >>/tmp/config_details.txt
fi
#echo "IP: $IP"
echo "vmCpu: $CPU_CORES" >>/tmp/config_details.txt
echo "vmMemory: $MEMORY" >>/tmp/config_details.txt
echo "vmSwap: $SWAP" >>/tmp/config_details.txt

# Method 1: Using the `timedatectl` command (works on most modern Linux systems)
if command -v timedatectl 2>&1 > /dev/nul l; then
#    timezone=$(timedatectl | grep "Time zone"| sed 's/^[[:space:]]*//')
timezone=$(timedatectl | grep "Time zone" | sed 's/^[[:space:]]*Time zone:/TimeZone:/')
    echo "$timezone" >>/tmp/config_details.txt
else
# Method 3: Fallback using the date command
        timezone=$(date +'%Z %z')
        echo "timeZone: $timezone" >>/tmp/config_details.txt
    fi

#-------------------------------------------------------------------------------
# VM host information about SAP Hostagent version and Patch level
#-------------------------------------------------------------------------------
# Execute the saphostctrl command to get version information
#output=$(./saphostctrl -function ExecuteOperation -name versioninfo)

# Extract Kernel Release and Patch Number using grep and awk
#kernel_release=$(echo "$output" | grep -i "kernel release" | awk '{print $NF}')
#patch_number=$(echo "$output" | grep -i "patch number" | awk '{print $NF}')

# Display the retrieved version information
echo "sapHostagentVersion: $(/usr/sap/hostctrl/exe/saphostctrl -function ExecuteOperation -name versioninfo |  grep -i "kernel release" | awk '{print $NF}')" >>/tmp/config_details.txt
echo "sapHostagentPatch: $(/usr/sap/hostctrl/exe/saphostctrl -function ExecuteOperation -name versioninfo |  grep -i "patch number" | awk '{print $NF}')" >>/tmp/config_details.txt

#-------------------------------------------------------------------------------
# VM host information about SAP Application such as SID, Stack, Instance Number
#-------------------------------------------------------------------------------

# File containing the information
sapservices_file="/usr/sap/sapservices"

if [[ -f $sapservices_file ]]; then
# Extract all unique SAPSIDs from the sapservices file
grep -o '/usr/sap/[A-Z0-9]\+' "$sapservices_file" | awk -F'/' '{print $4}' | sort -u | while read -r SAPSID; do
    profile_file="/sapmnt/${SAPSID}/profile/DEFAULT.PFL"

    # Check if the profile file exists
    if [[ -f "$profile_file" ]]; then
        SYSTEM_TYPE=$(grep -i '^system/type' "$profile_file" | awk -F'=' '{print $2}' | xargs)

        # Check if SYSTEM_TYPE is empty
        if [[ -z "$SYSTEM_TYPE" ]]; then
            SYSTEM_TYPE="Unknown"
        fi
    else
        SYSTEM_TYPE="Unknown"
    fi

    # Extract all lines associated with the current SAPSID

#    grep -E "pf=/usr/sap/${SAPSID}/(SYS/)?profile/${SAPSID}_" "$sapservices_file" | while read -r instance_line; do
#grep -E "pf=/usr/sap/${SAPSID}/(SYS/)?profile/${SAPSID}_(ASCS|ERS|[A-Z]+)[0-9]+" "$sapservices_file" | while read -r instance_line; do
grep -E "pf=/usr/sap/${SAPSID}/.*/profile/${SAPSID}_[A-Z]+[0-9]+" "$sapservices_file" | uniq | while read -r instance_line; do
        # Extract the part starting from /usr/sap/... until pf=
        profile_path=$(echo "$instance_line" | sed -n 's/.*pf=//p')

        # Extract the instance name using awk and sed
        instance_name=$(echo "$profile_path" | awk -F"${SAPSID}_" '{print $2}' | sed 's/[0-9]*_[^_]*$//')

        # Extract the dynamic instance number from the path
        instance_number=$(echo "$profile_path" | grep -oP "${SAPSID}_${instance_name}\K[0-9]{2}")

        # Extract the correct hostname
        instance_hostname=$(echo "$profile_path" | awk -F'_' '{print $NF}' | sed 's/ -D -u .*//')

        # Define SAP user and lowercase SAPSID
        sapsid=$(echo "$SAPSID" | tr '[:upper:]' '[:lower:]')
        SAP_USER="${sapsid}adm"
   # Retrieve SAP kernel version and patch level for specific instances
if [[ "$instance_name" == "D" || "$instance_name" == "DVEBMGS" ||  "$instance_name" == "ASCS" ||  "$instance_name" == "ERS" ||  "$instance_name" == "SCS" || "$instance_name" == "J" ]]; then
     kernel_version=$(su - $SAP_USER -c "disp+work -version" 2>&1 | grep -oP 'kernel release\s+\K[0-9]+') >>/tmp/config_details.txt
     kernel_patch=$(su - $SAP_USER -c "disp+work -version" 2>&1 | grep -oP 'patch number\s+\K[0-9]+') >>/tmp/config_details.txt
fi
        # Display the extracted details
     if [[ "$SAPSID" == "DAA" ]]; then
        echo "daaSid: $SAPSID" >>/tmp/config_details.txt
        echo "daaInstanceName: $instance_name" >>/tmp/config_details.txt
        echo "daaInstanceNumber: $instance_number" >>/tmp/config_details.txt
        echo "daaInstanceHostname: $instance_hostname" >>/tmp/config_details.txt
        echo "daaUser: daaadm" >>/tmp/config_details.tx
        echo "daaKernelVersion: $(su - $SAP_USER -c "sapcontrol -nr $instance_number -function GetVersionInfo" 2>&1 | grep sapstartsrv | awk -F', ' '{print $2}')" >>/tmp/config_details.txt
        echo "daaKernelPatch: $(su - $SAP_USER -c "sapcontrol -nr $instance_number -function GetVersionInfo" 2>&1 | grep sapstartsrv | awk -F', ' '{print $3}' | cut -d' ' -f2)" >>/tmp/config_details.txt
    fi  #DAA

     if [[ "$instance_name" == "ASCS" ]]; then
        echo "ascsSid: $SAPSID" >>/tmp/config_details.txt
        echo "ascsInstanceName: $instance_name" >>/tmp/config_details.txt
        echo "ascsInstanceNumber: $instance_number" >>/tmp/config_details.txt
        echo "ascsInstanceHostname: $instance_hostname" >>/tmp/config_details.txt
        echo "ascsSapUser: $SAP_USER" >>/tmp/config_details.txt
        echo "ascsSapSystemType: ASCS" >>/tmp/config_details.txt
        echo "ascsKernelVersion: $kernel_version" >>/tmp/config_details.txt
        echo "ascsKernelPatch: $kernel_patch" >>/tmp/config_details.txt
            ha_config=$(su - $SAP_USER -c "sapcontrol -nr $instance_number -function HAGetFailoverConfig" 2>&1)
            ha_enabled=$(echo "$ha_config" | grep HAActive: | cut -f2 -d:) 
	    if [[ $ha_enabled == "TRUE" ]]; then
        echo "ascsHaEnabled: $(echo "$ha_config" | grep HAActive: | cut -f2 -d:)" >>/tmp/config_details.txt
        echo "ascsHaActiveNodes: $(echo "$ha_config" | grep HAActiveNode: | cut -f2 -d:)" >>/tmp/config_details.txt
        echo "ascsHaNodes: $(echo "$ha_config" | grep  HANodes| cut -f2 -d:)" >>/tmp/config_details.txt
	    fi
       fi  #ASCS

     if [[ "$instance_name" == "ERS" ]]; then
        echo "ersSid: $SAPSID" >>/tmp/config_details.txt
        echo "ersInstanceName: $instance_name" >>/tmp/config_details.txt
        echo "ersInstanceNumber: $instance_number" >>/tmp/config_details.txt
        echo "ersInstanceHostname: $instance_hostname" >>/tmp/config_details.txt
        echo "ersSapUser: $SAP_USER" >>/tmp/config_details.txt
        echo "ersSapSystemType: ERS" >>/tmp/config_details.txt
        echo "ersKernelVersion: $kernel_version" >>/tmp/config_details.txt
        echo "ersKernelPatch: $kernel_patch" >>/tmp/config_details.txt
            ha_config=$(su - $SAP_USER -c "sapcontrol -nr $instance_number -function HAGetFailoverConfig" 2>&1)
            ha_enabled=$(echo "$ha_config" | grep HAActive: | cut -f2 -d:) 
	    if [[ $ha_enabled == "TRUE" ]]; then
    
        echo "ersHaEnabled: $(echo "$ha_config" | grep HAActive: | cut -f2 -d:)" >>/tmp/config_details.txt
        echo "ersHaActiveNodes: $(echo "$ha_config" | grep HAActiveNode: | cut -f2 -d:)" >>/tmp/config_details.txt
        echo "ersHaNodes: $(echo "$ha_config" | grep  HANodes| cut -f2 -d:)" >>/tmp/config_details.txt
	   fi   
      fi  #ERS

     if [[ "$instance_name" == "SCS" ]]; then
        echo "scsSid: $SAPSID" >>/tmp/config_details.txt
        echo "scsInstanceName: $instance_name" >>/tmp/config_details.txt
        echo "scsInstanceNumber: $instance_number" >>/tmp/config_details.txt
        echo "scsInstanceHostname: $instance_hostname" >>/tmp/config_details.txt
        echo "scsSapUser: $SAP_USER" >>/tmp/config_details.txt
        echo "scsSapSystemType: SCS" >>/tmp/config_details.txt
        echo "scsKernelVersion: $kernel_version" >>/tmp/config_details.txt
        echo "scsKernelPatch: $kernel_patch" >>/tmp/config_details.txt
            ha_config=$(su - $SAP_USER -c "sapcontrol -nr $instance_number -function HAGetFailoverConfig" 2>&1)
            ha_enabled=$(echo "$ha_config" | grep HAActive: | cut -f2 -d:) 
	    if [[ $ha_enabled == "TRUE" ]]; then
    
        echo "scsHaEnabled: $(echo "$ha_config" | grep HAActive: | cut -f2 -d:)" >>/tmp/config_details.txt
        echo "scsHaActiveNodes: $(echo "$ha_config" | grep HAActiveNode: | cut -f2 -d:)" >>/tmp/config_details.txt
        echo "scsHaNodes: $(echo "$ha_config" | grep  HANodes| cut -f2 -d:)" >>/tmp/config_details.txt
	   fi
       fi  #SCS

     if [[ "$instance_name" == "D" || "$instance_name" == "DVEBMGS" ]]; then
        echo "pasSid: $SAPSID" >>/tmp/config_details.txt
        echo "pasInstanceName: $instance_name" >>/tmp/config_details.txt
        echo "pasInstanceNumber: $instance_number" >>/tmp/config_details.txt
        echo "pasInstanceHostname: $instance_hostname" >>/tmp/config_details.txt
        echo "pasSapUser: $SAP_USER" >>/tmp/config_details.txt
        echo "pasSapSystemType: $SYSTEM_TYPE" >>/tmp/config_details.txt
        echo "pasKernelVersion: $kernel_version" >>/tmp/config_details.txt
        echo "pasKernelPatch: $kernel_patch" >>/tmp/config_details.txt
            # Execute sapcontrol command to get the component list
            output=$(su - "$SAP_USER" -c "sapcontrol -nr $instance_number -function ABAPGetComponentList")
            netweaver_info=$(echo "$output" | grep "SAP_BASIS")
            s4hana_info=$(echo "$output" | grep "S4CORE" | head -n 1)
            appl_info=$(echo "$output" | grep "SAP_APPL")

            if [ -n "$netweaver_info" ]; then
                NWversion=$(echo "$netweaver_info" | awk -F, '{print $2}' | xargs)
                sps_level=$(echo "$netweaver_info" | awk -F, '{print $3}' | xargs)
                echo "pasNetweaverVersion: $NWversion" >>/tmp/config_details.txt
               echo "pasNetweaverSpLevel: $sps_level" >>/tmp/config_details.txt
            fi

            if [ -n "$s4hana_info" ]; then
                s4core_version=$(echo "$s4hana_info" | awk -F, '{print $2}' | xargs)
                sps_level=$(echo "$s4hana_info" | awk -F, '{print $3}' | xargs)
                case "$s4core_version" in
                    102) s4hana_version="pasApplicationVersion: 1709" ;;
                    103) s4hana_version="pasApplicationVersion: 1809" ;;
                    104) s4hana_version="pasApplicationVersion: 1909" ;;
                    105) s4hana_version="pasApplicationVersion: 2020" ;;
                    106) s4hana_version="pasApplicationVersion: 2021" ;;
                    107) s4hana_version="pasApplicationVersion: 2022" ;;
                    108) s4hana_version="pasApplicationVersion: 2023" ;;
                    *)   s4hana_version="pasApplicationVersion: Unknown" ;;
                esac

                echo "sapApplicationComponent: S/4HANA" >>/tmp/config_details.txt
                echo "$s4hana_version" >>/tmp/config_details.txt
                echo "pasApplicationSPSLevel: $sps_level" >>/tmp/config_details.txt
            fi

            if [ -n "$appl_info" ]; then
                applversion=$(echo "$appl_info" | awk -F, '{print $2}' | xargs)
                sps_level=$(echo "$appl_info" | awk -F, '{print $3}' | xargs)
                echo "sapApplicationComponent: ERP" >>/tmp/config_details.txt
                echo "pasApplicationVersion: $applversion" >>/tmp/config_details.txt
                echo "pasApplicationSPSLevel: $sps_level" >>/tmp/config_details.txt
            fi
        SAPGENPSE_PATH="/usr/sap/${SAPSID}/SYS/exe/uc/linuxx86_64/sapgenpse"
          if [[ -x "$SAPGENPSE_PATH"  ]]; then
           echo "pasCryptolibVersion: $(su - ${SAP_USER} -c "sapgenpse support_info" | grep -i "Version:" | awk '{print $2}' 2>&1)" >>/tmp/config_details.txt
          fi
        fi    #D or DVEBMGS

     if [[ "$instance_name" == "J" ]]; then
        echo "pasSid: $SAPSID" >>/tmp/config_details.txt
        echo "pasInstanceName: $instance_name" >>/tmp/config_details.txt
        echo "pasInstanceNumber: $instance_number" >>/tmp/config_details.txt
        echo "pasInstanceHostname: $instance_hostname" >>/tmp/config_details.txt
        echo "pasSapUser: $SAP_USER" >>/tmp/config_details.txt
        echo "pasSapSystemType: $SYSTEM_TYPE" >>/tmp/config_details.txt
        echo "pasKernelVersion: $kernel_version" >>/tmp/config_details.txt
        echo "pasKernelPatch: $kernel_patch" >>/tmp/config_details.txt
	# Retrieve SAP Netweaver version and SP level
	instance=${instance_name}${instance_number}
#	NetweaverVersion=$(cat /usr/sap/${SAPSID}/$instance/work/std_server0.out | grep "AS Java version" | sed -n 's/.*AS Java version \[\([0-9]\+\.[0-9]\+\).*/\1/p')
	NetweaverVersion=$(cat /usr/sap/${SAPSID}/$instance/work/std_server0.out | grep "AS Java version" | sed -n 's/.*AS Java version \[\([0-9]\+\)\.\([0-9]\+\).*/\1\2/p')
	NetweaverSP=$(cat /usr/sap/${SAPSID}/$instance/work/std_server0.out | grep "AS Java version" | sed -n 's/.*SP \([0-9]*\).*/\1/p')
	echo "pasNetweaverVersion: $NetweaverVersion" >>/tmp/config_details.txt
	echo "pasNetweaverSPLevel: $NetweaverSP" >>/tmp/config_details.txt

        SAPGENPSE_PATH="/usr/sap/${SAPSID}/SYS/exe/uc/linuxx86_64/sapgenpse"
          if [[ -x "$SAPGENPSE_PATH"  ]]; then
           echo "pasCryptolibVersion: $(su - ${SAP_USER} -c "sapgenpse support_info" | grep -i "Version:" | awk '{print $2}' 2>&1)" >>/tmp/config_details.txt
          fi
        fi    #J

        # Add handling for Content Server, Web Dispatcher, HANA, SMDA as per your original requirements
        # Follow the same structure as above for consistency
 # Retrieve Content Server version and patch level for 'C' instance
        if [[ "$instance_name" == "C" ]]; then
        echo "cpasSid: $SAPSID" >>/tmp/config_details.txt
        echo "cpasInstanceName: $instance_name" >>/tmp/config_details.txt
        echo "cpasInstanceNumber: $instance_number" >>/tmp/config_details.txt
        echo "cpasInstanceHostname: $instance_hostname" >>/tmp/config_details.txt
        echo "cpasSapUser: $SAP_USER" >>/tmp/config_details.txt
        echo "cpasSapSystemType: Content Server" >>/tmp/config_details.txt
        echo "cpasKernelVersion: $(su - $SAP_USER -c "sapcontrol -nr $instance_number -function GetVersionInfo" 2>&1 | grep sapstartsrv | awk -F', ' '{print $2}')" >>/tmp/config_details.txt
            echo "cpasKernelPatch: $(su - $SAP_USER -c "sapcontrol -nr $instance_number -function GetVersionInfo" 2>&1 | grep sapstartsrv | awk -F', ' '{print $3}' | cut -d' ' -f2)">>/tmp/config_details.txt
         content_server_version=$(grep -i "contentserver release" /sapmnt/${SAPSID}/exe/uc/linuxx86_64/contentservermanifest.mf | awk -F': ' '{print $2}')
         content_server_patch=$(grep -i "contentserver patch number" /sapmnt/${SAPSID}/exe/uc/linuxx86_64/contentservermanifest.mf | awk -F': ' '{print $2}')
        echo "contentServerVersion: $content_server_version" >>/tmp/config_details.txt
        echo "contentServerPatch: $content_server_patch" >>/tmp/config_details.txt
        fi

        # Retrieve Web Dispatcher version and patch level for 'W' instance
        if [[ "$instance_name" == "W" ]]; then
        echo "wpasSid: $SAPSID" >>/tmp/config_details.txt
        echo "wpasInstanceName: $instance_name" >>/tmp/config_details.txt
        echo "wpasInstanceNumber: $instance_number" >>/tmp/config_details.txt
        echo "wpasInstanceHostname: $instance_hostname" >>/tmp/config_details.txt
        echo "wpasSapUser: $SAP_USER" >>/tmp/config_details.txt
        echo "wpasSapSystemType: Webdispatcher" >>/tmp/config_details.txt
        echo "wpasKernelVersion: $(su - $SAP_USER -c "sapcontrol -nr $instance_number -function GetVersionInfo" 2>&1 | grep sapstartsrv | awk -F', ' '{print $2}')" >>/tmp/config_details.txt
            echo "wpasKernelPatch: $(su - $SAP_USER -c "sapcontrol -nr $instance_number -function GetVersionInfo" 2>&1 | grep sapstartsrv | awk -F', ' '{print $3}' | cut -d' ' -f2)">>/tmp/config_details.txt
          webdispatcher_version=$(grep -i "webdispatcher release" /sapmnt/${SAPSID}/exe/uc/linuxx86_64/webdispatchermanifest.mf | awk -F': ' '{print $2}')
          webdispatcher_patch=$(grep -i "webdispatcher patch number" /sapmnt/${SAPSID}/exe/uc/linuxx86_64/webdispatchermanifest.mf | awk -F': ' '{print $2}')
            echo "webDispatcherVersion: $webdispatcher_version" >>/tmp/config_details.txt
            echo "webDispatcherPatch: $webdispatcher_patch" >>/tmp/config_details.txt
        fi

        # Retrieve SAP HANA Database (HDB) version and patch level
        if [[ "$instance_name" == "HDB" ]]; then
        echo "hdbSid: $SAPSID" >>/tmp/config_details.txt
        echo "hdbInstanceName: $instance_name" >>/tmp/config_details.txt
        echo "hdbInstanceNumber: $instance_number" >>/tmp/config_details.txt
        echo "hdbInstanceHostname: $instance_hostname" >>/tmp/config_details.txt
        echo "hdbSapUser: $SAP_USER" >>/tmp/config_details.txt
#        echo "hpasSapSystemType: HDB" >>/tmp/config_details.txt
        echo "hdbKernelVersion: $(su - $SAP_USER -c "sapcontrol -nr $instance_number -function GetVersionInfo" 2>&1 | grep sapstartsrv | awk -F', ' '{print $2}')" >>/tmp/config_details.txt
            echo "hdbKernelPatch: $(su - $SAP_USER -c "sapcontrol -nr $instance_number -function GetVersionInfo" 2>&1 | grep sapstartsrv | awk -F', ' '{print $3}' | cut -d' ' -f2)">>/tmp/config_details.txt
        SAPGENPSE_hdb_PATH="/usr/sap/${SAPSID}/SYS/exe/hdb/sapgenpse"
#         if [[ -x "$SAPGENPSE_hdb_PATH" ]]; then
#          echo "hdbCryprolibVersion: $(su - ${SAP_USER} -c "sapgenpse support_info" | grep -i "Version:" | awk '{print $2}' 2>&1)" >>/tmp/config_details.txt
#         fi
fi


        echo " " >>/tmp/config_details.txt

#==============================================================================================
# Database Details configuration
#======================================================================================

db_output=$(/usr/sap/hostctrl/exe/saphostctrl -function ListDatabaseSystems 2>&1 | grep ${SAPSID} )
if [[ $? -eq 0 && "$db_output" != "No database systems found" ]]; then
    # Extract Database Name, Type, and Release version
    DB_SID=$(echo "$db_output" | grep -oP "Database name: \K(${SAPSID}|${SAPSID}@[^,]+)")
    db_type=$(echo "$db_output" | grep -oP 'Type: \K[^,]+')
    db_vend=$(echo "$db_output" | grep -oP 'Vendor: \K[^,]+')
    db_release=$(echo "$db_output" | grep -oP 'Release:\K[^,]+')
    db_release_hdb=$(echo "$db_output" | grep -oP  'Release:\K[^,]+')
    db_user=$(echo "$db_output" | grep -oP 'Osuser=\K[^;]+')
    db_server=$(echo "$db_output" | grep -oP 'Instance name: .*?Host: \K[^,]+')


# Determine the database vendor based on the database type
    if [[ "$db_type" == "ora" ]]; then
        db_vendor="Oracle"
# Retrieve ORACLE_HOME from /etc/oratab
        oracle_home=$(grep "^${DB_SID}:" /etc/oratab | cut -d':' -f2| head -n 1)
        # Check if db_user is blank
          if [[ -z "$db_user" ]]; then
          db_user=ora${sapsid}
          fi
    db_release=$(echo "$db_output" | grep -oP 'DBRelease=\K[^,]+')
#        db_version=$(su - ${db_user} -c "$oracle_home/bin/sqlplus -V | awk '{print \$3}'| tr -d '[:space:]'")
        opatch_version=$(su ${db_user} -c "$oracle_home/OPatch/opatch version|grep -i 'OPatch Version:'|cut -f2 -d:|xargs")
        ps -ef | grep asm_pmon| grep -v grep  2>&1 > /dev/null
        if [[ $? -eq 0 ]]; then
          storage_type="ASM"
        else
         storage_type="Other"
        fi

    elif [[ "$db_type" == "syb" ]]; then
        db_vendor="Sybase"
        # Check if db_user is blank
          if [[ -z "$db_user" ]]; then
          db_user=syb${sapsid}
          fi

    elif [[ "$db_type" == "sap" ]]; then

        db_vendor="MAXDB (SAPDB)"
        db_release=$(echo "$db_output" | grep -oP 'Release:\K[^,]+')
        db_user=${sapsid}adm
    fi

 if [[ "$db_type" == "db6" ]]; then
   db_user=db2${sapsid}
   db_server=$(echo "$db_output" | grep -oP 'Host:\K[^,]+')
 fi

if [[ "$instance_name" == "HDB" ]]; then
#db_output=$(/usr/sap/hostctrl/exe/saphostctrl -function ListDatabaseSystems | grep ${SAPSID}|grep HDB|head -n 1)
db_output_hdb=$(/usr/sap/hostctrl/exe/saphostctrl -function ListDatabaseSystems )
#db_release=$(echo "$db_output_hdb"  | grep ${SAPSID}|grep HDB|head -n 1| grep -oP 'Release:\K[^,]+' | xargs)
db_release=$(echo "$db_output_hdb"  | grep ${SAPSID}|grep HDB|head -n 1| grep -oP 'Release:\K[^,]+' | sed 's/\(\([0-9]\+\.\)\{3\}[0-9]\+\).*/\1/' | xargs)
DB_SID=$(echo "$db_output_hdb"  | grep ${SAPSID}|grep HDB|head -n 1| awk -F'[@,]' '{print $2}' | xargs)
    db_type=$(echo "$db_output_hdb"  | grep ${SAPSID}|grep HDB|head -n 1| grep -oP 'Type: \K[^,]+')
    db_vend=$(echo "$db_output_hdb"  | grep ${SAPSID}|grep HDB|head -n 1| grep -oP 'Vendor: \K[^,]+')
    db_user=$(echo "$db_output_hdb" | grep ${SAPSID}|grep HDB|grep -oP 'Osuser=\K[^;]+'| head -n 1)
    db_server=$(echo "$db_output_hdb" |grep $instance_name |grep -oP 'Instance name: .*?Host: \K[^,]+'|head -n 1)
    hdb_replication_role=$(echo "$db_output_hdb" |grep "ReplicationRole"|cut -f2 -d=|head -n 1|xargs)
    hdb_replication_id=$(echo "$db_output_hdb" | grep "ReplicationInfo" | grep "site id" | head -n 1 | awk -F'[=;]' '{print $3}')
    hdb_replication_name=$(echo "$db_output_hdb" | grep "ReplicationInfo" | grep "site name" | head -n 1 | awk -F'[=;]' '{print $5}')
    hdb_replication_status=$(echo "$db_output_hdb" |grep "hdbreplication"|grep Status|cut -f3 -d:|head -n 1|xargs)
fi

if [[ "$instance_name" != "ASCS" &&  "$instance_name" != "W" &&  "$instance_name" != "C" &&  "$instance_name" != "SMDA" && "$instance_name" != "ERS" &&  "$instance_name" != "SCS" ]]; then
    if [[ "$db_type" == "ora" ]]; then
    [[ -n "$db_server" ]] && echo "oraDbHost: $db_server" >>/tmp/config_details.txt
    [[ -n "$DB_SID" ]] && echo "oraDbSid: $DB_SID" >>/tmp/config_details.txt
    [[ -n "$db_type" ]] && echo "oraDbType: $db_type" >>/tmp/config_details.txt
    [[ -n "$db_vendor" ]] && echo "oraDbName: $db_vendor" >>/tmp/config_details.txt
    [[ -n "$oracle_home" ]] &&  echo "oraDbHome : $oracle_home" >>/tmp/config_details.txt
    [[ -n "db_release" ]] && echo "oraDbRelease: $db_release" >>/tmp/config_details.txt
    [[ -n "$db_user" ]] && echo "oraDbUser: $db_user" >>/tmp/config_details.txt
    [[ -n "$opatch_version" ]] && echo "oraOpatchVersion: $opatch_version" >>/tmp/config_details.txt
    [[ -n "$storage_type" ]] && echo "oraStorageType: $storage_type" >>/tmp/config_details.txt

   elif [[ "$db_type" == "syb" ]]; then
    [[ -n "$db_server" ]] && echo "sybDbHost: $db_server" >>/tmp/config_details.txt
    [[ -n "$DB_SID" ]] && echo "sybDbSid: $DB_SID" >>/tmp/config_details.txt
    [[ -n "$db_type" ]] && echo "sybDbType: $db_type" >>/tmp/config_details.txt
    [[ -n "$db_vendor" ]] && echo "sybDbName: $db_vendor" >>/tmp/config_details.txt
    [[ -n "db_release" ]] && echo "sybDbRelease: $db_release" >>/tmp/config_details.txt
    [[ -n "$db_user" ]] && echo "sybDbUser: $db_user" >>/tmp/config_details.txt
   
   elif [[ "$db_type" == "db6" ]]; then
    [[ -n "$db_server" ]] && echo "db6DbHost: $db_server" >>/tmp/config_details.txt
    [[ -n "$DB_SID" ]] && echo "db6DbSid: $DB_SID" >>/tmp/config_details.txt
    [[ -n "$db_type" ]] && echo "db6DbType: $db_type" >>/tmp/config_details.txt
    [[ -n "$db_vendor" ]] && echo "db6DbName: $db_vendor" >>/tmp/config_details.txt
    [[ -n "db_release" ]] && echo "db6DbRelease: $db_release" >>/tmp/config_details.txt
    [[ -n "$db_user" ]] && echo "db6DbUser: $db_user" >>/tmp/config_details.txt

    elif  [[ "$db_type" == "sap" ]]; then
    [[ -n "$db_server" ]] && echo "maxDbHost: $db_server" >>/tmp/config_details.txt
    [[ -n "$DB_SID" ]] && echo "maxDbSid: $DB_SID" >>/tmp/config_details.txt
    [[ -n "$db_type" ]] && echo "maxDbType: $db_type" >>/tmp/config_details.txt
    [[ -n "$db_vendor" ]] && echo "maxDbName: $db_vendor" >>/tmp/config_details.txt
    [[ -n "db_release" ]] && echo "maxDbRelease: $db_release" >>/tmp/config_details.txt
    [[ -n "$db_user" ]] && echo "maxDbUser: $db_user" >>/tmp/config_details.txt

    elif  [[ "$db_type" == "hdb" ]]; then
    [[ -n "$db_server" ]] && echo "hdbDbHost: $db_server" >>/tmp/config_details.txt
    [[ -n "$DB_SID" ]] && echo "hdbDbSid: $DB_SID" >>/tmp/config_details.txt
    [[ -n "$db_type" ]] && echo "hdbDbType: $db_type" >>/tmp/config_details.txt
    [[ -n "$db_vendor" ]] && echo "hdbDbName: $db_vendor" >>/tmp/config_details.txt
    [[ -n "db_release" ]] && echo "hdbDbRelease: $db_release" >>/tmp/config_details.txt
    [[ -n "$db_user" ]] && echo "hdbDbUser: $db_user" >>/tmp/config_details.txt
    [[ -n "$hdb_replication_role" ]] && echo "hdbReplicationRole: $hdb_replication_role" >>/tmp/config_details.txt
    [[ -n "$hdb_replication_id" ]] && echo "hdbReplicationSiteId: $hdb_replication_id" >>/tmp/config_details.txt
    [[ -n "$hdb_replication_name" ]] && echo "hdbReplicationSiteName: $hdb_replication_name" >>/tmp/config_details.txt
    [[ -n "$hdb_replication_status" ]] && echo "hdbReplicationStatus: $hdb_replication_status" >>/tmp/config_details.txt
   fi     #db_type 
 fi       # not ASCS instance

fi   # Not in database systems
    done    #Inner loop Instances
done        #Outerloop SAPSID
fi          #sapservices

if [[ ! -f $sapservices_file ]]; then
#==============================================================================================
# Standalone Database Installations Details configuration
#======================================================================================

db_output=$(/usr/sap/hostctrl/exe/saphostctrl -function ListDatabaseSystems  2>&1)

if [[ $? -eq 0 && "$db_output" != "No database systems found" ]]; then
    # Extract Database Name, Type, and Release version
#    DB_SID=$(echo "$db_output" | grep -oP "Database name: \K(${SAPSID}|${SAPSID}@[^,]+)")
     DB_SID=$(echo "$db_output" | awk -F': ' '/Database name:/{print $2}' | awk -F',' '{print $1}')
    db_type=$(echo "$db_output" | grep -oP 'Type: \K[^,]+')
    db_vend=$(echo "$db_output" | grep -oP 'Vendor: \K[^,]+')
    db_release=$(echo "$db_output" | grep -oP 'Release:\K[^,]+')
    db_release_hdb=$(echo "$db_output" | grep -oP  'Release:\K[^,]+')
    db_user=$(echo "$db_output" | grep -oP 'Osuser=\K[^;]+')
    db_server=$(echo "$db_output" | grep -oP 'Instance name: .*?Host: \K[^,]+')

# Determine the database vendor based on the database type
    if [[ "$db_type" == "ora" ]]; then
        db_vendor="Oracle"
# Retrieve ORACLE_HOME from /etc/oratab
        oracle_home=$(grep "^${DB_SID}:" /etc/oratab | cut -d':' -f2| head -n 1)
        # Check if db_user is blank
          if [[ -z "$db_user" ]]; then
          db_user=ora${sapsid}
          fi
    db_release=$(echo "$db_output" | grep -oP 'DBRelease=\K[^,]+')
#        db_version=$(su ${db_user} -c "$oracle_home/bin/sqlplus -V | awk '{print \$3}'| tr -d '[:space:]'")
        opatch_version=$(su ${db_user} -c "$oracle_home/OPatch/opatch version|grep -i 'OPatch Version:'| cut -f2 -d:|xargs")
        ps -ef | grep asm_pmon| grep -v grep  2>&1 > /dev/null
        if [[ $? -eq 0 ]]; then
          storage_type="ASM"
        else
         storage_type="Other"
        fi

    elif [[ "$db_type" == "syb" ]]; then
        db_vendor="Sybase"
        # Check if db_user is blank
          if [[ -z "$db_user" ]]; then
          db_user=syb${sapsid}
          fi

    elif [[ "$db_type" == "sap" ]]; then
        db_vendor="MAXDB (SAPDB)"
 db_release=$(echo "$db_output" | grep -oP 'Release:\K[^,]+')
        db_user=${sapsid}adm
    fi

 if [[ "$db_type" == "db6" ]]; then
   db_user=db2${sapsid}
   db_server=$(echo "$db_output" | grep -oP 'Host:\K[^,]+')
 fi

if [[ "$instance_name" == "HDB" ]]; then
#db_output=$(/usr/sap/hostctrl/exe/saphostctrl -function ListDatabaseSystems | grep ${SAPSID}|grep HDB|head -n 1)
db_output_hdb=$(/usr/sap/hostctrl/exe/saphostctrl -function ListDatabaseSystems )
db_release=$(echo "$db_output_hdb"  | grep ${SAPSID}|grep HDB|head -n 1| grep -oP 'Release:\K[^,]+' | xargs)
DB_SID=$(echo "$db_output_hdb"  | grep ${SAPSID}|grep HDB|head -n 1| awk -F'[@,]' '{print $2}' | xargs)
    db_type=$(echo "$db_output_hdb"  | grep ${SAPSID}|grep HDB|head -n 1| grep -oP 'Type: \K[^,]+')
    db_vend=$(echo "$db_output_hdb"  | grep ${SAPSID}|grep HDB|head -n 1| grep -oP 'Vendor: \K[^,]+')
    db_user=$(echo "$db_output_hdb" | grep ${SAPSID}|grep HDB|grep -oP 'Osuser=\K[^;]+'| head -n 1)
    db_server=$(echo "$db_output_hdb" |grep $instance_name |grep -oP 'Instance name: .*?Host: \K[^,]+'|head -n 1)
    hdb_replication_role=$(echo "$db_output_hdb" |grep "ReplicationRole"|cut -f2 -d=|head -n 1|xargs)
    hdb_replication_id=$(echo "$db_output_hdb" | grep "ReplicationInfo" | grep "site id" | head -n 1 | awk -F'[=;]' '{print $3}')
    hdb_replication_name=$(echo "$db_output_hdb" | grep "ReplicationInfo" | grep "site name" | head -n 1 | awk -F'[=;]' '{print $5}')
    hdb_replication_status=$(echo "$db_output_hdb" |grep "hdbreplication"|grep Status|cut -f3 -d:|head -n 1|xargs)
fi

   if [[ "$instance_name" != "ASCS" &&  "$instance_name" != "W" &&  "$instance_name" != "C" &&  "$instance_name" != "SMDA" ]]; then
    if [[ "$db_type" == "ora" ]]; then
    [[ -n "$db_server" ]] && echo "oraDbHost: $db_server" >>/tmp/config_details.txt
    [[ -n "$DB_SID" ]] && echo "oraDbSid: $DB_SID" >>/tmp/config_details.txt
    [[ -n "$db_type" ]] && echo "oraDbType: $db_type" >>/tmp/config_details.txt
    [[ -n "$db_vendor" ]] && echo "oraDbName: $db_vendor" >>/tmp/config_details.txt
    [[ -n "$oracle_home" ]] &&  echo "oraDbHome: $oracle_home" >>/tmp/config_details.txt
    [[ -n "db_release" ]] && echo "oraDbRelease: $db_release" >>/tmp/config_details.txt
    [[ -n "$db_user" ]] && echo "oraDbUser: $db_user" >>/tmp/config_details.txt
    [[ -n "$opatch_version" ]] && echo "oraOpatchVersion: $opatch_version" >>/tmp/config_details.txt
    [[ -n "$storage_type" ]] && echo "oraStorageType: $storage_type" >>/tmp/config_details.txt

   elif [[ "$db_type" == "syb" ]]; then
    [[ -n "$db_server" ]] && echo "sybDbHost: $db_server" >>/tmp/config_details.txt
    [[ -n "$DB_SID" ]] && echo "sybDbSid: $DB_SID" >>/tmp/config_details.txt
    [[ -n "$db_type" ]] && echo "sybDbType: $db_type" >>/tmp/config_details.txt
    [[ -n "$db_vendor" ]] && echo "sybDbName: $db_vendor" >>/tmp/config_details.txt
    [[ -n "db_release" ]] && echo "sybDbRelease: $db_release" >>/tmp/config_details.txt
    [[ -n "$db_user" ]] && echo "sybDbUser: $db_user" >>/tmp/config_details.txt
   
   elif [[ "$db_type" == "db6" ]]; then
    [[ -n "$db_server" ]] && echo "db6DbHost: $db_server" >>/tmp/config_details.txt
    [[ -n "$DB_SID" ]] && echo "db6DbSid: $DB_SID" >>/tmp/config_details.txt
    [[ -n "$db_type" ]] && echo "db6DbType: $db_type" >>/tmp/config_details.txt
    [[ -n "$db_vendor" ]] && echo "db6DbName: $db_vendor" >>/tmp/config_details.txt
    [[ -n "db_release" ]] && echo "db6DbRelease: $db_release" >>/tmp/config_details.txt
    [[ -n "$db_user" ]] && echo "db6DbUser: $db_user" >>/tmp/config_details.txt

    elif  [[ "$db_type" == "sap" ]]; then
    [[ -n "$db_server" ]] && echo "maxDbHost: $db_server" >>/tmp/config_details.txt
    [[ -n "$DB_SID" ]] && echo "maxDbSid: $DB_SID" >>/tmp/config_details.txt
    [[ -n "$db_type" ]] && echo "maxDbType: $db_type" >>/tmp/config_details.txt
    [[ -n "$db_vendor" ]] && echo "maxDbName: $db_vendor" >>/tmp/config_details.txt
    [[ -n "db_release" ]] && echo "maxDbRelease: $db_release" >>/tmp/config_details.txt
    [[ -n "$db_user" ]] && echo "maxDbUser: $db_user" >>/tmp/config_details.txt

    elif  [[ "$db_type" == "hdb" ]]; then
    [[ -n "$db_server" ]] && echo "hdbDbHost: $db_server" >>/tmp/config_details.txt
    [[ -n "$DB_SID" ]] && echo "hdbDbSid: $DB_SID" >>/tmp/config_details.txt
    [[ -n "$db_type" ]] && echo "hdbDbType: $db_type" >>/tmp/config_details.txt
    [[ -n "$db_vendor" ]] && echo "hdbDbName: $db_vendor" >>/tmp/config_details.txt
    [[ -n "db_release" ]] && echo "hdbDbRelease: $db_release" >>/tmp/config_details.txt
    [[ -n "$db_user" ]] && echo "hdbDbUser: $db_user" >>/tmp/config_details.txt
    [[ -n "$hdb_replication_role" ]] && echo "hdbReplicationRole: $hdb_replication_role" >>/tmp/config_details.txt
    [[ -n "$hdb_replication_id" ]] && echo "hdbReplicationSiteId: $hdb_replication_id" >>/tmp/config_details.txt
    [[ -n "$hdb_replication_name" ]] && echo "hdbReplicationSiteName: $hdb_replication_name" >>/tmp/config_details.txt
    [[ -n "$hdb_replication_status" ]] && echo "HanaReplicationStatus: $hdb_replication_status" >>/tmp/config_details.txt
   fi

   fi
 fi

fi

#----------------------------------------------------------------------
# Cluster information
#----------------------------------------------------------------------

# Check if the host is part of a cluster using Pacemaker (common on RHEL)
if command -v crm &> /dev/null; then
    echo "clusterPackage: crm" >> /tmp/config_details.txt

    # Check for fencing configuration using crm command
    fencing_type=$(crm configure show | grep -i stonith)

    if echo "$fencing_type" | grep -iq "sbd"; then
        echo "clusterFencingType: SBD" >> /tmp/config_details.txt
    elif echo "$fencing_type" | grep -iq "fence_azure_arm"; then
        echo "clusterFencingType: Azure Fencing" >>/tmp/config_details.txt
    else
        echo "clusterFencingType: Not configured" >>/tmp/config_details.txt
    fi

elif systemctl is-active --quiet pacemaker; then
    echo "clusterPackage: Pacemaker" >>/tmp/config_details.txt

    # Check for SBD configuration file
    if [ -f /etc/sysconfig/sbd ]; then
        sbd_device=$(grep "^SBD_DEVICE=" /etc/sysconfig/sbd | cut -d'=' -f2)
        if [[ -n "$sbd_device" ]]; then
            echo "clusterFencingType: SBD" >>/tmp/config_details.txt
            echo "sbdDevice: $sbd_device" >>/tmp/config_details.txt
        fi
    fi

    # Check for Azure Fencing in the Pacemaker configuration file
    if grep -q "fence_azure_arm" /var/lib/pacemaker/cib/cib.xml; then
        echo "clusterFencingType: Azure Fencing" >>/tmp/config_details.txt
    
    fi

else
    echo "clusterFencingType: No" >>/tmp/config_details.txt
fi

#--------------------------------------------------------------------------------
# Converting  text output file into json format
#--------------------------------------------------------------------------------

input_file="/tmp/config_details.txt"
json_output_file="/tmp/config_details_${HOSTNAME}.json"

# Initialize the JSON object
echo "{" > "$json_output_file"

# Parse the file and extract key-value pairs dynamically
while IFS= read -r line; do
    # Match lines with "key: value" format
    if [[ "$line" =~ ^([^:]+):[[:space:]]*(.*)$ ]]; then
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        
        # Format the key for JSON (replace spaces with underscores and convert to lowercase)
#        json_key=$(echo "$key" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
        json_key=$(echo "$key" | tr ' ' '_' )
        
        # Escape quotes in the value
        value=$(echo "$value" | sed 's/"/\\"/g')
        
        # Append the key-value pair to the JSON file
        echo "\"$json_key\": \"$value\"," >> "$json_output_file"
    fi
done < "$input_file"

# Remove the trailing comma from the last line
sed -i '$ s/,$//' "$json_output_file"

# Close the JSON object
echo "}" >> "$json_output_file"

echo "JSON file generated at: $json_output_file"
