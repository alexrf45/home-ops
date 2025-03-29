#!/bin/bash

terraform destroy

#sudo rm -r ~/projects/home-ops-flux/

rm ~/.kube/stag-config

rm ~/.talos/stag-config
