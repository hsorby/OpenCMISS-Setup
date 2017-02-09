.. _`setup options`:

-------------------------------
Setup customisation and options
-------------------------------

The main purpose of this setup script is to simplify the installation of the OpenCMISS libraries, by design it is limited in the configurability it offers.  If you need to change settings that are not available through this script then consider a manual installation as described in _`manaage build instructions`.

This OpenCMISS setup script provides a basic OpenCMISS libraries installation suitable for most users by default.  If a more advanced installation configuration is required, setup an
installation without performing an initial build and then access the more advanced installation configuration options from the manage build directory (refer to the documentation `here <manage configuration>`_).

Below is a summary of the options that can be set.

 - :cmake:`OPENCMISS_SETUP_TYPE` this option sets the type of installation to create.  The available options are: default; libraries; dependencies; cmake_modules.
 - :cmake:`OPENCMISS_VERSION` this option sets the version of OpenCMISS to create (currently the only possible version is 'develop').
 - :cmake:`OPENCMISS_PERFORM_INITIAL_BUILD` this option sets whether an initial build is performed immediately or not.   
 - :cmake:`OPENCMISS_MULTI_ARCHITECTURE` this option sets whether multiple archtictures are required.  Once set for an installation this setting cannot be changed.
 - :cmake:`OPENCMISS_INDEPENDENT` this option sets whether the locations of the libraries, dependencies, CMake modules, and manage directories are independent of each other.
 - :cmake:`OPENCMISS_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_LIBRARIES_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_DEPENDENCIES_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_CMAKE_MODULES_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_MANAGE_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_IRON_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_ZINC_ROOT` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.
 - :cmake:`OPENCMISS_DEPENDENCIES_INSTALL_PREFIX` this option sets the root location of the installation.  Dependent on the value of option :cmake:`OPENCMISS_INDEPENDENT` and the value of :cmake:`OPENCMISS_SETUP_TYPE`.

Setup configuration options
===========================

These are the options available with full details.

.. toctree::
   :maxdepth: 1
   
   config

.. _`intercomponent`:

OpenCMISS inter-component configuration
---------------------------------------
.. cmake-source:: ../../Config/OpenCMISSInterComponentConfig.cmake
   
.. _OpenCMISSInstallaionConfig:
.. _installationconf:
   
