#!/bin/bash

## SSH Public Key
## Replace this public key with your own public key
pubkey='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzPZ1Y5pp0aheWU+fV4Fgy2wdtRBi70+PMJWWmZgy1sf3vsBqZWznX+4/wkqjCyppYK/35eHUEnHLfXahnbxKGebZT2S/kuiLcdzlw3tCNJUT++bQ9QMk3hnhTHdb4l3DINaUXyiJj11thcsV0Hz6NiLAKqbjweCIXjJNim4zvCxfTihE4xX0ciGTZ2gWvwxFzFupwPQ1I0QHZ7iBdFC+8Ii+D1ffgpM8Rfx/VgMVRz8sc3CnvsozPYU1DR2tJMGY3WlEgsDq2HTQw+wkyYQNdj+R4Tayy6C9AzNxs5Z4cfBvjU4bRLGx2WgzmFQyx4K7xR4W3wzGaQBx8I7TnA5TqkDR9ROoVWb5gJ0awlfl5K8Sf15BojnS3PZfcn4sLMakb5eGRAKh03Ge6WrKEvwusG47fOE6Qfv2FeugNMTpgBtiCERC3aIsKMXpmtUJ2A1aKEZCZIQUsHUaZGfo27e1fwVxqAOL5mFivT7Z+Wa6oJtfPHZadrsLVmjo1ClL5Skz0+Q9PJED387Ni/6SHTJqVsmgcmPCvdCr5+VGaHabiYdMJOuam+vSBLteIRy5DComqB3Nw96SBovuaD9WEm4HKARxPyWk9ck3giJctQIzFyZRXvw0qJORjUlAfPVIVTBR/+HZWqTj8RodSIpMOgj5mJfS0W3kx65Sk5APtnMDgvw=='

## SSH Username for Ansible
## Replace this username with the user you'd like to create
ansibleuser='anssvc'

echo "This script must be run as root"

osinfo=$(hostnamectl | grep 'Operating System')
echo $osinfo

usercheck=$(sudo cat /etc/passwd | grep -i $ansibleuser)
sudocheck=$(sudo cat /etc/sudoers | grep -i $ansibleuser)

echo "Checking for $ansibleuser Account"

if [[ $usercheck == *$ansibleuser*]]; then
    echo "$ansibleuser already exists"

else
    echo "Creating user $ansibleuser"
    sudo useradd --create-home $ansibleuser
fi

echo "Creating authorized_keys file for $ansibleuser"

if [ ! -d /home/$ansibleuser/.ssh ]; then
    echo "Creating .ssh directory"
    sudo mkdir /home/$ansibleuser/.ssh
fi

sudo echo $pubkey > /home/$ansibleuser/.ssh/authorized_keys

echo "Setting Permissions"
sudo chown -R $ansibleuser:$ansibleuser /home/$ansibleuser/.ssh
sudo chmod 700 /home/$ansibleuser/.ssh
sudo chmod 600 /home/$ansibleuser/.ssh/authorized_keys

## Set Sudoers Permissions

if [[ $sudocheck == *$ansibleuser* ]]; then
    echo "$ansbileuser exists in sudoers file"
else
    if [[ $osinfo == *"Ubuntu"* ]]; then
        echo "Adding $ansibleuser to suoders for Ubuntu OS"
        sudo echo "$ansibleuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    elif [[ $osinfo == *"Rocky"* ]]; then
        echo "Adding $ansibleuser to suoders for Rocky OS"
        sudo echo "$ansibleuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    fi
fi

echo "Complete!"