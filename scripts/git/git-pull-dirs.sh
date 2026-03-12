#!/usr/bin/env bash
# Pulls latest changes in all git repositories in subdirectories

for d in */; do (cd "$d" && echo "$d" && git co main && git pull); done