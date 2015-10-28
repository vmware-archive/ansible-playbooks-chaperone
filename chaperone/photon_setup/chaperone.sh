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

if [ -f ./vars ]
then
	source ./vars
else
	echo "ERROR: vars file is not in the current directory. Aborting!"
	exit 1
fi

# run ansible playbook
ansible_run() {
	local play="${1}"
	shift
	echo ">>>>>>>>>> ansible ${1} playbook . . ."
	pushd $(dirname $(dirname $(realpath ${0})))
	ansible-playbook -i examples/inventory ${1}.yml "$@"
	popd
}

# start the containers
check_docker() {
	docker ps -a >/dev/null 2>&1
	if [ $? -ne 0 ]
	then
		cat <<-EOF

			Docker was restarted with new rights for your user.
			Please logout and log back in as the same user and rerun this script:
			  exit
			  [re-SSH into this VM]
			  cd $(pwd)
			  $(realpath ${0})

		EOF
		exit 1
	fi
}

# start the containers
instructions() {
	ipaddr=$(ip a show eth0 | awk -F '[ /^]' '/^ *inet[^6]/ {print $6}')
	cat <<-EOF
		===============================================================================

		You can SSH to your dev container at IP address ${ipaddr} port 2222 with user vmware, password vmware.
		You can SSH to your ui container at IP address ${ipaddr} port 2223 with user vmware, password vmware.

		For example, to ssh to your dev container:
		    ssh -p 2222 vmware@${ipaddr}

		After that, initialize git and get the sources, as in:

			git config --global user.name "Your Full Name Here"
			git config --global user.email "your_email_name@your_company.com"
			cd chaperone
			repo init -u http://gerrit.cloudbuilders.vmware.local:8080/supervio -b master -g supervio
			repo sync

		Don't worry about all the 404 warnings from the sync -- they don't matter.

		===============================================================================
	EOF
}

###
# Main Line Code
ansible_run base
ansible_run chaperone --ask-sudo-pass
check_docker
ansible_run containers
instructions
