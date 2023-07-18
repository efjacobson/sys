#! /bin/bash

#echo "${1}"
#echo "${2}"
#exit 0
# JSON.stringify(Array.from(document.querySelector('html body div.container form#update div#version_info.form-row div.form-group.col-sm-6 select#version.form-control').children).reduce((acc, child) =>  {if (child.value !== 'Choose Version') {acc.push(child.value)} return acc}, []))
# '["v1.1.10","v1.10.1","v1.10.2","v1.10.4","v1.10.4-rc1","v1.11.0","v1.11.4","v1.11.4-DNSfix","v1.11.7","v1.11.8","v1.12","v1.12.1","v1.13.0","v1.5.10","v1.5.6","v1.5.7","v1.5.8","v1.5.9","v1.6.0","v1.6.1","v1.6.2","v1.7.0","v1.8.0","v1.8.1","v1.8.2","v1.8.3","v1.8.4","v1.8.5","v1.9.0","v1.9.2","v1.9.3","v1.9.4"]'

mkdir "${1}"
cd "${1}" || exit

while read -r version; do
    mkdir "${version}"
    cd "${version}" || exit
    wget "http://archive.shelly-tools.de/version/${version}/${1}.zip"
    cd ..
done < <(echo "$2" | jq -r '.[]')
#done < <(echo '["v1.1.10","v1.10.1","v1.10.2","v1.10.4","v1.10.4-rc1","v1.11.0","v1.11.4","v1.11.4-DNSfix","v1.11.7","v1.11.8","v1.12","v1.12.1","v1.13.0","v1.5.10","v1.5.6","v1.5.7","v1.5.8","v1.5.9","v1.6.0","v1.6.1","v1.6.2","v1.7.0","v1.8.0","v1.8.1","v1.8.2","v1.8.3","v1.8.4","v1.8.5","v1.9.0","v1.9.2","v1.9.3","v1.9.4"]' | jq -r '.[]')
