set up config file in /etc/rancher/k3s/config.yaml.d/etcd-backup.yaml

then restart k3s
```
etcd-s3: true
etcd-s3-access-key: <my-access-key>
etcd-s3-secret-key: <my-secret-key>
etcd-s3-bucket: <my-etcd-backup-bucket>
etcd-snapshot-schedule-cron: "0 /6 * * *"
```

then set up cron job

```
0 4 * * * k3s etcd-snapshot save
```


