# Ensure local bin is in the path for this session
if ($env:PATH -notlike "*$HOME/.local/bin*") {
    $env:PATH = "$HOME/.local/bin:" + $env:PATH
}

# Initialize Oh My Posh or fallback to basic prompt
if (Test-Path "$HOME/.config/powershell/custom-themes/ohmyposh/themeA.json") {
    oh-my-posh init pwsh --config "$HOME/.config/powershell/custom-themes/ohmyposh/themeA.json" | Invoke-Expression
} 
else {
    # --- Basic prompt based on GitHub Codespaces ---
    function prompt {
        $lastExit = $?
        # Get just the path string, not the whole object
        $currentPath = $(Get-Location).Path
        
        # Identify User (GitHub Codespaces friendly)
        $user = if ($env:GITHUB_USER) { "@$env:GITHUB_USER" } else { $env:USERNAME }

        # The Success/Failure Arrow
        $arrowColor = if ($lastExit) { "Red" } else { "Green" }

        # Draw the User and Path
        Write-Host "PS $user" -ForegroundColor Green -NoNewline
        Write-Host " ➜ " -ForegroundColor $arrowColor -NoNewline
        Write-Host "$currentPath" -ForegroundColor Cyan -NoNewline

        # Git Branch Logic (Consistency with your Bash prompt)
        if (git rev-parse --is-inside-work-tree 2>$null) {
            $branch = git symbolic-ref --short HEAD 2>$null
            Write-Host " ($branch)" -ForegroundColor Magenta -NoNewline
        }

        return " " 
    }
}

# --- PSReadLine / Tab Completion Tweaks ---

# Enable predictive history
Set-PSReadLineOption -PredictionSource HistoryAndPlugin

# Tab cycles through a menu of REAL files/folders (BASH style)
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# RightArrow accepts the gray text suggestions
Set-PSReadLineKeyHandler -Key RightArrow -Function AcceptSuggestion

# Use Up/Down arrows to search history based on what you've already typed
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Make it look a bit more modern
Set-PSReadLineOption -Colors @{ "InlinePrediction" = "#888888" }

# --- Simple Aliases (One-to-One executable mapping) ---
Set-Alias tf  terraform
Set-Alias ap  ansible-playbook
Set-Alias av  ansible-vault

# --- Static Functions (For commands with arguments/logic) ---
function tfa { terraform apply $args }
function tfp { terraform plan $args }





# --- Dynamically generated Git aliases from .gitconfig ---
function gs { git status $args }
function gpull { git pull $args }
function ga { git add $args }
function gpush { git push $args }
function gcom { git commit -m $args }
function gco { git checkout $args }
function gbr { git branch $args }
function glg { git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit $args }
function gtoday { git gtoday $args }
