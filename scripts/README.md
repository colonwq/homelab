# Network Configuration Script 

## Development notes:

All scripting was 'developed' using the Gemini AI. 

The initial propt was: 

```
Create a linux shell script which will configure network interface eth0 to use VLAN 50 and bind the ip address 192.168.50.3 with a 24 bit subnet mask
```

Additional updates were generated with ```Update prevous answer to add ...```

Additions include

- Using nmcli vs ip commands
- Adding interface to the trusted firewall zone
- Creating and setting the bridge name
- Optionally use DHCP addressing (untested)
- Sourcing configuration parameters from a defined configuration file
- Reading configuration parameters from a command line file
- Using default values if none are passed in
- Test for the bridge interface beforer attemtping to perform configuration
- Update to use 2 spaces for indention
- Using sudo to call the last firewall-cmd command
- Create an undo script
- Create an ansible playbook and example inventory (untested)

## Usage examples

1. Use default values in script

```
./configure_interface.sh
```

2. Use default values in default.conf

```
cat default.conf
./configure_interface.sh
```

3. Use default values in passed configuration file

```
./configure_interface.sh config-node1-50.conf
```
