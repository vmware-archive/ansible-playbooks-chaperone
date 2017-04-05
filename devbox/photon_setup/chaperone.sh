#!/bin/bash
#
#  Copyright 2015 VMware, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

# run ansible playbook
ansible_run() {
	local play="${1}"
	shift
	echo ">>>>>>>>>> ansible ${play} playbook . . ."
	pushd $(dirname $(dirname $(realpath ${0})))
	ansible-playbook -i 'localhost,' --connection=local ${play}.yml "$@"
	popd
}

###
# Main Line Code
unask 022
ansible_run base
ansible_run chaperone
cat <<EOF

==============================================================================
All done! You should logout of Photon OS and log back in as:

  user: vmware
  passwd: VMware1!

to continue developing. See the documentation for setting up the sources.
==============================================================================


EOF
