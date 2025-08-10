#!/bin/bash
set -e
sudo podman build -t openstack-controller -f ./controller/Containerfile .
sudo podman build -t openstack-compute -f ./compute/Containerfile .
sudo podman build -t openstack-storage -f ./storage/Containerfile .
