---
title: Controller API v2.3
linkTitle: Controller API v2.3
description: This is the v2.3 REST API for the Controller.
weight: 6
---

## What's New

**New!** `/v2/apps/{name}/logs` endpoint was fixed and no longer returns `b'log data'` and instead returns a normal string `log data`


## Authentication

### Register a New User

Example Request:

```
POST /v2/auth/register/ HTTP/1.1
Host: drycc.example.com
Content-Type: application/json

{
    "username": "test",
    "password": "opensesame",
    "email": "test@example.com"
}
```

Optional Parameters:

```
{
    "first_name": "test",
    "last_name": "testerson"
}
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "id": 1,
    "last_login": "2014-10-19T22:01:00.601Z",
    "is_superuser": true,
    "username": "test",
    "first_name": "test",
    "last_name": "testerson",
    "email": "test@example.com",
    "is_staff": true,
    "is_active": true,
    "date_joined": "2014-10-19T22:01:00.601Z",
    "groups": [],
    "user_permissions": []
}
```

### Log in

Example Request:

```
POST /v2/auth/login/ HTTP/1.1
Host: drycc.example.com
Content-Type: application/json

{"username": "test", "password": "opensesame"}
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{"token": "abc123"}
```

### Cancel Account

Example Request:

```
DELETE /v2/auth/cancel/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 204 NO CONTENT
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
```

### Who Am I

Example Request:

```
GET /v2/auth/whoami/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "id": 1,
    "last_login": "2014-10-19T22:01:00.601Z",
    "is_superuser": true,
    "username": "test",
    "first_name": "test",
    "last_name": "testerson",
    "email": "test@example.com",
    "is_staff": true,
    "is_active": true,
    "date_joined": "2014-10-19T22:01:00.601Z",
    "groups": [],
    "user_permissions": []
}
```

### Regenerate Token

> **note**
>
> This command could require administrative privileges

Example Request:

```
POST /v2/auth/tokens/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Optional Parameters:

```
{
    "username" : "test"
    "all" : "true"
}
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{"token": "abc123"}
```

### Change Password

Example Request:

```
POST /v2/auth/passwd/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123

{
    "password": "foo",
    "new_password": "bar"
}
```

Optional parameters:

```
{"username": "testuser"}
```

> **note**
>
> Using the `username` parameter requires administrative privileges and makes the `password` parameter optional.

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
```

## Applications

### List all Applications

Example Request:

```
GET /v2/apps HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
        {
            "created": "2014-01-01T00:00:00UTC",
            "id": "example-go",
            "owner": "test",
            "structure": {},
            "updated": "2014-01-01T00:00:00UTC",
            "url": "example-go.example.com",
            "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75"
        }
    ]
}
```

### Create an Application

Example Request:

```
POST /v2/apps/ HTTP/1.1
Host: drycc.example.com
Content-Type: application/json
Authorization: token abc123
```

Optional parameters:

```
{"id": "example-go"}
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "created": "2014-01-01T00:00:00UTC",
    "id": "example-go",
    "owner": "test",
    "structure": {},
    "updated": "2014-01-01T00:00:00UTC",
    "url": "example-go.example.com",
    "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75"
}
```

### Destroy an Application

Example Request:

```
DELETE /v2/apps/example-go/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 204 NO CONTENT
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
```

### List Application Details

Example Request:

```
GET /v2/apps/example-go/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "created": "2014-01-01T00:00:00UTC",
    "id": "example-go",
    "owner": "test",
    "structure": {},
    "updated": "2014-01-01T00:00:00UTC",
    "url": "example-go.example.com",
    "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75"
}
```

### Update Application Details

Example Request:

```
POST /v2/apps/example-go/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Optional parameters:

```
{
  "owner": "test"
}
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 1.8.0
Content-Type: application/json
```

### Retrieve Application Logs

Example Request:

```
GET /v2/apps/example-go/logs/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Optional URL Query Parameters:

```
?log_lines=
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: text/plain

"16:51:14 drycc[api]: test created initial release\n"
```

### Run one-off Commands

```
POST /v2/apps/example-go/run/ HTTP/1.1
Host: drycc.example.com
Content-Type: application/json
Authorization: token abc123

{"command": "echo hi"}
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{"exit_code": 0, "output": "hi\n"}
```

## Certificates

### List all Certificates

Example Request:

```
GET /v2/certs HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
  "count": 1,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 22,
      "owner": "test",
      "san": [],
      "domains": [],
      "created": "2016-06-22.32.34:20Z",
      "updated": "2016-06-22.32.34:20Z",
      "name": "foo",
      "common_name": "bar.com",
      "fingerprint": "7A:CA:B8:50:FF:8D:EB:03:3D:AC:AD:13:4F:EE:03:D5:5D:EB:5E:37:51:8C:E0:98:F8:1B:36:2B:20:83:0D:C0",
      "expires": "2017-01-14T23:57:57Z",
      "starts": "2016-01-15T23:57:57Z",
      "issuer": "/C=US/ST=CA/L=San Francisco/O=Drycc/OU=Engineering/CN=bar.com/emailAddress=engineering@drycc.cc",
      "subject": "/C=US/ST=CA/L=San Francisco/O=Drycc/OU=Engineering/CN=bar.com/emailAddress=engineering@drycc.cc"
    }
  ]
}
```

### Get Certificate Details

Example Request:

```
GET /v2/certs/foo HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
  "id": 22,
  "owner": "test",
  "san": [],
  "domains": [],
  "created": "2016-06-22.32.34:20Z",
  "updated": "2016-06-22.32.34:20Z",
  "name": "foo",
  "common_name": "bar.com",
  "fingerprint": "7A:CA:B8:50:FF:8D:EB:03:3D:AC:AD:13:4F:EE:03:D5:5D:EB:5E:37:51:8C:E0:98:F8:1B:36:2B:20:83:0D:C0",
  "expires": "2017-01-14T23:57:57Z",
  "starts": "2016-01-15T23:57:57Z",
  "issuer": "/C=US/ST=CA/L=San Francisco/O=Drycc/OU=Engineering/CN=bar.com/emailAddress=engineering@drycc.cc",
  "subject": "/C=US/ST=CA/L=San Francisco/O=Drycc/OU=Engineering/CN=bar.com/emailAddress=engineering@drycc.cc"
}
```

### Create Certificate

Example Request:

```
POST /v2/certs/ HTTP/1.1
Host: drycc.example.com
Content-Type: application/json
Authorization: token abc123

{
    "name": "foo"
    "certificate": "-----BEGIN CERTIFICATE-----",
    "key": "-----BEGIN RSA PRIVATE KEY-----"
}
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
  "id": 22,
  "owner": "test",
  "san": [],
  "domains": [],
  "created": "2016-06-22.32.34:20Z",
  "updated": "2016-06-22.32.34:20Z",
  "name": "foo",
  "common_name": "bar.com",
  "fingerprint": "7A:CA:B8:50:FF:8D:EB:03:3D:AC:AD:13:4F:EE:03:D5:5D:EB:5E:37:51:8C:E0:98:F8:1B:36:2B:20:83:0D:C0",
  "expires": "2017-01-14T23:57:57Z",
  "starts": "2016-01-15T23:57:57Z",
  "issuer": "/C=US/ST=CA/L=San Francisco/O=Drycc/OU=Engineering/CN=bar.com/emailAddress=engineering@drycc.cc",
  "subject": "/C=US/ST=CA/L=San Francisco/O=Drycc/OU=Engineering/CN=bar.com/emailAddress=engineering@drycc.cc"
}
```

### Destroy a Certificate

Example Request:

```
DELETE /v2/certs/foo HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 204 NO CONTENT
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
```

### Attach a Domain to a Certificate

Example Request:

```
POST /v2/certs/foo/domain/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123

{
    "domain": "test.com"
}
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
```

### Remove a Domain from a Certificate

Example Request:

```
DELETE /v2/certs/foo/domain/test.com/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 204 NO CONTENT
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
```

### Enable or disable TLS

Example Request:

```
POST /v2/apps/example-go/tls/ HTTP/1.1
Host: drycc.example.com
Content-Type: application/json
Authorization: token abc123

{
  "https_enforced": true
}
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "created": "2014-01-01T00:00:00UTC",
    "app": "example-go",
    "owner": "test",
    "https_enforced": true,
    "updated": "2014-01-01T00:00:00UTC",
    "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75"
}
```

### Get TLS status

Example Request:

```
GET /v2/apps/example-go/tls/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "created": "2014-01-01T00:00:00UTC",
    "app": "example-go",
    "owner": "test",
    "https_enforced": false,
    "updated": "2014-01-01T00:00:00UTC",
    "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75"
}
```

## Pods

### List all Pods

Example Request:

```
GET /v2/apps/example-go/pods/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "count": 1,
    "results": [
        {
            "name": "go-v2-web-e7dej",
            "release": "v2",
            "started": "2014-01-01T00:00:00Z",
            "state": "up",
            "type": "web"
        }
    ]
}
```

### List all Pods by Type

Example Request:

```
GET /v2/apps/example-go/pods/web/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "count": 1,
    "results": [
        {
            "name": "go-v2-web-e7dej",
            "release": "v2",
            "started": "2014-01-01T00:00:00Z",
            "state": "up",
            "type": "web"
        }
    ]
}
```

### Restart All Pods

Example Request:

```
POST /v2/apps/example-go/pods/restart/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

[
    {
        "name": "go-v2-web-atots",
        "release": "v2",
        "started": "2016-04-11T21:07:54Z",
        "state": "up",
        "type": "web"
    }
]
```

### Restart Pods by Type

Example Request:

```
POST /v2/apps/example-go/pods/web/restart/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

[
    {
        "name": "go-v2-web-atots",
        "release": "v2",
        "started": "2016-04-11T21:07:54Z",
        "state": "up",
        "type": "web"
    }
]
```

### Restart Pods by Type and Name

Example Request:

```
POST /v2/apps/example-go/pods/go-v2-web-atots/restart/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

[
    {
        "name": "go-v2-web-atots",
        "release": "v2",
        "started": "2016-04-11T21:07:54Z",
        "state": "up",
        "type": "web"
    }
]
```

### Scale Pods

Example Request:

```
POST /v2/apps/example-go/scale/ HTTP/1.1
Host: drycc.example.com
Content-Type: application/json
Authorization: token abc123

{"web": 3}
```

Example Response:

```
HTTP/1.1 204 NO CONTENT
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
```

## Configuration

### List Application Configuration

Example Request:

```
GET /v2/apps/example-go/config/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "owner": "test",
    "app": "example-go",
    "values": {
      "PLATFORM": "drycc"
    },
    "memory": {},
    "cpu": {},
    "tags": {},
    "healthcheck": {},
    "created": "2014-01-01T00:00:00UTC",
    "updated": "2014-01-01T00:00:00UTC",
    "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75"
}
```

### Create new Config

Example Request:

```
POST /v2/apps/example-go/config/ HTTP/1.1
Host: drycc.example.com
Content-Type: application/json
Authorization: token abc123

{"values": {"HELLO": "world", "PLATFORM": "drycc"}}
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "owner": "test",
    "app": "example-go",
    "values": {
        "DRYCC_APP": "example-go",
        "DRYCC_RELEASE": "v3",
        "HELLO": "world",
        "PLATFORM": "drycc"

    },
    "memory": {},
    "cpu": {},
    "tags": {},
    "healthcheck": {},
    "created": "2014-01-01T00:00:00UTC",
    "updated": "2014-01-01T00:00:00UTC",
    "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75"
}
```

### Unset Config Variable

Example Request:

```
POST /v2/apps/example-go/config/ HTTP/1.1
Host: drycc.example.com
Content-Type: application/json
Authorization: token abc123

{"values": {"HELLO": null}}
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "owner": "test",
    "app": "example-go",
    "values": {
        "DRYCC_APP": "example-go",
        "DRYCC_RELEASE": "v4",
        "PLATFORM": "drycc"
   },
    "memory": {},
    "cpu": {},
    "tags": {},
    "healthcheck": {},
    "created": "2014-01-01T00:00:00UTC",
    "updated": "2014-01-01T00:00:00UTC",
    "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75"
}
```

## Domains

### List Application Domains

Example Request:

```
GET /v2/apps/example-go/domains/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
        {
            "app": "example-go",
            "created": "2014-01-01T00:00:00UTC",
            "domain": "example.example.com",
            "owner": "test",
            "updated": "2014-01-01T00:00:00UTC"
        }
    ]
}
```

### Add Domain

Example Request:

```
POST /v2/apps/example-go/domains/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123

{'domain': 'example.example.com'}
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "app": "example-go",
    "created": "2014-01-01T00:00:00UTC",
    "domain": "example.example.com",
    "owner": "test",
    "updated": "2014-01-01T00:00:00UTC"
}
```

### Remove Domain

Example Request:

```
DELETE /v2/apps/example-go/domains/example.example.com HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 204 NO CONTENT
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
```

## Builds

### List Application Builds

Example Request:

```
GET /v2/apps/example-go/build/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "app": "example-go",
    "created": "2014-01-01T00:00:00UTC",
    "dockerfile": "FROM drycc/slugrunner RUN mkdir -p /app WORKDIR /app ENTRYPOINT [\"/runner/init\"] ADD slug.tgz /app ENV GIT_SHA 060da68f654e75fac06dbedd1995d5f8ad9084db",
    "image": "example-go",
    "owner": "test",
    "procfile": {
        "web": "example-go"
    },
    "sha": "060da68f",
    "updated": "2014-01-01T00:00:00UTC",
    "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75"
}
```

### Create Application Build

Example Request:

```
POST /v2/apps/example-go/build/ HTTP/1.1
Host: drycc.example.com
Content-Type: application/json
Authorization: token abc123

{"image": "drycc/example-go:latest"}
```

Optional Parameters:

```
{
    "procfile": {
      "web": "./cmd"
    }
}
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "app": "example-go",
    "created": "2014-01-01T00:00:00UTC",
    "dockerfile": "",
    "image": "drycc/example-go:latest",
    "owner": "test",
    "procfile": {},
    "sha": "",
    "updated": "2014-01-01T00:00:00UTC",
    "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75"
}
```

## Releases

### List Application Releases

Example Request:

```
GET /v2/apps/example-go/releases/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "count": 3,
    "next": null,
    "previous": null,
    "results": [
        {
            "app": "example-go",
            "build": "2.3d8e4b-600e-4425-a85c-ffc7ea607f61",
            "config": "ed637ceb-5d32-44bd-9406-d326a777a513",
            "created": "2014-01-01T00:00:00UTC",
            "owner": "test",
            "summary": "test changed nothing",
            "updated": "2014-01-01T00:00:00UTC",
            "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75",
            "version": 3
        },
        {
            "app": "example-go",
            "build": "2.3d8e4b-600e-4425-a85c-ffc7ea607f61",
            "config": "95bd6dea-1685-4f78-a03d-fd7270b058d1",
            "created": "2014-01-01T00:00:00UTC",
            "owner": "test",
            "summary": "test deployed 060da68",
            "updated": "2014-01-01T00:00:00UTC",
            "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75",
            "version": 2
        },
        {
            "app": "example-go",
            "build": null,
            "config": "95bd6dea-1685-4f78-a03d-fd7270b058d1",
            "created": "2014-01-01T00:00:00UTC",
            "owner": "test",
            "summary": "test created initial release",
            "updated": "2014-01-01T00:00:00UTC",
            "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75",
            "version": 1
        }
    ]
}
```

### List Release Details

Example Request:

```
GET /v2/apps/example-go/releases/v2/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "app": "example-go",
    "build": null,
    "config": "95bd6dea-1685-4f78-a03d-fd7270b058d1",
    "created": "2014-01-01T00:00:00UTC",
    "owner": "test",
    "summary": "test created initial release",
    "updated": "2014-01-01T00:00:00UTC",
    "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75",
    "version": 1
}
```

### Rollback Release

Example Request:

```
POST /v2/apps/example-go/releases/rollback/ HTTP/1.1
Host: drycc.example.com
Content-Type: application/json
Authorization: token abc123

{"version": 1}
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{"version": 5}
```

## Keys

### List Keys

Example Request:

```
GET /v2/keys/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
        {
            "created": "2014-01-01T00:00:00UTC",
            "id": "test@example.com",
            "owner": "test",
            "public": "ssh-rsa <...>",
            "updated": "2014-01-01T00:00:00UTC",
            "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75"
        }
    ]
}
```

### Add Key to User

Example Request:

```
POST /v2/keys/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123

{
    "id": "example",
    "public": "ssh-rsa <...>"
}
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "created": "2014-01-01T00:00:00UTC",
    "id": "example",
    "owner": "example",
    "public": "ssh-rsa <...>",
    "updated": "2014-01-01T00:00:00UTC",
    "uuid": "de1bf5b5-4a72-4f94-a10c-d2a3741cdf75"
}
```

### Remove Key from User

Example Request:

```
DELETE /v2/keys/example HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 204 NO CONTENT
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
```

## Permissions

### List Application Permissions

> **note**
>
> This does not include the app owner.

Example Request:

```
GET /v2/apps/example-go/perms/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "users": [
        "test",
        "foo"
    ]
}
```

### Create Application Permission

Example Request:

```
POST /v2/apps/example-go/perms/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123

{"username": "example"}
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
```

### Remove Application Permission

Example Request:

```
DELETE /v2/apps/example-go/perms/example HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 204 NO CONTENT
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
```

### List Administrators

Example Request:

```
GET /v2/admin/perms/ HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "count": 2,
    "next": null
    "previous": null,
    "results": [
        {
            "username": "test",
            "is_superuser": true
        },
        {
            "username": "foo",
            "is_superuser": true
        }
    ]
}
```

### Grant User Administrative Privileges

> **note**
>
> This command requires administrative privileges

Example Request:

```
POST /v2/admin/perms HTTP/1.1
Host: drycc.example.com
Authorization: token abc123

{"username": "example"}
```

Example Response:

```
HTTP/1.1 201 CREATED
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
```

### Remove User's Administrative Privileges

> **note**
>
> This command requires administrative privileges

Example Request:

```
DELETE /v2/admin/perms/example HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 204 NO CONTENT
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
```

## Users

### List all users

> **note**
>
> This command requires administrative privileges

Example Request:

```
GET /v2/users HTTP/1.1
Host: drycc.example.com
Authorization: token abc123
```

Example Response:

```
HTTP/1.1 200 OK
DRYCC_API_VERSION: 2.3
DRYCC_PLATFORM_VERSION: 2.3.0
Content-Type: application/json

{
    "count": 1,
    "next": null,
    "previous": null,
    "results": [
        {
            "id": 1,
            "last_login": "2014-10-19T22:01:00.601Z",
            "is_superuser": true,
            "username": "test",
            "first_name": "test",
            "last_name": "testerson",
            "email": "test@example.com",
            "is_staff": true,
            "is_active": true,
            "date_joined": "2014-10-19T22:01:00.601Z",
            "groups": [],
            "user_permissions": []
        }
    ]
}
```
