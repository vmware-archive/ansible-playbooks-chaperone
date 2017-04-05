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

