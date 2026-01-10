#!/bin/bash
BENCH_PATH=$CXL_PATH/cxlbench

replace_in_file() {
    local file_path="$1"
    local line_number="$2"
    local old_content="$3"
    local new_content="$4"

    local current_content=$(sed -n "${line_number}p" "$file_path")
    echo "$current_content" | grep -q "$old_content\|$new_content"
    if [ $? -eq 0 ]; then
        sed -i "${line_number} s/${old_content}/${new_content}/" "$file_path"
    else
        echo "${file_path}:${line_number} does not contain the expected content."
        echo "Instead: ${current_content}"
        exit 1
    fi
}

enable_bug() {
    local file_path="$1"
    local line_number="$2"
    replace_in_file "$file_path" "$line_number" "#ifdef CXLFIX" "#ifdef MYBUG"
}

disable_bug() {
    local file_path="$1"
    local line_number="$2"
    replace_in_file "$file_path" "$line_number" "#ifdef MYBUG" "#ifdef CXLFIX"
}

copy_cxlmc_libs() {
    local build_path="$1"
    local target="$CXL_PATH/cxlmc/build"
    mkdir -p $target 
    if [ -d "$target/src" ]; then rm -r $target/src; fi
    cp -r $build_path/src $target
}

build() {
    local bench_name="$1"
    bash build_benchmark.sh "$bench_name"
    if [ $? -ne 0 ]; then
        echo "Build failed for $bench_name"
        exit 1
    fi
}

check_timeout() {
    local exit_status="$1"
    local output_file="$2"
    if [ "$exit_status" -eq 124 ]; then
        echo "ERROR: The test case terminated by hitting the timeout." >> "$output_file"
    fi
}

RESULTS_DIR="results"
mkdir -p $RESULTS_DIR

bash build_tools.sh


##### RECIPE Bugs #####

# Bug 1 (verified)
enable_bug "$BENCH_PATH/RECIPE/CCEH/src/CCEH_LSB.cpp" 172
copy_cxlmc_libs build/cxlmc
build CCEH
disable_bug "$BENCH_PATH/RECIPE/CCEH/src/CCEH_LSB.cpp" 172
timeout 5 build/cxlmc/init -n 2 -f "build/CCEH/libexample.so 30 4" >> $RESULTS_DIR/RECIPE-bug1.txt 2>&1
check_timeout "$?" "$RESULTS_DIR/RECIPE-bug1.txt"

# Bug 2 (verified)
enable_bug "$BENCH_PATH/RECIPE/CCEH/src/CCEH_LSB.cpp" 178
copy_cxlmc_libs build/cxlmc
build CCEH
disable_bug "$BENCH_PATH/RECIPE/CCEH/src/CCEH_LSB.cpp" 178
timeout 20 build/cxlmc/init -n 2 -f "build/CCEH/libexample.so 30 4" >> $RESULTS_DIR/RECIPE-bug2.txt 2>&1
check_timeout "$?" "$RESULTS_DIR/RECIPE-bug2.txt"

# Bug 3 (verified)
enable_bug "$BENCH_PATH/RECIPE/CCEH/src/CCEH_LSB.cpp" 186
copy_cxlmc_libs build/cxlmc
build CCEH
disable_bug "$BENCH_PATH/RECIPE/CCEH/src/CCEH_LSB.cpp" 186
build/cxlmc/init -n 2 -f "build/CCEH/libexample.so 8 4" >> $RESULTS_DIR/RECIPE-bug3.txt 2>&1

# Bug 4 (verified)
enable_bug "$BENCH_PATH/RECIPE/FAST_FAIR/btree.h" 155
copy_cxlmc_libs build/cxlmc
build FAST_FAIR
disable_bug "$BENCH_PATH/RECIPE/FAST_FAIR/btree.h" 155
build/cxlmc/init -n 2 -f "build/FAST_FAIR/libexample.so 10 1" >> $RESULTS_DIR/RECIPE-bug4.txt 2>&1

# Bug 5 (verified)
enable_bug "$BENCH_PATH/RECIPE/FAST_FAIR/btree.h" 179
enable_bug "$BENCH_PATH/RECIPE/FAST_FAIR/btree.h" 201
copy_cxlmc_libs build/cxlmc_cxl_alloc_rand
build FAST_FAIR
disable_bug "$BENCH_PATH/RECIPE/FAST_FAIR/btree.h" 179
disable_bug "$BENCH_PATH/RECIPE/FAST_FAIR/btree.h" 201
build/cxlmc_cxl_alloc_rand/init -n 2 -f "build/FAST_FAIR/libexample.so 2 1" >> $RESULTS_DIR/RECIPE-bug5.txt 2>&1

# Bug 6 (verified)
enable_bug "$BENCH_PATH/RECIPE/FAST_FAIR/btree.h" 201
copy_cxlmc_libs build/cxlmc
build FAST_FAIR
disable_bug "$BENCH_PATH/RECIPE/FAST_FAIR/btree.h" 201
build/cxlmc/init -n 2 -f "build/FAST_FAIR/libexample.so 8 2" >> $RESULTS_DIR/RECIPE-bug6.txt 2>&1

# Bug 7 (verified)
enable_bug "$BENCH_PATH/RECIPE/FAST_FAIR/btree.h" 619
copy_cxlmc_libs build/cxlmc
build FAST_FAIR
disable_bug "$BENCH_PATH/RECIPE/FAST_FAIR/btree.h" 619
build/cxlmc/init -n 2 -f "build/FAST_FAIR/libexample.so 10 2" >> $RESULTS_DIR/RECIPE-bug7.txt 2>&1

# Bug 8 (verified)
enable_bug "$BENCH_PATH/RECIPE/FAST_FAIR/btree.h" 1872
copy_cxlmc_libs build/cxlmc
build FAST_FAIR
disable_bug "$BENCH_PATH/RECIPE/FAST_FAIR/btree.h" 1872
build/cxlmc/init -n 2 -f "build/FAST_FAIR/libexample.so 2 1" >> $RESULTS_DIR/RECIPE-bug8.txt 2>&1

# Bug 9 (verified)
enable_bug "$BENCH_PATH/RECIPE/Key.h" 38
enable_bug "$BENCH_PATH/RECIPE/Key.h" 55
copy_cxlmc_libs build/cxlmc
build P-ART
disable_bug "$BENCH_PATH/RECIPE/Key.h" 38
disable_bug "$BENCH_PATH/RECIPE/Key.h" 55
build/cxlmc/init -n 2 -f "build/P-ART/libexample_lib.so 4 1" >> $RESULTS_DIR/RECIPE-bug9.txt 2>&1

# Bug 10 (verified)
enable_bug "$BENCH_PATH/RECIPE/P-ART/N.h" 82
enable_bug "$BENCH_PATH/RECIPE/P-ART/N4.cpp" 27
enable_bug "$BENCH_PATH/RECIPE/P-ART/N16.cpp" 21
enable_bug "$BENCH_PATH/RECIPE/P-ART/N48.cpp" 26
copy_cxlmc_libs build/cxlmc
build P-ART
disable_bug "$BENCH_PATH/RECIPE/P-ART/N.h" 82
disable_bug "$BENCH_PATH/RECIPE/P-ART/N4.cpp" 27
disable_bug "$BENCH_PATH/RECIPE/P-ART/N16.cpp" 21
disable_bug "$BENCH_PATH/RECIPE/P-ART/N48.cpp" 26
build/cxlmc/init -n 2 -f "build/P-ART/libexample_lib.so 48 1" >> $RESULTS_DIR/RECIPE-bug10.txt 2>&1

# Bug 11 (verified)
enable_bug "$BENCH_PATH/RECIPE/P-ART/N4.cpp" 76
copy_cxlmc_libs build/cxlmc
build P-ART
disable_bug "$BENCH_PATH/RECIPE/P-ART/N4.cpp" 76
build/cxlmc/init -n 2 -f "build/P-ART/libexample_lib.so 50 1" >> $RESULTS_DIR/RECIPE-bug11.txt 2>&1

# Bug 12 (verified)
enable_bug "$BENCH_PATH/RECIPE/P-ART/N16.cpp" 16
copy_cxlmc_libs build/cxlmc
build P-ART
disable_bug "$BENCH_PATH/RECIPE/P-ART/N16.cpp" 16
build/cxlmc/init -n 2 -f "build/P-ART/libexample_lib.so 128 1" >> $RESULTS_DIR/RECIPE-bug12.txt 2>&1

# Bug 13 (verified)
enable_bug "$BENCH_PATH/RECIPE/Key.h" 13
copy_cxlmc_libs build/cxlmc
build P-ART
disable_bug "$BENCH_PATH/RECIPE/Key.h" 13
build/cxlmc/init -n 2 -f "build/P-ART/libexample_lib.so 258 1" >> $RESULTS_DIR/RECIPE-bug13.txt 2>&1

# Bug 14 (verified)
enable_bug "$BENCH_PATH/RECIPE/P-BwTree/src/bwtree.h" 468
copy_cxlmc_libs build/cxlmc
build P-BwTree
disable_bug "$BENCH_PATH/RECIPE/P-BwTree/src/bwtree.h" 468
build/cxlmc/init -n 2 -f "build/P-BwTree/libexample_lib.so 2 1" >> $RESULTS_DIR/RECIPE-bug14.txt 2>&1

# Bug 15 (verified)
enable_bug "$BENCH_PATH/RECIPE/P-BwTree/src/bwtree.h" 485
copy_cxlmc_libs build/cxlmc
build P-BwTree
disable_bug "$BENCH_PATH/RECIPE/P-BwTree/src/bwtree.h" 485
build/cxlmc/init -n 2 -f "build/P-BwTree/libexample_lib.so 10 1" >> $RESULTS_DIR/RECIPE-bug15.txt 2>&1

# Bug 16 (verified)
enable_bug "$BENCH_PATH/RECIPE/P-BwTree/src/bwtree.h" 2041
copy_cxlmc_libs build/cxlmc
build P-BwTree
disable_bug "$BENCH_PATH/RECIPE/P-BwTree/src/bwtree.h" 2041
build/cxlmc/init -n 2 -f "build/P-BwTree/libexample_lib.so 2 1" >> $RESULTS_DIR/RECIPE-bug16.txt 2>&1

# Bug 17 (verified)
enable_bug "$BENCH_PATH/RECIPE/P-BwTree/src/bwtree.h" 2068
copy_cxlmc_libs build/cxlmc
build P-BwTree
disable_bug "$BENCH_PATH/RECIPE/P-BwTree/src/bwtree.h" 2068
timeout 15 build/cxlmc/init -n 2 -f "build/P-BwTree/libexample_lib.so 2 1" >> $RESULTS_DIR/RECIPE-bug17.txt 2>&1
check_timeout "$?" "$RESULTS_DIR/RECIPE-bug17.txt"

# Bug 18 (verified)
enable_bug "$BENCH_PATH/RECIPE/P-BwTree/src/bwtree.h" 2841
copy_cxlmc_libs build/cxlmc
build P-BwTree
disable_bug "$BENCH_PATH/RECIPE/P-BwTree/src/bwtree.h" 2841
build/cxlmc/init -n 2 -f "build/P-BwTree/libexample_lib.so 2 1" >> $RESULTS_DIR/RECIPE-bug18.txt 2>&1

# Bug 19 (verified)
enable_bug "$BENCH_PATH/RECIPE/P-CLHT/src/clht_lf_res.c" 175
copy_cxlmc_libs build/cxlmc
build P-CLHT
disable_bug "$BENCH_PATH/RECIPE/P-CLHT/src/clht_lf_res.c" 175
build/cxlmc/init -n 2 -f "build/P-CLHT/libexample_lib.so 1 1" >> $RESULTS_DIR/RECIPE-bug19.txt 2>&1

# Bug 20 (verified)
enable_bug "$BENCH_PATH/RECIPE/P-CLHT/src/clht_lf_res.c" 230
copy_cxlmc_libs build/cxlmc_cxl_alloc_rand
build P-CLHT
disable_bug "$BENCH_PATH/RECIPE/P-CLHT/src/clht_lf_res.c" 230
build/cxlmc_cxl_alloc_rand/init -n 2 -f "build/P-CLHT/libexample_lib.so 2 1" >> $RESULTS_DIR/RECIPE-bug20.txt 2>&1

# Bug 21 (verified)
enable_bug "$BENCH_PATH/RECIPE/P-CLHT/src/clht_lf_res.c" 236
copy_cxlmc_libs build/cxlmc_cxl_alloc_rand
build P-CLHT
disable_bug "$BENCH_PATH/RECIPE/P-CLHT/src/clht_lf_res.c" 236
timeout 5 build/cxlmc_cxl_alloc_rand/init -n 2 -f "build/P-CLHT/libexample_lib.so 2 1" >> $RESULTS_DIR/RECIPE-bug21.txt 2>&1
check_timeout "$?" "$RESULTS_DIR/RECIPE-bug21.txt"

# Bug 22 (verified)
enable_bug "$BENCH_PATH/RECIPE/P-Masstree/masstree.h" 818
copy_cxlmc_libs build/cxlmc
build P-Masstree
disable_bug "$BENCH_PATH/RECIPE/P-Masstree/masstree.h" 818
build/cxlmc/init -n 2 -f "build/P-Masstree/libexample_lib.so 40 4" >> $RESULTS_DIR/RECIPE-bug22.txt 2>&1


##### CXL-SHM Bugs #####

# Bug 1 (verified, no fix)
copy_cxlmc_libs build/cxlmc
build CXL-SHM
build/cxlmc/init -n 2 -f "build/CXL-SHM/librecovery_check.so" -f "build/CXL-SHM/libcxlmalloc-benchmark-kv.so 1"  >> $RESULTS_DIR/CXL-SHM-bug1.txt 2>&1

# Bug 2 (verified)
enable_bug "$BENCH_PATH/CXL-SHM/src/recovery.cpp" 282
copy_cxlmc_libs build/cxlmc
build CXL-SHM
disable_bug "$BENCH_PATH/CXL-SHM/src/recovery.cpp" 282
build/cxlmc/init -n 2 -f "build/CXL-SHM/librecovery_check.so" -f "build/CXL-SHM/libcxlmalloc-test-stress.so 1">> $RESULTS_DIR/CXL-SHM-bug2.txt 2>&1
