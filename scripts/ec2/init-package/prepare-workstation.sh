#!/usr/bin/env bash

set -ex

#########################################################
################### Helper functions ####################
#########################################################
export PID="$$" # Get parent pid so that you can kill the main proc from subshells
err() {
  echo >&2 "Error : $@"
  kill -s TERM $PID
  exit 1
}

#########################################################
################### Helper functions ####################
#########################################################
setup_pyenv() {
  [[ -d ~/.pyenv ]] && rm -rf ~/.pyenv
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(pyenv init -)"' >> ~/.bashrc
  pip install virtualenv virtualenvwrapper
  git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
  echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
  . ~/.bashrc
}

setup_ssh_keys_and_tokens() {
  if [[ ! -f ~/.ssh/id_rsa && ! -f ~/.ssh/id_rsa.pub ]]; then
    ssh-keygen -t rsa -N "" -b 4096 -C "ssh private key" -f ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa.pub
  fi
  touch ~/.ssh/authorized_keys
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  ssh-keyscan -H localhost >> ~/.ssh/known_hosts
  echo "Updated ssh"
}

setup_workstation() {
  pushd .
  . ~/.bashrc
  cd ~
  [[ -d ~/workstation ]] && rm -rf ~/workstation
  git clone https://github.com/sumanmukherjee03/workstation.git ~/workstation
  cd workstation
  . .env
  make build HOST_IP=localhost DRY_RUN=off
  popd
}

main() {
  setup_pyenv
  setup_ssh_keys_and_tokens
  setup_workstation
}

[[ "$BASH_SOURCE" == "$0" ]] && main "$@"
