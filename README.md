# Chaperone Playbooks

This repository provides playbooks associated with the
[Chaperone](https://github.com/vmware/chaperone) project
for configuring and installing various Software Defined Data Center ("SDDC")
scenarios.

One should note that the playbooks herein show general examples, though are
used for their purposes. But where new scenarios, for example a specific
model of automating a particular setup of certificates, or other use cases
for automation, you will need to make new directories for your playbooks.
In such cases, it is perfectly viable to create your own independently
managed "playbooks" project and use a [Local Manifest](https://gerrit.googlesource.com/git-repo/+/master/docs/manifest-format.txt#335)
to remove this playbook repo and replace it with yours. For example:

NOTE: A non-defaulted variable, download_site, must be set in the vars/assets.yml
file or by other mechanism prior to calling this playbook. The download_site must
provide a valid URL base (e.g., http://mysite.com/downloads) supportable by the
Ansible url module. The roles download files (e.g., ISO files or similar) therefrom.
See the vars/assets.yml for the files of interest. In general, you should
set the assets.yml file to point to all of the files you want to use for
the deployment, which may be different versions than are shown in this example
setup.

NOTE 2: By default, this playbook example sets the variable: download_files to
false to prevent attempts to download invalid or unavailable URLs. The variable
is set in vars/assets.yml, which upon fixing up the download_site and making
available the files of interest at that site you should reset the download_files
variable to true.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remove-project name=ansible-playbooks-chaperone />
  <project path="ansible/playbooks" name="my_github_id/ansible-playbooks-chaperone" remote="github"/>
</manifest>
```

See the docs directory in the
[Chaperone](https://github.com/vmware/chaperone) project for detailed
startup instructions for developers and users. Also, for a more automated
developer setup on Photon OS or a Mac, see the documentation in
[devbox](devbox).

# Playbook Descriptions

### ansible
Intended for installing ansible on a host the correct way, with needed extra modules

### chaperone-ui
Intended to setup the Deployment server.  It does the following:
* install the webserver needed to
  * host the Chaperone UI,
  * host deployment assets (isos, ovas, ovfs needed to perform installation of various)
* clone local chaperone ansible resources (playbooks, roles, modules, etc.) to the Deployment Server for use via the UI
* install any extra tools needed on the Deployment Server

### chaperone
This set of playbooks is intended to be run from the Deployment Server to do the actual
work of deploying various SDDC artifacts.

It is called by the UI after the UI has been used to specify the environment configuration.
The UI generates the *answersfile.yml* that is referenced in all these playbooks.


### chaperone-appc-devbox
**Depricated**
This is intended to run against a photon machine to install
docker and containerized versions of the CDS and DE.

### gerrit
**Depricated**
For use in setting up a shared gerrit server for use in
development environment.


### jenkins
Sets up a jenkins server and haproxy to expose it.

### labrouter

For setting up dnsmasq and iptables in a lab setup.

### photon

**Depricated**
For setting up a basic photon vm.


# Known Issues:
* Getting an error like `/bin/sh: 1: /usr/bin/python: not found`

Try running the following on the remote host: `apt-get -y install python-simplejson` and re-try the playbook.

See for more info: http://stackoverflow.com/questions/32429259/ansible-fails-with-bin-sh-1-usr-bin-python-not-found

# License and Copyright

Copyright 2015-2017 VMware, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

