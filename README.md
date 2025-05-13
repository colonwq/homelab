Home Lab Network Configuration

Description:
A libvirt hosted k8s/OCP development environment. OCP hosts are vms hosted on interconnected commodity mini-PCs

Equpment
 - Hardware: Varous BosGame mini PCs
 - Memory: 64G SODIMM
 - Storage: 1T NVME or SSD
 - Network: 2.5G Ethernet for lab. Wifi for initial install
 - Switch: 'keepLINK' unmanaged switch from Amazon

IP Ranges:
-192.168.50.0/24 routable attached to br50 (vlan 50)
-192.168.60.0/24 non-routable  attached to br60 (vlan 60)

Interfaces: 
- provisioning - br60
- baremetal - br50

DNS Configuration:
- api.ocp.example.com: 192.168.50.21 
- *.apps.ocp.example.com: 192.168.50.21

## Host Configuration Information

- node-1 (hypervisor)
  - Hosts vms node-1-x
  - 192.168.0.50/24 on wlp3s0
  - 192.168.50.1/24 on br50 on enp2s0
  - 192.168.60.1/24 on br60 on enp2s0

VBMC Configuration commands
  ```
  vbmc add --username admin --password password --port 6231 node-1-1
  vbmc add --username admin --password password --port 6232 node-1-2
  vbmc add --username admin --password password --port 6233 node-1-3
  ```

IPMI Commands
  ```
  ipmitool -I lanplus -U admin -P password -H 192.168.50.1 -p 6231 -R 7 -N 5 -L ADMINISTRATOR power status
  ipmitool -I lanplus -U admin -P password -H 192.168.50.1 -p 6232 -R 7 -N 5 -L ADMINISTRATOR power status
  ipmitool -I lanplus -U admin -P password -H 192.168.50.1 -p 6233 -R 7 -N 5 -L ADMINISTRATOR power status
  ```

- node-2 (hypervisor)
  - Hosts vms node-2-x
  - 192.168.0.177/24 on wlp4s0
  - 192.168.50.2/24 on br50 on enp2s0
  - 192.168.60.2/24 on br60 on enp2s0

VBMC Configuration commands
  ```
  vbmc add --username admin --password password --port 6231 node-1-1
  vbmc add --username admin --password password --port 6232 node-1-2
  vbmc add --username admin --password password --port 6233 node-1-3
  ```

IPMI Commands
  ```
  ipmitool -I lanplus -U admin -P password -H 192.168.50.2 -p 6231 -R 7 -N 5 -L ADMINISTRATOR power status
  ipmitool -I lanplus -U admin -P password -H 192.168.50.2 -p 6232 -R 7 -N 5 -L ADMINISTRATOR power status
  ipmitool -I lanplus -U admin -P password -H 192.168.50.2 -p 6233 -R 7 -N 5 -L ADMINISTRATOR power status
  ```

- node-3 (hypervisor)
  Hosts vms node-3-x, managment, install
  - 192.168.0.103/24 on wlp9s0
  - 192.168.50.3/24 on br0 on eth0
  - 192.168.60.3/24 on br60 on eth0

## Notable VMs
- management (vm)
  Services: named, dhcp
  - 192.168.50.39/24
- install (vm)
  Services: ipi installer, ipmitool
  - 192.168.50.38/24
  - 192.168.60.38/24 on enp7s0 52:54:00:55:F4:A3
- node-1-1 worker01 (vm)
  - 192.168.60.11/24 on enp1s0 
  - 192.168.50.11/24 on enp7s0 52:54:00:7d:29:d8
- node-1-2 worker02 (vm)
  - 192.168.60.12/24 on enp1s0 
  - 192.168.50.12/24 on enp7s0 52:54:00:d3:97:3e
- node-1-3 woker03 (vm)
  - 192.168.60.13/13 on enp1s0 
  - 192.168.50.13/24 on enp7s0 52:54:00:db:19:f0
- node-2-1 master01 (vm)
  - 192.168.60.21/24 on enp1s0 
  - 192.168.50.21/24 on enp7s0 52:54:00:d1:d7:6b
- node-2-2 master02 (vm)
  - 192.168.60.22/24 on enp1s0 
  - 192.168.50.22/24 on enp7s0 52:54:00:f5:97:16
- node-2-3 master03 (vm)
  - 192.168.60.23/24 on enp1s0
  - 192.168.50.23/24 on enp7s0 52:54:00:cc:13:ab
- node-3-1 storage01 (vm) 
  - 192.168.60.31/24 on enp1s0 
  - 192.168.50.31/24 on enp7s0 52:54:00:3b:37:38
- node-3-2 storage02 (vm) 
  - 192.168.60.32/24 on enp1s0 
  - 192.168.50.32/24 on enp7s0 52:54:00:e7:83:a5
- node-3-3 storage03 (vm) 
  - 192.168.60.33/24 on enp1s0 
  - 192.168.50.33/24 on enp7s0 52:54:00:ce:79:5e

