# Per-machine settings (theme, aliases, PATH). This file is gitignored.
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local

# Antigen 把主题写进 ~/.antigen/init.zsh。缓存还在时，antigen theme 不会再执行。
# 本机主题和缓存不一致时删掉缓存，下次启动按 ANTIGEN_THEME 重新生成。
antigen_theme=${ANTIGEN_THEME:-random}
antigen_cache=${ADOTDIR:-$HOME/.antigen}/init.zsh
if [[ -f $antigen_cache ]] && ! grep -F -q "themes/${antigen_theme}.zsh-theme" "$antigen_cache"; then
  rm -f "$antigen_cache"
fi
unset antigen_theme antigen_cache

# Ubuntu package zsh-antigen.
antigen_zsh=/usr/share/zsh-antigen/antigen.zsh
if [[ ! -r $antigen_zsh ]]; then
  print -u2 -- "antigen.zsh not found. Install the zsh-antigen package."
else
  source "$antigen_zsh"

  # Oh My Zsh 在 antigen apply 时读取这个变量，写在 apply 之后不会生效。
  # ~/.zshrc.local 可以提前把它设成别的值。
  : ${COMPLETION_WAITING_DOTS:=true}

  antigen use oh-my-zsh

  antigen bundle z
  antigen bundle git
  antigen bundle sudo
  antigen bundle tmux
  if (( $+commands[direnv] )); then
    antigen bundle direnv
  fi
  antigen bundle extract
  antigen bundle colorize
  antigen bundle command-not-found
  antigen bundle docker-compose

  antigen bundle zsh-users/zsh-completions
  antigen bundle zsh-users/zsh-history-substring-search
  antigen bundle zsh-users/zsh-autosuggestions

  # syntax-highlighting must be the last plugin sourced.
  # https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md#with-a-plugin-manager
  antigen bundle zsh-users/zsh-syntax-highlighting

  antigen theme "${ANTIGEN_THEME:-random}"
  antigen apply

  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  if [[ -n ${terminfo[kcuu1]:-} ]]; then
    bindkey "${terminfo[kcuu1]}" history-substring-search-up
    bindkey "${terminfo[kcud1]}" history-substring-search-down
  fi
fi

# format `time` command
TIMEFMT=$'\n================\nCPU\t%P\nuser\t%*U\nsystem\t%*S\ntotal\t%*E'

# Disable do you wish to see all x posibilities
# https://stackoverflow.com/a/69533208/19176002
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:*:man:*:*' menu select=long search

# set locale
export LC_ALL=C.UTF-8
export LANG=en_US.UTF-8

# configure pygmentize colorize style
ZSH_COLORIZE_STYLE="native"

# alias config
# 不要把 cat/less 换成 ccat/cless：colorize 会改写字节，管道和 transfer 会拿到高亮后的内容。
alias j=z
alias ls="eza -lh --icons"

# 再读一次本机文件，让这里的别名和 PATH 覆盖上面的默认值。
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local

# enable wildmatch
setopt nonomatch

# transfer function
transfer() {
  if [ $# -eq 0 ]; then
    printf 'No arguments specified.\nUsage:\n transfer <file|directory>\n ... | transfer <file_name>\n' >&2
    return 1
  fi
  if tty -s; then
    local file="$1"
    local file_name
    file_name=$(basename "$file")
    if [ ! -e "$file" ]; then
      printf '%s: No such file or directory\n' "$file" >&2
      return 1
    fi
    if [ -d "$file" ]; then
      file_name="$file_name.zip"
      (cd "$file" && zip -r -q - .) | curl --progress-bar --upload-file "-" "https://packets.zip/$file_name"
    else
      curl --progress-bar --upload-file "$file" "https://packets.zip/$file_name"
    fi
  else
    local file_name="$1"
    curl --progress-bar --upload-file "-" "https://packets.zip/$file_name"
  fi
}

# Machine-local secrets. This file is gitignored and is not part of the dotfiles repo.
[[ -r ~/.zshrc.secrets ]] && source ~/.zshrc.secrets

