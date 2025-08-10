#!/bin/bash
set -e
podman build -t openstack-networker -f ./networker/Containerfile .
podman build -t openstack-compute -f ./compute/Containerfile .
podman build -t openstack-storage -f ./storage/Containerfile .
podman build -t openstack-monitoring -f ./monitoring/Containerfile .
