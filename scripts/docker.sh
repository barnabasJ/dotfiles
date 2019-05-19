#!/bin/bash

# Install dependencies =========================================================

sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent \
    software-properties-common

# Add gpg key ==================================================================

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add repository ===============================================================

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

# install docker ===============================================================

sudo apt install -y docker-ce docker-ce-cli containerd.io

# install docker-compose =======================================================

if [ ! -d "$HOME/Apps" ] ; then
  mkdir -p "$HOME/Apps"
fi

curl -L \
  "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" \
  -o "$HOME/Apps/docker-compose"

chmod +x "$HOME/Apps/docker-compose"

if [ ! -d "$HOME/.local/bin" ] ; then
  mkdir -p "$HOME/.local/bin"
fi

ln -s "$HOME/Apps/docker-compose" "$HOME/.local/bin/docker-compose"

