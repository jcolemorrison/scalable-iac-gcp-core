#!/bin/bash
apt-get update
apt-get install -y nutcracker
mkdir -p /etc/nutcracker
mkdir -p /run/nutcracker
echo 'alpha:
  listen: 0.0.0.0:6379
  redis: true
  servers:
  - ${REDIS_HOST}:6379:1' > /etc/nutcracker/nutcracker.yml
nutcracker -d -c /etc/nutcracker/nutcracker.yml