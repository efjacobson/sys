#! /usr/bin/env bash
set -e

main() {
  options=
  if [ '--dry-run=false' != "$1" ]; then
    options='--pretend'
  fi

  secsize=512
  one_MiB=$((1024 * 1024))
  one_GiB=$((one_MiB * 1024))
  buffer=$((one_MiB * 128))
  buffer=$((buffer / secsize))

  declare -A unordered
  declare -a ordered
  unordered[4]=3
  ordered+=("4")
  unordered[8]=2
  ordered+=("8")
  unordered[16]=2
  ordered+=("16")
  unordered[400]=1
  ordered+=("400")

  driveA=/dev/disk/by-id/ata-WDC_WD5000LPLX-75ZNTT0_WXD1E85ESJJ7
  driveB=/dev/disk/by-id/ata-ST9500420AS_5VJ0F7VY
  declare -A drives
  drives[A]="$driveA"
  drives[B]="$driveB"

  for letter in "${!drives[@]}"; do
    disk="${drives[$letter]}"

    cmd="sgdisk $options --zap-all $disk"
    echo "$cmd"
    output=$($cmd)
    echo "${output}"

    cmd="sgdisk $options --clear $disk"
    echo "$cmd"
    output=$($cmd)
    echo "${output}"

    start=4096
    end=
    i=1
    for size_in_GB in "${ordered[@]}"; do
      num=${unordered[$size_in_GB]}
      for j in $(eval echo "{1..$num}"); do
        end=$((one_GiB * size_in_GB))
        end=$((end / secsize))
        end=$((end + start))

        cmd="sgdisk $options --new $i:$start:$end $disk"
        echo "$cmd"
        output=$($cmd)
        echo "${output}"

        if [ '400' == "$size_in_GB" ]; then # lame
          label='rust'
          append=''
        else
          label='swap'
          append=".$j"
        fi
        cmd="sgdisk $options --change-name $i:$label.$letter.${size_in_GB}${append} $disk"

        echo "$cmd"
        output=$($cmd)
        echo "${output}"

        start=$((end + buffer))
        i=$((i + 1))
      done
    done
  done
}

main "$1"
