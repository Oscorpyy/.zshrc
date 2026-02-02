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

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

systemctl --user start pulseaudio

alias norm="norminette -R CheckForbiddenSourceHeader" 

alias c="cc -Wall -Wextra -Werror" 

alias py="python3" 

alias normy='norminette 2>&1 | grep -v '\''OK'\'' | awk '\''NR==1{first=$0} NR>1{print} END{if(NR==1) print "\033[34m[\033[37mOK\033[31m]\033[0m"}'\' 

alias flake='flake8 2>&1 | awk '\''{print} END{if (NR==0) print "\033[34m[\033[37mOK\033[31m]\033[0m"}'\' 

alias blue="/sgoinfre/scros/Public/utils/blue42" 

alias gp="git pull" 

alias stdgame="/sgoinfre/42stdGamesLauncher" 

alias sound="systemctl --user start pulseaudio >/dev/null 2>&1" 

# Config pour le repo dedié au zshrc
export ZSH_REPO="$HOME/zsh_config_repo"

# Fonction pour synchroniser le .zshrc depuis GitHub (pull)
sync_zshrc() {
    if [ ! -d "$ZSH_REPO" ]; then
        echo "Erreur: Le dossier $ZSH_REPO n'existe pas."
        return 1
    fi

    # Pull depuis le repo distant (dans un sous-shell pour rester dans le dossier actuel)
    (
        cd "$ZSH_REPO"
        if git remote | grep -q "origin"; then
            echo -e "\e[33m[Syncing .zshrc from GitHub...]\e[0m"
            git pull --quiet origin main 2>/dev/null || git pull --quiet origin master 2>/dev/null || git pull --quiet
        fi
    )

    # Si le fichier distant est different, on le copie vers ~/.zshrc
    if [ -f "$ZSH_REPO/.zshrc" ]; then
        if ! diff -q "$HOME/.zshrc" "$ZSH_REPO/.zshrc" >/dev/null 2>&1; then
            echo -e "\e[32m[Mise a jour du .zshrc depuis le repo]\e[0m"
            cp "$ZSH_REPO/.zshrc" "$HOME/.zshrc"
        fi
    fi
}

# Fonction de sauvegarde automatique
save_zshrc() {
    local msg="${1:-Auto update .zshrc}"
    
    # Creation du dossier si besoin
    if [ ! -d "$ZSH_REPO" ]; then
        echo "Creation du dossier $ZSH_REPO..."
        mkdir -p "$ZSH_REPO"
        (cd "$ZSH_REPO" && git init && echo "Repo initialisé. N'oubliez pas d'ajouter votre remote origin !")
    fi

    # Copie du fichier
    cp "$HOME/.zshrc" "$ZSH_REPO/.zshrc"
    
    # Git operations dans un sous-shell (pour ne pas changer le dossier courant de l'utilisateur)
    (
        cd "$ZSH_REPO"
        git add .zshrc
        # Verifie s'il y a des changements a commit
        if ! git diff --cached --quiet; then
            git commit -m "$msg" --quiet
            # Push seulement si une remote est configuree
            if git remote | grep -q "origin"; then
                git push --quiet origin master 2>/dev/null || git push --quiet origin main 2>/dev/null || git push --quiet
            fi
        fi
    )
}

# Modification de openz pour :
# 1. Ouvrir vscode et ATTENDRE la fermeture du fichier (-w)
# 2. Lancer la sauvegarde automatiquement
# 3. Recharger la conf
alias openz="code -w ~/.zshrc && save_zshrc 'Modification via openz' && source ~/.zshrc" 

# zs: Synchronise depuis GitHub (pull) puis recharge le .zshrc
alias zs="sync_zshrc && source ~/.zshrc" 

export PATH="$HOME/.local/bin:$PATH" 

gall() 
{ 
    git add .
    git commit -m "$@" 
    git push 
}

gitz()
{
    save_zshrc "$@"
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
# This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 
# This loads nvm bash_completion
