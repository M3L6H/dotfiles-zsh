# Environment variables
. "/etc/profiles/per-user/testUser/etc/profile.d/hm-session-vars.sh"

# Only source this once
if [[ -z "$__HM_ZSH_SESS_VARS_SOURCED" ]]; then
  export __HM_ZSH_SESS_VARS_SOURCED=1
  
fi

ZVM_VI_SURROUND_BINDKEY='s-prefix'
export ZOXIDE_CMD_OVERRIDE='cd'

ZSH="/nix/store/q1lnra10r7ggwkwrx2y0vi8pmm1xfpkg-oh-my-zsh-2025-08-08/share/oh-my-zsh";
ZSH_CACHE_DIR="/home/testUser/.cache/oh-my-zsh";
