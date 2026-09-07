#!/bin/bash

CONTAINER_NAME=$1

if [ -z "$CONTAINER_NAME" ]; then
    echo "Vui lòng nhập tên container!"
    exit 1
fi


echo -n "[1] IP Address: "
docker inspect "$CONTAINER_NAME" --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'

echo -n "[2] MAC Address: "
docker inspect "$CONTAINER_NAME" --format='{{range .NetworkSettings.Networks}}{{.MacAddress}}{{end}}'

echo -n "[3] Mounted Volumes: "
docker inspect "$CONTAINER_NAME" --format='{{range .Mounts}}{{.Source}} -> {{.Destination}}{{end}}' | grep . || echo "Không có volume"

echo -n "[4] Port Mappings: "
docker inspect "$CONTAINER_NAME" --format='{{range $port, $map := .NetworkSettings.Ports}}{{if $map}}{{$port}} -> Host: {{(index $map 0).HostPort}}{{end}}{{end}}' | grep . || echo "Không có port được map"

echo -n "[5] Env Variables: "
docker inspect "$CONTAINER_NAME" --format='{{json .Config.Env}}'

echo -n "[6] Network Mode: "
docker inspect "$CONTAINER_NAME" --format='{{.HostConfig.NetworkMode}}'

echo -n "[7] Restart Policy: "
docker inspect "$CONTAINER_NAME" --format='{{.HostConfig.RestartPolicy.Name}}'

echo -n "[8] Container PID: "
docker inspect "$CONTAINER_NAME" --format='{{.State.Pid}}'
echo ""