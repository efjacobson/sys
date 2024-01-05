#! /bin/bash

file_name="${1}"
shift

key='password'
vendor=
list=
for opt in "$@"; do
    case ${opt} in
        --key=*)
            key="${opt#*=}"
            ;;
        --vendor=*)
            vendor="${opt#*=}"
            ;;
        --list)
            list=1
            ;;
        -l)
            list=1
            ;;
        *)
            echo "unknown option: ${opt}"
            exit 1
            ;;
    esac
done

clear_clipboard() {
    sleep 15
    pbcopy </dev/null
}

main() {
    cd "${SPHYNX_ROOT}" || exit 1

    printf '[pw] unlock: '
    creds=$(7z x -so "./${file_name}.7z")
    [ -z "${creds}" ] && echo '[pw] fail:7z' && exit 1

    if [ -n "${list}" ]; then
        options=$(yq -r 'keys[]' <<<"${creds}")
        while read -r option; do
            username=$(yq -r --arg option "${option}" '.[$option].username' <<<"${creds}")
            if [ "${username}" == 'null' ]; then
                echo "[pw] ${option}"
            else
                echo "[pw] ${option}:${username}"
            fi
        done <<<"${options}"
        exit 0
    fi

    if [ -z "${vendor}" ]; then
        if ! read -r -p '[pw] vendor? ' vendor; then
            echo '[pw] fail:read:vendor'
            exit 1
        fi
    fi

    pw=$(yq -r --arg vendor "${vendor}" --arg key "${key}" '.[$vendor].[$key]' <<<"${creds}")
    [ "${pw}" = 'null' ] && echo "[pw] fail: key \"${key}\" not found for vendor \"${vendor}\"" && exit 1

    pbcopy < <(tr -d '\n' <<<"${pw}") && echo '[pw] success (copied to clipboard)'
    (clear_clipboard &)
}

if [ -z "${SPHYNX_ROOT}" ]; then
    echo 'no SPHYNX_ROOT!'
    exit 1
fi

main "${@}"
