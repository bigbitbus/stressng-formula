#!/bin/bash
set -e
cd /tmp
tar xf stress-ng-*
cd /tmp/stress-ng-*
make
cp stress-ng /usr/bin
cd /tmp
rm -rf /tmp/stress-*
