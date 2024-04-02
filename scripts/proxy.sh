#!/bin/bash
apt-get update
apt-get install -y build-essential autoconf automake libtool git
git clone https://github.com/twitter/twemproxy.git
cd twemproxy
autoreconf -fvi
./configure --enable-debug=log
make
make install
mkdir -p /etc/nutcracker
echo 'alpha:
  listen: 0.0.0.0:6379
  redis: true
  servers:
  - ${REDIS_HOST}:6379:1' > /etc/nutcracker/nutcracker.yml
nutcracker -d -c /etc/nutcracker/nutcracker.yml