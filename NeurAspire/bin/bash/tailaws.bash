#! /bin/bash

main() {
  tailed_log="$1"
  aws logs tail /tmz-web/prod --profile wb-tmz --region us-east-1 --follow --filter-pattern 'GET "200 -"'
}

main "$1"
