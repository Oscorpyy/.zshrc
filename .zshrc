# ============================================================================
# OH MY ZSH - Configuration de base
# ============================================================================

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# ============================================================================
# CONFIGURATION
# ============================================================================

export PATH="$HOME/.local/bin:$PATH"
export ZSH_REPO="$HOME/zsh_config_repo"
export ZSHRC_WATCHER_FLAG="/tmp/.zshrc_watcher_running"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


# ============================================================================
# FONCTIONS
# ============================================================================

# Afficher les changements du .zshrc au reload
check_zsh_changes() {
    local current_file="${(%):-%x}"
    local cache="${current_file}.bak"
    if [[ -f "$cache" ]]; then
        diff --new-line-format=$'\e[32m+ Ligne %dn: %L\e[0m' \
             --old-line-format=$'\e[31m- Ligne %dn: %L\e[0m' \
             --unchanged-line-format="" \
             "$cache" "$current_file"
    fi
    cp "$current_file" "$cache"
}

# Synchroniser le .zshrc depuis GitHub (pull)
sync_zshrc() {
    if [ ! -d "$ZSH_REPO" ]; then
        echo "Erreur: Le dossier $ZSH_REPO n'existe pas."
        return 1
    fi
    (
        cd "$ZSH_REPO"
        if git remote | grep -q "origin"; then
            git pull --quiet origin main 2>/dev/null || git pull --quiet origin master 2>/dev/null || git pull --quiet
        fi
    )
    if [ -f "$ZSH_REPO/.zshrc" ]; then
        if ! diff -q "$HOME/.zshrc" "$ZSH_REPO/.zshrc" >/dev/null 2>&1; then
            echo -e "\e[32m[Mise a jour du .zshrc depuis le repo]\e[0m"
            cp "$ZSH_REPO/.zshrc" "$HOME/.zshrc"
        fi
    fi
}

# Sauvegarder le .zshrc vers GitHub (push)
save_zshrc() {
    local msg="${1:-Auto update .zshrc}"
    if [ ! -d "$ZSH_REPO" ]; then
        echo "Creation du dossier $ZSH_REPO..."
        mkdir -p "$ZSH_REPO"
        (cd "$ZSH_REPO" && git init && echo "Repo initialise. Ajoutez votre remote origin !")
    fi
    cp "$HOME/.zshrc" "$ZSH_REPO/.zshrc"
    (
        cd "$ZSH_REPO"
        git add .zshrc
        if ! git diff --cached --quiet; then
            git commit -m "$msg" --quiet
            if git remote | grep -q "origin"; then
                git push --quiet origin master 2>/dev/null || git push --quiet origin main 2>/dev/null || git push --quiet
            fi
        fi
    )
}

# Git add, commit et push en une commande
gall() {
    git add .
    git commit -m "$@"
    git push
}

# Sauvegarder le .zshrc manuellement
gitz() {
    save_zshrc "$@"
}

# Pull le .zshrc depuis GitHub et recharge
pullz() {
    sync_zshrc && source ~/.zshrc
}

# Arreter le watcher manuellement
stopz() {
    if [ -f "$ZSHRC_WATCHER_FLAG" ]; then
        rm -f "$ZSHRC_WATCHER_FLAG"
        echo -e "\e[33m[Signal d arret envoye au watcher]\e[0m"
    else
        echo "Pas de watcher actif."
    fi
}

# Ouvrir le .zshrc avec surveillance dans un terminal separe
openz() {
    touch "$ZSHRC_WATCHER_FLAG"
    (gnome-terminal --title="ZSH Watcher" -- bash -c '
        SAVE_INTERVAL=120
        FLAG_FILE="/tmp/.zshrc_watcher_running"
        ZSH_REPO="$HOME/zsh_config_repo"
        
        echo -e "\e[34m========================================\e[0m"
        echo -e "\e[34m[Watcher actif - Surveille ~/.zshrc]\e[0m"
        echo -e "\e[33mSauvegarde auto toutes les 2 min\e[0m"
        echo -e "\e[33mFerme VS Code pour arreter\e[0m"
        echo -e "\e[34m========================================\e[0m"
        echo ""
        
        save_and_push() {
            cp "$HOME/.zshrc" "$ZSH_REPO/.zshrc"
            cd "$ZSH_REPO"
            git add .zshrc
            if ! git diff --cached --quiet; then
                git commit -m "Auto-save .zshrc" --quiet
                git push --quiet origin main 2>/dev/null || git push --quiet origin master 2>/dev/null || git push --quiet
                echo -e "\e[32m[$(date +%H:%M:%S)] Sauvegarde et push OK!\e[0m"
                return 0
            fi
            return 1
        }
        
        cleanup() {
            echo
            echo -e "\e[33m[Sauvegarde finale...]\e[0m"
            save_and_push
            rm -f "$FLAG_FILE"
            echo -e "\e[32m[Termine! Tape zs pour recharger]\e[0m"
            sleep 2
            exit
        }
        
        trap cleanup INT
        
        (code -w "$HOME/.zshrc"; rm -f "$FLAG_FILE") &
        
        last_hash=$(md5sum "$HOME/.zshrc" 2>/dev/null | cut -d" " -f1)
        last_save=$(date +%s)
        
        while true; do
            sleep 2
            
            if [ ! -f "$FLAG_FILE" ]; then
                echo -e "\e[33m[VS Code ferme ou stopz]\e[0m"
                cleanup
            fi
            
            current_hash=$(md5sum "$HOME/.zshrc" 2>/dev/null | cut -d" " -f1)
            now=$(date +%s)
            elapsed=$((now - last_save))
            
            if [[ "$current_hash" != "$last_hash" ]]; then
                last_hash="$current_hash"
                echo -e "\e[33m[$(date +%H:%M:%S)] Modification detectee\e[0m"
            fi
            
            if [ $elapsed -ge $SAVE_INTERVAL ]; then
                if save_and_push; then
                    last_save=$now
                else
                    echo -e "\e[90m[$(date +%H:%M:%S)] Pas de changement\e[0m"
                    last_save=$now
                fi
            fi
        done
    ' &) 2>/dev/null
}

# ============================================================================
# ALIAS
# ============================================================================

# --- Norminette & Linting ---
alias norm="norminette -R CheckForbiddenSourceHeader"
alias normy='norminette 2>&1 | grep -v '\''OK'\'' | awk '\''NR==1{first=$0} NR>1{print} END{if(NR==1) print "\033[34m[\033[37mOK\033[31m]\033[0m"}'\'
alias flake='flake8 2>&1 | awk '\''{print} END{if (NR==0) print "\033[34m[\033[37mOK\033[31m]\033[0m"}'\'

# --- Compilation ---
alias c="cc -Wall -Wextra -Werror"

# --- Python ---
alias py="python3"

# --- Git ---
alias gp="git pull"

# --- Outils 42 ---
alias blue="/sgoinfre/scros/Public/utils/blue42"
alias stdgame="/sgoinfre/42stdGamesLauncher"

# --- Systeme ---
alias sound="systemctl --user start pulseaudio >/dev/null 2>&1"

# --- ZSH Config ---
alias zs="source ~/.zshrc"

# ============================================================================
# INITIALISATION (execute au chargement)
# ============================================================================

check_zsh_changes
systemctl --user start pulseaudio
echo -e "\e[37m[aliases reloaded]\e[0m"
