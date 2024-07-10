#! /usr/bin/env bash
set -e

diff=$(git diff --diff-filter=dr "${@}")

files=()
while read -r file; do
    files+=("${file}")
    git add "${file}"
done < <(git ls-files . --exclude-standard --others)

if [[ "${#files[@]}" -ne 0 ]]; then
    diff+="
"
    diff+=$(git diff --cached)
    for file in "${files[@]}"; do
        git reset HEAD > /dev/null 2>&1 "${file}"
    done
fi

has_quote=false
ignore_next=false;
pager=
for token in $(git var GIT_PAGER); do
    if $ignore_next; then
        ignore_next=false
        continue;
    fi
    if [[ "${token}" == "--width" ]]; then
        ignore_next=true
        continue;
    fi
    if [ "'" == "${token:0:1}" ]; then
        has_quote=true
    fi
    if [ -z "${pager}" ]; then
        pager="${token}"
    else
        pager="${pager} ${token}"
    fi
done

if $has_quote && [ "'" != "${pager:-1}" ]; then
    pager="${pager}'"
fi
eval "${pager}" <<< "${diff}"