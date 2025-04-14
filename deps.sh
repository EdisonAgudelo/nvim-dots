#!/bin/bash


sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt-get update

sudo apt-get install -y fd-find ripgrep clang luajit libmagickwand-dev luarocks python-venv neovim
sudo luarocks install magick

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

rm -r lazygit lazygit.tar.gz
