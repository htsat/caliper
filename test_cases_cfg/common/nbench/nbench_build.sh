
build_nbench()
{
    OBJ="building nbench"
    do_msg $OBJ "start"

    SrcPath=${BENCH_PATH}"405.nbench"
    myOBJPATH=${OBJPATH}
    pushd $SrcPath
    mkdir -p ../../$myOBJPATH/nbench
    if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ];then
         make
         cp * ../../$myOBJPATH/nbench
         make CC=$GCC clean
    fi
    if [ $ARCH = "arm_32" ]; then
        make CC=$GCC CFLAGS="-mfloat-abi=hard -mfpu=vfpv4 -mcpu=cortex-a15"
        cp * ../../$myOBJPATH/nbench
        make CC=$GCC clean
    fi
    if [ $ARCH = "arm_64" ]; then
        make CC=$GCC CFLAGS="-mabi=lp64"
        cp * ../../$myOBJPATH/nbench
        make CC=$GCC clean
    fi
    if [ $ARCH = "android" ]; then
        ndk-build
        cp libs/armeabi-v7a/nbench ../../$myOBJPATH/nbench
        ndk-build clean
        rm -fr lib/ obj/
    fi
    popd
    do_msg $OBJ "done"
}

build_nbench
