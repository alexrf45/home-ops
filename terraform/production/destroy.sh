#!/bin/bash

terraform destroy

rm ~/.kube/new_config

rm ~/.talos/prod_config

mv ~/.kube/config_bk ~/.kube/config
