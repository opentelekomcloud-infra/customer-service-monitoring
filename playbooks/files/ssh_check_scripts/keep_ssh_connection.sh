#!/bin/bash
date | ssh -i $1 $2 bash  "cat > log1.txt"
