#!/usr/bin/env bash
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
# Mac-bootsrapper: Configures a Mac for Chaperone development

LOGFILE=_macbootstrapper.log
echo "Welcome to Mac-Boostrapper!"
echo "This session, and additional information is logged to: $LOGFILE"

# Write everything to the screen, and also to a log file.
echo -e "\n\nBegan new run of Mac Chaperone Bootstrapper at $(date +%s)" >> $LOGFILE
exec > >(tee -a $LOGFILE)

# IP Address to test VPN connectivity, presently gerrit:
VPN_IP=10.150.38.241

echo -n "Confirming VPN connectivity... "
if ping -c2 -t2 $VPN_IP > /dev/null; then
  echo "[ OK ]"
else
  echo "[ Error ]"
  echo "Please connect to the VPN and try again."
  exit 1
fi

echo ""

# =============================================================================
# Phase One: Install requisite development components
# =============================================================================

# I consider Homebrew, git, wget, and homebrew-based Python (which gives pip),
# and Ansible to be essential tools for the Mac. Strictly speaking, we don't
# need them as they're wrapped in the dev-photon-vm, but for future bootstrap-
# ping, let's leave it here.

COUNT=0

# Recurse this to achieve a somewhat idempotent execution:
check_system() {

  STATE=OK

  # In case we loop too many times, keep this equal to # of ifs:
  let COUNT+=1
  if [ $COUNT -gt 6 ]; then
    echo "We seem to be stuck in a loop, please have a look and correct."
    exit 1
  fi

  if [ $COUNT -eq 1 ]; then
    CHECK_VERB="Checking"
  else
    CHECK_VERB="\nRechecking"
  fi

  echo -e "${CHECK_VERB} your system for Chaperone development..."
  echo ""

  # Check for Homebrew
  echo -n "Homebrew:       "
  if command -v brew &> /dev/null; then
    echo "[ OK ]"

    # Check for Python in Homebrew:
    echo -n "Python:         "
    if brew list python &> /dev/null; then
      echo "[ OK ]"

      # Check for Pip in Python in Homebrew:
      echo -n "Pip:            "
      if command -v pip &> /dev/null; then
        echo "[ OK ]"

        # Check for Ansible in Pip in Python in Homebrew:
        echo -n "Ansible:        "
        if pip show ansible &> /dev/null; then
          echo "[ OK ]"

        else
          echo "[ Missing ]"
          echo "Installing Ansible..."
          pip install ansible >> $LOGFILE 2>&1
          echo ""
          STATE=Bad
        fi

      # No Pip:
      else
        echo "[ Error ]"
        echo "Pip was not found in your path. This is sometimes an error caused"
        echo "by Homebrew's permissions. Please reinstall Python manually."
        echo "Check permissions on /usr/local/lib/python2.7/site-packages/*"
      fi

    # No Python:
    else
      echo "[ Missing ]"
      echo "Installing Python..."
      brew install python >> $LOGFILE 2>&1
      echo ""
      STATE=Bad
    fi

  # No Homebrew:
  else
    echo "[ Missing ]"
    echo "Requesting an install of Homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo ""
    STATE=Bad
  fi

  # Check for wget, because curl doesn't like resuming with AppCatalyst:
  echo -n "wget:           "
  if command -v wget > /dev/null; then
    echo "[ OK ]"

  else
    echo "[ Missing ]"
    echo "Installing wget..."
    brew install wget >> $LOGFILE 2>&1
    echo ""
    STATE=Bad
  fi

  # Check for git, because OS X is old:
  echo -n "git:            "
  if git --version | grep -qv Apple > /dev/null; then
    echo "[ OK ]"

  else
    echo "[ Missing ]"
    echo "Installing git..."
    brew install git >> $LOGFILE 2>&1
    echo ""
    STATE=Bad
  fi

  # Check and Install AppCatalyst:
  echo -n "AppCatalyst:    "
  if pkgutil --pkg-info com.vmware.pkg.AppCatalyst &> /dev/null; then
    echo "[ OK ]"

  else
    echo " [ Missing ]"
    echo "Downloading AppCatalyst..."
    wget --quiet -c http://getappcatalyst.com/downloads/VMware-AppCatalyst-Technical-Preview-August-2015.dmg >> $LOGFILE 2>&1

    echo "Installing AppCatalyst..."
    hdiutil attach VMware-AppCatalyst-Technical-Preview-August-2015.dmg >> $LOGFILE 2>&1
    sudo installer -pkg "/Volumes/VMware AppCatalyst/Install VMware AppCatalyst.pkg" -target / >> $LOGFILE 2>&1
    umount "/Volumes/VMware AppCatalyst/" >> $LOGFILE 2>&1
    STATE=Bad
  fi

}

until [[ $STATE == "OK" ]]; do
  check_system
done

echo ""
echo "Your system is ready for Chaperone development!"
echo ""

# =============================================================================
# Phase Two: Bootstrap the AppCatalyst VM
# =============================================================================

# TODO: Check for running Fusion VMs and kernel things here.

APC=/opt/vmware/appcatalyst/bin/appcatalyst
APC_KEY=/opt/vmware/appcatalyst/etc/appcatalyst_insecure_ssh_key

echo -n "Creating the Chaperone Photon VM..."
if $APC vm list 2> /dev/null | grep -q chaperone; then
  echo "Done."
else
  if $APC vm create chaperone >> $LOGFILE 2>&1; then
    echo "Done."
  else
    echo "Error. See $LOGFILE for more information."
    exit 1
  fi
fi

# Can execute if running:
echo -n "Powering on the Chaperone Photon VM..."
if $APC vmpower on chaperone >> $LOGFILE 2>&1; then
  echo "Done."
else
  echo "Error. See $LOGFILE for more information."
  exit 1
fi

echo -n "Waiting for the Chaperone Photon VM to obtain an IP address (~30s)..."
until $APC guest getip chaperone &> /dev/null; do
  echo -n '.'
  sleep 1
done

CHAPERONE_IP=$($APC guest getip chaperone)

echo "Done (${CHAPERONE_IP})."

echo "==============================================================="
echo "Bootstrapping the Chaperone Photon VM..."
echo "==============================================================="

# These are executed remotely, and exist to bootstrap the VM prior to running
# Ansible on it, in case you were wondering why we add host entries here:

echo "Installing Git..."
ssh -i $APC_KEY photon@$CHAPERONE_IP "sudo tdnf install -y git"

echo "Cloning repository..."
ssh -i $APC_KEY photon@$CHAPERONE_IP "git clone http://10.150.111.238:8080/ansible-playbooks-chaperone"

# These will go away once DNS entries have been properly established:
echo "Setting host entries..."
if ssh -i $APC_KEY photon@$CHAPERONE_IP "grep -q 'registry.cloudbuilders.vmware.local' /etc/hosts"; then
  echo "Warning: Host entries were detected already, this might cause an issue!"
else
  ssh -i $APC_KEY photon@$CHAPERONE_IP "sudo sh -c 'echo 10.150.111.233  registry.cloudbuilders.vmware.local >> /etc/hosts'"
fi

echo "==============================================================="
echo "Mac-Boostrapper: Invoking Photon setup script..."
echo "==============================================================="
ssh -i $APC_KEY photon@$CHAPERONE_IP "cd /home/photon/ansible-playbooks-chaperone/chaperone/photon_setup/; sudo ./photon.sh"

echo "==============================================================="
echo "Mac-Boostrapper: Invoking Chaperone setup script..."
echo "==============================================================="
ssh -i $APC_KEY photon@$CHAPERONE_IP "cd /home/photon/ansible-playbooks-chaperone/chaperone/photon_setup/; ./chaperone.sh"
