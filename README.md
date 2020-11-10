## Purpose

This repository provides a plan which deploys a vm where:
- openshift-install and oc are downloaded
- dnsmasq and radvd are set to provide ipv6 services in a dedicated network.
- openshift-install is leveraged to generate ignition file for all the nodes.
- rhcos live iso is used along with coreos-installer to generate an auto installer for each node
- an optional bootstrap vm is precreated to be used along with the live iso

## Why

Because it was time to do some upi messing around

## Requirements

### for kcli

- kcli installed (for rhel8/cento8/fedora, look [here](https://kcli.readthedocs.io/en/latest/#package-install-method))
- an openshift pull secret (stored by default in openshift_pull.json)

### on the provisioning node

- libvirt daemon
- two physical bridges:
    - baremetal with a nic from the external network
    - provisioning with a nic from the provisioning network

Here's a script you can run on the provisioning node for that (adjust the nics variable as per your environment)

```
export MAIN_CONN=eno2
sudo nmcli connection add ifname baremetal type bridge con-name baremetal
sudo nmcli con add type bridge-slave ifname "$MAIN_CONN" master baremetal
sudo nmcli con down "System $MAIN_CONN"; sudo pkill dhclient; sudo dhclient baremetal
export PROV_CONN=eno1
sudo nmcli connection add ifname provisioning type bridge con-name provisioning
sudo nmcli con add type bridge-slave ifname "$PROV_CONN" master provisioning
sudo nmcli connection modify provisioning ipv4.addresses 172.22.0.1/24 ipv4.method manual
sudo nmcli con down provisioning
sudo nmcli con up provisioning
```

If using vlans on the provisioning interface, the following can be used:

```
VLANID=1200
BRIDGE=prov$VLAN
IP="172.22.0.100/24"
nmcli connection add ifname $BRIDGE type bridge con-name $BRIDGE
nmcli connection add type vlan con-name vlan$VLAN ifname eno1.$VLAN dev eno1 id $VLAN master $BRIDGE slave-type bridge
nmcli connection modify $BRIDGE ipv4.addresses $IP ipv4.method manual
nmcli con down $BRIDGE
nmcli con up $BRIDGE
```

## Launch

Prepare a valid parameter file with the information needed. At least, you need to specify the following elements:

- api_ip
- ingress_ip

You can have a look at:

- [parameters.yml.sample](parameters.yml.sample) for a parameter file targetting baremetal nodes only

Call the resulting file `kcli_parameters.yml` to avoid having to specify it in the creation command.

Then you can launch deployment with:

```
kcli create plan
```

## Parameters

|Parameter                |Default Value                                |
|-------------------------|---------------------------------------------|
|image                    |centos8                                      |
|installer_mac            |None                                         |
|openshift_image          |registry.svc.ci.openshift.org/ocp/release:4.6|
|cluster                  |upi                                          |
|domain                   |karmalabs.com                                |
|masters                  |3                                            |
|workers                  |0                                            |
|keys                     |[]                                           |
|api_ip                   |None                                         |
|ingress_ip               |None                                         |
|image_url                |None                                         |
|network                  |default                                      |
|pool                     |default                                      |
|numcpus                  |16                                           |
|memory                   |32768                                        |
|disk_size                |30                                           |
|extra_disks              |[]                                           |
|rhnregister              |True                                         |
|rhnwait                  |30                                           |
|ipmi_user                |root                                         |
|ipmi_password            |calvin                                       |
|baremetal_net            |default                                      |
|provisioning_net         |fakeipv6                                     |
|pullsecret               |openshift_pull.json                          |
|notifyscript             |notify.sh                                    |
|virtual_bootstrap        |True                                         |
|virtual_bootstrap_numcpus|8                                            |
|virtual_bootstrap_memory |16384                                        |
|virtual_bootstrap_mac    |aa:aa:aa:bb:bb:cc                            |
|notify                   |True                                         |
|deploy                   |True                                         |
|disconnected_user        |dummy                                        |
|disconnected_password    |dummy                                        |
|disconnected_origin      |quay.io                                      |
|disconnected_prefix      |ocp4                                         |
|nbde                     |False                                        |
|ntp                      |False                                        |
|ntp_server               |0.rhel.pool.ntp.org                          |
|tag                      |4.6.1                                        |
|machine_cidr             |2001:db8:dead:beef:fe::/96                   |
