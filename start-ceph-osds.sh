#!/bin/bash
# Run this inside the storage container
set -e
for i in 1 2 3; do
  fallocate -l 5G /var/lib/ceph-osd-$i.img
  losetup /dev/loop$i /var/lib/ceph-osd-$i.img
done
ceph-volume lvm create --data /dev/loop1
ceph-volume lvm create --data /dev/loop2
ceph-volume lvm create --data /dev/loop3
