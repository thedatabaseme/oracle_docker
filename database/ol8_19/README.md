# Oracle Database on Docker

The following article provides a description of this Dockerfile.

Directory contents when software is included.

```
$ tree
.
├── Dockerfile
├── README.md
├── patch
|   |── p31771877_190000_Linux-x86-64.zip
│   ├── put_patches_here.txt
|   └── p6880880_122010_Linux-x86-64.zip
├── scripts
│   ├── healthcheck.sh
│   └── start.sh
|── software
│   ├── apex_21.1_en.zip
│   ├── LINUX.X64_193000_db_home.zip
│   └── put_software_here.txt
└── templates
    └── 19EE_Database.rsp


$
```

Requirements:
  - Docker needs to be installed
  - Oracle Database Software and Patches as ZIP Archives

Image Build:
Before you start to build the Docker Image, you need to place the Oracle Database Software and
Patches you want to install during Image creation in the software and patch directories.
Don't forget to include the needed OPatch Archive for the Release Update you want to install in
the patch Directory.

To build an Image, you can make two approaches. One just installing the Oracle 19.3 Base Release and
one with a Release Update included.

To install only the Base Release (19.3) you can issue the following commands:
  cd <path_to_dockerfile>
  docker build -t ol8_oradb:19.3 .

To install also a Release Update, you need to specify the ARGs INSTALL_PATCH and PATCH_ID. The
PATCH_ID is the ID for the Release Update you want to install (also included in the Filename). In
this example, we install the Release Update 19.9 on top of the 19.3 Base Release
  
  cd <path_to_dockerfile>
  docker build -t ol8_oradb:19.9 --build-arg INSTALL_PATCH=true --build-arg PATCH_ID=31771877 .

Attention!: When you run the Image on an existing Database, the Database will not be updated to the
installed Release Update. You have to do this manually. Only the RDBMS itself is patched here!

To install the Patch on the Database, you need to connect to the Container and run datapatch from there:

  docker exec -it ol8_19_con /bin/bash
  cd /oracle/product/19_ENT/OPatch
  ./datapatch

Run the Docker Container:
To run a Container based on the created Image above, you can issue the following docker run command. In this example, you will start a Container based on an persistent Volume located under /docker/oracle/ORATST on your Docker Host. 

  docker run -dit --name ol8_19_con -p 1521:1521 -p 5500:5500 -v /docker/oracle/ORATST/:/db_data -e "ORACLE_SID=ORATST" -e "SYS_PASSWORD=Initial!" --restart unless-stopped ol8_oradb:19.3

When starting the first time, this will be recognized and a new Database will be created. Be aware, that the Sizing and Parameters are quite static at the moment. For Example, you cannot specify the 
SGA size or the Character Set at the moment. You have to change the Parameters after the first 
startup. All Parameters, Controlfiles etc. are stored under the persistent Volume and will be
accessible for later starts.

Troubleshooting:
You can have a look into the Log of the Container by using the docker logs command:
  
  docker logs --follow ol8_19_con

To connect to the Docker Container you can use docker exec:

  docker exec -it ol8_19_con /bin/bash

Disclaimer:
The fact that you can run Oracle Database within a Docker container does not mean, that you have
also support from Oracle for this configuration. At the time writing these lines, there is no 
official support for Oracle 18 and above running in a containerized environment. Don't blame me.