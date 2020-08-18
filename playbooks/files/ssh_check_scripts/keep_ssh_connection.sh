#!/bin/bash
date | ssh -i $1 $2  "cat > log1.txt"
