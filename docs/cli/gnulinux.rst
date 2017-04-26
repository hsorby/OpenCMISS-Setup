
=========
GNU/Linux
=========

To build a 'Release' version of the OpenCMISS libraries.

::

 mkdir opencmiss
 mkdir setup-build
 git clone https://github.com/OpenCMISS/setup.git
 cd setup-build
 cmake -DOPENCMISS_ROOT=../opencmiss ../setup
 cmake --build .

To build a 'Debug' version of the OpenCMISS libraries replace the fifth command above with::

 cmake -DOPENCMISS_CONFIG_BUILD_TYPE=Debug -DOPENCMISS_ROOT=../opencmiss ../setup

To build only a 'Debug' version of the 'iron' library replace the fifth command above with::

 cmake -DOPENCMISS_LIBRARIES=iron -DOPENCMISS_CONFIG_BUILD_TYPE=Debug -DOPENCMISS_ROOT=../opencmiss ../setup
