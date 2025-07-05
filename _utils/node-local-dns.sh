curl -sL https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/dns/nodelocaldns/nodelocaldns.yaml \
  | sed -e 's/__PILLAR__DNS__DOMAIN__/cluster.local/g' \
  | sed -e "s/__PILLAR__DNS__SERVER__/$(kubectl get service --namespace kube-system kube-dns -o jsonpath='{.spec.clusterIP}')/g" \
  | sed -e 's/__PILLAR__LOCAL__DNS__/169.254.20.10/g' \
  | kubectl apply -f -