build_lmbench() {
        OBJ="Building lmbench"
        do_msg $OBJ "start"

        SrcPath="./benchmarks/490.lmbench"
        pushd $SrcPath
   if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]; then
      make OS=lmbench  CC="$GCC -O2 -msse4"
           rm -rf bin/lmbench/*.a
           rm -rf bin/lmbench/*.o
           mv bin/lmbench    ../../$OBJPATH/
           rm -rf bin
      cp src/webpage-lm.tar  ../../$OBJPATH/lmbench/
   fi
   if [ $ARCH = "arm_64" -o $ARCH = "arm_32" ]; then
        if [ $ARCH = "arm_32" ]; then
          make OS=lmbench  CC="$GCC -mfloat-abi=hard -mfpu=vfpv4 -mcpu=cortex-a15"
         else
          make OS=lmbench  CC="$GCC -mabi=lp64"
         fi
      #make OS=lmbench  CC=${ARM_OPT}
                rm -rf bin/lmbench/*.a
                rm -rf bin/lmbench/*.o
                mv bin/lmbench    ../../$OBJPATH/
                rm -rf bin
      cp src/webpage-lm.tar  ../../$OBJPATH/lmbench/
   fi
        if [ $ARCH = "android" ]; then
            myARMCROSS=arm-linux-gnueabihf
                    myGCC=${myARMCROSS}-gcc
            make OS=lmbench  CC="$myGCC --static -mfloat-abi=hard -mfpu=neon-vfpv4 -mcpu=cortex-a15"
            rm -rf bin/lmbench/*.a
            rm -rf bin/lmbench/*.o
            mv bin/lmbench    ../../$OBJPATH/
            rm -rf bin
            cp src/webpage-lm.tar  ../../$OBJPATH/lmbench/

            #make -f makefile.android CROSS_COMPILE=$ANDROIDCROSS SYSROOT=$ANDROIDSYSROOT
            #mkdir -p ../$OBJPATH/lmbench
            #cp bin/* ../$OBJPATH/lmbench/ -rf
                    #rm -rf bin
            #cp src/webpage-lm.tar  ../$OBJPATH/lmbench/
        fi
        popd

        do_msg $OBJ "done"
}

build_lmbench
