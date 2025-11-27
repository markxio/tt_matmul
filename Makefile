CXX     := clang++-17
LINKER  := $(CXX)
	
#export LD_LIBRARY_PATH=/opt/llvm-17.0.6-omp:$LD_LIBRARY_PATH

TT_INC  := -I$(TT_METAL_HOME)/tt_metal/api \
           -I$(TT_METAL_HOME)/tt_metal/api/tt-metalium \
           -I$(TT_METAL_HOME)/build_Release/include \
           -I$(TT_METAL_HOME)/build_Release/include/metalium-thirdparty \
           -I$(TT_METAL_HOME)/build_Release/include/umd/device/device/api \
           -I$(TT_METAL_HOME)/tt_metal/hostdevcommon/api/ \
           -I$(TT_METAL_HOME)/tt_metal/third_party/tracy/public \
           -I./src/matmul_common \
           -I./src
		
INCLUDES := -I./tt_power/tt_power -I/opt/llvm-17.0.6-omp 

SRC_DIR := src
BIN_DIR := bin

CFLAGS  := $(TT_INC) $(INCLUDES) -O3 -Wno-int-to-pointer-cast -stdlib=libc++ -mavx2 -fPIC \
           -DFMT_HEADER_ONLY -fvisibility-inlines-hidden -fno-lto -DARCH_WORMHOLE \
           -DDISABLE_ISSUE_3487_FIX -Werror -Wdelete-non-virtual-dtor -Wreturn-type \
           -Wswitch -Wuninitialized -Wno-unused-parameter -Wsometimes-uninitialized \
           -Wno-c++11-narrowing -Wno-c++23-extensions -Wno-error=local-type-template-args \
           -Wno-delete-non-abstract-non-virtual-dtor -Wno-c99-designator \
           -Wno-shift-op-parentheses -Wno-non-c-typedef-for-linkage \
           -Wno-deprecated-this-capture -Wno-deprecated-volatile -Wno-deprecated-builtins \
           -Wno-deprecated-declarations -std=c++20 -fopenmp

LFLAGS  := -rdynamic -L$(TT_METAL_HOME)/build_Release/lib \
           -ltt_metal -ldl -lstdc++fs -pthread -lyaml-cpp -lm -lc++ -ldevice -L/opt/llvm-17.0.6-omp -fopenmp

# List of programs (without extension)
PROGRAMS := matmul_single_core \
            matmul_multi_core \
            matmul_multicore_reuse \
            matmul_multicore_reuse_mcast

.PHONY: all clean mkrefdir matmul_single_core matmul_multi_core
mkrefdir:
	@mkdir -p $(BIN_DIR)

matmul_single_core:
	$(CXX) -I./src/matmul_single_core/kernels/dataflow $(CFLAGS) -o $(BIN_DIR)/matmul_single_core $(SRC_DIR)/matmul_single_core/matmul_single_core.cpp $(LFLAGS)

matmul_multi_core:
	$(CXX) -I./src/matmul_multi_core/kernels/dataflow $(CFLAGS) -o $(BIN_DIR)/matmul_multi_core $(SRC_DIR)/matmul_multi_core/matmul_multi_core.cpp $(LFLAGS)

matmul_multicore_reuse:
	$(CXX) $(CFLAGS) -o $(BIN_DIR)/matmul_multicore_reuse $(SRC_DIR)/matmul_multicore_reuse/matmul_multicore_reuse.cpp $(LFLAGS)

matmul_multicore_reuse_mcast:
	$(CXX) $(CFLAGS) -o $(BIN_DIR)/matmul_multicore_reuse_mcast $(SRC_DIR)/matmul_multicore_reuse_mcast/matmul_multicore_reuse_mcast.cpp $(LFLAGS)

clean:
	$(RM) -r $(BIN_DIR)

all: mkrefdir matmul_single_core matmul_multi_core matmul_multicore_reuse matmul_multicore_reuse_mcast 