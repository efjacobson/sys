#!/usr/bin/env bash
set -e

command -v xmllint >/dev/null 2>&1 || { echo "xmllint required" >&2; exit 1; }

display_help() {
  echo "fiximl - fix PHPStorm .iml configuration for tmz projects

Usage: fiximl [OPTION]... [DIR]

Fix sourceFolder and excludeFolder entries in the module's .iml file.
DIR defaults to the current directory.

  -h, --help        display this help and exit
  -d, --dry-run     show changes without modifying files
  -v, --verbose     verbose output
      --schemas     add schemas directories as sources (default: exclude)
"
}

dry_run=false
verbose=false
include_schemas=false
args=()
for opt in "$@"; do
  case ${opt} in
  -d | --dry-run)
    dry_run=true
    ;;
  --verbose | -v)
    verbose=true
    ;;
  --schemas)
    include_schemas=true
    ;;
  --help | -h)
    display_help
    exit 0
    ;;
  -*)
    display_help
    echo "unknown option: ${opt}" >&2
    exit 1
    ;;
  *)
    args+=("$opt")
    ;;
  esac
done

main() {
	local dir
	if [ "$#" -gt 1 ]; then
		echo "too many arguments" >&2
		exit 1
	fi
	if [ "$#" -ne 1 ]; then
		dir="$(pwd)"
	else
		dir="$1"
	fi

	if ! [ -d "${dir}" ]; then
		echo "Directory does not exist: ${dir}" >&2
		exit 1
	fi

	local repo
	repo=$(basename "${dir}")
	if [[ ! "${repo}" =~ ^tmz-(web|api|feeds|share|amp)$ ]]; then
		echo "invalid directory: ${dir}" >&2
		exit 1
	fi

	local config_file
	config_file="${dir}/.idea/${repo}.iml"
	if ! [ -e "${config_file}" ]; then
		echo "iml file does not exist: $config_file" >&2
		exit 1
	fi

	local vendor
	vendor=$(cut -d'-' -f1 <<< "${repo}")

	local temp
	temp=$(mktemp "${TMPDIR:-/tmp}/fiximl.XXXXXX")
	trap 'rm -f "'"$temp"'"' EXIT

	cp "${config_file}" "${temp}"

	local temp2
	temp2=$(mktemp "${TMPDIR:-/tmp}/fiximl.XXXXXX")
	xmllint --format "${temp}" | sed -e '/<sourceFolder.*\/>/d' -e '/<excludeFolder.*\/>/d' >"${temp2}"
	mv "${temp2}" "${temp}"

	local new_lines
	new_lines=$'      <sourceFolder url="file://$MODULE_DIR$/src" isTestSource="false" packagePrefix="App\\\\" />\n'
	new_lines+=$'      <sourceFolder url="file://$MODULE_DIR$/tests" isTestSource="true" packagePrefix="App\\\\Tests\\\\" />\n'
	new_lines+=$'      <sourceFolder url="file://$MODULE_DIR$/vendor/gdbots" isTestSource="false" />\n'
	new_lines+=$'      <sourceFolder url="file://$MODULE_DIR$/vendor/triniti" isTestSource="false" />\n'
	new_lines+="      <sourceFolder url=\"file://\$MODULE_DIR\$/vendor/${vendor}\" isTestSource=\"false\" />"$'\n'
	new_lines+=$'      <excludeFolder url="file://$MODULE_DIR$/var" />\n'

	if [ -d "${dir}/public" ]; then
		new_lines+=$'      <excludeFolder url="file://$MODULE_DIR$/public/client" />\n'
	fi

	if [ -d "${dir}/vendor" ]; then
		if $include_schemas; then
			new_lines+=$'      <sourceFolder url="file://$MODULE_DIR$/vendor/gdbots/schemas" isTestSource="false" />\n'
			new_lines+=$'      <sourceFolder url="file://$MODULE_DIR$/vendor/triniti/schemas" isTestSource="false" />\n'
			new_lines+="      <sourceFolder url=\"file://\$MODULE_DIR\$/vendor/${vendor}/schemas\" isTestSource=\"false\" />"$'\n'
		else
			new_lines+=$'      <excludeFolder url="file://$MODULE_DIR$/vendor/gdbots/schemas" />\n'
			new_lines+=$'      <excludeFolder url="file://$MODULE_DIR$/vendor/triniti/schemas" />\n'
			new_lines+="      <excludeFolder url=\"file://\$MODULE_DIR\$/vendor/${vendor}/schemas\" />"$'\n'
		fi

		for dependency in "${dir}/vendor"/*; do
			if [ -d "${dependency}" ]; then
				base_dependency=$(basename "${dependency}")
				if [[ "${base_dependency}" != "${vendor}" && ! "${base_dependency}" =~ ^(gdbots|triniti)$ ]]; then
					new_lines+="      <excludeFolder url=\"file://\$MODULE_DIR\$/vendor/${base_dependency}\" />"$'\n'
				fi
			fi
		done
	fi

	awk -v nlines="$new_lines" '/<\/content>/ {print nlines} 1' "${temp}" >"${temp}.new"
	mv "${temp}.new" "${temp}"

	if ! xmllint --noout "${temp}"; then
		echo "XML validation failed" >&2
		exit 1
	fi

	if $dry_run; then
		diff <(xmllint --format "${config_file}") <(xmllint --format "${temp}")
		exit 0
	fi

	$verbose && echo "Updating ${config_file}" >&2
	xmllint --format "${temp}" >"${config_file}"
}

main "${args[@]}"
