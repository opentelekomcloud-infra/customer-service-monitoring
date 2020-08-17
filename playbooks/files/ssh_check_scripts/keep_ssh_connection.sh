#!/bin/bash
date | ssh -i $1 $2 bash -c "cat > log1.txt"
