#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# todo: add logic for when it fails (reuse previous one)

readonly max_backups=14
readonly dest_dir='/mnt/storage.01/rsync/omv'
readonly latest_backup_link="$dest_dir/latest"
readonly datetime="$(date --utc +%FT%T.%3NZ)"
readonly current_backup_path="$dest_dir/$datetime"

! [ -d "$dest_dir" ] && mkdir -p "$dest_dir"

for file in $dest_dir/*; do
  filename=$(basename -- "$file")
  extension="${filename##*.}"
  filename="${filename%.*}"
  if [ "$extension" == 'lock' ]; then
    mv "$dest_dir/$filename" "$current_backup_path"
    rm "$file"
    break;
  fi
done

! [ -f "$current_backup_path.lock" ] && touch "$current_backup_path.lock"

rsync -aAHXxiv \
  --exclude="node_modules" \
  --exclude "vendor" \
  --exclude ".git" \
  --exclude ".Trash-1000" \
  --inplace \
  --numeric-ids \
  --delete \
  --progress \
  --bwlimit=10000 \
  -e "ssh -T -o Compression=no -x" \
  --link-dest "${latest_backup_link}" \
  hbot@192.168.1.100:/srv/dev-disk-by-uuid-61ecdf5e-a78f-4b90-bef8-f523d0cb9354/ \
  "$current_backup_path"

rm -rf "${latest_backup_link}"
ln -s "${current_backup_path}" "${latest_backup_link}"
rm "$current_backup_path.lock"

backups=0
while IFS= read -r -d '' backup
do
    [ 'omv' == "$(basename "$backup")" ] && continue
    ((backups+=1))
    [[ "$backups" -gt "$max_backups" ]] && rm -rf $(basename "$backup")
done < <(find "$dest_dir" -maxdepth 1 -type d -printf '%T@ %p\0' | sort -z -n -r)
