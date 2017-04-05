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

install_yum() {
	# make sure yum is available and updated
	echo ">>>>>>>>>> installing yum . . ."
	which yum >/dev/null 2>&1
	ret=$?
	if [ $ret -ne 0 ];
	then
		echo "Check on prior install: rc was ${ret}"
		tdnf install yum -y
	fi
	yum update -y
}

install_dev_tools() {
	# make dev tools are installed
	echo ">>>>>>>>>> installing dev tools . . ."
	yum install -y sshpass git curl less tar \
		gcc make binutils gawk autoconf autogen automake \
		glibc-devel gmp gmp-devel linux-api-headers \
		openssl-devel python2-devel libxml2-devel libxslt zlib
}

# Install python-setuptools
install_python_setuptools() {
	echo ">>>>>>>>>> installing python-setuptools . . ."
	which easy_install >/dev/null 2>&1
	ret=$?
	if [ $ret -ne 0 ];
	then
		echo "Check on prior install: rc was ${ret}"
		yum install python-setuptools -y
	fi
}

# install pip
install_pip() {
	echo ">>>>>>>>>> installing pip . . ."
	which pip >/dev/null >/dev/null 2>&1
	ret=$?
	if [ $ret -ne 0 ];
	then
		echo "Check on prior install: rc was ${ret}"
		easy_install pip
	fi
}

# install ansible
install_ansible() {
	echo ">>>>>>>>>> installing ansible . . ."
	which ansible >/dev/null 2>&1
	ret=$?
	if [ $ret -ne 0 ];
	then
		echo "Check on prior install: rc was ${ret}"
		pip install --no-clean ansible
	fi
}

# install repo
install_repo() {
	echo ">>>>>>>>>> installing repo . . ."
	if ! [ -x /usr/local/bin/repo ];
	then
		curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
	fi
	chmod a+rx /usr/local/bin/repo
}

###
# Main Line Code
umask 022
install_yum
install_dev_tools
install_python_setuptools
install_pip
install_ansible
install_repo
