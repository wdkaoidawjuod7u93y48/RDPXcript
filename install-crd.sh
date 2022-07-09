#!/bin/bash

set -e

output() {
  echo -e "\033[0;34m- ${1} \033[0m"
}
ask() {
  GC='\033[0;32m'
  NC='\033[0m'
  echo -e -n "${GC}- ${1}${NC} "
}
error() {
  RC='\033[0;31m'
  NC='\033[0m'
  echo -e "${RC}ERROR: ${1}${NC}"
}
detect_distro() {
  if type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si | awk '{print tolower($0)}')
    OS_VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$(echo "$DISTRIB_ID" | awk '{print tolower($0)}')
    OS_VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS="debian"
    OS_VER=$(cat /etc/debian_version)
  fi

  OS=$(echo "$OS" | awk '{print tolower($0)}')
  OS_VER_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
}
os_check() {
detect_distro
if [[ $OS == debian ]]; then
   echo -e "\033[0;34m- Found Current OS: $OS\033[0m"
elif [[ $OS == ubuntu ]]; then
   output "Found Current OS: $OS"
else
   error "Unsupported OS!"
   exit 1
fi
}
user() {
# Purpose - Script to add a user to Linux system including passsword
# Author - Vivek Gite <www.cyberciti.biz> under GPL v2.0+
# ------------------------------------------------------------------
# Am i Root user?
outputo() {
  echo -e "\033[0;34m\n- ${1} \033[0m"
}
asko() {
  GoC='\033[0;32m'
  NoC='\033[0m'
  echo -e -n "${GoC}- ${1}${NoC} "
}

erroro() {
  RoC='\033[0;31m'
  NoC='\033[0m'
  echo -e "${RoC}\nERROR: ${1}${NoC}"
}
if [ $(id -u) -eq 0 ]; then
	asko "Enter username to setup with CRD: "
	read username
	asko "Enter password for user: "
	read -s password
	if [[ "$username" == root ]]
	then
	erroro "Root user is not allowed!"
	exit 1
	fi
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		outputo "$username exists!"
		asko "Do you want continue with this user? (y/N): "
		read -r continue
		if [[ "$continue" =~ [Yy] ]]
		then
		crd_setup
		else
		erroro "User already exists"
		exit 1
		fi
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p "$pass" "$username"
		[ $? -eq 0 ] && outputo "User has been added to system!" || erroro "Failed to add a user!"
	fi
else
	outputo "Only root may add a user to the system."
	exit 2
fi
}
os_check
user
