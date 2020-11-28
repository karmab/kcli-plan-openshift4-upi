## Purpose

This repository provides a plan which deploys an installer vm where:
- openshift-install and oc are downloaded
- dnsmasq, haproxy and radvd are set to provide services in a dedicated network, either on ipv4 or ipv6
- disconnected registry and olm operators are synced
- openshift-install is leveraged to generate ignition file for all the nodes.
- rhcos live iso is used along with coreos-installer to generate an auto installer for each node
- an optional bootstrap vm is precreated to be used along with the live iso
- if specified, virtual masters and workers are created and started
- if specified, baremetal masters and workers are rebooted in the iso via racadm

## Why

This provides an easy way to deploy Openshift using UPI

Custom isos are used to drive the installation.

## Requirements

### for kcli

- kcli installed (for rhel8/cento8/fedora, look [here](https://kcli.readthedocs.io/en/latest/#package-install-method))
- an openshift pull secret (stored by default in openshift_pull.json), containing secret for registry.redhat.io and for ci if needed

### on the provisioning node

- libvirt daemon
- two physical bridges:
    - baremetal with a nic from the external network, with direct access to internet.
    - provisioning with a nic from the provisioning network, where ipv6 will be hosted

### on dns

in order to be able to access the env other ipv4, two baremetal vips can be provided for api and ingress

Currently, the api-int dns record needs to be resolvable (over ipv4)

## Launch

Prepare a valid parameter file with the information needed (start with the sample)

Call the resulting file `kcli_parameters.yml` to avoid having to specify it in the creation command.

Then you can launch deployment with:

```
kcli create plan
```

## Parameters

|Parameter                  |Default Value                                                                                     |
|---------------------------|--------------------------------------------------------------------------------------------------|
|image                      |centos8                                                                                           |
|cluster                    |upi                                                                                               |
|domain                     |karmalabs.com                                                                                     |
|openshift_image            |None                                                                                              |
|network_type               |OVNKubernetes                                                                                     |
|masters                    |3                                                                                                 |
|workers                    |0                                                                                                 |
|keys                       |[]                                                                                                |
|machine_cidr               |2620:52:0:1302::/64                                                                               |
|static_ips                 |True                                                                                              |
|image_url                  |None                                                                                              |
|network                    |default                                                                                           |
|pool                       |default                                                                                           |
|numcpus                    |16                                                                                                |
|memory                     |32768                                                                                             |
|disk_size                  |80                                                                                                |
|extra_disks                |[]                                                                                                |
|rhnregister                |True                                                                                              |
|networkwait                |30                                                                                                |
|fake_network               |False                                                                                             |
|disable_nics               |[]                                                                                                |
|baremetal_net              |baremetal                                                                                         |
|ipmi_user                  |root                                                                                              |
|ipmi_password              |calvin                                                                                            |
|baremetal_vips             |[]                                                                                                |
|baremetal_masters          |[]                                                                                                |
|baremetal_workers          |[]                                                                                                |
|provisioning_net           |provisioning                                                                                      |
|pullsecret                 |openshift_pull.json                                                                               |
|notifyscript               |notify.sh                                                                                         |
|dnsmasq                    |True                                                                                              |
|haproxy                    |True                                                                                              |
|virtual_bootstrap          |True                                                                                              |
|virtual_bootstrap_numcpus  |8                                                                                                 |
|virtual_bootstrap_memory   |16384                                                                                             |
|virtual_bootstrap_mac      |aa:bb:bb:bb:aa:01                                                                                 |
|virtual_masters            |False                                                                                             |
|virtual_masters_number     |3                                                                                                 |
|virtual_masters_numcpus    |8                                                                                                 |
|virtual_masters_memory     |32768                                                                                             |
|virtual_masters_mac_prefix |aa:aa:aa:aa:aa                                                                                    |
|virtual_workers            |False                                                                                             |
|virtual_workers_number     |1                                                                                                 |
|virtual_workers_numcpus    |8                                                                                                 |
|virtual_workers_memory     |16384                                                                                             |
|virtual_workers_mac_prefix |aa:aa:aa:bb:bb                                                                                    |
|notify                     |True                                                                                              |
|deploy                     |False                                                                                             |
|disconnected               |True                                                                                              |
|disconnected_registry_image|quay.io/saledort/registry:2                                                                       |
|disconnected_user          |dummy                                                                                             |
|disconnected_password      |dummy                                                                                             |
|disconnected_origin        |quay.io                                                                                           |
|disconnected_prefix        |ocp4                                                                                              |
|disconnected_url           |None                                                                                              |
|ca                         |None                                                                                              |
|nbde                       |False                                                                                             |
|ntp                        |False                                                                                             |
|olm                        |True                                                                                              |
|ntp_server                 |0.rhel.pool.ntp.org                                                                               |
|tag                        |4.6.4                                                                                             |
|build                      |False                                                                                             |
|small_iso                  |False                                                                                             |
|olm_operators              |['local-storage-operator', 'performance-addon-operator', 'ptp-operator', 'sriov-network-operator']|
|extra_images               |[]                                                                                                |
