#!/usr/bin/env bash

set -euo pipefail

container_name="myapp"


docker run --rm -d --name "$container_name" nginx
