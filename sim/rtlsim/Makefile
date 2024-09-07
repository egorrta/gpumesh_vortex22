include ../common.mk

DESTDIR ?= $(CURDIR)

SRC_DIR = $(VORTEX_HOME)/sim/rtlsim

MESH_DIR = /home/user/poly/gpumesh_global/chipyard/sims/verilator/generated-src/gpumesh.test.TestHarness.TLMesh01

CXXFLAGS += -std=c++17 -Wall -Wextra -Wfatal-errors -Wno-array-bounds
CXXFLAGS += -fPIC -Wno-maybe-uninitialized
CXXFLAGS += -I$(ROOT_DIR)/hw -I$(COMMON_DIR)
CXXFLAGS += -I$(THIRD_PARTY_DIR)/softfloat/source/include
CXXFLAGS += -I$(THIRD_PARTY_DIR)/ramulator/ext/spdlog/include
CXXFLAGS += -I$(THIRD_PARTY_DIR)/ramulator/ext/yaml-cpp/include
CXXFLAGS += -I$(THIRD_PARTY_DIR)/ramulator/src
CXXFLAGS += -DXLEN_$(XLEN)

LDFLAGS += $(THIRD_PARTY_DIR)/softfloat/build/Linux-x86_64-GCC/softfloat.a
LDFLAGS += -Wl,-rpath,$(THIRD_PARTY_DIR)/ramulator  -L$(THIRD_PARTY_DIR)/ramulator -lramulator

# control RTL debug tracing states
DBG_TRACE_FLAGS += -DDBG_TRACE_PIPELINE
DBG_TRACE_FLAGS += -DDBG_TRACE_MEM
DBG_TRACE_FLAGS += -DDBG_TRACE_CACHE
DBG_TRACE_FLAGS += -DDBG_TRACE_AFU
DBG_TRACE_FLAGS += -DDBG_TRACE_SCOPE
DBG_TRACE_FLAGS += -DDBG_TRACE_GBAR

DBG_FLAGS += -DDEBUG_LEVEL=$(DEBUG) -DVCD_OUTPUT $(DBG_TRACE_FLAGS)

RTL_PKGS = $(RTL_DIR)/VX_gpu_pkg.sv $(RTL_DIR)/fpu/VX_fpu_pkg.sv $(RTL_DIR)/core/VX_trace_pkg.sv

FPU_INCLUDE = -I$(RTL_DIR)/fpu
ifneq (,$(findstring FPU_FPNEW,$(CONFIGS)))
	RTL_PKGS += $(THIRD_PARTY_DIR)/fpnew/src/fpnew_pkg.sv $(THIRD_PARTY_DIR)/fpnew/src/common_cells/src/cf_math_pkg $(THIRD_PARTY_DIR)/fpnew/src/fpu_div_sqrt_mvp/hdl/defs_div_sqrt_mvp.sv
	FPU_INCLUDE += -I$(THIRD_PARTY_DIR)/fpnew/src/common_cells/include -I$(THIRD_PARTY_DIR)/fpnew/src/common_cells/src -I$(THIRD_PARTY_DIR)/fpnew/src/fpu_div_sqrt_mvp/hdl -I$(THIRD_PARTY_DIR)/fpnew/src
endif
RTL_INCLUDE = -I$(RTL_DIR) -I$(DPI_DIR) -I$(RTL_DIR)/libs -I$(RTL_DIR)/interfaces -I$(RTL_DIR)/core -I$(RTL_DIR)/mem -I$(RTL_DIR)/cache $(FPU_INCLUDE)

SRCS = $(COMMON_DIR)/util.cpp $(COMMON_DIR)/mem.cpp $(COMMON_DIR)/rvfloats.cpp $(COMMON_DIR)/dram_sim.cpp
SRCS += $(DPI_DIR)/util_dpi.cpp $(DPI_DIR)/float_dpi.cpp
SRCS += $(SRC_DIR)/processor.cpp

ifdef AXI_BUS
	TOP = Vortex_axi
	CXXFLAGS += -DAXI_BUS
else
	TOP = Vortex
endif

VL_FLAGS = --exe
VL_FLAGS += --language 1800-2009 -Wno-context -Wno-fatal -Wno-lint -Wno-style
#VL_FLAGS += --language 1800-2009 --assert -Wall -Wpedantic #-Wno-unused
VL_FLAGS += -Wno-DECLFILENAME -Wno-REDEFMACRO 
VL_FLAGS += --x-initial unique --x-assign unique
VL_FLAGS += $(SRC_DIR)/verilator.vlt
VL_FLAGS += -DSIMULATION -DSV_DPI
VL_FLAGS += -DXLEN_$(XLEN)
VL_FLAGS += $(CONFIGS)
VL_FLAGS += $(RTL_INCLUDE)
VL_FLAGS += $(RTL_PKGS)
VL_FLAGS += --cc $(TOP) --top-module $(TOP)

CXXFLAGS += $(CONFIGS)

# Enable Verilator multithreaded simulation
THREADS ?= $(shell python -c 'import multiprocessing as mp; print(mp.cpu_count())')
VL_FLAGS += -j $(THREADS)
#VL_FLAGS += --threads $(THREADS)

# Debugging
ifdef DEBUG
	VL_FLAGS += --trace --trace-structs $(DBG_FLAGS)
	CXXFLAGS += -g -O0 $(DBG_FLAGS)
else
	VL_FLAGS += -DNDEBUG
	CXXFLAGS += -O2 -DNDEBUG
endif

# Enable perf counters
ifdef PERF
	VL_FLAGS += -DPERF_ENABLE
	CXXFLAGS += -DPERF_ENABLE
endif

PROJECT := rtlsim

FROM_CONSTELLATION := -f $(MESH_DIR)/sim_files.common.f \
+define+CLOCK_PERIOD=1.0 +define+RESET_DELAY=777.7 +define+PRINTF_COND=0 +define+STOP_COND=0 +define+MODEL=TestHarness \
+define+RANDOMIZE_MEM_INIT +define+RANDOMIZE_REG_INIT +define+RANDOMIZE_GARBAGE_ASSIGN +define+RANDOMIZE_INVALID_ASSIGN \
+define+VERILATOR +define+ASSERT_VERBOSE_COND_=0 +define+ASSERT_VERBOSE_COND=0

all: $(DESTDIR)/$(PROJECT)

$(DESTDIR)/VX_mesh_define.vh:
    python $(SCRIPT_DIR)/prepare_mesh_verilog.py -i $(MESH_DIR)
	python $(SCRIPT_DIR)/gen_mesh_connect.py -i $(MESH_DIR) -o $(DESTDIR)/VX_mesh_define.vh

$(DESTDIR)/$(PROJECT): $(SRCS) $(SRC_DIR)/main.cpp $(DESTDIR)/VX_mesh_define.vh
	verilator --build $(VL_FLAGS) -I$(DESTDIR)/VX_mesh_define.vh $(FROM_CONSTELLATION) $^ -CFLAGS '$(CXXFLAGS) -DSTARTUP_ADDR=0x80000000' -LDFLAGS '$(LDFLAGS)' --Mdir $@.obj_dir -o $@

$(DESTDIR)/lib$(PROJECT).so: $(SRCS) $(DESTDIR)/VX_mesh_define.vh
	verilator --build $(VL_FLAGS) -I$(DESTDIR)/VX_mesh_define.vh $(FROM_CONSTELLATION) $^ -CFLAGS '$(CXXFLAGS)' -LDFLAGS '-shared $(LDFLAGS)' --Mdir $@.obj_dir -o $@

clean-mesh:
	rm -f $(DESTDIR)/VX_mesh_define.vh

clean-lib:
	rm -rf $(DESTDIR)/lib$(PROJECT).so.obj_dir
	rm -f $(DESTDIR)/lib$(PROJECT).so

clean-exe:
	rm -rf $(DESTDIR)/$(PROJECT).obj_dir
	rm -f $(DESTDIR)/$(PROJECT)

clean: clean-lib clean-exe clean-mesh