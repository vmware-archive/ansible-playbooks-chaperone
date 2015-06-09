SuperVIO Playbooks
==================
This repository provides for playbooks associated with developing and installing SuperVIO.

Getting Started
---------------

## Assumptions:
- You have a reasonably Ubuntu 14.04 LTS or similar VM from which you
can clone new VMs;
- You have Fusion or Workstation (or something reasonably as good);
- Your clonable VM has a "vmware" userid.

## Special Note about Domains:
The default domain name for most things SuperVIO is "vmware.local" for
development VMs or containers. However, at times (arguably often) work
will occur on One Cloud systems, which generally use a domain name of
"corp.local" instead.

Given that note, take care to understand the actual domain name the DNS
server you use uses in the event it is providing names, for example,
as supervio-ui.corp.local.

There are variables in some of the playbooks, and inventory files, that
require care and attention. In particular, the inventory files will need
changes from "vmware.local" to "corp.local" in One Cloud scenarios.

## The General Process
Generally you create two VMs, the first of which is the one from which
you run ansible-playbooks and the second the one on which you install
and view the SuperVIO UI.

On the first VM you will install the Google repo tool (unless it is
already installed), pull this code base and then run the ansible
playbook.

On the second VM, there's little to do other than obtain its IP address
so you can properly setup the Ansible VM to address it easily.

For the remainder of this document references to AVM will mean the
ansible VM and referencs to SVM will mean the SuperVIO UI VM.

## Setting up the Ansible VM (AVM)
Start your AVM and login. You also will need to assure the following are
installed on the AVM:

- Ansible
- Git;
- [Google Repo](https://source.android.com/source/using-repo.html);
- A userid "vmware" to which you are logged in and will run everything.

### Setup /etc/hosts File For Gerrit Access

Add the following to your /etc/hosts file:

- 10.150.111.217 gerrit.cloudbuilders.vmware.local

### Setup your ~/.ssh/config

Your ~/.ssh/config file should have something similar to the following
so you can more easily access Gerrit:

```
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null

Host gerrit.cloudbuilders.vmware.local
    Hostname gerrit.cloudbuilders.vmware.local
    User MYUSERID
    IdentityFile ~/.ssh/cloudbuilders/id_rsa
    Port 29418
```

Change the "MYUSERID" to your own gerrit userid and make sure the
~/.ssh/cloudbuilders/id_rsa contains your private key, the public key of
which you registered with the Gerrit server.

### Pull the SuperVIO Code
Once Gerrit access is working, you can pull the code base:

    mkdir supervio
    cd supervio
    repo init -u http://gerrit.cloudbuilders.vmware.local/supervio -b master -g supervio
    repo sync

### Setup the AVM for future work

    cd ansible/playbooks/ansible
    ansible-playbook --ask-sudo-pass -i inventory ansible.yml

## Setting up the SuperVIO UI VM
To setup the SVM, you really only need to assure the VM has a "vmware"
userid and you'll need the IP address of the SVM that is reachable from
the AVM.

### SVM UserId
Make sure the SVM has a userid "vmware" and that should have (generally)
the same password as the AVM's "vmware" userid.

- The SVM should have a vmware userid that is used for all operations.

This is not truly a strict requirement, as many of the Ansible plays
can del with other names, but it is much easier to start with this.

### Get the IP address of the SVM:

    ip address

### Setup the AVM /etc/hosts with the SVM IP address
Add an line in the AVM /etc/hosts file with the following

SVM_IP_ADDRESS supervio-ui.vmware.local

where SVM_IP_ADDRESS is the actual dotted quad address of the SVM.

## Run the SuperVIO Playbook
To setup the SuperVIO UI on the SVM, run the supervio-ui playbooks
from the AVM. The playbooks install and configure the SVM automatically
with commands similar to the following:

    cd ~/supervio/ansible/playbooks/supervio-ui
    ansible --ask-pass --ask-sudo-pass -i inventory base.yml
    ansible -i inventory ui.yml

NOTE: The commands above will execute the sshkeys role, which creates
and rotates keys across fleets of servers -- any listed in the the
inventory file for supervio. That work overwrites any file at
~/.ssh/id_rsa, thus you should *not* place your private gerrit key
in that file -- see the comments on setting up ~/.ssh/config above.
