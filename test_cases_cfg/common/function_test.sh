
run_function_test() {
   echo "**     LTP test suite       **"        1>>result.txt  2>>error.txt
   cd ltp/
   ./runltp -c 2 -i 2 -m 2,4,10240,1 -D 2,10,10240,1 -p -q -l /tmp/ltp_result.log -o /tmp/ltp_output.log
   cd ../
   mv /tmp/ltp_result.log ./
   mv /tmp/ltp_output.log ./

   echo "**     cpu hotplug test suite       **"        1>>result.txt  2>>error.txt
   cd ltp/
   ./runltp  -p  -f cpuhotplug -l /tmp/ltp_result.log
   cd ../
   cat /tmp/ltp_result.log  >> result.txt
   rm /tmp/ltp_result.log

   echo "**     OpenPosixTestsuite test suite       **"        1>>result.txt  2>>error.txt
   cd OpenPosixTestsuite
   make
   cp logfile.conformance-all ../
   cp logfile.functional-all ../
   cp logfile.stress-all ../
   make clean
   cd ../
}

run_function_test
