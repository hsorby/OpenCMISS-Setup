.. _`opencmiss librarries setup script options`:

=======
Options
=======

Below is a summary of the options that can be set.

 - :cmake:`OPENCMISS_SETUP_TYPE` this option sets the type of installation to create.  The available options are: default; libraries; dependencies; cmake_modules.
 - :cmake:`OPENCMISS_INDEPENDENT` this option sets whether the locations of the libraries, dependencies, CMake modules, and manage directories are independent of each other.
 - :cmake:`OPENCMISS_PERFORM_INITIAL_BUILD` this option sets whether an initial build is performed immediately or not.   

The following configuration variables are dependent of the value of :cmake:`OPENCMISS_PERFORM_INITIAL_BUILD`, if the value of this variable is false then the following configuration variables will not be visible/configurable.

 - :cmake:`OPENCMISS_LIBRARIES` this option sets which libraries should be built.  The possible values are: all; iron; zinc.
 - :cmake:`OPENCMISS_CONFIG_BUILD_TYPE` this option sets the build type of the libraries.  The possible values are: Debug; Release; RelWithDebInfo, MinSizeRel.
 - :cmake:`OPENCMISS_VERSION` this option sets the version of OpenCMISS to create (currently the only possible version is 'develop').
 - :cmake:`OPENCMISS_MULTI_ARCHITECTURE` this option sets whether multiple archtictures are required.  Once set for an installation this setting cannot be changed.

The following locations are dependent on the value of :cmake:`OPENCMISS_INDEPENDENT` and :cmake:`OPENCMISS_LIBRARIES`.  They may or may not be visible/configurable depending on the values of the aforementioned configuration variables.  All 'ROOT' locations must exist *prior* to configuration.

 - :cmake:`OPENCMISS_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_LIBRARIES_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_DEPENDENCIES_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_CMAKE_MODULES_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_MANAGE_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_IRON_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_ZINC_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_DEPENDENCIES_INSTALL_PREFIX` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.

Setup Configuration Options
===========================

Detailed documentation of the configuration options.

.. toctree::
   :maxdepth: 1
   
   config

