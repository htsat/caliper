build_dhrystone()
{
    OBJ="Building dhrystone and whetstone"
    do_msg $OBJ "start"

    SrcPath=${BENCH_PATH}'404.dhrystone/source_code'
    myOBJPATH=${OBJPATH}/bin
    pushd $SrcPath
    if [ $ARCH = "x86_64" ]; then
        make CC=$GCC CFLAGS="-O3 -Icommon_64bit -lrt -lm"
        cp dhry1 dhry2 lloops whets ../../../$myOBJPATH/
        make CC=$GCC clean
    fi
    if [ $ARCH = "x86_32" ]; then
        make CC=$GCC CFLAGS="-O3 -Icommon_32bit -lrt -lm"
        cp dhry1 dhry2 lloops whets ../../../$myOBJPATH/
    fi
    if [ $ARCH = "arm_32" ]; then
        #-mcpu=cortex-a15 -mtune=cortex-a15 -mfpu=neon -funroll-loops 
        make CC=$GCC CFLAGS="-static -O3 -Icommon_32bit -lrt -lm"
        cp dhry1 dhry2 lloops whets ../../../$myOBJPATH/
        make CC=$GCC clean
    fi
    if [ $ARCH = "arm_64" ]; then
        make CC=$GCC CFLAGS="-static -O3 -funroll-loops -Icommon_64bit -lrt -lm"
        cp dhry1 dhry2 lloops whets ../../../$myOBJPATH/
        make CC=$GCC clean
    fi
    if [ $ARCH = "android" ]; then
        ndk-build
        cp libs/armeabi-v7a/scimark2 ../../../$myOBJPATH/
        ndk-build clean
        rm -fr lib/ obj/
    fi
    popd
do_msg $OBJ "done"
}

build_dhrystone
