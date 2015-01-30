##chenxiang c00284940
##chenxiang66@hisilicon.com

build_fio()
{
   SrcPath="./benchmarks/432.fio"

   if [ $ARCH = "x86_64" -o $ARCH = "x86_32" ]
      then
          echo $SrcPath
      pushd $SrcPath
      make clean
      ./configure
      make -j16
      #make install
      cp ./fio  ../../$OBJPATH/bin
      popd
   fi
    if [ $ARCH = "arm_64" -o $ARCH = "arm_32" ]
      then
          echo $SrcPath
      pushd $SrcPath
      make clean
      if [ $ARCH = "arm_32" ]
      then
          ./configure --cpu=arm --cc=arm-linux-gnueabihf-gcc
          make
          cp ./fio ../../$OBJPATH/bin
      fi
      if [ $ARCH = "arm_64" ]
      then
          ./configure --cpu=arm --cc=aarch64-linux-gnu-gcc
          make
          #make install
      fi
      cp ./fio ../../$OBJPATH/bin
      popd
   fi
}

build_fio


