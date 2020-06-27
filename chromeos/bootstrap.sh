#!/bin/bash

source "../shared/sbin/functions.sh"
source "../shared/sbin/versions.sh"

LINE="-----------------------------------------"

STATUS_DEV=false
STATUS_DOT=false

lstart() {
  becho "START: $1\n${LINE}"
}

lend() {
  becho "${LINE}\nEND: $1\n"
}

echo -e " "

# Install Development Tools
if ask "Install Basic Development Tools?" Y; then
  lstart "Installing Development Tools";
  apt-get update && apt-get install -y --no-install-recommends \
    wget \
    nano \
    git \
    rsync \
    make | indent
  lend "Installing Development Tools"
  STATUS_DEV=true
fi

# Install DotFiles
if [ -f /usr/bin/rsync ]; then
  if ask "Install Dot Files?" Y; then
    lstart "Installing Dot Files..."
    shopt -s dotglob
    rsync --exclude ".git/" \
      --exclude "chromeos" \
      --exclude "bootstrap.sh" \
      --exclude ".gitignore" \
      --exclude "functions/" \
      --exclude "README.md" \
      --exclude "LICENSE" \
      -avP --no-perms .* ~/;
    lend "Installing Dot Files"
  fi
fi

# Install VS Code
if [ ! -f /usr/bin/code ] || [ "${1}" == "--force" ]; then
  if ask "Install VSCode?" Y; then
    lstart "Installing VS Code..."
    curl -L "https://go.microsoft.com/fwlink/?LinkID=760868" > vscode.deb
    sudo apt install ./vscode.deb
    rm vscode.deb
    lend "Installing VS Code"
  fi
fi

# Install PHPStorm
if [ ! -f /opt/PhpStorm-*/bin/phpstorm.sh ]; then
  if ask "Install PhpStorm?" Y; then
    lstart "Installing PHPStorm..."
    curl -L "https://download.jetbrains.com/webide/PhpStorm-${PHPSTORM_VER}.tar.gz" > PhpStorm.tar.gz
    tar xzf ./PhpStorm.tar.gz -C /opt
    rm ./PhpStorm*.tar.gz
    lend "Installing PHPStorm"
  fi
fi

# Install Docker
if ask "Install Docker?" N; then
  becho "START: Installing Docker..."
  apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
  add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
  apt-get update && apt-get install docker-ce docker-ce-cli containerd.io
  becho "END: Installing Docker"
fi

# Install PHP
if ask "Install PHP and NPM?" Y; then
  becho "START: Installing PHP...\n"
  apt-get update && apt-get install -y --no-install-recommends \
    locales \
    libzip-dev \
    libwebp-dev libjpeg62-turbo-dev libpng-dev \
    libmagickwand-dev \
    sassc \
    jhead \
    imagemagick \
    libimage-exiftool-perl \
    nodejs \
    npm \
    node-babel-cli \
    node-babel-preset-es2015 \
    php${PHP_VER} php${PHP_VER}-{bcmath,cli,common,curl,dev,exif,gd,intl,mbstring,mysql,opcache,sqlite3,xml,zip} php-pear php-imagick
  pecl install APCu-5.1.17
  locale-gen en_US.UTF-8 && locale-gen en_US
  # Install Box
  BOX_FILE=$(mktemp)
  curl -o "$BOX_FILE" -SL "${BOXURL}"
  mkdir -p /usr/local/bin/
  mv ${BOX_FILE} /usr/local/bin/box; chmod 755 /usr/local/bin/box
  # Install Pleasing
  PLEASING_FILE=$(mktemp)
  curl -o "$PLEASING_FILE" -SL "${PLEASINGURL}"
  mv ${PLEASING_FILE} /usr/local/bin/pleasing
  chmod 755 /usr/local/bin/pleasing
  becho "\nEND: Installing PHP"
fi

if [ -f ~/.bash_profile ]; then
  source ~/.bash_profile
fi

echo -e " "