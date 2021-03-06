build_dbench()
{
        SrcPath=${BENCH_PATH}"431.dbench"
        MYPWD=${PWD}
        BuildPATH="$MYPWD/build.dbench"
        TOP_SRCDIR="$MYPWD/$SrcPath"
        INSTALL_DIR="$MYPWD/$OBJPATH"
        pushd $SrcPath 
        find . -name '*.o' 
        if [ $? -eq 0 ]
        then
            make clean
        fi
        popd
        mkdir -p $BuildPATH
        if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]
        then
             pushd $TOP_SRCDIR
             find . -name '*.o'
             if [ $? -e 0 ]
             then 
                 make clean
             fi
                $TOP_SRCDIR/configure
                make
                mkdir -p $INSTALL_DIR/dbench
                cp dbench    $INSTALL_DIR/dbench
                cp -r $TOP_SRCDIR/loadfiles $INSTALL_DIR/dbench
                popd
        fi

    if [ $ARCH = "arm_64" -o $ARCH = "arm_32" ]
   then
   	  ##ARMCROSS=arm-linux
      pushd $TOP_SRCDIR
      #$TOP_SRCDIR/configure CC=$GCC --target=$ARMCROSS  --host=$ARMCROSS
      $TOP_SRCDIR/configure CC=$GCC
      make
      cp dbench    $INSTALL_DIR/dbench
      cp -r $TOP_SRCDIR/loadfiles $INSTALL_DIR/dbench
      popd
   fi
        rm -rf $BuildPATH
}

build_dbench
