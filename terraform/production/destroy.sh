#!/bin/bash

terraform destroy

sudo rm -r ~/projects/home-ops-flux/

rm ~/.kube/config

rm ~/.talos/config
