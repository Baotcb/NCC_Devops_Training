#!/bin/bash

echo "giám sát các sự kiện Docker"
docker events --filter 'type=container' --filter 'event=die' --format '{{.Actor.Attributes.name}} {{.Actor.Attributes.exitCode}}' | while read container_name exit_code; do
    
    if [ "$exit_code" != "0" ] && [ ! -z "$exit_code" ]; then
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        alert_msg="[ALERT - $timestamp] Container '$container_name' vừa crash với Exit Code: $exit_code!"
        
        echo -e "\033[31m$alert_msg\033[0m"

         curl -s -H "Content-Type: application/json" -d "{\"content\": \"$alert_msg\"}" "https://webhook.mezon.ai/webhooks/2095396828265582592/MTc4ODQxNjUyMzA5NDE2NTQ4ODoyMDk1Mzk2Nzg2MTI5NjA0NjA4OjIwOTUzOTY4MjgyNjU1ODI1OTI6MjA5NTM5Njg4NTE5NDg3MDc4NA.w7F1OOY5kdc-LHBfwSbmKhEcOCwIvSf_Am6u14EF81U" > /dev/null
        
       
    fi
done