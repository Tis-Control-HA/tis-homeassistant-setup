#!/bin/sh

# Define variables
HOMEASSISTANT_CONFIG="/config"
ADDONS_DIR="/addons"
CUSTOM_COMPONENTS_DIR="${HOMEASSISTANT_CONFIG}/custom_components"
INTEGRATION_REPO_URL="https://github.com/KarimTIS/tis_integration"
INTEGRATION_REPO_NAME="tis_integration"
ADDON_REPO_URL="https://github.com/KarimTIS/tis_addon"
ADDON_REPO_NAME="home-assistant-addon"

# Function to install a package if not already installed
install_if_missing() {
    PACKAGE=$1
    if ! command -v $PACKAGE >/dev/null 2>&1; then
        echo "Installing $PACKAGE..."
        sudo apt-get install -y $PACKAGE
    else
        echo "$PACKAGE is already installed."
    fi
}

# Function to check for errors
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Update package list and install sudo if missing
echo "Checking and installing sudo if missing..."
if ! command -v sudo >/dev/null 2>&1; then
    echo "Installing sudo..."
    apt-get update
    apt-get install -y sudo
    check_error "Failed to install sudo."
else
    echo "sudo is already installed."
fi

# Update system package list
echo "Updating system package list..."
sudo apt-get update
check_error "Failed to update the system."

# Check and install other required packages
echo "Checking required packages..."
install_if_missing git
check_error "Failed to install Git."
# install_if_missing p7zip-full
# check_error "Failed to install 7z."

# Ensure custom_components folder exists
echo "Ensuring custom_components folder exists..."
if [ ! -d "$CUSTOM_COMPONENTS_DIR" ]; then
    echo "Creating custom_components directory at $CUSTOM_COMPONENTS_DIR..."
    mkdir -p "$CUSTOM_COMPONENTS_DIR"
else
    echo "custom_components directory already exists."
fi

# Navigate to custom_components folder
cd "$CUSTOM_COMPONENTS_DIR" || exit

# Clone or update the integration repository
if [ ! -d "$INTEGRATION_REPO_NAME" ]; then
    echo "Cloning the integration repository..."
    git clone --depth 1 "$INTEGRATION_REPO_URL"
    check_error "Failed to clone the integration repository."
else
    echo "Integration repository already exists. Resetting to the latest commit..."
    cd "$INTEGRATION_REPO_NAME" || exit
    git reset --hard
    check_error "Failed to reset the integration repository."
    git pull
    check_error "Failed to update the integration repository."
fi

# Ensure addons folder exists
echo "Ensuring addons folder exists..."
if [ ! -d "$ADDONS_DIR" ]; then
    echo "Creating addons directory at $ADDONS_DIR..."
    mkdir -p "$ADDONS_DIR"
else
    echo "addons directory already exists."
fi

# Navigate to addons folder
cd "$ADDONS_DIR" || exit

# Clone or update the addon repository
if [ ! -d "$ADDON_REPO_NAME" ]; then
    echo "Cloning the addon repository..."
    git clone --depth 1 "$ADDON_REPO_URL" "$ADDON_REPO_NAME"
    check_error "Failed to clone the addon repository."
    cd "$ADDON_REPO_NAME" || exit
else
    echo "Addon repository already exists. Resetting to the latest commit..."
    cd "$ADDON_REPO_NAME" || exit
    git reset --hard
    check_error "Failed to reset the addon repository."
    git pull
    check_error "Failed to update the addon repository."
fi

# # Extract the multipart archive
# echo "Extracting laravel_2.zip.001..."
# 7z x -y laravel_2.zip.001
# check_error "Failed to extract laravel_2.zip.001."

# echo "Deleting laravel_2.zip.* files..."
# rm laravel_2.zip.*
echo "Installation of integration and addon completed successfully!"
