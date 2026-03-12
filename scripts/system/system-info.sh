#!/usr/bin/env bash

set -euo pipefail

echo "System Information"
echo "-------------------"

echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "Kernel: $(uname -r)"

echo ""
echo "CPU:"
lscpu | grep "Model name"

echo ""
echo "Memory:"
free -h

echo ""
echo "Disk:"
df -h

echo ""
echo "Top Processes:"
ps aux --sort=-%mem | head
