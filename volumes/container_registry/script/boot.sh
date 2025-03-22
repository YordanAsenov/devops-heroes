#!/bin/sh
export REGISTRY_HTTP_SECRET=$(cat /run/secrets/registry_notification_secret)

exec /entrypoint.sh "/etc/docker/registry/config.yml" 