#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 [P-ART | P-BwTree | P-CLHT | P-Masstree | CCEH | FAST_FAIR | CXL-SHM | all]"
    exit 1
fi

BENCH_PATH=$CXL_PATH/cxlbench

build_recipe_cmake() {
    local bench=$1
    cmake -DCXL_PATH=$CXL_PATH -B build/$bench -S $BENCH_PATH/RECIPE/$bench
    cmake --build build/$bench
}

build_recipe_make() {
    local bench=$1
    make -C $BENCH_PATH/RECIPE/$bench CXL_PATH=$CXL_PATH
    mkdir -p build/$bench
    cp $BENCH_PATH/RECIPE/$bench/libexample.so build/$bench/
}

build_cxlshm() {
    cmake -DCXL_PATH=$CXL_PATH -DUSE_CXL=OFF -B build/CXL-SHM -S $BENCH_PATH/CXL-SHM
    cmake --build build/CXL-SHM
}

build_all() {
    for bench in P-ART P-BwTree P-CLHT P-Masstree; do
        build_recipe_cmake $bench
    done

    for bench in CCEH FAST_FAIR; do
        build_recipe_make $bench
    done

    build_cxlshm
}

for arg in "$@"; do
    case $arg in
        P-ART | P-BwTree | P-CLHT | P-Masstree)
            build_recipe_cmake $arg
            ;;
        CCEH | FAST_FAIR)
            build_recipe_make $arg
            ;;
        CXL-SHM)
            build_cxlshm
            ;;
        all)
            build_all
            ;;
        *)
            echo "Unknown argument: $arg"
            exit 1
            ;;
    esac
done
