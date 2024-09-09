#!/bin/bash

cd $1 && \
eval "$(conda shell.bash hook)" && \
source ./env.sh && \
make -C $1/sims/verilator -B $1/sims/verilator/generated-src/gpumesh.test.TestHarness.TLMesh01/sim_files.common.f SUB_PROJECT=gpumesh BINARY=none CONFIG=TLMesh01