#!/bin/bash

# bgp.tools files
# URL|Local file location|Expiry time in seconds

files=(
  [0]="https://bgp.tools/table.txt|/var/cache/bgp-tools/table.txt|7200"
  [1]="https://bgp.tools/asns.csv|/var/cache/bgp-tools/asns.csv|86400"
  [2]="https://bgp.tools/tags/gov.csv|/var/cache/bgp-tools/gov.csv|86400"
  [3]="https://bgp.tools/tags/icrit.csv|/var/cache/bgp-tools/icrit.csv|86400"
  [4]="https://bgp.tools/tags/dsl.csv|/var/cache/bgp-tools/dsl.csv|86400"
)

for file in "${files[@]}"; do
  IFS='|' read -r -a file_details <<< "$file"

  url="${file_details[0]}"
  local_file="${file_details[1]}"
  expiration="${file_details[2]}"

  current_time=$(date +%s)
  stale_time=$((current_time - expiration))

  if [ ! -f "$local_file" ] || [ $(stat -c %Y "$local_file") -lt $stale_time ]; then
    curl -A "bgp.tools cache script - contact@juggalol.com" -o "$local_file" "$url"
  fi
done
