#! /bin/bash

append=''
where='github'
app='web'
vendor='tmz'

display_help() {
  echo "
Available options:
  --pull-requests
   -pr                If you want to open the list of pull requests
  --branches
   -b                 If you want to open the list of branches
  --releases
   -r                 If you want to open the list of releases
  --labels
   -l                 If you want to open the list of labels
  --where
   -w                 github (default) or cms
  --help
   -h                 This message
"
}

for opt in "$@"; do
  case ${opt} in
  tmz | toofab)
    vendor=$opt
    shift
    ;;
  -pr | --pull-requests)
    append='pulls/'
    ;;
  -b | --branch)
    append='branches/'
    ;;
  -r | --releases)
    append='releases/'
    ;;
  -l | --labels)
    append='issues/labels/'
    ;;
  -w=* | --where=*)
    where="${opt#*=}"
    ;;
  -a=* | --app=*)
    app="${opt#*=}"
    ;;
  --help)
    display_help
    exit
    ;;
  *)
    display_help
    exit
    ;;
  esac
done

main() {
  if [ 'cms' == "$where" ]; then
    open -a "Brave Browser" -n --args --new-tab "https://cms.dev.$vendor.com/sys/flagsets/dev-$app"
    open -a "Brave Browser" -n --args --new-tab "https://cms.dev.$vendor.com/sys/flagsets/local-$app"
    open -a "Brave Browser" -n --args --new-tab "https://cms.test.$vendor.com/sys/flagsets/test-$app"
    open -a "Brave Browser" -n --args --new-tab "https://cms.test.$vendor.com/sys/flagsets/local-$app"
    open -a "Brave Browser" -n --args --new-tab "https://cms2.$vendor.com/sys/flagsets/prod-$app"
    exit
  fi

  repos=(amp api cms feeds ncr pbjx share web)
  for r in "${repos[@]}"; do
    open -a "Brave Browser" -n --args --new-tab "https://github.com/tmz-apps/$vendor-$r/$append"
  done

  if [ 'tmz' == "$vendor" ]; then
    open -a "Brave Browser" -n --args --new-tab "https://github.com/tmz-apps/$vendor-ovp/$append"
    open -a "Brave Browser" -n --args --new-tab "https://github.com/tmz-apps/$vendor-app/$append"
  fi
}

main "$@"
