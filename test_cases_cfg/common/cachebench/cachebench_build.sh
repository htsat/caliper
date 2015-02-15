build_cachebench() {
        OBJ="Building cachebench"
        do_msg $OBJ "start"

        SrcPath=${BENCH_PATH}"410.cachebench"
   myOBJPATH=${OBJPATH}/bin
        pushd $SrcPath
        if [ $ARCH = "x86_32" -o $ARCH = "x86_64" ]; then
      make CC=$GCC CFLAGS="-msse4"
           mv cachebench    ../../$myOBJPATH/
        fi
        if [ $ARCH = "arm_32" ]; then
          make CC=$GCC CFLAGS="-mfloat-abi=hard -mfpu=vfpv4 -mcpu=cortex-a15"
           mv cachebench    ../../$myOBJPATH/
        fi
        if [ $ARCH = "arm_64" ]; then
          make CC=$GCC #CFLAGS="-mabi=lp64"
           mv cachebench    ../../$myOBJPATH/
        fi
        if [ $ARCH = "android" ]; then
      ndk-build
      cp libs/armeabi-v7a/cachebench ../../$myOBJPATH/
      ndk-build clean
      rm -rf libs/ obj/
        fi
        popd
        do_msg $OBJ "done"
}

build_cachebench
