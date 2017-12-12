# Lab VM for Jenkins Demos

This repository contains everything need to create a standalone
VirtualBox + vagrant VM to play with Jenkins.

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

## Requirements

* This VM needs VirtualBox and Vagrant installed
* Packer is required to build the VM template
* A bash Command Line is expected
* Initialize the submodule project with :

```bash
git submodule update --init --recursive
```

## How to build the VM template ?


```bash
make box
```

## How to try the VM quickly ?

```bash
make lab # Starts a standalone VM instance outside the build pipeline process
```
