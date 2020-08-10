#!/bin/bash
while sleep 60; do
  date
done | ssh $1 bash -c "cat > log1.txt"
