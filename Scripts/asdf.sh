#!/bin/bash

sudo apt install -y git

git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf || exit
git checkout "$(git describe --abbrev=0 --tags)"

### Postgres ===================================================================

postgres_version='10.5'

asdf plugin-add postgres

# install dependencies =========================================================

sudo apt install -y "linux-headers-$(uname -r)" build-essential \
	libreadline-dev zlib1g-dev

# install and activate postgres ================================================

asdf install postgres "${postgres_version}"

asdf global postgres "${postgres_version}"

### Java =======================================================================

java_version='openjdk-11.0.1'

asdf plugin-add java

asdf install java "${java_version}"

asdf global java "${java_version}"

### Erlang =====================================================================

erlang_version='21.3.8.1'

asdf plugin-add erlang

# install dependencies =========================================================

sudo apt install -y build-essential autoconf m4 libncurses5-dev libwxgtk3.0-dev \
	libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev \
	xsltproc fop

# install erlang ===============================================================

asdf install erlang "${erlang_version}"

asdf global erlang "${erlang_version}"

### Elixir =====================================================================

elixir_version="1.8"

asdf plugin-add elixir

asdf install elixir "${elixir_version}"

asdf global elixir "${elixir_version}"

### Node =======================================================================

node_version="10.15.3"

asdf plugin-add nodejs

# install dependencies =========================================================

sudo apt install -y dirmngr gpg

# import keyring

bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring

# install node =================================================================

asdf install nodejs "${node_version}"

asdf global nodejs "${node_version}"

### Elm ========================================================================

elm_version="0.19.0"

asdf plugin-add elm

asdf install elm "${elm_version}"

asdf global elm "${elm_version}"

### Python =====================================================================

python_version="3.7.3"

asdf plugin-add python

# install dependencies =========================================================

sudo apt install -y --no-install-recommends make build-essential libssl-dev \
	zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
	libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev \
	liblzma-dev

# install python ===============================================================

asdf install python "${python_version}"

asdf global python "${python_version}"
