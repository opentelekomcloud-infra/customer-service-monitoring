#!/bin/bash
for i in {7000..7009}
do
  while netcat -lp $i
    do echo "port $i terminated"
    done
done
