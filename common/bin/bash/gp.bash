#! /bin/bash

main() {
  local branch && branch=$(git symbolic-ref --short HEAD)
  local toplevel && toplevel=$(git rev-parse --show-toplevel)
  if [[ $toplevel == *"efjacobson"* ]]; then
    git push origin "$branch"
    exit 0
  fi

  local protected=('master' 'main' 'release-next')
  if [[ " ${protected[*]} " =~ " ${branch} " ]]; then
    echo "don't push $branch..."
    exit 1
  fi

  [ -f .nvmrc ] && source "$(brew --prefix nvm)/nvm.sh" && nvm use

  git push origin "$branch"
}

main
