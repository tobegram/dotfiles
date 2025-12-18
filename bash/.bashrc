#
# ~/.bashrc
#

# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# File system
if command -v eza &> /dev/null; then
  alias ls='eza -la --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
else
  alias ls='ls -la --color=auto'
  alias grep='grep --color=auto'
fi

alias ..='cd ..'
alias home='cd $HOME'

eval "$(starship init bash)"
