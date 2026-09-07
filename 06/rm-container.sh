#!/usr/bin/env bash

set -euo pipefail

container_name="myapp"


docker rm -f "$container_name" 2>/dev/null || true
docker run -d --name "$container_name" nginx
