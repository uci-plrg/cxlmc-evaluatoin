#!/bin/bash
BENCH_PATH=$CXL_PATH/cxlbench

copy_cxlmc_libs() {
    local build_path="$1"
    local target="$CXL_PATH/cxlmc/build"
    mkdir -p $target 
    if [ -d "$target/src" ]; then rm -r $target/src; fi
    cp -r $build_path/src $target
}


bash build_tools.sh
bash build_benchmark.sh all

RESULTS_DIR="results"
mkdir -p $RESULTS_DIR

copy_cxlmc_libs build/cxlmc

for bench in CCEH FAST_FAIR; do
    (time build/cxlmc/init -n 2 -f "build/$bench/libexample.so 10 2") >> $RESULTS_DIR/$bench-perf.log 2>&1
done

for bench in P-ART P-BwTree P-CLHT P-Masstree; do
    (time build/cxlmc/init -n 2 -f "build/$bench/libexample_lib.so 10 2") >> $RESULTS_DIR/$bench-perf.log 2>&1
done

copy_cxlmc_libs build/cxlmc_gpf

for bench in CCEH FAST_FAIR; do
    (time build/cxlmc_gpf/init -n 2 -f "build/$bench/libexample.so 10 2") >> $RESULTS_DIR/${bench}_GPF-perf.log 2>&1
done

for bench in P-ART P-BwTree P-CLHT P-Masstree; do
    (time build/cxlmc_gpf/init -n 2 -f "build/$bench/libexample_lib.so 10 2") >> $RESULTS_DIR/${bench}_GPF-perf.log 2>&1
done
