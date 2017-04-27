
=======
Windows
=======

To build a 'Release' version of the OpenCMISS libraries.

::

 mkdir opencmiss
 mkdir setup-build
 git clone https://github.com/OpenCMISS/setup.git
 cd setup-build
 cmake -DOPENCMISS_ROOT=..\opencmiss -G"Visual Studio 14 2015 Win64" ..\setup
 cmake --build .

To build a 'Debug' version of the OpenCMISS libraries replace the sixth command above with::

 cmake --build . --config=Debug

To build only a 'Debug' version of the 'iron' library replace the fifth and sixth commands above with::

 cmake -DOPENCMISS_LIBRARIES=iron -DOPENCMISS_ROOT=..\opencmiss -G"Visual Studio 14 2015 Win64" ..\setup
 cmake --build . --config=Debug
