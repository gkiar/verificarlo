#!/bin/bash
set -e

Check() {
    MAX_PREC=$1
    for PREC in $(seq 3 10 $MAX_PREC) ; do

        echo "Checking at PRECISION $PREC"
        export VERIFICARLO_PRECISION=$PREC

        rm -f out_mpfr out_quad
        export VERIFICARLO_BACKEND="MPFR"
        ./test >> out_mpfr

        export VERIFICARLO_BACKEND="QUAD"
        ./test >> out_quad
        ./check.py
        if [ $? -ne 0 ] ; then
            exit $?
        fi
    done
}

# Test operates at different precisions, and different operands.
# It compares s': the estimated number of significant digits across the MCA samples.


for op in + "*" ; do
    echo "Checking $op float"
    ../../verificarlo -D REAL=float -D SAMPLES=1000 -D OPERATION="$op" -O0 -lm --function operate test.c -o test
    Check 24

    echo "Checking $op double"
    ../../verificarlo -D REAL=double -D SAMPLES=1000 -D OPERATION="$op" -O0 -lm --function operate test.c -o test
    Check 53
done
