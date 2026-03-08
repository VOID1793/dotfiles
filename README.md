# VOID1793's Dotfiles

A collection of cross-compatible dotfiles for Linux environments, optimized for DevOps/CI/CD workflows using Bash and PowerShell Core. Designed to work seamlessly in GitHub Codespaces and local Linux installations.

## Attribution

This repository is a customized and AI-assisted revision of the GitHub Codespaces dotfiles template, tailored for users who prefer PowerShell Core as their primary shell in Linux environments for DevOps and CI/CD projects.

## Features

- **Git-Aware Prompts**: Custom prompts in both Bash and PowerShell that display the current Git branch and indicate command success/failure.
- **DevOps Aliases**: Short aliases for common Terraform, Ansible, and Git commands:
  - Terraform: `tf` (terraform), `tfp` (terraform plan), `tfa` (terraform apply)
  - Ansible: `ap` (ansible-playbook), `av` (ansible-vault)
  - Git: `gs` (git status), `gp` (git pull), `gpush` (git push), `gcm` (git commit -m)
- **Automated Installation**: The `install.sh` script handles:
  - Symlinking configuration files to your home directory
  - Installing PowerShell Core if not present (on Debian/Ubuntu systems)
  - Backing up existing configurations
- **Cross-Platform Compatibility**: Works on any Debian-based Linux distribution with   Bash and PowerShell support that uses the apt package manager
- **Codespaces-Friendly**: Detects GitHub Codespaces environment and adapts prompts accordingly

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/VOID1793/dotfiles.git
   cd dotfiles
   ```

2. Run the installation script:
   ```bash
   ./install.sh
   ```

   This will:
   - Install PowerShell Core (if not already installed)
   - Create symlinks for `.bashrc` and `Microsoft.PowerShell_profile.ps1`
   - Backup any existing configurations

3. Restart your shell or source the profiles:
   ```bash
   # For Bash
   source ~/.bashrc

   # For PowerShell
   . $PROFILE
   ```

## Requirements

- Linux environment
- Bash shell
- Sudo access for package installation (on supported distros)
- Internet connection for PowerShell installation

## Supported Environments

- GitHub Codespaces
- Local Linux installations (Debian/Ubuntu currently supported for auto-installation)
- Any Linux distro with manual PowerShell setup

## Customization

- Edit `.bashrc` for Bash customizations
- Edit `Microsoft.PowerShell_profile.ps1` for PowerShell customizations
- Add your own `.gitconfig` file to the repository for Git configuration management



