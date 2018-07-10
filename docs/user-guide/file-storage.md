---
layout: documentation
title: File Storage
---

# Overview

Cerberus encrypts and stores secure files as binary blobs in its database.

Users can create, read, update, and delete using one of the Cerberus clients, the Dashboard UI, or the REST API.


# Dashboard UI

<img src="../../images/dashboard/add-new-file-screen.png" alt="Cerberus Dashboard add file screenshot" />


# Clients

### Java

```java
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.Path;

Path path = Paths.get("path/to/file");
byte[] contents = Files.readAllBytes(path);
cerberusClient.writeFile("app/my-app/certificate.cer", contents);
```

### Python

```python
## put_file('SDB Path', 'file name', file handle to file you want to upload)
client.put_file('category/sdb/path/to/certificate.cer', 'certificate.cer', open('file.example', 'rb'))
```
Note: For the file you open, please make sure it's opened in binary mode, otherwise the size calculations for how big it is can be off.

### Golang

```golang
import (
	"os"

	"github.com/Nike-Inc/cerberus-go-client/cerberus"
	"github.com/Nike-Inc/cerberus-go-client/api"
	"github.com/Nike-Inc/cerberus-go-client/auth"
)

client, err := cerberus.NewClient(authMethod, nil)
contents, err := os.Open("certificate.cer")
client.SecureFile().Put("app/my-app/certificate.cer", "certificate.cer", contents)
```


# REST API

POST /v1/secure-file/app/my-app/certificate.cer

+ Request (application/json)

    + Headers

            X-Cerberus-Token: AaAAAaaaAAAabCdEF0JkLMNZ01iGabcdefGHIJKLtClQabcCVabEYab1aDaZZz12a
            X-Cerberus-Client: MyClientName/1.0.0
            Content-Type: multipart/form-data; boundary=----------4123509835381001

    + Body
            
            ------------4123509835381001
            Content-Disposition: form-data; name="file-content"; filename="certificate.cer"
            Content-Type: application/octet-stream
 
 
            PEM87a.............,...........D..;
            ------------4123509835381001

+ Response 204


+ Response 401 (application/json)

    + Body

            {
              "error_id": "9c4dc9de-2ce2-4b55-9bda-dbd8e2397879",
              "errors": [
                {
                  "code": 99105,
                  "message": "X-Cerberus-Token header is malformed or invalid."
                }
              ]
            }

+ Response 404 (application/json)

    + Body

            {
              "error_id": "6b13cdaa-ce64-473d-9228-5cf9bf0e51a9",
              "errors": [
                {
                  "code": 99996,
                  "message": "Not found"
                }
              ]
            }

