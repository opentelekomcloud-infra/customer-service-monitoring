#!/bin/bash
test -f data || dd if=/dev/urandom of=data bs=1M count=256
while sleep 10; do
    < data ssh ECS1 bash -c ‘cat > log2’
done
