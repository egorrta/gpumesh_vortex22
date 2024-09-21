#!/bin/bash

cd $1 && \
eval "$(conda shell.bash hook)" && \
source ./env.sh && \
make -C $1/sims/verilator -B $4/sim_files.common.f SUB_PROJECT=$2 BINARY=none CONFIG=$3