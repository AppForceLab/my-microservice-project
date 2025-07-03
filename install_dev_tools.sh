#!/bin/bash

# Check if Docker is already installed
if ! command -v docker &> /dev/null
then
    echo "Docker not found. Installing Docker..."
    # Install Docker (for Ubuntu/Debian-based systems)
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

# Check if Docker Compose is already installed
if ! command -v docker-compose &> /dev/null
then
    echo "Docker Compose not found. Installing Docker Compose..."
    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully."
else
    echo "Docker Compose is already installed."
fi

# Check if Python 3.9+ is installed
if ! python3 --version | grep -q "3\.[9-9]\|3\.[1-9][0-9]"; then
    echo "Python 3.9+ not found. Installing Python 3.9..."
    sudo apt update
    sudo apt install -y python3.9 python3.9-venv python3.9-dev
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
    sudo apt install -y python3-pip
    echo "Python 3.9 installed successfully."
else
    echo "Python 3.9+ is already installed."
fi

# Check if Django is installed
if ! python3 -m django --version &> /dev/null
then
    echo "Django not found. Installing Django..."
    pip3 install django
    echo "Django installed successfully."
else
    echo "Django is already installed."
fi

echo "Development tools installation completed."
