---
title: Managing resources for an Application
linkTitle: Managing App Resources
description: Tools and services for developing, extending, and operating your app.
weight: 10
---


We can use blow command to create resources and bind which resource is created.
This command depend on [service-catalog](https://service-catalog.drycc.cc).


Use `drycc resources` to create and bind a resource for a deployed application.

    $ drycc help resources
    Manage resources for your applications

    Usage:
    drycc resources [flags]
    drycc resources [command]

    Available Commands:
    services    List all available resource services
    plans       List all available plans for a resource service
    create      Create a resource for the application
    list        List resources in the application
    describe    Get a resource's detail in the application
    update      Update a resource from the application
    bind        Bind a resource for an application
    unbind      unbind a resources for an application
    destroy     Delete a resource from the application

    Flags:
    -a, --app string   The uniquely identifiable name for the application
    -l, --limit int    The maximum number of results to display

    Global Flags:
    -c, --config string   Path to configuration file. (default "~/.drycc/client.json")
    -h, --help            Display help information
    -v, --version         Display client version

    Use "drycc resources [command] --help" for more information about a command.


## List all available resource services

You can list available resource services with one `drycc resources services` command

    $ drycc resources services
    ID                                      NAME                  UPDATEABLE 
    15032a52-33c2-4b40-97aa-ceb972f51509    airflow               true          
    b7cb26a4-b258-445c-860b-a664239a67f8    cloudbeaver           true          
    9ce3c3ba-33b5-4e4e-a5e9-a338a83d5070    flink                 true          
    b80c51a1-957c-4d93-b3d5-efde84cd8031    fluentbit             true          
    fff5b6c7-ed85-429b-8265-493e40cc53c7    grafana               true          
    412e368f-bf78-4798-92cc-43343119a57d    kafka                 true          
    ea2a9b87-fbc4-4e2a-adee-161c1f91d98d    minio                 true          
    383f7316-84f3-4955-8491-1d4b02b749c8    mongodb               true          
    fbee746b-f3a7-4bef-8b55-cbecfd4c8ac3    mysql-cluster         true          
    5975094d-45cc-4e85-8573-f93937d026c7    opensearch            true          
    1db95161-7193-4544-8c76-e5ad5f6c03f6    pmm                   true          
    5cfb0abf-276c-445b-9060-9aa964ede87d    postgresql-cluster    true          
    b8f70264-eafc-4b2f-848e-2ec0d059032b    prometheus            true    
    e1fd0d37-9046-4152-a29b-d155c5657c8b    redis                 true          
    7d2b64c6-0b59-4f08-a2f5-7b17cea6e5ee    redis-cluster         true          
    2e6877df-86e7-4bcc-a869-2a9b6847a465    seaweedfs             true          
    4aea5c0f-9495-420d-896a-ffc61a3eced5    spark                 true          
    b50db3b5-8d5f-4be9-b8bd-467ecd6cc11d    zookeeper             true

## List all available plans for an resource services

You can list all available plans for an resource services with one `drycc resources plans` command

    $ drycc resources plans redis
    ID                                      NAME              DESCRIPTION                                                       
    8d659058-a3b4-4058-b039-cc03a31b9442    standard-128      Redis standard-128 plan which limit resources memory size 128Mi.     
    36e3dbec-fc51-4f6b-9baa-e31e316858be    standard-256      Redis standard-256 plan which limit resources memory size 256Mi.     
    560817c2-5aa1-41c4-9ee6-a77e3ee552d5    standard-512      Redis standard-512 plan which limit resources memory size 512Mi.     
    d544d989-9fb8-43e9-a74e-0840ce1b8f0f    standard-1024     Redis standard-1024 plan which limit resources memory size 1Gi.      
    ad51b7bb-9b12-4ffd-8e49-010c0141b263    standard-2048     Redis standard-2048 plan which limit resources memory size 2Gi.      
    5097d76e-557c-453f-bdb1-54009e0df78d    standard-4096     Redis standard-4096 plan which limit resources memory size 4Gi.      
    be3fa2d0-36d2-47c5-9561-9deffe5ba373    standard-8192     Redis standard-8192 plan which limit resources memory size 8Gi.      
    4ca812a8-d7c3-439f-96cd-26523e88400e    standard-16384    Redis standard-16384 plan which limit resources memory size 16Gi.    
    b7f2a71f-0d97-48fd-8eed-aab24a7822f3    standard-32768    Redis standard-32768 plan which limit resources memory size 32Gi.    
    25c6b5d5-7505-47c8-95b1-dc9bdc698063    standard-65536    Redis standard-65536 plan which limit resources memory size 64Gi.

## Create resource in application

You can create a resource with one `drycc resources create` command

    $ drycc resources create redis redis standard-128
    Creating redis to scenic-icehouse... done

After resources are created, you can list the resources in this application.

    $ drycc resources list
    UUID                                    NAME     OWNER    PLAN                  UPDATED              
    07220e9e-d54d-4d74-a88c-f464aa374386    redis    admin    redis:standard-128    2024-05-08T01:01:00Z   

## Bind resources

The resource which is named redis is created, you can bind the redis to the application,
use the command of `drycc resources bind redis`.

    $ drycc resources bind redis
    Binding resource... done

## Describe resources

And use `drycc resources describe` show the binding detail. If the binding is successful, this command will show the information of connect to the resource.

    $ drycc resources describe redis
    === scenic-icehouse resource redis
    plan:               redis:1000
    status:             Ready
    binding:            Ready

    REDISPORT:          6379
    REDIS_PASSWORD:     RzG87SJWG1
    SENTINELHOST:       172.16.0.2
    SENTINELPORT:       26379

## Update resources

You can use the `drycc resources update` command to upgrade a new plan.
An example of how to upgrade the plan's capacity to 128MB:

    $ drycc resources update redis redis standard-128
    Updating redis to scenic-icehouse... done

## Remove the resource

If you don't need resources, use `drycc resources unbind` to unbind the resource and then use `drycc resources destroy` to delete the resource from the application.
Before deleting the resource, the resource must be unbinded.

    $ drycc resources unbind redis
    Unbinding resource... done

    $ drycc resources destroy redis
    Deleting redis from scenic-icehouse... done
