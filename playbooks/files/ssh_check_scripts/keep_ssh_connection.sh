#!/bin/bash
while sleep 60; do
  date
done | ssh -i $1 $2  "cat > log1.txt"
