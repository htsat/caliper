build_scimark() {
    OBJ="Building scimark"
    do_msg $OBJ "start"
    SrcPath=${BENCH_PATH}"402.scimark"
    myOBJPATH=${OBJPATH}/bin
    pushd $SrcPath
    if [ $ARCH = "x86_32" -o $ARCH = "x86_64" ]; then
    make CC=$GCC CFLAGS="-msse4"
        cp scimark2 ../../$myOBJPATH/
                    make CC=$GCC clean
                             fi
    if [ $ARCH = "arm_32" ]; then
        # -mfloat-abi=hard -mfpu=vfpv4 -mcpu=cortex-a15
        make CC=$GCC CFLAGS=" -mfloat-abi=hard -mfpu=vfpv4 -mcpu=cortex-a15 "
        cp scimark2 ../../$myOBJPATH/
        make CC=$GCC clean
    fi
    if [ $ARCH = "arm_64" ]; then
        make CC=$GCC #CFLAGS="-mabi=lp64"
        cp scimark2 ../../$myOBJPATH
        make CC=$GCC clean
    fi

    if [ $ARCH = "android" ]; then
        ndk-build
        cp libs/armeabi-v7a/scimark2 ../../$myOBJPATH/
        ndk-build clean
        rm -rf libs/ obj/
    fi
    popd
    do_msg $OBJ "done"
}

build_scimark
