#!/bin/bash
# Script to configure network interface with VLAN and bridge, optionally using DHCP
# Sources configuration from an external file (e.g., config.conf)

# Default configuration file name
DEFAULT_CONFIG_FILE="default.conf"

# Configuration file name (can be overridden by command-line argument)
CONFIG_FILE="$DEFAULT_CONFIG_FILE"

# Check if a configuration file is provided as a command-line argument
if [ $# -gt 0 ]; then
  CONFIG_FILE="$1"
  echo "Using configuration file: $CONFIG_FILE"
else
  echo "Using default configuration file: $CONFIG_FILE"
fi

# Function to check if a command is installed
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Source the configuration file
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
  echo "Configuration loaded from $CONFIG_FILE"
else
  echo "Error: Configuration file $CONFIG_FILE not found.  Using default values."
  # Define default values here, in case config.conf is missing
  INTERFACE="eth0"
  VLAN_ID="50"
  IP_ADDRESS="192.168.50.3"  # Default static IP
  NETMASK="24"
  FIREWALLD_ZONE="trusted"
  BRIDGE_NAME="br50"
  BRIDGE_IP="192.168.50.1"  # Default static IP for bridge
  BRIDGE_NETMASK="24"
  DNS1="192.168.1.1"
  DOMAIN="example.com"
  USE_DHCP=false # Set to true to use DHCP, false for static
fi

# Ensure necessary packages are installed
echo "Ensuring necessary packages are installed..."
if ! command_exists ip
then
  echo "Error: 'ip' command not found. Please install the 'iproute2' package."
  exit 1
fi
if ! command_exists firewall-cmd
then
  echo "Error: 'firewall-cmd' not found. Please install the 'firewalld' package."
  exit 1
fi
if ! command_exists nmcli
then
  echo "Error: 'nmcli' command not found. Please install the 'NetworkManager' package."
  exit 1
fi

# Check if the bridge interface already exists
if interface_exists "$BRIDGE_NAME"
then
    echo "Bridge interface $BRIDGE_NAME already exists.  Exiting."
    exit 0
fi

# Create VLAN interface
echo "Creating VLAN interface ${INTERFACE}.${VLAN_ID}..."
sudo nmcli connection add type vlan con-name ${INTERFACE}.${VLAN_ID} dev ${INTERFACE} id ${VLAN_ID}

# Configure VLAN interface IP address
echo "Configuring VLAN interface IP address..."
if $USE_DHCP
then
  echo "Configuring for DHCP..."
  sudo nmcli connection modify ${INTERFACE}.${VLAN_ID} ipv4.method auto
else
  echo "Configuring for static IP ${IP_ADDRESS}/${NETMASK}..."
  sudo nmcli connection modify ${INTERFACE}.${VLAN_ID} ipv4.addresses "${IP_ADDRESS}/${NETMASK}"
  sudo nmcli connection modify ${INTERFACE}.${VLAN_ID} ipv4.method manual
  sudo nmcli connection modify ${INTERFACE}.${VLAN_ID} ipv4.dns "${DNS1}"
  sudo nmcli connection modify ${INTERFACE}.${VLAN_ID} ipv4.dns-search "${DOMAIN}"
fi

# Bring up VLAN interface
echo "Bringing up VLAN interface ${INTERFACE}.${VLAN_ID}..."
sudo nmcli connection up ${INTERFACE}.${VLAN_ID}

# Create bridge interface
echo "Creating bridge interface ${BRIDGE_NAME}..."
sudo nmcli connection add type bridge con-name ${BRIDGE_NAME} ifname ${BRIDGE_NAME} stp no

# Configure bridge interface IP address
echo "Configuring bridge interface IP address..."
if $USE_DHCP
then
  echo "Configuring for DHCP..."
  sudo nmcli connection modify ${BRIDGE_NAME} ipv4.method auto
else
  echo "Configuring for static IP ${BRIDGE_IP}/${BRIDGE_NETMASK}..."
  sudo nmcli connection modify ${BRIDGE_NAME} ipv4.addresses "${BRIDGE_IP}/${BRIDGE_NETMASK}"
  sudo nmcli connection modify ${BRIDGE_NAME} ipv4.method manual
  sudo nmcli connection modify ${BRIDGE_NAME} ipv4.dns "${DNS1}"
  sudo nmcli connection modify ${BRIDGE_NAME} ipv4.dns-search "${DOMAIN}"
fi

# Bring up bridge interface
echo "Bringing up bridge interface ${BRIDGE_NAME}..."
sudo nmcli connection up ${BRIDGE_NAME}

# Add VLAN interface to bridge
echo "Adding VLAN interface ${INTERFACE}.${VLAN_ID} to bridge ${BRIDGE_NAME}..."
sudo nmcli connection modify ${INTERFACE}.${VLAN_ID} master ${BRIDGE_NAME}

# Bring VLAN interface up again (as part of bridge)
echo "Bringing VLAN interface up again..."
sudo nmcli connection up ${INTERFACE}.${VLAN_ID}

# Add bridge interface to firewalld zone
echo "Adding interface ${BRIDGE_NAME} to firewalld zone ${FIREWALLD_ZONE}..."
sudo firewall-cmd --permanent --zone=${FIREWALLD_ZONE} --add-interface=${BRIDGE_NAME}

# Reload firewalld
echo "Reloading firewalld..."
sudo firewall-cmd --reload

# Verify configuration
echo "Configuration complete. The following configuration is now active:"
echo "VLAN Interface: ${INTERFACE}.${VLAN_ID}"
if $USE_DHCP
then
  echo "VLAN IP Address: DHCP"
else
  echo "VLAN IP Address: ${IP_ADDRESS}/${NETMASK} (Static)"
fi
echo "Bridge Interface: ${BRIDGE_NAME}"
if $USE_DHCP
then
  echo "Bridge IP Address: DHCP"
else
  echo "Bridge IP Address: ${BRIDGE_IP}/${BRIDGE_NETMASK} (Static)"
fi
echo "Firewalld Zone: ${FIREWALLD_ZONE}"
nmcli connection show ${INTERFACE}.${VLAN_ID}
nmcli connection show ${BRIDGE_NAME}
sudo firewall-cmd --zone=${FIREWALLD_ZONE} --list-interfaces

