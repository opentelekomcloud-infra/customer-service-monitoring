#!/bin/bash
date | ssh $1 bash -c "cat > log1.txt"
