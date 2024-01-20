#! /bin/bash

convert_time() {
  brief=false
  [[ $1 = "-b" ]] && shift && brief=true

  ((w=${1}/604800))
  ((d=(${1}%604800)/86400))
  ((h=(${1}%86400)/3600))
  ((m=(${1}%3600)/60))
  ((s=${1}%60))

  narrative=()
  list[0]="$w week"
  list[1]="$d day"
  list[2]="$h hour"
  list[3]="$m minute"
  list[4]="$s second"
  for (( component=0; $component < ${#list[@]}; ++component )); do
      # Strip the verbage to get the number
      val="${list[$component]/ [a-z]*}"
      if [[ "$val" -gt 0 ]]; then
          if [[ "$val" -gt 1 ]]; then
              list[$component]+='s'
          fi
          narrative+=( "${list[$component]}" )
      fi
  done

  if $brief; then
      if [[ ${#narrative[@]} -eq 0 ]]; then
          echo "Now"
      else
          echo "About ${narrative[0]}"
      fi
  else
      if [[ ${#narrative[@]} -eq 0 ]]; then
          echo "Now"
      elif [[ ${#narrative[@]} -eq 1 ]]; then
          echo "${narrative[0]}"
      elif [[ ${#narrative[@]} -eq 2 ]]; then
          echo "${narrative[0]} and ${narrative[1]}"
      else
          for (( index=0; $index < $((${#narrative[@]}-1)); ++index )); do
              echo -n "${narrative[$index]}, "
          done
          echo "and ${narrative[$(( ${#narrative[@]}-1))]}"
      fi
  fi
}

self="${BASH_SOURCE[0]}"
while [ -L "${self}" ]; do
    self_dir="$(cd -P "$(dirname "${self}")" >/dev/null 2>&1 && pwd)"
    self="$(readlink "${self}")"
    [[ ${self} != /* ]] && self="${self_dir}/${self}"
done
self="$(readlink -f "${self}")"

for d in /home/*; do
  user="$(basename "$d")"
  break
done

logfile="/home/${user}/_/log/sleep.yaml"

if ! [ -e "${logfile}" ]; then
  echo '[]' > "${logfile}"
fi

what="${1}:${2}"
when="$(date +%s)"

item="$(yq -r '.' <<< '{}')"
item="$(yq -r --arg what "${what}" '. += {what:$what}' <<< "${item}")"
item="$(yq -r --arg when "${when}" '. += {when:$when|tonumber}' <<< "${item}")"

length=$(yq '. | length' "${logfile}")
if [ -n "${length}" ] && [ "${length}" -gt 0 ]; then
  lastIndex=$((length - 1))
  lastWhat=$(yq -r ".[${lastIndex}].what" "${logfile}")
  if [ "${lastWhat}" == 'pre:suspend-then-hibernate' ] && [ "${what}" == 'post:suspend-then-hibernate' ]; then
    lastWhen=$(yq ".[${lastIndex}].when" "${logfile}")
    elapsed=$((when - lastWhen))
    elapsedText=$(convert_time "${elapsed}")
    item="$(yq -r --arg elapsed "${elapsedText}" '. += {elapsed:$elapsed}' <<< "${item}")"
  fi
fi

log="$(yq '.' "${logfile}")"
percentage=$(upower -i "$(upower -e | grep battery)" | grep percentage | tr -d ' ' | cut -d':' -f2)
item="$(yq -r --arg percentage "${percentage}" '. += {percentage:$percentage}' <<< "${item}")"
item="$(yq -r --arg reporter "${self}" '. += {reporter:$reporter}' <<< "${item}")"
log="$(yq -y --argjson item "${item}" '. += [$item]' <<< "${log}")"

# log="$(
#   yq -y \
#     --arg percentage "${percentage}" \
#     --arg what "${1}:${2}" \
#     --arg when "$(date +%s)" \
#     --arg reporter "${self}" \
#     '. += [{percentage:$percentage,reporter:$reporter,what:$what,when:$when|tonumber}]' \
#   <<< "${log}" \
# )"

yq -y '.' <<< "${log}" > "${logfile}"
