---
title: Resource Limits
linkTitle: Resource Limits
description: Drycc Workflow supports restricting memory and CPU shares of each process.
weight: 12
---

## 

## Managing Application Resource Limits

Drycc Workflow supports restricting memory and CPU shares of each process. Requests/Limits set on a per-process type are given to
Kubernetes as a requests and limits. Which means you guarantee <requests\> amount of resource for a process as well as limit
the process from using more than <limits\>.
By default, Kubernetes will set <requests\> equal to <limit\> if we don't explicitly set <requests\> value. Please keep in mind that `0 <= requests <= limits`.

## Limiting

If you set a requests/limits that is out of range for your cluster, Kubernetes will be unable to schedule your application
processes into the cluster!

```
$ drycc limits plans

ID                    SPEC    CPU              VCPUS    MEMORY     FEATURES                      
std1.large.c1m1       std1    Universal CPU    1        1 GiB      Integrated GPU shared    
std1.large.c1m2       std1    Universal CPU    1        2 GiB      Integrated GPU shared    
std1.large.c1m4       std1    Universal CPU    1        4 GiB      Integrated GPU shared    
std1.large.c1m8       std1    Universal CPU    1        8 GiB      Integrated GPU shared    
std1.large.c2m2       std1    Universal CPU    2        2 GiB      Integrated GPU shared    
std1.large.c2m4       std1    Universal CPU    2        4 GiB      Integrated GPU shared    
std1.large.c2m8       std1    Universal CPU    2        8 GiB      Integrated GPU shared    
std1.large.c2m16      std1    Universal CPU    2        16 GiB     Integrated GPU shared    

$ drycc limits set web=std1.large.c1m1
Applying limits... done
```

