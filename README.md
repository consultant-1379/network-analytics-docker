# Running Spotfire on Docker

## Copyright

**IMPORTANT**: This repository uses 3rd party software subject to U.S. and international copyright laws and treaties. 

**You are not authorized to use or distribute this application, this is mainly for the Ericsson NetAn team to perform tests.**

## Introduction 

This document shows how to create images and run Spotfire on Windows Containers.

The Spotfire can run on Linux containers, except one component: the Node Manager (also known as **Web Player**). 
This limitation restricts the use of Linux containers because the Node Manager is responsible for proving the web interface, 
and the web interface is needed for automated tests.

## Setting the local repository

After cloning this repository, please run the following command to set up the git hooks:
```bash
git config core.hooksPath .githooks
```

The `pre-commit` hook is responsible for checking if there are any updates in the Docker images files without the 
corresponding update in the version number (specified in the file `image_versions.env`.

## Creating the Docker images

All the Docker images can be generated from this repository, from the respective directories:

- **spotfire-wp**: contains all the assets for creating the Docker image for Spotfire Node Manager.
- **spotfire-db**: contains all the assets for creating the Docker image for the Spotfire Database.
- **spotfire-svc**: contains all the assets for creating the Docker image  for the Spotfire Server.

In order to create the Docker images for all the components, invoke the following command in **Git bash**:

```bash
./generate-images.sh
```

The images will be created in the local Docker repository. If any error occur, the script will exit with the status code.

## Running the platform

The easiest way to run the platform is to use Docker Compose, it just need to run the `docker-compose` commands from the same 
directory where the `docker-compose.yml` is located. The Docker commands can run on **Git bash** or **PowerShell**.
Review the `docker-compose.yml` to check the image versions.

**Pre-requisite**: all the Docker images should be available locally. 

Running the platform using Docker Compose:
```powershell
docker-compose up -d
```

Stopping the platform:
```powershell
docker-compose down
```

Stopping the platform and remove all the volumes and resources associated:
```powershell
docker-compose down -v
```

## Resources

All the Spotfire components can be downloaded from https://accounts.tibco.com/storefront.

Extra documents:

- https://github.com/TIBCOSoftware/SpotfireDockerScripts
- https://community.tibco.com/wiki/tibco-spotfirer-server-docker-scripts


## Issues for exposing services on all network interfaces on Windows Server 2016

When exposing services on all network interfaces (address `0.0.0.0`) the service will not be available 
at the `localhost`. For this reason the use of `localhost` should be avoided. The services should be accessible via 
IP address of the public interface.