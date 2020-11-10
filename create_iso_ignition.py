#!/usr/bin/env python3

import base64
import os

if not os.path.exists('iso.ign.template'):
    print("Missing iso.ign.template")
    os._exit(1)
else:
    iso_template = "iso.ign.template"

ssh_key_file = os.path.expanduser('~/.ssh/id_rsa.pub')
if not os.path.exists(ssh_key_file):
    print("Missing ssh public key")
    os._exit(1)
else:
    ssh_key = open(ssh_key_file).read().strip()

if not os.path.exists('config.ign'):
    print("Missing config.ign")
    os._exit(1)
else:
    content = open('config.ign').read()
    ignition_file = base64.b64encode(content.encode()).decode("UTF-8")

if not os.path.exists('iso.sh'):
    print("Missing iso.sh")
    os._exit(1)
else:
    content = open('iso.sh').read()
    iso_script = base64.b64encode(content.encode()).decode("UTF-8")


with open('iso.ign', 'w') as iso:
    for line in open(iso_template, 'r').readlines():
        if 'SSH_KEY' in line:
            iso.write(line.replace('SSH_KEY', ssh_key))
        elif 'IGNITION_FILE' in line:
            iso.write(line.replace('IGNITION_FILE', ignition_file))
        elif 'ISO_SCRIPT' in line:
            iso.write(line.replace('ISO_SCRIPT', iso_script))
        else:
            iso.write(line)
