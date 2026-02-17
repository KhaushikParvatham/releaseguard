#!/usr/bin/env bash
set -e

IMAGE_TAG=$1
ACTIVE_CONF="/tmp/nginx-upstreams/active.conf"

if [ -z "$IMAGE_TAG" ]; then
  echo "Image tag not provided"
  exit 1
fi

if [ ! -f "$ACTIVE_CONF" ]; then
  echo "Active upstream config not found"
  exit 1
fi

# Determine active color
if grep -q "releaseguard-blue" "$ACTIVE_CONF"; then
  ACTIVE="blue"
  INACTIVE="green"
else
  ACTIVE="green"
  INACTIVE="blue"
fi

echo "Active: $ACTIVE"
echo "Deploying new version to: $INACTIVE"

# Remove old inactive container if exists
docker rm -f releaseguard-$INACTIVE || true

# Start new container
docker run -d \
  --name releaseguard-$INACTIVE \
  --network releaseguard-net \
  -e APP_ENV=${APP_ENV} \
  releaseguard:$IMAGE_TAG

echo "Waiting for health check..."

# Health gate (60 seconds max)
for i in {1..12}; do
  if docker exec releaseguard-nginx \
    curl -sf http://releaseguard-$INACTIVE:3000/health > /dev/null; then

    echo "Health check passed"

    # Switch upstream
    cp nginx/upstreams/$INACTIVE.conf $ACTIVE_CONF
    docker exec releaseguard-nginx nginx -s reload

    echo "Traffic switched to $INACTIVE"

    # Remove old container
    docker rm -f releaseguard-$ACTIVE || true

    echo "Deployment successful"
    exit 0
  fi

  echo "Health not ready yet... retrying"
  sleep 5
done

echo "Health check failed — rolling back"

# Cleanup failed container
docker rm -f releaseguard-$INACTIVE || true

exit 1

