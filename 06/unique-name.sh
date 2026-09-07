#!/usr/bin/env bash

set -euo pipefail

suffix="$(date +%Y%m%d-%H%M%S)-$RANDOM"
container_name="myapp-$suffix"

docker run -d --name "$container_name" nginx
printf 'Created container: %s\n' "$container_name"
