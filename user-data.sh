#!/bin/bash
set -u

cpu_count=$(getconf _NPROCESSORS_ONLN)
pids=()

for ((i = 0; i < cpu_count; i++)); do
  timeout 900 bash -c 'while :; do :; done' &
  pids+=("$!")
done

for pid in "${pids[@]}"; do
  wait "$pid"
  status=$?
  if [ "$status" -ne 0 ] && [ "$status" -ne 124 ]; then
    echo "CPU load worker $pid failed with status $status" >&2
    exit "$status"
  fi
done
