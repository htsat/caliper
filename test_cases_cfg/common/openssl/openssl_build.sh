#do_msg()
#{
#    OBJ=$1
#    ACTION=$2
#    echo "========================================================="
#    echo "$OBJ - $ACTION"
#    echo "========================================================="
#}

build_openssl() {
        OBJ="Building openssl"
        do_msg $OBJ "start"
echo $OBJPATH
        SrcPath="benchmarks/403.openssl"
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
        if [ $ARCH = "arm_32" -o $ARCH = 'arm_64' ]; then  #-o $ARCH = "arm_64"
            cp -rf $TOP_SRCDIR/* $BuildPATH/
            pushd $BuildPATH
            if [ $ARCH = "arm_32" ] ; then
                CC=$GCC ./Configure linux-armv4
            else
                CC=$GCC ./Configure linux-arm64
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

build_openssl
