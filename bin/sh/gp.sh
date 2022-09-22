#! /bin/bash

branch=$(git symbolic-ref --short HEAD)
toplevel=$(git rev-parse --show-toplevel)
if [[ $toplevel == *"efjacobson"* ]]; then
  [ -f .nvmrc ] && source "$(brew --prefix nvm)/nvm.sh" && nvm use
  git push origin "$branch"
  exit 0
fi

vhost_file='provisioning/docker/vhost.conf.tpl'
if [ -f "$vhost_file" ]; then
  sed 's|RewriteRule . http://|RewriteRule . https://|g' "$vhost_file" >"$vhost_file".what && mv "$vhost_file".what "$vhost_file"
fi

protected=('master' 'main' 'release-next')
if [[ " ${protected[*]} " =~ " ${branch} " ]]; then
  echo "don't push $branch..."
  exit 1
fi

[ -f .nvmrc ] && source "$(brew --prefix nvm)/nvm.sh" && nvm use
git push origin "$branch"
