#!/bin/bash
set -e
podman build -t openstack-controller -f ./controller/Containerfile .
podman build -t openstack-compute -f ./compute/Containerfile .
podman build -t openstack-storage -f ./storage/Containerfile .
