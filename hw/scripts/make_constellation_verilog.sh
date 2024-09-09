#!/bin/bash

cd /home/user/poly/gpumesh_global/chipyard && \
eval "$(conda shell.bash hook)" && \
source ./env.sh && \
make -C /home/user/poly/gpumesh_global/chipyard/sims/verilator -B /home/user/poly/gpumesh_global/chipyard/sims/verilator/generated-src/gpumesh.test.TestHarness.TLMesh01/sim_files.common.f SUB_PROJECT=gpumesh BINARY=none CONFIG=TLMesh01