#!/usr/bin/env bash

for var in "$@"
do
  echo "$var" | base64 -d
  echo
done
