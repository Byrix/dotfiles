LINECOL="%F{blue}"
ZSH_THEME_GIT_PROMPT_PREFIX=" on git::"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=" %{%F{red}%}*%{$reset_color%}"

p_date() {
  local c
  echo "[%{%F{green}%B%}%D{%a, %d %b}%b$LINECOL]"
}

p_pyenv() {
  local pyenv="$CONDA_DEFAULT_ENV"
  if [[ -n $pyenv ]]; then
    pyenv="conda:${pyenv:t:gs/%/%%}"
    # [[ "$pyenv"=*"env" ]] && pyenv="${CONDA_DEFAULT_ENV:h:t:gs/%/%%}"
  fi
  echo "$pyenv"
}

p_name() {
  local me="%n"
  [[ -n $SSH_CONNECTION ]] && me="$me@%m"
  echo "$me"
}

p_git() {
  ref="$vcs_info_msg_0_"
  [[ -n $ref ]] && echo "git:$ref"
}
p_dirty() {
  local dirty 
  [[ -n "$vcs_info_msg_0_" && -n "$(git status --porcelain --ignore-submodules)" ]] && dirty='*'
  echo "$dirty"
}

function thm_precmd() {
  vcs_info

  local pyenv="$(p_pyenv)"
  local git="$(p_git)"
  local me="$(p_name)"
  local dirty="$(p_dirty)"

  local TERMWIDTH=$(( COLUMNS - ${ZLE_RPROMPT_INDENT:-1} ))

  PR_FILLBAR=""
  PR_PWDLEN=""

  pwdsize=${#${(%):-%2~}}
  pyenvsize=${#pyenv}
  gitsize=${#git}
  gitdirty=${#dirty}
  gitln=0

  [[ $gitsize -gt 0 ]] && gitln=$((gitsize+gitdirty+4))
  [[ $pyenvsize -gt 0 ]] && pyenvsize=$((pyenvsize+2))

  fill="\${(l:$(( TERMWIDTH - (4 + (pwdsize + gitln) + 1 + pyenvsize + 2) ))::─:)}"

  ul=" $LINECOL┌─[%{%B%F{green}%}%2~%b"
  [[ -n $git ]] && ul="$ul%f on%F{yellow} $git"
  [[ -n $dirty ]] && ul="$ul%F{red}$dirty"
  ul="$ul$LINECOL]"
  ur="─┐"
  [[ -n $pyenv ]] && ur="[%{%F{green}%k%}$pyenv$LINECOL]$ur"
  bl=" $LINECOL└─[%{%F{green}%}$me %(!.#.$) %{%f%k%}"
  br="$LINECOL]─┘"

  PROMPT='
$ul${(e)fill}$ur
$bl'
  RPROMPT='$br'
}

autoload -Uz add-zsh-hook
autoload -Uz vcs_info

add-zsh-hook precmd thm_precmd

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes false
zstyle ':vcs_info:git*' formats '%b'
zstyle ':vcs_info:git*' actionformats '%b (%a)'

