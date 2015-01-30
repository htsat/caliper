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

build_ToolsCheck
