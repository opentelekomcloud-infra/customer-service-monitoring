#!/bin/bash
while sleep 60; do
  date
done | ssh ECS1 bash -c "cat > log1.txt"
if $?!=0 then echo "SSH connection was destroyed"
