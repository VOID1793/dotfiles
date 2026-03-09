#!/bin/bash

# Exit on error, unset variables, or pipe failure
set -euo pipefail

# Get the absolute path of the dotfiles directory FIRST
# This anchors the rest of the script so it knows where to find your files
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Function to create or set the needed directories and files for the dotfiles to work
make_dirs_files(){

    # Define destination for bashrc
    DEST="$HOME/.bashrc"

    # Check if a real file exists (not a link) and back it up
    if [ -f "$DEST" ] && [ ! -L "$DEST" ]; then
        echo "Existing .bashrc found. Backing up to .bashrc.bak"
        mv "$DEST" "$DEST.bak"
    fi

    # Remove existing directory if it's a real folder to avoid nesting
    rm -rf "$HOME/.config/powershell/custom-themes"

    # Create the PowerShell config directory if it doesn't exist
    mkdir -p "$HOME/.config/powershell"

    # Define the path for the local config
    LOCAL_GITCONFIG="$HOME/.gitconfig.local"
}
# Function to set symlinks for the dotfiles
set_symlinks(){
    # Create Symlinks with Backup Logic
    echo "Linkin' up dotfiles..."

    # Link bashrc and gitconfig
    ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
    ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

    # Link the profile
    ln -sf "$DOTFILES_DIR/Microsoft.PowerShell_profile.ps1" "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"

    # Link the entire custom-themes folder directly to the config root
    ln -sfn "$DOTFILES_DIR/custom-themes" "$HOME/.config/powershell/custom-themes"
}
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
# Function to install OhMyPosh (Terminal Themes)
install_ohmyposh(){

    echo "Installing OhMyPosh!"

    # Install Oh My Posh binary to a local bin folder
    mkdir -p $HOME/.local/bin
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d $HOME/.local/bin
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
# Function to install GitHub CLI
install_gh_cli(){
    if command -v gh &> /dev/null; then
        echo "GH_CLI is already installed. Skipping."
        return 0
    fi

    echo "Installing GH_CLI..."

    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null


    sudo apt-get update || true
    sudo apt-get install -y gh
}
# Function to set the default editor based on availability
set_editor() {
    if command -v code &> /dev/null; then
        export EDITOR="code --wait"
    else
        export EDITOR="nano"
    fi
}
# Function to set up the local Git identity
set_git_identity() {

    # Only run if the local config doesn't exist to avoid overwriting manual changes
    if [ ! -f "$LOCAL_GITCONFIG" ]; then
        echo "No local git identity found. Detecting environment..."

        # The :- syntax tells Bash: "Use $CODESPACES, but if it's unset, use an empty string"
        if [ "${CODESPACES:-}" = "true" ]; then
            # We do the same for GITHUB_USER just to be safe
            GIT_NAME="${GITHUB_USER:-CodespaceUser}"
            GIT_EMAIL="${GITHUB_USER:-user}@users.noreply.github.com"
            echo "Codespaces detected."
        
        # 2. Fallback for WSL, Ubuntu, or generic Debian systems
        else
            SYS_USER=$(whoami)
            SYS_HOST=$(hostname)
            GIT_NAME="$SYS_USER"
            GIT_EMAIL="${SYS_USER}@${SYS_HOST}.local"
            echo "Local system detected. Using machine-context identity."
        fi

        # Write to the non-synced local file
        cat <<EOF > "$LOCAL_GITCONFIG"
[user]
    name = $GIT_NAME
    email = $GIT_EMAIL
EOF
        echo "Identity saved to $LOCAL_GITCONFIG ($GIT_EMAIL)"
    fi
}
# Execute installation
export DEBIAN_FRONTEND=noninteractive

# Invoke init functions
make_dirs_files
set_symlinks

# Invoke setup functions
set_pwsh_git_aliases
set_editor
set_git_identity

# Invoke installation functions
install_git
install_pwsh
install_ohmyposh
install_gh_cli


# Automatically switch to PowerShell if it exists and we are in an interactive session
if [[ $- == *i* ]] && command -v pwsh &> /dev/null; then
    exec pwsh
fi

echo "Setup complete!"