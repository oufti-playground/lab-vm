# Lab VM for Jenkins Demos

This repository contains everything need to create a standalone
VirtualBox + vagrant VM to play with Jenkins.

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)


## Quick Start (Using Docker)

Docker and Docker-Compose are required.
If you do not want to (or cannot) use Docker,
you can build the virtual machine and run it with Vagrant
(heavier but more portable), as described in tghe next section.

With Docker and Docker-Compose installed,
use the commands below to start the workshop's lab locally.

You can set the variable `EXTERNAL_PORT` to change the external port
to reach the services.

```bash
cd ./docker
docker-compose up -d --build --force-recreate
```

and open the URL http://localhost:80 with your web browser
(or replace "80" by the value provided to the variable `EXTERNAL_PORT`
if you did so).

You might want to wait a while before having Jenkins ready.

## Alternative Start (Using VirtualBox's VM)

This alternative required VirtualBox, Packer GNU Make and Vagrant to be installed.

Start by building the VM template for Vagrant (withg VirtualBox as backend):

```bash
make box
```

Then, start the workshop's lab with this command:

```bash
make lab
```

You might want to use another port than the default "80":
use the `EXTERNAL_PORT` environment variable:

```bash
export EXTERNAL_PORT=10000
make lab
```
