#!/bin/bash

### comment out commands as needed, last command is for general upates of packages. I usually manually run this to play it safe.

ansible-playbook -i ./inventory/initial.ini -e @secrets.yaml --ask-vault-password ./playbooks/packages-ubuntu.yaml -K

#scp sean@10.3.3.3:/home/sean/.ssh/sean ~/.ssh/home

ansible-playbook -i ./inventory/hosts.yaml ssh.yaml -K

#ansible-playbook -i ./inventory/hosts.yaml packages.yaml -K
