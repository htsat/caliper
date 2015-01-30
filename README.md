###   Caliper

####1. Introduction

    Caliper is a test suite focused on functional integrity and performance of boards, it not only
    detects if the hardware and software on the board can work, but also tests the performance.
    Caliper can be run on boards to generate the test data, then converse the test data to scores
    by using a series of formulas so that the test data can be easily to read, thereby intuitively
    showing various performance values and helping to analyze the performance gaps of the boards.
    Caliper鈥檚 ultimate goals: one hand is that it can generate a series of test data which provides
    inputs for optimization of specific boards or SoC platforms; the other hand, it helps to analyze
    the functional stability and performance capability of software solution (such as Estuary and
    Harmonic) on hardware platforms.

####2. Status

    Caliper now only integrate lmbench, and it can only select three Test Points; they are latency,
    network and memory. And it use some the formulas to traverse the results to scores. In the
    later version, we will integrate more benchmarks.

####3. How to use?

    Can be found in the Wiki.

####4. How to Contribute?

    Can be found in the Wiki.

####5. The Future Work
   
    Can be found in the Wiki.
