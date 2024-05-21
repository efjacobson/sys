#!/usr/bin/env bash

main() {
    cd "${SPHYNX_ROOT}" || exit 1
    file_name="${1}"

    pw=
    if [ -z "${pw}" ]; then
        if ! read -r -s -p '[pwmod] unlock: ' pw; then
            echo '[pwmod] fail:read'
            exit 1
        fi
    fi

    contents=$(7z x -so "./${file_name}.7z" -p"${pw}")
    [ -z "${contents}" ] && echo '[pwmod] fail:7z:x' && exit 1

    work_dir=$(mktemp -d)
    sum=$(sha256sum <<< "${contents}" | cut -d' ' -f1)
    echo "${contents}" > "${work_dir}/${file_name}"
    if ! nano "${work_dir}/${file_name}"; then
        echo '[pwmod] fail:nano'
        rm -rf "${work_dir}"
        exit 1
    fi

    if [ "${sum}" == "$(sha256sum "${work_dir}/${file_name}" | cut -d' ' -f1)" ]; then
        echo '[pwmod] success (unchanged)'
        rm -rf "${work_dir}"
        exit 0
    fi

    mv "./${file_name}".7z "${work_dir}/${file_name}.7z"
    if 7z a "./${file_name}".7z "${work_dir}/${file_name}" -p"${pw}" -mhe=on; then
        echo '[pwmod] success (updated)'
    else
        mv "${work_dir}/${file_name}.7z" "./${file_name}".7z
        echo '[pwmod] fail:7z:a'
    fi
    rm -rf "${work_dir}"
}

if [ -z "${SPHYNX_ROOT}" ]; then
    echo 'no SPHYNX_ROOT!'
    exit 1
fi

main "${@}"
