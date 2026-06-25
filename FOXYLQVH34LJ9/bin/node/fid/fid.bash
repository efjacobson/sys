#! /usr/bin/env bash

config_file="$(realpath "${1}")"

if [ -z "${config_file}" ]; then
    echo "Usage: ${0} <path_to_config_file>"
    exit 1
fi

self="${BASH_SOURCE[0]}"
while [ -L "${self}" ]; do
    self_dir="$(cd -P "$(dirname "${self}")" >/dev/null 2>&1 && pwd)"
    self="$(readlink "${self}")"
    [[ ${self} != /* ]] && self="${self_dir}/${self}"
done
self="$(readlink -f "${self}")"
selfdir=$(dirname "${self}")
cd "${selfdir}" || exit 1

nvmrc="${selfdir}/.nvmrc"
required_version=$(head -n 1 "${nvmrc}")
current_version=$(node -v)

if [ "${current_version}" != "${required_version}" ]; then
  if ! nvm use "${nvmrc}"; then
    echo "Error: nvm is not installed or not available in the current shell. Please install an nvm-like program and try again."
    exit 1
  fi
fi

node_modules="${selfdir}/node_modules"
package_lock="${selfdir}/package-lock.json"
if [ ! -f "${package_lock}" ]; then
    [ -d "${node_modules}" ] && rm -rf "${node_modules}"
    npm install
fi

if [ ! -d "${node_modules}" ]; then
    npm install
fi

if ! npm ls &>/dev/null; then
    [ -d "${node_modules}" ] && rm -rf "${node_modules}"
    npm install
fi

node "${selfdir}/fid.mjs" "${config_file}"