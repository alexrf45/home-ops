#!/bin/bash

### comment out commands as needed, last command is for general upates of packages. I usually manually run this to play it safe.

ansible-playbook -i ./inventory/hosts.yaml -e @secrets.yaml --ask-vault-password ./playbooks/packages-ubuntu.yaml -K

ansible-playbook -i ./inventory/hosts.yaml ./playbooks/ssh.yaml -K

#ansible-playbook -i ./inventory/hosts.yaml packages.yaml -K
