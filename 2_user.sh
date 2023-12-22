#!/bin/bash

cd /home/nic
mkdir dotfiles
cd dotfiles
git clone https://x-token-auth:ATCTT3xFfGN0t23rMBttLxpoGYPZS5Eoy-kFuiFMAqz9n9od1Ks7_r5Wjw92LiW7qnlecNaXY_g3aHBQWwS-Vi5qDoKSQejm9UfO03K_wQ552cb194oxLBXDfH-852fUwiIIdP4pbbEM5XInmJ4iHZ3pWrcutk-hnGzherjk5RAHvam-Ax3xb58=DDD580B9@bitbucket.org/nrweber/dotfiles.git .


# create links to config files
echo "Setting up config files"
./set_all_config_files.sh

echo "Build st terminal"
./st_terminal.sh


echo ""
echo "Downloading ssh key"
./get_ssh_key.sh

echo "Git config"
./git_config.sh

echo "Fixing dotfiles git setup"
./resetOriginToUseSSH.sh

