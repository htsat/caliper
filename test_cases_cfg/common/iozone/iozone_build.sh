build_iozone() {
        SrcPath=${BENCH_PATH}"430.iozone"
   myOBJPATH=${OBJPATH}/bin

        pushd $SrcPath
        if [ $ARCH = "x86_64" ]
        then
                make linux-AMD64
           cp iozone ../../$myOBJPATH
           cp fileop ../../$myOBJPATH
           make clean
        fi
        if [ $ARCH = "x86_32" ]; then
            make linux
            cp iozone ../../$myOBJPATH
           cp fileop ../../$myOBJPATH
           make clean
        fi
        if [ $ARCH = "arm_64" -o $ARCH = "arm_32" ]
        then
                make linux-arm CC=$GCC GCC=$GCC
           cp iozone ../../$myOBJPATH
           cp fileop ../../$myOBJPATH
           make clean
        fi

        if [ $ARCH = "android" ]
        then
      myARMCROSS=arm-linux-gnueabihf
                make linux-arm CC=$myARMCROSS-gcc GCC=$myARMCROSS-gcc LDFLAGS="--static"
      $myARMCROSS-strip iozone
      $myARMCROSS-strip fileop
                cp iozone ../../$myOBJPATH
                cp fileop ../../$myOBJPATH
                make clean
        fi
        popd
}

build_iozone
