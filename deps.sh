#!/bin/bash


sudo apt-get update

#Instal neovim from official releases
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo tee /etc/profile.d/nvim.sh > /dev/null << EOF
PATH=\$PATH:/opt/nvim-linux-x86_64/bin
EOF

#Instal some dependecies
sudo apt-get autoremove --purge npm neovim -y
sudo apt-get install -y xclip fd-find curl ripgrep clang luajit libmagickwand-dev luarocks python3-pip python3-venv python3-neovim
sudo luarocks install magick

#Install node
curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get install nodejs -y

#Install lazygit from official releases
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

rm -r lazygit lazygit.tar.gz
