# Environment variables


# Only source this once
if [[ -z "$__HM_ZSH_SESS_VARS_SOURCED" ]]; then
  export __HM_ZSH_SESS_VARS_SOURCED=1
  
fi

export ZOXIDE_CMD_OVERRIDE='cd'

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export ZVM_VI_SURROUND_BINDKEY='s-prefix'


ZSH="${HOME}/.oh-my-zsh";
ZSH_CACHE_DIR="${HOME}/.cache/oh-my-zsh";
