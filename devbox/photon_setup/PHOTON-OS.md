Chaperone Setup on Photon
=========================
This playbook and script set intends to ease setting up to develop and install
Chaperone on Photon OS.

## Getting Started
To use Photon OS for Chaperone development, we need a few things to start with:

1. Start a Photon OS VM. For example, on VMware Fusion or Workstateion.
1. Login to that VM, as root, and find its IP address for future use: `ip addr`.
1. Make sure git is available: `tdnf install -y git
1. Get the code we'll use to setup Photon: `git clone https://github.com/vmware/chaperone`
1. Change directories so accessing the setup scripts is easier: `cd chaperone/scripts`
1. Setup Photon with all the things we need: `./photon.sh`
1. Setup the VM for develpoment as non-root user vmware: `./chaperone.sh`

## Cleaning up
After setting up, you no longer need the playbook repository cloned above,
so just remove it:
```
    cd ${HOME}
    rm -rf chaperone
```

## Login as user vmware and get the code.

1. Login to the VM as vmware and (by default) password VMware1!
1. Make the chaperone directory: `mkdir chaperone`
1. Change directories to the dev folder: `cd chaperone`
1. Initialize repo: `init -u https://github.com/chaperone -b master -g chaperone`

That's it! Next up is creating the CDS.

# License and Copyright

Copyright 2015 VMware, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
