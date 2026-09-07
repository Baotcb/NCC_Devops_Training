#!/bin/bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-python:3.11-slim}"

if ! command -v docker >/dev/null 2>&1; then
    echo "Lỗi: Docker chưa được cài đặt hoặc chưa có trong PATH."
    exit 1
fi

if ! command -v jq >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
    echo "Lỗi: Script yêu cầu 'jq' hoặc 'python3' để xử lý JSON. Vui lòng cài đặt jq hoặc Python trước."
    exit 1
fi

if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "Image $IMAGE_NAME không tồn tại. Đang tải về..."
    docker pull "$IMAGE_NAME"
fi


if command -v jq >/dev/null 2>&1; then
    LAYERS_JSON=$(docker history --format '{{json .}}' "$IMAGE_NAME" | jq -s 'map({Size: .Size, CreatedBy: .CreatedBy})')

    docker inspect "$IMAGE_NAME" | jq --argjson layers "$LAYERS_JSON" '.[0] | {
      "BaseImage_OS": (.Os + "/" + .Architecture),
      "WorkDir": (if .Config.WorkingDir == "" then "/" else .Config.WorkingDir end),
      "ExposedPorts": (if .Config.ExposedPorts == null then [] else (.Config.ExposedPorts | keys) end),
      "EnvironmentVariables": .Config.Env,
      "Cmd": (if .Config.Cmd == null then [] else .Config.Cmd end),
      "Entrypoint": (if .Config.Entrypoint == null then null else .Config.Entrypoint end),
      "CreatedDate": .Created,
      "Layers": $layers
    }' > image_info.json
else
    PYTHON_BIN="$(command -v python3 || command -v python)"
    "$PYTHON_BIN" - "$IMAGE_NAME" <<'PY'
import json
import subprocess
import sys

image = sys.argv[1]

inspect_data = json.loads(subprocess.check_output(["docker", "inspect", image], text=True))
image_info = inspect_data[0]
config = image_info.get("Config") or {}

history_output = subprocess.check_output(["docker", "history", "--format", "{{json .}}", image], text=True)
layer_entries = []
for line in history_output.splitlines():
    line = line.strip()
    if not line:
        continue
    try:
        item = json.loads(line)
    except json.JSONDecodeError:
        continue
    layer_entries.append({
        "Size": item.get("Size"),
        "CreatedBy": item.get("CreatedBy")
    })

payload = {
    "BaseImage_OS": f"{image_info.get('Os', '')}/{image_info.get('Architecture', '')}",
    "WorkDir": config.get("WorkingDir") or "/",
    "ExposedPorts": list((config.get("ExposedPorts") or {}).keys()),
    "EnvironmentVariables": config.get("Env"),
    "Cmd": config.get("Cmd") or [],
    "Entrypoint": config.get("Entrypoint"),
    "CreatedDate": image_info.get("Created"),
    "Layers": layer_entries,
}

print(json.dumps(payload, ensure_ascii=False, indent=2))
PY
    > image_info.json
fi

echo "Toàn bộ thông tin đã được xuất ra file: image_info.json"