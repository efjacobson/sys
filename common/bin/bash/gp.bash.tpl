IFS=' '
while read local_ref local_sha remote_ref remote_sha; do
	while read -r sha; do
		if git log --format=%B -n 1 "${sha}" | grep -q -E '(^|\s)(wip|temp(orary)?)($|\s)'; then
			echo 'temp commit found' && exit 1
		fi
		if ! git verify-commit $commit >/dev/null 2>&1; then
			echo 'unsigned commit found' && exit 1
		fi
	done < <(git rev-list "${remote_sha}..${local_sha}")
done