#! /bin/bash

# todo: add clobber protection

function main() {
  input_file_path="$1"
  if [ '' == "$input_file_path" ]; then
    echo 'enter the path to the json file you want to convert to yaml'
    exit 1
  fi

  if [ ! -f "$input_file_path" ]; then
    echo "file '$input_file_path' does not exist"
    exit 1
  fi

  extension="${input_file_path##*.}"
  regex="^(json|ya?ml)$"
  if [[ ! $extension =~ $regex ]]; then
    echo 'that file is neither json nor yaml..'
    exit 1
  fi

  directory="$(dirname "$input_file_path")"
  file_name=$(basename -- "$input_file_path")
  file_name="${file_name%.*}"
  output_file_path="$directory/$file_name"

  if [ 'json' == "$extension" ]; then
    output_file_path="$output_file_path.yaml"
    jq '.' "$input_file_path" | yq -y >"$output_file_path"
  else
    output_file_path="$output_file_path.json"
    yq '.' "$input_file_path" >"$output_file_path"
  fi

  prettier -w --loglevel warn "$output_file_path"
  exit 0
}

main "$@"
