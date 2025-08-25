DEFAULT_USER="byrix"

local current_dir="%{%F{blue}%B%}%3~%{$reset_color%}"
local return_code="%(?..%{$fg[red]%}%? x%{$reset_color%})"
local user_symbol='%(!.#.$)'
local conda_prompt='$(conda_prompt_info)'
local git_branch='$(git_prompt_info)$(hg_prompt_info)'

local user_host() {
  local rsp
  local me=`whoami`
  local host
  if [[ $me != $DEFAULT_USER ]]; then
    rsp="%n"
  elif [[ -n $SSH_CONNECTION ]]; then
    rsp="%m"
  elif [[ -n $SSH_CONNECTION && $me!=$DEFAULT_USER ]]; then 
    rsp="%n@%m"
  fi
  [[ -n $rsp ]] && echo "$rsp"
}
local pyenv() {
  local cnda="$(conda_prompt_info)"
  local venv="$(virtualenv_prompt_info)"
  [[ -n $cnda && -n $venv ]] && echo "conda:$cnda venv:$venv"
  [[ -n $cnda ]] && echo "conda:$cnda"
  [[ -n $venv ]] && echo "venv:$venv"
}

PROMPT=" ${current_dir}${git_branch}${conda_prompt}${venv_prompt}
 %B$(user_host)${user_symbol}%b%{$reset_color%F{white}%} "
RPROMPT="%B${return_code}%b"

ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[yellow]%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX=" with %{$fg[green]%}"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_VIRTUALENV_PREFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX"
ZSH_THEME_VIRTUALENV_SUFFIX="$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX"
