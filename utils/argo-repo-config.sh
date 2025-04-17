#!/bin/bash

kubectl config set-context --current --namespace=argo-cd

argocd repo add git@github.com:alexrf45/prod-argo.git --ssh-private-key-path ~/.ssh/fr3d --upsert

#argocd repo add git@github.com:alexrf45/dev-argo.git --ssh-private-key-path ~/.ssh/fr3d

kubectl config set-context --current --namespace=default
