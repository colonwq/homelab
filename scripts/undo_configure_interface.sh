#!/bin/bash
# Script to undo the network configuration performed by the configure_network.sh script
# Sources configuration from an external file (e.g., config.conf)
# Allows specifying the config file on the command line

# Configuration file
CONFIG_FILE="config.conf"  # Default value

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
  BRIDGE_NAME="br50"
  FIREWALLD_ZONE="trusted"
fi

# Ensure necessary packages are installed
echo "Ensuring necessary packages are installed..."
if ! command_exists ip
then
  echo "Error: 'ip' command not found.  Please install the 'iproute2' package."
  exit 1
fi
if ! command_exists firewall-cmd
then
  echo "Error: 'firewall-cmd' command not found.  Please install the 'firewalld' package."
  exit 1
fi
if ! command_exists nmcli
then
  echo "Error: 'nmcli' command not found.  Please install the 'NetworkManager' package."
  exit 1
fi

# Remove VLAN interface from bridge
echo "Removing VLAN interface ${INTERFACE}.${VLAN_ID} from bridge ${BRIDGE_NAME}..."
sudo nmcli connection modify ${INTERFACE}.${VLAN_ID} master ""

#Bring down vlan
echo "Bringing down VLAN interface ${INTERFACE}.${VLAN_ID}..."
sudo nmcli connection down ${INTERFACE}.${VLAN_ID}

# Delete VLAN interface
echo "Deleting VLAN interface ${INTERFACE}.${VLAN_ID}..."
sudo nmcli connection delete ${INTERFACE}.${VLAN_ID}

# Bring down bridge interface
echo "Bringing down bridge interface ${BRIDGE_NAME}..."
sudo nmcli connection down ${BRIDGE_NAME}

# Delete bridge interface
echo "Deleting bridge interface ${BRIDGE_NAME}..."
sudo nmcli connection delete ${BRIDGE_NAME}

# Remove bridge interface from firewalld zone
echo "Removing interface ${BRIDGE_NAME} from firewalld zone ${FIREWALLD_ZONE}..."
sudo firewall-cmd --permanent --zone=${FIREWALLD_ZONE} --remove-interface=${BRIDGE_NAME}

# Reload firewalld to apply the changes
echo "Reloading firewalld..."
sudo firewall-cmd --reload

echo "Network configuration changes have been undone."

