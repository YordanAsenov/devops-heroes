#!/bin/sh

# Set the notification headers correctly - Docker Registry expects a specific format
SECRET=$(cat /run/secrets/registry_notification_secret)
export REGISTRY_NOTIFICATIONS_ENDPOINTS_0_HEADERS="{\"Authorization\":[\"bearer $SECRET\"]}"

# Set HTTP secret to prevent warning
export REGISTRY_HTTP_SECRET=$(cat /run/secrets/registry_notification_secret)

# Start the registry with the default configuration
exec /entrypoint.sh "/etc/docker/registry/config.yml" 