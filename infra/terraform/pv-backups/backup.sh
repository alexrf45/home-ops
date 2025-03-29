export AWS_ACCESS_KEY_ID=$(kubectl get secret aws-etcd-secret -n etcd-backup -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(kubectl get secret aws-etcd-secret -n etcd-backup -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --decode)
export AWS_ROLE_ARN=$(kubectl get secret aws-etcd-secret -n etcd-backup -o jsonpath='{.data.AWS_ROLE_ARN}' | base64 --decode)
export AWS_REGION=$(kubectl get configmap etcd-backup-config -n etcd-backup -o jsonpath='{.data.AWS_REGION}')
export S3_BUCKET=$(kubectl get configmap etcd-backup-config -n etcd-backup -o jsonpath='{.data.S3_BUCKET}')
export S3_ENDPOINT=$(kubectl get configmap etcd-backup-config -n etcd-backup -o jsonpath='{.data.S3_ENDPOINT}')
export RETENTION=$(kubectl get configmap etcd-backup-config -n etcd-backup -o jsonpath='{.data.RETENTION}')

# Run etcd snapshot save command
k3s etcd-snapshot save \
  --s3 \
  --s3-access-key "${AWS_ACCESS_KEY_ID}" \
  --s3-secret-key "${AWS_SECRET_ACCESS_KEY}" \
  --s3-bucket "${S3_BUCKET}" \
  --s3-endpoint "${S3_ENDPOINT}" \
  --name "snapshot-$(date +%Y-%m-%d-%H-%M-%S)"
