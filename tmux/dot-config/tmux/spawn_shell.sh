#!/bin/bash

function rsc() {
  [[ "$(systemctl --user is-active tmux.service)"!="active" ]] && systemctl --user start tmux.service
  CLIENTID="$1-$(date +%S)"
  tmux new -d -t $1 -s $CLIENTID \; set-option destroy-unattached \; attach-session -t $CLIENTID \; new-window -n $CLIENTID -c $HOME
}
rsc byrix
