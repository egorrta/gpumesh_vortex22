#!/bin/bash

cd $1 && \
eval "$(conda shell.bash hook)" && \
source ./env.sh && \
make -C $1/sims/verilator clean