#!/bin/bash
set -e
podman build -t openstack-controller ./controller
podman build -t openstack-compute ./compute
podman build -t openstack-storage ./storage
