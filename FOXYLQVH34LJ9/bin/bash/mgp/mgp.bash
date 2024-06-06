#!/usr/bin/env bash

get_status_for_project() {
  project=$1
  case $project in
    13)
      echo '📋 To Do'
      ;;
    11)
      echo 'Awaiting Engineering'
      ;;
    *)
      echo "unknown project: ${project}"
      exit 1
      ;;
  esac
}

self="${BASH_SOURCE[0]}"
while [ -L "${self}" ]; do
  self_dir="$(cd -P "$(dirname "${self}")" >/dev/null 2>&1 && pwd)"
  self="$(readlink "${self}")"
  [[ ${self} != /* ]] && self="${self_dir}/${self}"
done
self="$(readlink -f "${self}")"

self_dir="$(dirname "${self}")"
self_base_name=$(basename -- "$self")
self_base_name="${self_base_name%.*}"

env_file="${self_dir}/${self_base_name}.env."
if ! [ -e "${env_file}" ]; then
  echo "missing env file: ${env_file}"
  exit 1
fi

source "${env_file}"

lock_file="${self_dir}/${self_base_name}.lock"
if [ -e "${lock_file}" ]; then
  exit
fi
touch "${lock_file}"
trap '[ -e ${lock_file} ] && rm ${lock_file}' EXIT

state_file="${self_dir}/${self_base_name}.state"
projects=(11 13)
if ! [ -e "${state_file}" ]; then
  state=$(jq '.' <<< '{}')
  for project in "${projects[@]}"; do
    state=$(jq ". += { \"${project}\": { \"tickets\": [], \"interesting\": [] } }" <<< "${state}")
  done
  echo "${state}" > "${state_file}"
fi

state=$(jq '.' "${state_file}")

new_state=$(jq '.' <<< '{}')
for project in "${projects[@]}"; do
  project_state=$(jq '.' <<< '{}')
  ticket_state=$(gh project item-list "${project}" \
    --owner "tmz-apps" \
    --format json \
    --jq '.items[] | { status: .status, title: .title, url: .content.url, assignees: .assignees }' | jq -s '.')
  project_state=$(jq ".tickets = ${ticket_state}" <<< "${project_state}")
  interesting_state=$(jq --arg status "$(get_status_for_project "${project}")" '.[] | select(.status == $status) | select (.url != null) | .url' <<< "${ticket_state}" | jq -s '.')
  project_state=$(jq ".interesting = ${interesting_state}" <<< "${project_state}")
  new_state=$(jq ". += { \"${project}\": ${project_state} }" <<< "${new_state}")
done

is_interesting=false
for project in "${projects[@]}"; do
  if [ "${is_interesting}" = true ]; then
    break
  fi
  interesting=$(jq -r ".\"${project}\".interesting" <<< "${new_state}")
  old_interesting=$(jq -r ".\"${project}\".interesting" <<< "${state}")
  if [ "${interesting}" != "${old_interesting}" ]; then
    is_interesting=true
  fi
done

if [ "${is_interesting}" = false ]; then
    exit
fi

now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

old_state_file="${state_file}.${now}"
cp "${state_file}" "${old_state_file}"
jq '.' <<< "${new_state}" > "${state_file}"

patch_file="${state_file}.${now}.patch"
git diff <(cat "${old_state_file}") <(cat "${state_file}") > "${patch_file}"
cmd="iterm2:/command?c=echo%20'press%20enter'%20%26%26%20read%20line%3B%20bat%20$(realpath "${patch_file}")&d=$(dirname "${patch_file}")"

data=$(jq '.' <<< '{ "text": "test", "blocks": [ { "type": "section", "text": { "type": "mrkdwn" } } ] }')
data=$(jq --arg cmd "\`\`\`${cmd}\`\`\`" '.blocks[0].text.text = $cmd' <<< "${data}")
curl -X POST -H 'Content-type: application/json' --data "${data}" "${SLACK_WEBHOOK}"