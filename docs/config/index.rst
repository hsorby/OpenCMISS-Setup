.. _`setup options`:

-------------------------------
Setup customisation and options
-------------------------------

Below is a summary of the options that can be set.

 - :cmake:`OPENCMISS_SETUP_TYPE` this option sets the type of installation to create.  The available options are: default; libraries; dependencies; cmake_modules.
 - :cmake:`OPENCMISS_VERSION` this option sets the version of OpenCMISS to create (currently the only possible version is 'develop').
 - :cmake:`OPENCMISS_PERFORM_INITIAL_BUILD` this option sets whether an initial build is performed immediately or not.   
 - :cmake:`OPENCMISS_MULTI_ARCHITECTURE` this option sets whether multiple archtictures are required.  Once set for an installation this setting cannot be changed.
 - :cmake:`OPENCMISS_INDEPENDENT` this option sets whether the locations of the libraries, dependencies, CMake modules, and manage directories are independent of each other.
 - :cmake:`OPENCMISS_ROOT` this option sets the root location of the installation.
 - :cmake:`OPENCMISS_LIBRARIES_ROOT` this option sets the root location of the installation. 
 - :cmake:`OPENCMISS_DEPENDENCIES_ROOT` this option sets the root location of the installation.
 - :cmake:`OPENCMISS_CMAKE_MODULES_ROOT` this option sets the root location of the installation.
 - :cmake:`OPENCMISS_MANAGE_ROOT` this option sets the root location of the installation.
 - :cmake:`OPENCMISS_IRON_ROOT` this option sets the root location of the installation.
 - :cmake:`OPENCMISS_ZINC_ROOT` this option sets the root location of the installation.
 - :cmake:`OPENCMISS_DEPENDENCIES_INSTALL_PREFIX` this option sets the root location of the dependencies installation.
 - :cmake:`OPENCMISS_CMAKE_MODULES_INSTALL_PREFIX` this option sets the root location of the CMake modules installation.

Setup configuration options
===========================

Below are all the options available with full details.

.. toctree::
   :maxdepth: 1
   
   config
