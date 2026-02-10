# ============================================================
# ZSHRC BASE - détecte l'OS et charge le bon fichier
# ============================================================

if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  OS_ID="$ID"
  OS_LIKE="$ID_LIKE"
fi

# Arch / EndeavourOS
if [[ "$OS_ID" == "endeavouros" || "$OS_ID" == "arch" || "$OS_LIKE" == *"arch"* ]]; then
  [[ -f ~/.zshrc_arch ]] && source ~/.zshrc_arch
  return
fi

# Debian / Ubuntu
if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" || "$OS_LIKE" == *"debian"* ]]; then
  [[ -f ~/.zshrc_debian ]] && source ~/.zshrc_debian
  return
fi
