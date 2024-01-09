#!/bin/bash

set -e

ls -ltr

touch example.txt

echo "Before wrong command"

lsfff    #here this script will stop/exit as given set -e

echo "After wrong command"

cd /tmp

cd /home/centos
