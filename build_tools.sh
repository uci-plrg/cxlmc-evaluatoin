#!/bin/bash
cmake -B build/cxlmc -S $CXL_PATH/cxlmc
cmake --build build/cxlmc --target init

cmake -D CXLMC_CXL_ALLOC_RAND=ON -B build/cxlmc_cxl_alloc_rand -S $CXL_PATH/cxlmc
cmake --build build/cxlmc_cxl_alloc_rand --target init

cmake -D CXLMC_GPF=ON -B build/cxlmc_gpf -S $CXL_PATH/cxlmc
cmake --build build/cxlmc_gpf --target init
