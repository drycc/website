---
title: Mounting volumes for an Application
linkTitle: Managing App Volumes
description: Drycc supports many types of volumes. A container can use any number of volume types simultaneously.
weight: 8
---

We can use the blow command to create volumes and mount the created volumes.
Drycc create volume support [ReadWriteMany](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes), so before deploying drycc, you need to have a StorageClass ready which can support ReadWriteMany.
Deploying drycc, set controller.appStorageClass to this StorageClass.


Use `drycc volumes` to mount a volume for a deployed application's processes.

    $ drycc help volumes
    Valid commands for volumes:

    add              create a volume for the application
    expand           expand a volume for the application
    list             list volumes in the application
    info             print information about a volume
    remove           delete a volume from the application
    client           the client used to manage volume files
    mount            mount a volume to process of the application
    unmount          unmount a volume from process of the application

    Use 'drycc help [command]' to learn more.

## Create a volume for the application

You can create a csi volume with the `drycc volumes add` command.

    $ drycc volumes add myvolume 200M
    Creating myvolume to scenic-icehouse... done

Or use an existing nfs server

    $ drycc volumes add mynfsvolume 200M -t nfs --nfs-server=nfs.drycc.com --nfs-path=/
    Creating mynfsvolume to scenic-icehouse... done

Or maybe use an existing oss3

    $ drycc volumes add myossvolume 200M -t oss --oss-server=oss.drycc.com --oss-bucket=vbucket --oss-access-key=ak --oss-secret-key=sk
    Creating myossvolume to scenic-icehouse... done

## List volumes in the application

After volume is created, you can list the volumes in this application.

    $ drycc volumes list
    NAME          OWNER    TYPE    PTYPE    PATH     SIZE
    myvolume      admin    csi                       200M
    mynfsvolume   admin    nfs                       200M
    myossvolume   admin    oss                       200M

## Mount a volume

The volume which is named myvolume is created, you can mount the volume with process of the application,
use the command of `drycc volumes mount`. When volume is mounted, a new release will be created and deployed automatically.

    $ drycc volumes mount myvolume web=/data/web
    Mounting volume... done

And use `drycc volumes list` show mount detail.

    $ drycc volumes list
    NAME       OWNER    TYPE    PTYPE    PATH         SIZE
    myvolume   admin    nfs     web      /data/web    200M

If you don't need the volume, use `drycc volumes unmount` to unmount the volume and then use  `drycc volumes remove` to delete the volume from the application.
Before deleting volume, the volume has to be unmounted.

    $ drycc volumes unmount myvolume web
    Unmounting volume... done

    $ drycc volumes remove myvolume
    Deleting myvolume from scenic-icehouse... done

## Use volume client to manage volume files.
Assume the volume which is named myvolume is created and mounted.

Prepare a file named testfile.

    $ echo "testtext" > testfile

Upload.
    $ drycc volumes client cp testfile vol://myvolume/
    [↑] testfile                       100% [==================================================] (5/ 5 B, 355 B/s)

List files in myvolume.

    $ drycc volumes client ls vol://myvolume/
    [2024-07-22T15:32:28+08:00]    5    testfile


Delete testfle in myvolume.

    $ drycc volumes client rm vol://myvolume/testfile