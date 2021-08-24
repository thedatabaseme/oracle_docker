# dockerfiles

Some Dockerfiles to build your own Oracle Database Images. They support you in Installing the RDBMS, Database and also to Patch the RDBMS by putting the appropriate Patch ZIP in the patch directory during Image Build. See README of the several Dockerfiles under /database/...

At the moment, I've only adapted the 19c Dockerfile for Oracle Linux 8. I'm working on it. Promissed!

Disclaimer: This Repository is forked from https://github.com/oraclebase/dockerfiles
All fame and honor for creating the initial Dockerfiles belongs to him.
This fork is adjusted to my needs and also handles the Patching of the Database Software better (I think) during the build.