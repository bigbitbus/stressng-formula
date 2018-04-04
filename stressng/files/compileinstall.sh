#!/bin/bash
set -E
cd /tmp/stress-ng-*
STATIC=1 make
cp stress-ng /usr/bin
cd /tmp
rm -rf /tmp/stress-*
stress-ng #To test successful installation for stateful
