#!/bin/bash

# Exit on error, unset variables, or pipe failure
set -euo pipefail

# Get the absolute path of the dotfiles directory FIRST
# This anchors the rest of the script so it knows where to find your files
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Create Symlinks with Backup Logic
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

# Function to dynamically add Git aliases to PowerShell profile
set_pwsh_git_aliases() {
    
    echo "Setting up Git aliases in PowerShell profile..."
    # Dynamically add Git aliases to PowerShell profile from .gitconfig
    if [ -f "$DOTFILES_DIR/.gitconfig" ]; then
    PS_PROFILE="$DOTFILES_DIR/Microsoft.PowerShell_profile.ps1"
        # Remove any existing dynamic section to prevent duplicates
        sed -i '/# --- Dynamically generated Git aliases from .gitconfig ---/,$d' "$PS_PROFILE"
        echo "" >> "$PS_PROFILE"
        echo "# --- Dynamically generated Git aliases from .gitconfig ---" >> "$PS_PROFILE"
        while read -r line; do
            IFS='=' read -r key value <<< "$line"
            alias_name="${key#alias.}"
            if [[ "$value" == \!* ]]; then
                # For shell aliases starting with !, call git with the alias name
                echo "function $alias_name { git $alias_name \$args }" >> "$PS_PROFILE"
            else
                # For regular git commands
                echo "function $alias_name { git $value \$args }" >> "$PS_PROFILE"
            fi
        done < <(git config --file "$DOTFILES_DIR/.gitconfig" --list | grep '^alias\.')
    fi
}
# Function to install PowerShell Core portably
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
# Function to install Git if not present
install_git() {
    if command -v git &> /dev/null; then
        echo "Git is already installed. Skipping."
        return 0
    fi

    echo "Installing Git..."
    sudo apt-get update || true
    sudo apt-get install -y git
}
# Function to set the default editor based on availability
set_editor() {
    if command -v code &> /dev/null; then
        export EDITOR="code --wait"
    else
        export EDITOR="nano"
    fi
}

# Execute installation
export DEBIAN_FRONTEND=noninteractive

set_editor
install_git
set_pwsh_git_aliases
install_pwsh

# Automatically switch to PowerShell if it exists and we are in an interactive session
if [[ $- == *i* ]] && command -v pwsh &> /dev/null; then
    exec pwsh
fi

echo "Setup complete!"