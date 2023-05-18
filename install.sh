#!/bin/bash

set -eu
#set -eux 

# install macos
install_macos() {
    echo "Install MacOS ..."
}

# intall centos
install_centos() {
    echo "Install CentOS ..."
}

# install ubuntu
install_ubuntu() {
    echo "Install Ubuntu ..."

    echo "Install Develop Environment ..."
    sudo apt update
    sudo apt install -y build-essential cmake unzip curl wget git zsh tmux net-tools
    sudo apt install -y python3-dev libpython3-dev libssl-dev libcurl4-openssl-dev libmysqlclient-dev

    #setting coredump
    sudo sh -c "echo '/usr/local/lib' >> /etc/ld.so.conf.d/usr_local_lib"
    sudo sh -c "echo 'kernel.core_pattern=core.%e.%p.%t' >> /etc/sysctl.conf"
    sudo sh -c "echo '*                soft    core            unlimited' >> /etc/security/limits.conf"
    sudo sh -c "echo '*                hard    core            unlimited' >> /etc/security/limits.conf"
    sudo sysctl -w kernel.core_pattern=core.%e.%p.%t

    echo "Install oh_my_zsh ..."
    cd $DOWNLOADDIR
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    echo "Install libevlite ..."
    cd $INSTALLDIR
    sudo git clone https://github.com/spriteray/libevlite.git
    cd $INSTALLDIR/libevlite && sudo make && sudo make install

    echo "Install Lua ..."
    cd $DOWNLOADDIR
    curl -R -O http://www.lua.org/ftp/lua-5.4.6.tar.gz
    sudo tar zxf lua-5.4.6.tar.gz -C $INSTALLDIR
    cd $INSTALLDIR/lua-5.4.6 && sudo make all test && sudo make install

    echo "Install Protobuf ..."
    cd $DOWNLOADDIR
    wget https://github.com/protocolbuffers/protobuf/releases/download/v3.19.4/protobuf-all-3.19.4.zip
    sudo unzip -d $INSTALLDIR protobuf-all-3.19.4.zip
    cd $INSTALLDIR/protobuf-3.19.4 && sudo ./configure && sudo make && sudo make install

    echo "Install Neovim ..."
    cd $INSTALLDIR
    sudo git clone https://github.com/neovim/neovim.git
    cd $INSTALLDIR/neovim && sudo make CMAKE_BUILD_TYPE=Release && sudo make install
    
    echo "Install YouCompleteMe ..."
    cd $INSTALLDIR
    sudo git clone https://github.com/ycm-core/YouCompleteMe.git /usr/src/YouCompleteMe
    cd $INSTALLDIR/YouCompleteMe && sudo git submodule update --init --recursive && sudo ./install.py --clangd-completer

    echo "Config Neovim ..."
    cd $BASEDIR
    cp -r nvim ~/.config/nvim
    nvim
}

BASEDIR=$(cd `dirname $0`; pwd)
DOWNLOADDIR=$BASEDIR/download
INSTALLDIR=/usr/src
OSNAME=`uname -a`

if [[ $OSNAME =~ "Darwin" ]]; then
    install_macos
elif [[ $OSNAME =~ "centos" ]]; then
    install_centos
elif [[ $OSNAME =~ "ubuntu" ]]; then
    install_ubuntu
else
    install_ubuntu
fi

exit $?
