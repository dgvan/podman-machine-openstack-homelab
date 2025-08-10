#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <number_of_loops>"
  exit 1
fi

NUM_LOOPS=$1

for ((i=1; i<=NUM_LOOPS; i++)); do
  IMAGE="/var/lib/ceph${i}.img"
  LOOPDEV="/dev/loop${i}"

  if [ ! -f "$IMAGE" ]; then
    echo "Image file $IMAGE does not exist, creating."
    truncate -s 10G $IMAGE
  fi

  # Create loop device node if missing
  if [ ! -e "$LOOPDEV" ]; then
    echo "$LOOPDEV does not exist, creating..."
    mknod $LOOPDEV b 7 $i
    chmod 660 $LOOPDEV
    chown root:disk $LOOPDEV || true
  fi

  # Detach if loop device is busy
  if losetup $LOOPDEV &>/dev/null; then
    echo "$LOOPDEV is already in use, detaching..."
    losetup -d $LOOPDEV
  fi

  # Setup loop device with image
  echo "Setting up $LOOPDEV with $IMAGE"
  losetup $LOOPDEV $IMAGE

done

echo "All loop devices setup."
losetup -a | grep "/var/lib/ceph"
