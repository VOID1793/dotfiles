# VOID1793’s Dotfiles

A polished collection of cross‑compatible shell configuration files for Linux, <mark>**with a focus on bringing PowerShell Core into the Linux development workflow as a first class shell option.**</mark> Ideal for **DevOps/CI‑CD workflows**, these dotfiles work out‑of‑the‑box in GitHub Codespaces and on local Debian‑based systems, with first‑class support for both **Bash** (general CodeSpaces look and feel) and **PowerShell Core**.

---

## 🚀 Overview
This repo provides a unified, easily deployable environment that:

- Enhances the command‑line experience with informative, Git‑aware prompts.
- Supplies handy aliases and completions for Terraform, Ansible, Git, and more.
- Automates setup via `install.sh`, including package installation and backup of existing configs.
- Adapts seamlessly between interactive shells and automated environments such as Codespaces.

> Designed for engineers who prefer a fast, consistent shell setup across machines and containers.

---

## ✅ Compatibility

| Component | Status | Notes |
|-----------|--------|-------|
| Bash 4.4+ | ✓ | Default shell on most Linux distros
| PowerShell 7+ | ✓ | Installed automatically on Debian/Ubuntu via script
| Debian / Ubuntu | ✓ | `apt`‑based installer; manual support for other distros
| GitHub Codespaces | ✓ | Environment detection enables simplified prompt and telemetry
| Other Linux distros | ◼ | Works with manual PowerShell setup and path adjustments


These dotfiles are **Linux‑centric** but most settings are portable; non‑Linux users may adapt as needed.

---

## 📋 Requirements

- A **Linux** host (Debian/Ubuntu recommended)
- `bash` available as an interactive shell
- `sudo` privileges for the installer script (for package installs)
- Internet access to fetch PowerShell Core and other dependencies


---

## ✨ Key Features (PowerShell First)

These dotfiles treat PowerShell Core as a **first‑class, fully supported shell** on Linux.  Everything in the repo works in Bash, but the installer and profiles go the extra mile to make PowerShell the default daily driver.

- **First‑Class PowerShell Support**
  - Installer boots PowerShell 7+ (Debian/Ubuntu) and configures `$PROFILE` automatically.
  - Git aliases from `.gitconfig` are converted into PowerShell functions (`gs`, `ga`, etc.), ensuring the same shorthand works in either shell.
  - Built‑in integration with [Oh‑My‑Posh](https://ohmyposh.dev) themes; custom JSON files live under `custom-themes/ohmyposh/`.
  - Installer optionally switches the user into PowerShell at the end of setup for a seamless transition.

- **Git‑Aware Prompts** (Bash & PowerShell)
  - Show current branch or short SHA with a “dirty” marker when there are uncommitted changes.
  - Exit‑status indicator that turns red on failure.
  - Prompts adapt intelligently inside GitHub Codespaces or other CI‑style environments.

- **DevOps & Git Shortcuts**
  - Terraform commands: `tf`, `tfp` (plan), `tfa` (apply).
  - Ansible helpers: `ap` (`ansible‑playbook`), `av` (`ansible‑vault`).
  - Git alias synchronization guarantees identical command patterns in both shells.

- **Smart Installation Script** (`install.sh`)
  - Detects and installs missing dependencies (PowerShell Core, Git) on supported distros.
  - Creates timestamped backups of existing config files before symlinking from the repo.
  - Generates PowerShell wrappers for every Git alias defined in `.gitconfig`.
  - Sets the default editor to VS Code when present, with a sane `nano` fallback.

- **Autocompletion & UX Enhancements**
  - Bash completion for Terraform and Ansible when available; PowerShell enjoys native module completion.
  - Terminal title updates, colorized output, and a clean, unobtrusive aesthetic.

- **Backup & Revert Friendly**
  - Existing configuration files are archived with timestamps, allowing easy rollback.
  - Running the installer multiple times is safe and idempotent.

---

## 🎨 Look & Feel

The shell environment aims for clarity and minimal distraction:

- **Color‑coded prompts**: green user/host, blue working directory, cyan Git info.
- **Compact Git branch display** with optional “dirty” ⛔ marker.
- **Terminal title updates** show running command (xterm‑style).
- Prompts written to behave well in CI and non‑interactive scripts.

Custom themes for [Oh‑My‑Posh](https://ohmyposh.dev) are included under `custom-themes/`; modify or add your own JSON files there.

---

## 📦 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/VOID1793/dotfiles.git
   cd dotfiles
   ```
2. Execute the installer:
   ```bash
   ./install.sh
   ```
   This will:
   - Install required packages (PowerShell Core, Git).
   - Create symlinks for `.bashrc`, `.gitconfig`, and PowerShell profile.
   - Backup any existing configuration.
   - Generate Git alias helpers for PowerShell.
   - Optionally launch PowerShell when finished.

3. Reload your shell if not automatically switched:
   ```bash
   source ~/.bashrc        # Bash
   . $PROFILE              # PowerShell
   ```

---

## ⚙️ Customization

- Modify `~/.bashrc` or create `~/.bash_aliases` for personal Bash tweaks.
- Edit `Microsoft.PowerShell_profile.ps1` for PowerShell functions and modules.
- Add or update `.gitconfig` in the repo; it will be symlinked to `$HOME` on install.
- Place additional Oh‑My‑Posh theme files in `custom-themes/ohmyposh/` and reference them from your PowerShell profile.

---

## 📜 Attribution

This project began as a fork of the [GitHub Codespaces dotfiles template](https://github.com/codespaces/dotfiles) and has been **customized and enhanced** for personal use. Many improvements were assisted by AI tools and community examples.

Much inspiration was taken from [Scott Hanselman](https://www.hanselman.com/blog/my-ultimate-powershell-prompt-with-oh-my-posh-and-the-windows-terminal) and his shell customization article (linked). 

Themes lifted from [OhMyPosh](https://ohmyposh.dev/docs/themes)

---

*Maintained by [VOID1793](https://github.com/VOID1793). Contributions and suggestions welcome!*


