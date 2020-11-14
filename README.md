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
    - baremetal with a nic from the external network, with direct access to internet.
    - provisioning with a nic from the provisioning network, where ipv6 will be hosted

## Launch

Prepare a valid parameter file with the information needed. At least, you need to specify the following elements:

- machine_cidr

Call the resulting file `kcli_parameters.yml` to avoid having to specify it in the creation command.

Then you can launch deployment with:

```
kcli create plan
```

## Parameters

|Parameter                 |Default Value      |
|--------------------------|-------------------|
|image                     |centos8            |
|cluster                   |upi                |
|domain                    |karmalabs.com      |
|masters                   |3                  |
|workers                   |1                  |
|keys                      |[]                 |
|machine_cidr              |2620:52:0:1302::/64|
|image_url                 |None               |
|network                   |default            |
|pool                      |default            |
|numcpus                   |16                 |
|memory                    |32768              |
|disk_size                 |30                 |
|extra_disks               |[]                 |
|rhnregister               |True               |
|rhnwait                   |30                 |
|ipmi_user                 |root               |
|ipmi_password             |calvin             |
|baremetal_net             |baremetal          |
|provisioning_net          |provisioning       |
|pullsecret                |openshift_pull.json|
|notifyscript              |notify.sh          |
|virtual_bootstrap         |True               |
|virtual_bootstrap_numcpus |8                  |
|virtual_bootstrap_memory  |16384              |
|virtual_bootstrap_mac     |aa:bb:bb:bb:aa:01  |
|virtual_masters           |False              |
|virtual_masters_number    |3                  |
|virtual_masters_numcpus   |8                  |
|virtual_masters_memory    |32768              |
|virtual_masters_mac_prefix|aa:aa:aa:aa:aa     |
|virtual_workers           |False              |
|virtual_workers_number    |1                  |
|virtual_workers_numcpus   |8                  |
|virtual_workers_memory    |16384              |
|virtual_workers_mac_prefix|aa:aa:aa:bb:bb     |
|notify                    |True               |
|deploy                    |True               |
|disconnected_user         |dummy              |
|disconnected_password     |dummy              |
|disconnected_origin       |quay.io            |
|disconnected_prefix       |ocp4               |
|nbde                      |False              |
|ntp                       |False              |
|ntp_server                |0.rhel.pool.ntp.org|
|tag                       |4.6.3              |
