# New ZSH theme

CURRENT_BG='NONE'
pmt=''
SEGMENT_SEPERATOR=''
BGCOLOURS=(red '#f5a97f' yellow green)

# utils
p_user() {
  local me=`whoami`
  [[ -n $SSH_CONNECTION ]] && me="$me@%m"

  [[ -n $me ]] && echo "$me"
}

p_pyenv() {
  local pyenv

  local cenv
  if [[ -n $CONDA_DEFAULT_ENV ]]; then 
    cenv="${CONDA_DEFAULT_ENV:t:gs/%/%%}"
    [[ $cenv == '.env' ]] && cenv="${CONDA_DEFAULT_ENV:h:t:gs/%/%%}/"
  fi
  [[ -n $cenv ]] && pyenv="conda:$cenv"

  local venv
  [[ -n $VIRTUAL_ENV ]] && venv="${VIRTUAL_ENV:t:gs/%/%%}"
  [[ -n $venv ]] && pyenv="venv:$venv"

  if [[ -n $cenv && -n $venv ]]; then
    local aenv="$(where python | head -n 1)"
    [[ $aenv = "$CONDA_PREFIX/bin/python" ]] && pyenv="%U conda:$cenv%u venv:$venv"
    [[ $aenv = "$VIRTUAL_ENV/bin/python" ]] && pyenv="conda:$cenv %U venv:$venv%u"
  else 
    [[ -n $cenv ]] && pyenv="conda:$cenv"
    [[ -n $venv ]] && pyenv="venv:$venv"
  fi
  [[ -n $pyenv ]] && echo "$pyenv"
}

p_status() {
  local sts=""

  [[ $RTVAL -ne 0 ]] && sts="$sts \uef0e"
  [[ $(jobs -l | wc -l) -gt 0 ]] && sts="$sts \uf013"

  echo "$sts %(!.#.$)"
}

p_dir() {
  local disp_depth=3
  local path="$PWD"
  local directs=(${(s:/:)PWD})
  local depth="$((${#directs}-1-$disp_depth))"

  local dir="%${disp_depth}~"
  [[ $depth -gt 0 ]] && dir="\uf015 \uf060 $depth/$dir"
  echo "$dir"
}

p_git() {
  ref="$vcs_info_msg_0_"
  if [[ -n $ref ]]; then
    [[ -n "$(git status --porcelain --ignore-submodules)" ]] && ref="$ref 󰦒"

    if [[ "$ref" = "${ref/.../}" ]]; then
      ref="\ue725 $ref"
    else 
      ref="\ue729 $ref"
    fi

    [[ -n "$(git remote)" ]] && ref="\uebaa $ref"
    echo "$ref"
  fi
}

p_writeseg() {
  # agnoster
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"

  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    print -n "%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPERATOR%{$fg%}"
  else 
    print -n "%{$bg%}%{$fg%}"
  fi

  [[ -n $3 ]] && echo " $CURRENT_BG "
  CURRENT_BG="$1"
}

prompt_precmd() {
  vcs_info

  RTVAL="$?"
  local segments=("$(p_user)" "$(p_dir)" "$(p_pyenv)" "$(p_git)")
  local seg
  local bg
  local fg='%F{black}'
  local i=1
  pmt="%{%f%k%B%}"

  for segment in $segments; do
  # for i in {1..${#segments}}; do
    [[ ! -n $segment ]] && continue
    bg="%K{$BGCOLOURS[i]}" || bg="%k"

    if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
      seg="%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPERATOR%{$fg%}"
    else 
      seg="%{$bg%}%{$fg%}"
    fi

    seg="$seg $segment "

    [[ $i -eq 2 ]] && seg="$seg %b"
    CURRENT_BG=$BGCOLOURS[i]
    i=$((i+1))

    pmt="$pmt$seg"
  done

  if [[ -n $CURRENT_BG ]]; then
    seg="%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPERATOR"
  else 
    seg="%{%k%}"
  fi
  PROMPT="%E
$pmt$seg%{%f%}
%{%K{blue}%F{black}%}$(p_status) %{%k%F{blue}%}$SEGMENT_SEPERATOR%{$reset_color%} "
  RPROMPT=""
  CURRENT_BG=''
}

setup() {
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info

  add-zsh-hook precmd prompt_precmd

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' check-for-changes false
  zstyle ':vcs_info:git*' formats '%b'
  zstyle ':vcs_info:git*' actionformats '%b (%a)'
}

setup "$@"
