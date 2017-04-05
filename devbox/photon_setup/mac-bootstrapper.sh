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

echo -n "Confirming connectivity... "
if ping -c2 -t2 github.com > /dev/null; then
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

# We consider Homebrew, git, and homebrew-based Python (which gives pip),
# and Ansible to be essential tools for the Mac. Strictly speaking, we don't
# need them since Chaperone development can occur in a VM, but for future
# bootstrapping, let's leave it all here.

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
}

until [[ $STATE == "OK" ]]; do
  check_system
done

echo ""
echo "Your Mac is ready for Chaperone development!"
echo ""
