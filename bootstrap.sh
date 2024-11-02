#!/usr/bin/env bash

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" ]]; then
            echo "Ubuntu"
        elif [[ "$ID" == "arch" ]]; then
            echo "Arch"
        else
            echo "Unknown"
        fi
    else
        echo "Unknown"
    fi
}

is_wsl() {
    if grep -qi "Microsoft" /proc/version; then
        return 1
    else
        return 0
    fi
}

install_shared() {
    echo "Installing shared packages..."

    sudo groupadd wireshark
    sudo usermod -aG wireshark $USER
    newgrp wireshark

    cp -r ./shared/.??* ~
    cp -r ./linux/.??* ~

    git clone https://github.com/asdf-vm/asdf ~/.asdf
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    chsh -s /bin/zsh
    curl -sS https://starship.rs/install.sh | sh
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source "$HOME/.cargo/env"
    rustup toolchain install nightly
    rustup +nightly component add rust-src

    asdf plugin add dotnet https://github.com/hensou/asdf-dotnet
    asdf plugin add golang https://github.com/kennyp/asdf-golang
    asdf plugin add java https://github.com/halcyon/asdf-java
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs
    asdf plugin-add zig https://github.com/asdf-community/asdf-zig

    asdf install dotnet 8.0.403
    asdf install golang 1.23.2
    asdf install java temurin-21.0.5+11.0.LTS
    asdf install nodejs 20.18.0
    asdf install zig 0.13.0

    asdf global dotnet 8.0.403
    asdf global golang 1.23.2
    asdf global java temurin-21.0.5+11.0.LTS
    asdf global nodejs 20.18.0
    asdf global zig 0.13.0

    curl -fsSL https://get.pnpm.io/install.sh | sh -
}

install_ubuntu() {
    echo "Installing Ubuntu packages..."

    touch ~/.hushlogin

    sudo apt update -y && sudo apt upgrade -y
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch

    sudo apt install -y --no-install-recommends \
        autoconf \
        automake \
        bash \
        ca-certificates \
        clang \
        cmake \
        curl \
        dnsutils \
        fastfetch \
        ffmpeg \
        file \
        g++ \
        gcc \
        gh \
        git \
        gnupg \
        gzip \
        htop \
        iputils-ping \
        libc6-dev \
        libluajit-5.1-dev \
        libncurses5-dev \
        libssl-dev \
        libudev-dev \
        llvm \
        lsb-release \
        make \
        nano \
        ninja-build \
        python3 \
        python3-pip \
        samba \
        tar \
        tshark \
        unzip \
        wget \
        whois \
        xz-utils \
        yt-dlp \
        zsh

    if grep -vq "microsoft" /proc/version; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
        sudo usermod -aG docker $USER
        newgrp docker
        docker version
    fi
}

install_arch() {
    echo "Installing Arch packages..."

    sudo pacman-key --init
    sudo pacman-key --populate
    sudo pacman -Sy archlinux-keyring
    sudo pacman -Su

    sudo pacman -S \
        autoconf \
        automake \
        clang \
        cmake \
        curl \
        fastfetch \
        ffmpeg \
        gcc \
        git \
        github-cli \
        gzip \
        htop \
        llvm \
        make \
        nano \
        neofetch \
        nginx \
        ninja \
        python \
        tar \
        unzip \
        wget \
        zsh

    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si
}

main() {
    distro=$(detect_distro)

    if [[ "$distro" == "Ubuntu" ]]; then
        install_ubuntu
        install_shared
    elif [[ "$distro" == "Arch" ]]; then
        install_arch
        install_shared
    else
        echo "Unsupported distro."
    fi
}

main
