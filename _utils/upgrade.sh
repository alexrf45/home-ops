#!/bin/bash

kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/download/v0.13.4/crd.yaml

kubectl apply -f system-upgrade-controller.yaml

sleep 3

kubectl apply -f upgrade.yaml
