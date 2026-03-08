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
    
    # We use '|| true' because pre-installed repos like Yarn often have expired keys
    # which shouldn't block YOUR installation.
    sudo apt-get update || true
    sudo apt-get install -y curl gnupg apt-transport-https

    . /etc/os-release
    
    # Register Microsoft Repo
    curl -sSL "https://packages.microsoft.com/config/$ID/$VERSION_ID/packages-microsoft-prod.deb" -o /tmp/packages-microsoft-prod.deb
    
    if [ -f /tmp/packages-microsoft-prod.deb ]; then
        sudo dpkg -i /tmp/packages-microsoft-prod.deb
        rm /tmp/packages-microsoft-prod.deb
        # Update again to pull in the new Microsoft list, again ignoring Yarn errors
        sudo apt-get update || true
        sudo apt-get install -y powershell
    fi
}

install_git() {
    if command -v git &> /dev/null; then
        echo "Git is already installed. Skipping."
        return 0
    fi

    echo "Installing Git..."
    sudo apt-get update || true
    sudo apt-get install -y git
}

set_editor() {
    if command -v code &> /dev/null; then
        export EDITOR="code --wait"
    else
        export EDITOR="nano"
    fi
}

# 5. Execute installation
export DEBIAN_FRONTEND=noninteractive
set_editor
install_pwsh
install_git

echo "Setup complete!"