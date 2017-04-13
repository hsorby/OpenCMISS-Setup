
.. title:: OpenCMISS Setup Build Script

============================  
OpenCMISS Setup Build Script
============================

The main purpose of this setup script is to simplify the installation of the OpenCMISS libraries, by design it is limited in the configurability it offers.  If you need to change settings that are not available through this script then consider a manual installation as described in _`manaage build instructions`.

This OpenCMISS setup script provides a basic OpenCMISS libraries installation suitable for most users by default.  If a more advanced installation configuration is required, setup an
installation without performing an initial build and then access the more advanced installation configuration options from the manage build directory (refer to the documentation `here <manage configuration>`_).

This setup script can be used from the command line or with a CMake configuration and generation GUI.

It is recommended to have installed and available 'git' DVCS application.  WHile it is possible to create an installation without git the substitution of the git clone commands with the appropreiate zip archive commands is left as an exerdise for the reader.

Once installed the created directory setup-build can be removed, it is of not further use.

Instructions for use
====================

The setup script makes use of CMake the cross-platform build command generation tool.  The OpenCMISS libraries build requires the version of CMake
to be at least 3.4.0.  If the current CMake available is less than this version number then there are two options to resolve this problem::

  1. Downlad and install CMake in a manner suitable for the current platform that has a sufficient version number.
  2. Allow this script to configure, build, and install a suitable version of CMake. 
  
Either way the CMake invoked to make use of this script and therefore used to create the installation must meet the minimum version requirement.

The default configuration of this script creates an installation under a single existing directory OPENCMISS_ROOT.  The limited configuration 
options allow for installations to have independent roots where the individual parts of the installation the libraries, dependencies, manage scripts, and CMake modules
all have their own root location.  Again these roots must be existing directories.  This script may also be used to create an installation of the libraries only
and make use of an existing installation's dependencies and CMake modules [work in progress].

This script will perform the initial build unless configured not to.  This means that on finishing the first phase of the script, the installation of the CMake modules and manage files, a 'release' or optimised build of the OpenCMISS libraries will commence.  When a successful build completes there will be under the OPENCMISS_ROOT directory an install tree of a working OpenCMISS libraries installation.

For more information on the different configuration options read the full option description documentation at the end of this section.

The following sub-sections cover creating a default installation in different platform scenarios.  The following commands assume a directory has already been created under which the OpenCMISS libraries will be placed.

GNU/Linux Command Line
----------------------

The following commands should be with minor changes suitable for most variants of GNU/Linux.

::

   

Mac OS X Command Line
---------------------
  

For more details on the configurable options the following gives a full explanation of each option.

.. toctree::
   :maxdepth: 1
   
   config/index
   

.. note::

   The root directories must exist for the setup script to generate the desired build commands.

Getting help
============
   
.. toctree::
   :maxdepth: 1
   
   support

.. _Iron: https://github.com/OpenCMISS/iron
.. _`OpenCMISS`: http://www.opencmiss.org
.. _Zinc: /documentation/zinc
.. _`OpenCMISS manage project`: https://github.com/OpenCMISS/manage


