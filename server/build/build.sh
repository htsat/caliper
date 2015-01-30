#!/bin/bash
#
# ./build.sh x86
# ./build.sh android
# ./build.sh arm
#

set -x
do_msg() {
   OBJ=$1
   ACTION=$2
   echo "========================================================="
   echo "$OBJ - $ACTION"
   echo "========================================================="
}
build_coremark() {
   OBJ="Building coremark"
   do_msg $OBJ "start"

   CoreMarkPath=${BENCH_PATH}"400.coremark"
   myOBJPATH=${OBJPATH}/bin
   pushd $CoreMarkPath
   if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]; then
      # -O2 -msse4
      make PORT_DIR=linux64 CC=$GCC XCFLAGS="-msse4" compile
      cp coremark.exe ../../$myOBJPATH/coremark
      make PORT_DIR=linux64 CC=$GCC clean
   fi
   if [ $ARCH = "arm_32" ]; then
      # O2 -mfloat-abi=hard -mfpu=vfpv4 -mcpu=cortex-a15
      make PORT_DIR=linux CC=$GCC XCFLAGS="-mfloat-abi=hard -mfpu=vfpv4 -mcpu=cortex-a15" compile
      cp coremark.exe ../../$myOBJPATH/coremark
      make PORT_DIR=linux64 CC=$GCC compile clean
   fi
    if [ $ARCH = "arm_64"  ]; then
        make PORT_DIR=linux64 CC=$GCC XCFLAGS=" -mabi=lp64 " compile
        cp coremark.exe ../../$myOBJPATH/coremark
        make PORT_DIR=linux64 CC=$GCC clean
    fi
   if [ $ARCH = "android" ]; then
      ndk-build
      cp  libs/armeabi-v7a/coremark ../../$myOBJPATH/
      ndk-build clean
      rm -rf libs/ obj/
   fi
   popd

   do_msg $OBJ "done"
}

build_linpack() {
        OBJ="Building linpack"
        do_msg $OBJ "start"

        SrcPath=${BENCH_PATH}"401.linpack"
   myOBJPATH=${OBJPATH}/bin
        pushd $SrcPath
    if [ $ARCH = "android" ]; then
      ndk-build
      cp libs/armeabi-v7a/linpack_sp  ../../$myOBJPATH/
      cp libs/armeabi-v7a/linpack_dp  ../../$myOBJPATH/
      ndk-build clean
      rm -rf libs/ obj/
   else
      ${GCC} -O2  -DDP -o linpack_dp linpack.c
      ${GCC} -O2 -DSP -o linpack_sp linpack.c
           mv linpack_sp ../../$myOBJPATH/
           mv linpack_dp ../../$myOBJPATH/
    fi      
        popd

        do_msg $OBJ "done"
}

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
            make CC=$GCC CFLAGS="-mfloat-abi=hard -mfpu=vfpv4 -mcpu=cortex-a15"
            cp scimark2 ../../$myOBJPATH/
            make CC=$GCC clean
        fi
        if [ $ARCH = "arm_64" ]; then
            make CC=$GCC CFLAGS="-mabi=lp64"
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
#add by wuyanjun
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
        make CC=$GCC CFLAGS="-static -O3 -mcpu=cortex-a15 -mtune=cortex-a15 -mfpu=neon -funroll-loops -Icommon_64bit -lrt -lm"
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

build_nbench()
{
    OBJ="building nbench"
do_msg $OBJ "start"
   
    SrcPath=${BENCH_PATH}"405.nbench"
    myOBJPATH=${OBJPATH}/bin
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

build_openssl() {
        OBJ="Building openssl"
        do_msg $OBJ "start"

        SrcPath=${BENCH_PATH}"403.openssl"
   myOBJPATH=${OBJPATH}/bin
        MYPWD=${PWD}
        BuildPATH="$MYPWD/build.openssl"
        TOP_SRCDIR="$MYPWD/$SrcPath"
   mkdir -p $BuildPATH

        if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]; then
            cp -rf $TOP_SRCDIR/* $BuildPATH/
            pushd $BuildPATH
            if [ $ARCH = "x86_64" ]; then
                OS_OPTION="linux-x86_64"
            else
                OS_OPTION="linux"
            fi
            CC=$GCC $TOP_SRCDIR/Configure $OS_OPTION #linux-x86_64
            make
            cp apps/openssl ../$myOBJPATH/
            popd
            rm -rf $BuildPATH/
        fi
        if [ $ARCH = "arm_32" ]; then  #-o $ARCH = "arm_64"
            cp -rf $TOP_SRCDIR/* $BuildPATH/
            pushd $BuildPATH
            if [ $ARCH = "arm_32" ] ; then
                CC=$GCC ./Configure linux-armv4
            #else
            #CC=$GCC ./Configure linux-arm64
            fi
            make
            cp apps/openssl ../$myOBJPATH/
            popd
            rm -rf $BuildPATH/
        fi
        pushd $SrcPath
        if [ $ARCH = "android" ]; then
            cp -rf $TOP_SRCDIR/* $BuildPATH/
            pushd $BuildPATH
            export ANDROID_DEV=$ANDROIDSYSROOT/usr
            CC="$ANDROIDGCC --sysroot=$ANDROIDSYSROOT"  ./Configure android-armv7
            make
            cp apps/openssl ../$myOBJPATH/
            popd
            rm -rf $BuildPATH/
        fi
        popd

        do_msg $OBJ "done"

}

build_lmbench() {
        OBJ="Building lmbench"
        do_msg $OBJ "start"

        SrcPath=${BENCH_PATH}"490.lmbench"
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
          make CC=$GCC CFLAGS="-mabi=lp64"
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

build_memspeed() {
        OBJ="Building memspeed"
        do_msg $OBJ "start"

        SrcPath=${BENCH_PATH}"412.memspeed"
   myOBJPATH=${OBJPATH}/bin
        pushd $SrcPath
        if  [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]; then
                make CC=$GCC CFLAGS="-msse4"
           mv memspeed    ../../$myOBJPATH/
        fi
        if [ $ARCH = "arm_64" -o $ARCH = "arm_32" ]; then
            #if [ $ARCH = "arm_64" ]; then
             #   CFLAGS_OPT="-mabi=lp64"
            #else
            if [ $ARCH = "arm_32" ]; then
                make CC=$GCC CFLAGS="-mfloat-abi=hard -mfpu=vfpv4 -mcpu=cortex-a15"
               mv  memspeed    ../../$myOBJPATH/
            fi
        fi
        if [ $ARCH = "android" ]; then
                ndk-build
                cp libs/armeabi-v7a/memspeed ../../$myOBJPATH/
                ndk-build clean
                rm -rf libs/ obj
        fi
        popd
        do_msg $OBJ "done"
}

build_ARMmemspeed() {
        OBJ="Building memspeed"
        do_msg $OBJ "start"

        SrcPath=${BENCH_PATH}"413.armMemSpeed"
   myOBJPATH=${OBJPATH}/bin
        pushd $SrcPath
        if [ $ARCH = "arm_32" -o $ARCH = "arm_64" ]; then
            #if [ $ARCH = "arm_64" ]; then
            #    CFLAGS_OPT="-mabi=lp64"
            #else
            if [ $ARCH = "arm_32" ]; then
            make CC=$GCC CFLAGS="-mfloat-abi=hard -mfpu=vfpv4 -mcpu=cortex-a15 -g -O3 -Wall -fno-tree-vectorize"
           mv memspeed_a8    ../../$myOBJPATH/
           mv memspeed_a9    ../../$myOBJPATH/
           mv memspeed_a9d16 ../../$myOBJPATH/
            fi
        fi
        if [ $ARCH = "android" ]; then
            make CC="$ANDROIDGCC --sysroot=$ANDROIDSYSROOT" CFLAGS="-mfloat-abi=soft -mfpu=neon-vfpv4 -mcpu=cortex-a15 -g -O3 -Wall -fno-tree-vectorize"
            mv memspeed_a8    ../../$myOBJPATH/
            mv memspeed_a9    ../../$myOBJPATH/
            mv memspeed_a9d16 ../../$myOBJPATH/
        fi
        popd
        do_msg $OBJ "done"
}

build_ethtool() {
        SrcPath=${BENCH_PATH}"422.ethtool"
        MYPWD=${PWD}
        BuildPATH="$MYPWD/build.ethtool"
        TOP_SRCDIR="$MYPWD/$SrcPath"
        myOBJPATH=${OBJPATH}/bin

        if [ $ARCH = "arm_64" -o $ARCH = "arm_32" ]
        then
           mkdir -p $BuildPATH
                pushd $BuildPATH
                $TOP_SRCDIR/configure --host=$ARMCROSS
                make
      $STRIP ethtool
                cp ethtool ../$myOBJPATH/
                popd
                rm -rf $BuildPATH
        fi
}

build_iperf() {
        SrcPath=${BENCH_PATH}"420.iperf"
        MYPWD=${PWD}
        BuildPATH="$MYPWD/build.iperf"
        TOP_SRCDIR="$MYPWD/$SrcPath"
   myOBJPATH=${OBJPATH}/bin
   mkdir -p $BuildPATH

        if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]
        then
      pushd $BuildPATH
                $TOP_SRCDIR/configure
                make
                cp src/iperf ../$myOBJPATH/
      popd
      rm -rf $BuildPATH
        fi
        if [ $ARCH = "arm_64" -o $ARCH = "arm_32" ]
        then
      pushd $BuildPATH
                ac_cv_func_malloc_0_nonnull=yes $TOP_SRCDIR/configure #--host=$ARMCROSS
           make
           cp src/iperf ../$myOBJPATH/
      popd
      rm -rf $BuildPATH
        fi
        if [ $ARCH = "android" ]; then
            pushd $BuildPATH
            cp $TOP_SRCDIR/* ./ -rf
            cp include/config.android.h include/config.h
            cp include/iperf-int.android.h include/iperf-int.h
            ndk-build V=1 LOCAL_DISABLE_FORMAT_STRING_CHECKS=true
            cp ./libs/armeabi-v7a/iperf ../$myOBJPATH/
            popd
            rm -rf $BuildPATH
        fi
}

build_netperf() {
        SrcPath=${BENCH_PATH}"421.netperf"
        MYPWD=${PWD}
        BuildPATH="$MYPWD/build.netperf"
        TOP_SRCDIR="$MYPWD/$SrcPath"
        myOBJPATH=${OBJPATH}/bin

        if [ $ARCH = "x86_64" -o  $ARCH = "x86_32" ]
        then
      mkdir -p $BuildPATH
      pushd $BuildPATH
      cp $TOP_SRCDIR/* ./ -rf
                aclocal -I src/missing/m4
                automake  --add-missing
                autoconf
                autoheader
                ./configure
                make
                cp src/netperf ../$myOBJPATH/
                cp src/netserver ../$myOBJPATH/
      popd
      rm -rf $BuildPATH
        fi

        if [ $ARCH = "arm_64" -o $ARCH = "arm_32" ]
        then
      mkdir -p $BuildPATH
      pushd $BuildPATH
      cp $TOP_SRCDIR/* ./ -rf
                aclocal -I src/missing/m4
                automake  --add-missing
                autoconf
                autoheader
                ac_cv_func_setpgrp_void=yes ac_cv_func_malloc_0_nonnull=yes ./configure #--host=$ARMCROSS
           make
           cp src/netperf ../$myOBJPATH/
           cp src/netserver ../$myOBJPATH/
      popd
      rm -rf $BuildPATH
        fi
}

build_ToolsCheck() {
   SrcPath=${BENCH_PATH}"304.ToolsCheck"
   MYPWD=${PWD}
   BuildPATH="$MYPWD/build.ToolsCheck"
   TOP_SRCDIR="$MYPWD/$SrcPath"
   INSTALL_DIR="$MYPWD/$OBJPATH"

    if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]
   then
      mkdir -p $BuildPATH
      pushd $BuildPATH
      cp $TOP_SRCDIR/* ./ -rf
      cd kdump/lib/
      make
      cp crasher/crasher.ko ./
      cp lkdtm/lkdtm.ko ./
      rm -rf crasher  kprobes  lkdtm
                cd ../../
      mkdir -p $INSTALL_DIR/toolsCheck
      cp ./ $INSTALL_DIR/toolsCheck/ -rf
      popd
      rm -rf $BuildPATH
   fi
}

build_ltp() {
        SrcPath=${BENCH_PATH}"300.ltp"
   MYPWD=${PWD}
   BuildPATH="$MYPWD/build.ltp"
   TOP_SRCDIR="$MYPWD/$SrcPath"
   INSTALL_DIR="$MYPWD/$OBJPATH"
   mkdir -p $BuildPATH

    if [ $ARCH = "x86_64" -o  $ARCH = "x86_32" ]
        then
            echo $SrcPath
      pushd $BuildPATH
      $TOP_SRCDIR/configure
      eval "make -C $BuildPATH -f $TOP_SRCDIR/Makefile "top_srcdir=$TOP_SRCDIR" "top_builddir=$BuildPATH""
      make -C $BuildPATH -f $TOP_SRCDIR/Makefile "top_srcdir=$TOP_SRCDIR" "top_builddir=$BuildPATH" "DESTDIR=$INSTALL_DIR" SKIP_IDCHECK=1 install
      mv $INSTALL_DIR/opt/ltp  $INSTALL_DIR/ltp
      rm -rf  $INSTALL_DIR/opt
      popd
      rm -rf $BuildPATH
   fi

        if [ $ARCH = "arm_64" -o  $ARCH = "arm_32" ]
        then
                pushd $BuildPATH
                if [ $ARCH = "arm_32" ]; then
                    BUILD="i686-pc-linux-gnu"
                else
                    BUILD="x86_64-unknown-linux-gnu"
                fi
                $TOP_SRCDIR/configure CC=$GCC --target=$ARMCROSS  --host=$ARMCROSS  --build=$BUILD
                make -C $BuildPATH -f $TOP_SRCDIR/Makefile "top_srcdir=$TOP_SRCDIR" "top_builddir=$BuildPATH"
                make -C $BuildPATH -f $TOP_SRCDIR/Makefile "top_srcdir=$TOP_SRCDIR" "top_builddir=$BuildPATH" "DESTDIR=$INSTALL_DIR" SKIP_IDCHECK=1 install
                mv $INSTALL_DIR/opt/ltp  $INSTALL_DIR/ltp
                rm -rf  $INSTALL_DIR/opt
                popd
                rm -rf $BuildPATH
        fi

        if [ $ARCH = "android" ]
        then
                pushd $BuildPATH
      myARMCROSS=arm-linux-gnueabihf
           myGCC=${myARMCROSS}-gcc
                $TOP_SRCDIR/configure CC=$myGCC --target=$myARMCROSS  --host=$myARMCROSS  --build=x86_64-unknown-linux-gnu CFLAGS="-static" LDFLAGS="-static -pthread"
                make -C $BuildPATH -f $TOP_SRCDIR/Makefile "top_srcdir=$TOP_SRCDIR" "top_builddir=$BuildPATH"
                make -C $BuildPATH -f $TOP_SRCDIR/Makefile "top_srcdir=$TOP_SRCDIR" "top_builddir=$BuildPATH" "DESTDIR=$INSTALL_DIR" SKIP_IDCHECK=1 install
                mv $INSTALL_DIR/opt/ltp  $INSTALL_DIR/ltp
                rm -rf  $INSTALL_DIR/opt
                popd
                rm -rf $BuildPATH
        fi
}

#
# dependent library libpopt
#
build_dbench()
{
        SrcPath=${BENCH_PATH}"431.dbench"
        MYPWD=${PWD}
        BuildPATH="$MYPWD/build.dbench"
        TOP_SRCDIR="$MYPWD/$SrcPath"
        INSTALL_DIR="$MYPWD/$OBJPATH/bin"

        mkdir -p $BuildPATH
        if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]
        then
                pushd $BuildPATH
                $TOP_SRCDIR/configure
                make
      cp dbench    $INSTALL_DIR/
      cp $TOP_SRCDIR/client.txt $INSTALL_DIR/
                popd
        fi

    if [ $ARCH = "arm_64" -o $ARCH = "arm_32" ]
   then
      pushd $BuildPATH
      #$TOP_SRCDIR/configure CC=$GCC --target=$ARMCROSS  --host=$ARMCROSS
      #$TOP_SRCDIR/configure --host=$ARMCROSS
      #make
      #cp dbench    $INSTALL_DIR/
      #cp $TOP_SRCDIR/client.txt $INSTALL_DIR/
      popd
   fi
        rm -rf $BuildPATH
}

build_powerMgr()
{
   SrcPath=${BENCH_PATH}"301.powerMgr"
    if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]
   then
      pushd $SrcPath
      make
      popd
      cp $SrcPath ${OBJPATH}/powerMgr -rf
      pushd $SrcPath
      make clean
      popd
   fi

        if [ $ARCH = "arm_64" -o $ARCH = "arm_32" ]
        then
                pushd $SrcPath
                make CC=$GCC
                popd
                cp $SrcPath ${OBJPATH}/powerMgr -rf
                pushd $SrcPath
                make clean
                popd
        fi

        if [ $ARCH = "android" ]
        then
      myARMCROSS=arm-linux-gnueabihf
                pushd $SrcPath
                make CC="${myARMCROSS}-gcc --static"
                popd
                cp $SrcPath ${OBJPATH}/powerMgr -rf
                pushd $SrcPath
                make clean
                popd
        fi
}

build_openPosix()
{
   SrcPath=${BENCH_PATH}"302.OpenPosixTestsuite"
    if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]
   then
      cp $SrcPath ${OBJPATH}/OpenPosixTestsuite -rf
   fi
}

build_rttest()
{
        SrcPath=${BENCH_PATH}"303.RTtest"
        MYPWD=${PWD}
   myOBJPATH=$MYPWD/${OBJPATH}/rttest
   mkdir -p $myOBJPATH
        if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]
            then
                    pushd $SrcPath
                    make
            cp -rf cyclictest    $myOBJPATH
            cp -rf hackbench     $myOBJPATH
            cp -rf pip_stress    $myOBJPATH
            cp -rf pi_stress     $myOBJPATH
            cp -rf pmqtest       $myOBJPATH
            cp -rf ptsematest    $myOBJPATH
            cp -rf rt-migrate-test     $myOBJPATH
            cp -rf sendme        $myOBJPATH
            cp -rf signaltest    $myOBJPATH
            cp -rf sigwaittest   $myOBJPATH
            cp -rf svsematest   $myOBJPATH
            make clean
                    popd
        fi

        if [ $ARCH = "arm_64" -o $ARCH = "arm_32" ]
        then
                pushd $SrcPath
      make CC=$GCC
                cp -rf cyclictest    $myOBJPATH
                cp -rf hackbench     $myOBJPATH
                cp -rf pip_stress    $myOBJPATH
                cp -rf pi_stress     $myOBJPATH
                cp -rf pmqtest       $myOBJPATH
                cp -rf ptsematest    $myOBJPATH
                cp -rf rt-migrate-test     $myOBJPATH
                cp -rf sendme        $myOBJPATH
                cp -rf signaltest    $myOBJPATH
                cp -rf sigwaittest   $myOBJPATH
                cp -rf svsematest   $myOBJPATH
                make clean
                popd
        fi

        if [ $ARCH = "android" ]
        then
      myARMCROSS=arm-linux-gnueabihf
                pushd $SrcPath
                make CC="${myARMCROSS}-gcc --static"
                cp -rf cyclictest    $myOBJPATH
                cp -rf hackbench     $myOBJPATH
                cp -rf pip_stress    $myOBJPATH
                cp -rf pi_stress     $myOBJPATH
                cp -rf pmqtest       $myOBJPATH
                cp -rf ptsematest    $myOBJPATH
                cp -rf rt-migrate-test     $myOBJPATH
                cp -rf sendme        $myOBJPATH
                cp -rf signaltest    $myOBJPATH
                cp -rf sigwaittest   $myOBJPATH
                cp -rf svsematest   $myOBJPATH
                make clean
                popd
        fi
}

build_stressapptest ()
{
        SrcPath=${BENCH_PATH}"310.stressapptest"
        MYPWD=${PWD}
        BuildPATH="$MYPWD/build.stressapptest"
   TOP_SRCDIR="$MYPWD/$SrcPath"
   myOBJPATH=${OBJPATH}/bin

        if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]
        then
            mkdir -p $BuildPATH
                pushd $BuildPATH
            $TOP_SRCDIR/configure
            make
            cp src/stressapptest ../$myOBJPATH/
            popd
            rm -rf $BuildPATH
        fi

        if [ $ARCH = "arm_64" -o $ARCH = "arm_32" ]
        then
                mkdir -p $BuildPATH
                pushd $BuildPATH
            if [ $ARCH = "arm_32" ]; then
                $TOP_SRCDIR/configure --target=armv7a-none-linux-gnueabi --host=$ARMCROSS
            else
                $TOP_SRCDIR/configure #--target=armv8a-none-linux-gnueabi --host=$ARMCROSS
            fi
                make
                cp src/stressapptest ../$myOBJPATH/
                popd
                rm -rf $BuildPATH
        fi

        if [ $ARCH = "android" ]
        then
      pushd $SrcPath
                ndk-build
      cp libs/armeabi/stressapptest ../$myOBJPATH/
      ndk-build distclean
      rm -rf libs obj
      popd
        fi
}

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

##
## arm server platform does not support java script engine
##
build_v8() {
   SrcPath=${BENCH_PATH}"440.v8"
   myOBJPATH="${OBJPATH}/browser"
    BROWSER=${BENCH_PATH}/441.browser
   rm -rf   $myOBJPATH
   mkdir -p $myOBJPATH
    if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]
   then
      pushd $SrcPath
      make werror=no x64.release
      cp  out/x64.release/d8  ../../$myOBJPATH/
      make clean
      popd
      cp -rf $BROWSER/v8benchmark      $myOBJPATH/
      cp -rf $BROWSER/octane-bench     $myOBJPATH/
      cp -rf $BROWSER/sunspider-bench  $myOBJPATH/
      cp -rf $BROWSER/CanvasMark       $myOBJPATH/
      cp -rf $BROWSER/webgl-bench      $myOBJPATH/
      rm -rf `find $SrcPath/build/ -name "*.pyc" -print`
      rm -rf $SrcPath/tools/jsmin.pyc
      rm -rf $SrcPath/out/* -rf
   fi

        if [ $ARCH = "android" ]
        then
                pushd $SrcPath
      make android_arm.release ANDROID_NDK_ROOT=$ANDROID_NDK_PATH ANDROID_NDK_HOST_ARCH=x86 armfpu=neon armfloatabi=softfp
      cp out/android_arm.release/d8 ../../$myOBJPATH/
                make clean
                popd
                cp -rf $BROWSER/v8benchmark      $myOBJPATH/
                cp -rf $BROWSER/octane-bench     $myOBJPATH/
                cp -rf $BROWSER/sunspider-bench  $myOBJPATH/
                cp -rf $BROWSER/CanvasMark       $myOBJPATH/
                cp -rf $BROWSER/webgl-bench      $myOBJPATH/
      rm -rf `find $SrcPath/build/ -name "*.pyc" -print`
      rm -rf $SrcPath/tools/jsmin.pyc
      rm -rf $SrcPath/out/* -rf
        fi
}

build_jvm() {
   SrcPath=${BENCH_PATH}"444.jvm"
   myOBJPATH="${OBJPATH}/jvm"
   mkdir -p $myOBJPATH

    if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]
   then
      pushd $SrcPath/JavaGrandeForum
      ./build.sh
      mv jgf_section1.jar       ../../../$myOBJPATH/
      mv jgf_section2.jar       ../../../$myOBJPATH/
      mv jgf_section3.jar       ../../../$myOBJPATH/
       cp section3/tunnel.dat    ../../../$myOBJPATH/
      mkdir -p                  ../../../$myOBJPATH/Data
      cp section3/Data/hitData           ../../../$myOBJPATH/Data/ 
      popd

      pushd $SrcPath/LinkpackJava
      ./build.sh
      mv Linpack.jar           ../../../$myOBJPATH/
      popd

      pushd $SrcPath/scimark2
      ./build.sh
      mv scimark2.jar          ../../../$myOBJPATH/
      popd

      pushd $SrcPath/GCBench
      ./build.sh
      mv GCBench.jar           ../../../$myOBJPATH/
      popd
   fi

        if [ $ARCH = "arm_64" -o $ARCH = "arm_32" ]
        then
                pushd $SrcPath/JavaGrandeForum
                ./build.sh
                mv jgf_section1.jar       ../../../$myOBJPATH/
                mv jgf_section2.jar       ../../../$myOBJPATH/
                mv jgf_section3.jar       ../../../$myOBJPATH/
                cp section3/tunnel.dat    ../../../$myOBJPATH/
                mkdir -p                  ../../../$myOBJPATH/Data
                cp section3/Data/hitData           ../../../$myOBJPATH/Data/
                popd

                pushd $SrcPath/LinkpackJava
                ./build.sh
                mv Linpack.jar           ../../../$myOBJPATH/
                popd

                pushd $SrcPath/scimark2
                ./build.sh
                mv scimark2.jar          ../../../$myOBJPATH/
                popd

      pushd $SrcPath/GCBench
      ./build.sh
      mv GCBench.jar           ../../../$myOBJPATH/
      popd
        fi

        if [ $ARCH = "android" ]
        then
                pushd $SrcPath/JavaGrandeForum
                ./build.sh
      dx --dex   --output=jgf_section1.dex jgf_section1.jar
      dx --dex   --output=jgf_section2.dex jgf_section2.jar
      dx --dex   --output=jgf_section3.dex jgf_section3.jar
      rm -rf jgf_section1.jar jgf_section2.jar jgf_section3.jar
                mv jgf_section1.dex       ../../../$myOBJPATH/
                mv jgf_section2.dex       ../../../$myOBJPATH/
                mv jgf_section3.dex       ../../../$myOBJPATH/
                cp section3/tunnel.dat    ../../$myOBJPATH/
                mkdir -p                  ../../$myOBJPATH/Data
                cp section3/Data/hitData           ../../../$myOBJPATH/Data/
                popd

                pushd $SrcPath/LinkpackJava
                ./build.sh
      dx --dex   --output=Linpack.dex Linpack.jar
      rm -rf Linpack.jar
                mv Linpack.dex           ../../../$myOBJPATH/
                popd

                pushd $SrcPath/scimark2
                ./build.sh
      dx --dex   --output=scimark2.dex scimark2.jar
      rm -rf scimark2.jar
                mv scimark2.dex          ../../../$myOBJPATH/
                popd

      pushd $SrcPath/GCBench
      ./build.sh
      dx --dex   --output=GCBench.dex GCBench.jar
      mv GCBench.dex           ../../../$myOBJPATH/
      popd
        fi
}

build_glmark2() {
   SrcPath=${BENCH_PATH}"442.glmark2"
   myOBJPATH=${OBJPATH}/bin

   if [ $ARCH = "android" ]
   then
      #pushd $SrcPath
      #cd android
      #ndk-build
      #android   update project -p . -s -t 1
      #ant  debug
      #popd

      cp ${BENCH_PATH}/android/Glmark2-debug.apk $myOBJPATH
   fi
}

build_ffmpeg() {
        SrcPath=${BENCH_PATH}"443.ffmpeg"
        MYPWD=${PWD}
        BuildPATH="$MYPWD/build.ffmpeg"
        TOP_SRCDIR="$MYPWD/$SrcPath"
   myOBJPATH=${OBJPATH}/bin

   rm -rf $BuildPATH
        if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]
        then
      mkdir -p $BuildPATH
      pushd $BuildPATH
      $TOP_SRCDIR/configure --disable-yasm  --target-os=linux  --enable-demuxers --enable-decoders --enable-decoder=flac --disable-stripping --disable-ffserver --disable-ffprobe --enable-muxer=spdif --disable-devices --enable-parsers --disable-bsfs --disable-protocols --enable-protocol=file   --disable-postproc --disable-logging
      make
      $STRIP ffmpeg
      cp    ffmpeg  ../$myOBJPATH/
           popd
      rm -rf $BuildPATH
        fi

        if [ $ARCH = "arm_32" ]
   then
                mkdir -p $BuildPATH
                pushd $BuildPATH
      $TOP_SRCDIR/configure --disable-yasm  --target-os=linux --arch=arm --enable-demuxers --enable-decoders --enable-decoder=flac --disable-stripping --enable-ffmpeg --disable-ffplay --disable-ffserver --disable-ffprobe --disable-encoders --disable-muxers --enable-muxer=spdif --disable-devices --enable-parsers --disable-bsfs --disable-protocols --enable-protocol=file --disable-protocol=http --disable-protocol=https --disable-protocol=udp --disable-filters --disable-avdevice --enable-cross-compile --cross-prefix=${ARMCROSS}-  --disable-neon --disable-postproc --disable-logging --extra-cflags="-mfpu=vfpv4 "
                make
                $STRIP ffmpeg
                cp    ffmpeg  ../$myOBJPATH/
                popd
                rm -rf $BuildPATH
   fi
}

build_prepare() {
   OBJPATH=$OBJDIR/$ARCH
   rm -rf $OBJPATH
   mkdir -p $OBJPATH/bin
    mkdir -p $OBJDIR/output

    #cp script/common.py  $OBJPATH
    #cp -r script/  $OBJPATH
    cp -r server/parser_process/show_output/output/ $OBJPATH
    #cp -r test_cases_cfg $OBJPATH

    #cp script/run/run.py $OBJPATH/run.py
    #cp script/parser_process/parser.py $OBJPATH/parser.py
   #if [ $ARCH = "x86" ]; then
    ##modified by wuyanjun 9-16
    #cp script/common/run.sh $OBJPATH/run.sh
   ##  cp script/common.sh $OBJPATH/

    ##   add by wuyanjun 2014-09-11
    ##cp script/common/lmbench_run.sh $OBJPATH/
    #cp script/common/ltp_run.sh $OBJPATH/
    ##cp script/*.py  $OBJPATH
   #fi
    #if [ $ARCH = "arm" ]; then
    ##cp script/arm_run.sh $OBJPATH/run.sh
    #cp script/common/run.sh $OBJPATH
    ##cp script/common.sh $OBJPATH/
    #fi
   #if [ $ARCH = "android" ]; then
   #   export PATH=$PATH:$ANDROIDPATH/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.7/bin
   #   cp script/android_run.sh $OBJPATH/run.sh
   #   cp script/common.sh $OBJPATH/
   #fi
}

build_cleanup()
{
    BIN_PATH=$OBJPATH/bin
    if [ "`ls -A $BIN_PATH`" = "" ]; then
        rm -fr $BIN_PATH
    fi
}

OBJDIR=gen
if [ $# -eq 0 ]; then
   ARCH=x86_64
else
   ARCH=$1
fi
if [ $ARCH = "arm_32" ]; then
   ARMCROSS=arm-linux-gnueabihf
   GCC=${ARMCROSS}-gcc
   STRIP=${ARMCROSS}-strip
elif [ $ARCH = "arm_64" ]; then
   ARMCROSS=aarch64-linux-gnu
   GCC=${ARMCROSS}-gcc
   STRIP=${ARMCROSS}-strip
fi

if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]; then
   GCC=gcc
   STRIP=strip
fi
if [ $ARCH = "android" ]; then
   #ANDROID_NDK_PATH=/opt/android-ndk-r9d
   ANDROID_SDK_PATH=/opt/android-sdk-linux
   # for dx command usage, converting jar package into dex package
   export PATH=$PATH:$ANDROID_SDK_PATH/build-tools/19.1.0
 ANDROIDCROSS=$ANDROID_NDK_PATH/toolchains/arm-linux-androideabi-4.8/prebuilt/linux-x86/bin/arm-linux-androideabi-
   ANDROIDGCC=${ANDROIDCROSS}gcc
   ANDROIDSYSROOT=$ANDROID_NDK_PATH/platforms/android-19/arch-arm
fi

set -e
build_prepare
BENCH_PATH="benchmarks/"
#
#changed by wuyanjun
# 2014-9-11
#
# function test suite building
#build_ToolsCheck
#build_ltp
#build_powerMgr
#build_openPosix
##
### realtime test suite building
#build_rttest
##
## stress test suite building
#build_stressapptest
#
## cpu benchmark building
#build_coremark
#build_linpack
#build_scimark
#build_openssl
#build_lmbench
#build_nbench
#build_dhrystone
#
## memory benchmark building
#build_cachebench
#build_memspeed
#build_ARMmemspeed
#
## network benchmark building
#build_ethtool
#build_iperf
#build_netperf
#
## disk/filesystem benchmark building
#build_iozone
#build_dbench
#
### v8 javascript engine
#build_v8
#
### build JVM testsuite
#build_jvm
#
### build glmark2 testsuite
#build_glmark2
#
## ffmpeg video codec benchmark
#build_ffmpeg
#

build_cleanup
