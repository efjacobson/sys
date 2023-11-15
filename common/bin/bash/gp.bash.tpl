IFS=' '
while read local_ref local_sha remote_ref remote_sha
do
	while read -r sha; do git log --format=%B -n 1 "${sha}" | grep -q temp && echo 'temp commit found' && exit 1; done < <(git rev-list "${remote_sha}..${local_sha}")
done