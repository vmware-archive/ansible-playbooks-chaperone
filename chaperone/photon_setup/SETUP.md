Chaperone Setup on Photon
=========================
This playbook and script set intends to ease setting up to develop and install
Chaperone on Photon OS.

## Getting Started
Start a Photon VM. For example, on AppCatalyst:

    appcatalyst vm create chaperone

SSH to that VM:

    appcatalyst guest getip chaperone
      (assume that returned 172.16.61.128)
    ssh -i /opt/vmware/appcatalyst/etc/appcatalyst_insecure_ssh_key.pub photon@172.16.61.128

Make sure git is available

    sudo tdnf install git

Get the code we'll use to setup Photon:

    git clone http://10.150.111.238:8080/ansible-playbooks-supervio

Change directories so accessing the setup scripts is easier:

    cd ansible-playbooks-supevio/chaperone/photon_setup

Fix the 'vars' file with the appropriate values for the gerrit and docker registry:

    vi vars
      (edit the values appropriately and save the file)

Setup Photon with all the things we need:

    sudo ./photon.sh

Setup the Chaperone Docker environment (do NOT use sudo for this one):

    ./chaperone.sh

Follow the instructions that script displays at the end.

## Cleaning up
After setting up, you no longer need the playbook repository cloned above,
so just remove it:

    cd ${HOME}
    rm -rf ansible-playbooks-supervio

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
