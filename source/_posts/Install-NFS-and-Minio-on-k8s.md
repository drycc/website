---
title: Install NFS and Minio on k8s
date: 2019-04-16 10:44:40
tags: minio
categories: 
keywords: nfs,minio
description: Install NFS and Minio on k8s
photos: [
  ["/images/sample/mydesk.png"]
] 
---

Install NFS and Minio on k8s for drycc.
<!--more-->

---

# Install nfs-client-provisioner

```
helm install --name k8s-nfs \
  --set nfs.server=192.168.6.100 \
  --set nfs.path=/nas/k8s-nfs/baike \
  stable/nfs-client-provisioner
```

# Installing Minio in nasgateway mode

```
helm install --name minio \
  --set persistence.storageClass=nfs-client \
  --set persistence.size=100G \
  --set service.type=NodePort \
  --set service.nodePort=31053 \
  --set nasgateway.enabled=true \
  --set nasgateway.replicas=3 \
  stable/minio
```