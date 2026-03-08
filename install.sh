#!/bin/bash
# 1. Flight Checks: Exit on error, unset variables, or pipe failure
set -euo pipefail

# 2. Get the absolute path of the dotfiles directory FIRST
# This anchors the rest of the script so it knows where to find your files
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 3. Create Symlinks with Backup Logic
echo "Linkin' up dotfiles..."

# Define destination for bashrc
DEST="$HOME/.bashrc"

# Check if a real file exists (not a link) and back it up
if [ -f "$DEST" ] && [ ! -L "$DEST" ]; then
    echo "Existing .bashrc found. Backing up to .bashrc.bak"
    mv "$DEST" "$DEST.bak"
fi

# Link bashrc and gitconfig
ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

# Create the PowerShell config directory if it doesn't exist
mkdir -p "$HOME/.config/powershell"

# Link the profile
ln -sf "$DOTFILES_DIR/Microsoft.PowerShell_profile.ps1" "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"

# 4. Function to install PowerShell Core portably
install_pwsh() {
    if command -v pwsh &> /dev/null; then
        echo "PowerShell is already installed. Skipping."
        return 0
    fi

    echo "Installing PowerShell Core..."
    sudo apt-get update
    sudo apt-get install -y curl gnupg apt-transport-https

    # Portable OS detection
    . /etc/os-release
    OS_ID=$ID
    VERSION_ID=$VERSION_ID

    # Download and register Microsoft repo
    curl -sSL "https://packages.microsoft.com/config/$OS_ID/$VERSION_ID/packages-microsoft-prod.deb" -o /tmp/packages-microsoft-prod.deb
    
    if [ -f /tmp/packages-microsoft-prod.deb ]; then
        sudo dpkg -i /tmp/packages-microsoft-prod.deb
        rm /tmp/packages-microsoft-prod.deb
        sudo apt-get update
        sudo apt-get install -y powershell
    else
        echo "Failed to register Microsoft repo. Installation aborted."
        return 1
    fi
}

# 5. Execute installation
export DEBIAN_FRONTEND=noninteractive
install_pwsh

echo "Setup complete!"