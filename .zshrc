check_zsh_changes() {
    local current_file="${(%):-%x}"
    local cache="${current_file}.bak"
    if [[ -f "$cache" ]]; then
        # + en vert pour les ajouts, - en rouge pour les suppressions
        diff --new-line-format=$'\e[32m+ Ligne %dn: %L\e[0m' \
             --old-line-format=$'\e[31m- Ligne %dn: %L\e[0m' \
             --unchanged-line-format="" \
             "$cache" "$current_file"
    fi
    cp "$current_file" "$cache"
}

check_zsh_changes
echo -e "\e[37m[aliases reloaded]\e[0m"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# ============================================================================
# CONFIGURATION
# ============================================================================

export PATH="$HOME/.local/bin:$PATH"
export ZSH_REPO="$HOME/zsh_config_repo"

# Demarrage auto du son (silencieux)
systemctl --user start pulseaudio >/dev/null 2>&1

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ============================================================================
# FONCTIONS
# ============================================================================

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
        (cd "$ZSH_REPO" && git init && echo "Repo initialisé. N'oubliez pas d'ajouter votre remote origin !")
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

# Alias pour sauvegarder le .zshrc
gitz() {
    save_zshrc "$@"
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
# zs: Recharge les alias (sans pull)
alias zs="source ~/.zshrc"

# Fichier flag pour arreter le watcher
export ZSHRC_WATCHER_FLAG="/tmp/.zshrc_watcher_running"

# Ouvrir le .zshrc avec surveillance dans un terminal separe
openz() {
    touch "$ZSHRC_WATCHER_FLAG"
    (gnome-terminal --title="ZSH Watcher" -- bash -c '
        SAVE_INTERVAL=120  # Sauvegarde toutes les 2 minutes
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
        
        # Lancer VS Code avec -w (wait) en arriere-plan
        # Quand il se ferme, on supprime le flag
        (code -w "$HOME/.zshrc"; rm -f "$FLAG_FILE") &
        
        last_hash=$(md5sum "$HOME/.zshrc" 2>/dev/null | cut -d" " -f1)
        last_save=$(date +%s)
        
        while true; do
            sleep 2
            
            # Verifier si le flag existe (VS Code ferme ou stopz)
            if [ ! -f "$FLAG_FILE" ]; then
                echo -e "\e[33m[VS Code ferme ou stopz]\e[0m"
                cleanup
            fi
            
            current_hash=$(md5sum "$HOME/.zshrc" 2>/dev/null | cut -d" " -f1)
            now=$(date +%s)
            elapsed=$((now - last_save))
            
            # Sauvegarde si modification detectee
            if [[ "$current_hash" != "$last_hash" ]]; then
                last_hash="$current_hash"
                echo -e "\e[33m[$(date +%H:%M:%S)] Modification detectee\e[0m"
            fi
            
            # Sauvegarde periodique toutes les SAVE_INTERVAL secondes
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

# Arreter le watcher manuellement
stopz() {
    if [ -f "$ZSHRC_WATCHER_FLAG" ]; then
        rm -f "$ZSHRC_WATCHER_FLAG"
        echo -e "\e[33m[Signal d arret envoye au watcher]\e[0m"
    else
        echo "Pas de watcher actif."
    fi
}

# Pull le .zshrc depuis GitHub et recharge
pullz() {
    sync_zshrc && source ~/.zshrc
}
