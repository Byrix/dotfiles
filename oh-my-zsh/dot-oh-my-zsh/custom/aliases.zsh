alias please='sudo'
alias src='source ~/.zshrc'
alias c='clear'
alias pvpn='sudo protonvpn'
alias update='eos-update --yay'
alias cnap='conda activate ./.env'
alias n='conda activate ./.env && nvim'
# alias cnde=$(_conda_deactivate)

unalias cnde
function cnde() {
  while [[ -n $CONDA_DEFAULT_ENV ]]; do
    conda deactivate 
  done
}

unalias md
function md() {
  mkdir -p "$1"
  [[ $? -ne 0 ]] && return $?

  cd $1
}

function lg() {
  ls -lah | grep "$1"
}
