#!/usr/bin/env bash

#  COPYRIGHT Ericsson 2019
#  The copyright to the computer program(s) herein is the property of
#  Ericsson Inc. The programs may be used and/or copied only with written
#  permission from Ericsson Inc. or in accordance with the terms and
#  conditions stipulated in the agreement/contract under which the
#  program(s) have been supplied.

# Load all the variables.
source ./image_versions.env
source ./spotfire-svc/config.env
source ./spotfire-wp/config.env

export DB_TAG=netan/database:${DB_VERSION}
export SVC_TAG=netan/server:${SVC_VERSION}
export WP_TAG=netan/web-player:${WP_VERSION}

export DB_HOSTNAME=spotfiredb
export SVC_HOSTNAME=spotfire
export WP_HOSTNAME=spotfirewp

export DB=spotfire_db
export SVC=spotfire_svc
export WP=spotfire_wp

function error {
    code=$?
    exit ${code}
}

trap error ERR

function print {
    echo -e "\e[32m$1"
    echo -en "\e[0m"
}

function step {
    print "====================================================================="
    print "$1\n"
}

function substep {
    print "---------------------------------------------------------------------"
    print "$1\n"
}

# --------------------------------------------------------------------------------
step "STEP 1: Building the Spotfire database image"
# --------------------------------------------------------------------------------
# Removing containers, if they exist.
(docker ps -a | grep ${DB}) && docker rm -f ${DB} > /dev/null
(docker ps -a | grep ${SVC}) && docker rm -f ${SVC} > /dev/null
(docker ps -a | grep ${WP}) && docker rm -f ${WP} > /dev/null

substep "1.1: Building the database image"
cd spotfire-db
docker build -t ${DB_TAG} .

substep "1.2: Starting the database container"
docker run --network=nat --hostname ${DB_HOSTNAME} --name ${DB}  -p 1433:1433 -d ${DB_TAG}

substep "1.3: Populating the database"
until docker exec ${DB} powershell "sqlcmd -Q \"select 1\"" > /dev/null
do print "Waiting db..."; sleep 1s; done
docker exec ${DB} powershell "cd install; .\create_databases.bat"

# --------------------------------------------------------------------------------
step "STEP 2: Building the Spotfire Server image"
# --------------------------------------------------------------------------------

substep "2.1: Downloading the Spotfire install file"
cd ../spotfire-svc
curl ${SVC_INSTALL_URL} -o ./install/setup-win64.exe
curl ${SVC_DXP_INSTALL_URL} -o ./install/Spotfire.Dxp.sdn

substep "2.2: Building the Docker image"
docker build --network=nat -m 3GB -t ${SVC_TAG} \
--build-arg toolpwd=spotfire \
--build-arg adminuser=spotfire \
--build-arg doconfig=true \
--no-cache .

substep "2.3: Running the Spotfire Server image"
docker run --network=nat --name=${SVC} --hostname=${SVC_HOSTNAME} -p 80:80 -m 4GB --cpus=4 -it -d ${SVC_TAG}

# --------------------------------------------------------------------------------
step "STEP 3: Creating the Docker image for the Node Manager"
# --------------------------------------------------------------------------------

substep "3.1: Waiting Spotfire to be ready to use (it may take few minutes)"
until curl --max-time 15 -s http://localhost
do print "Waiting..."; done
print "Spotfire is ready!"

substep "3.2: Downloading the Spotfire Node Manager install file"
cd ../spotfire-wp
curl ${WP_INSTALL_URL} -o ./install/nm-setup.exe

substep "3.3: Building the Spotfire Node Manager image"
docker build --network=nat -m 3GB -t ${WP_TAG} --build-arg tssname=${SVC_HOSTNAME} .

substep "3.4 Running the Spotfire Node Manager container"
docker run --network=nat --name=${WP} --hostname=${WP_HOSTNAME} -m 3GB --cpus=2 -it -d ${WP_TAG}

# --------------------------------------------------------------------------------
step "STEP 4: Saving container state to images.\n"
# --------------------------------------------------------------------------------

substep "4.1: Stopping containers"
docker stop ${DB} ${SVC} ${WP}

substep "4.2: Saving database to image"
docker commit ${DB} ${DB_TAG}

substep "4.3: Saving Spotfire server to image"
docker commit ${SVC} ${SVC_TAG}

substep "4.4: Saving Node Manager to image"
docker commit ${WP} ${WP_TAG}