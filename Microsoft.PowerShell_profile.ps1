# --- 1. Simple Aliases (One-to-One executable mapping) ---
Set-Alias tf  terraform
Set-Alias ap  ansible-playbook
Set-Alias av  ansible-vault

# --- 2. Functions (For commands with arguments/logic) ---
function tfa { terraform apply $args }
function tfp { terraform plan $args }


# --- 3. The Custom Prompt ---
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