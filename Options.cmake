
##
# .. _`opencmiss_version`:
#
# OPENCMISS_VERSION
# -----------------
#
# Set the version of OpenCMISS to create installation for.  The value of this variable must be one of
# the known OpenCMISS versions.
#
# The default value is 'develop'.

set(OPENCMISS_VERSION "develop" CACHE STRING "The branch or tag to setup.  Must be one of: ${KNOWN_OPENCMISS_VERSIONS}")

##
# .. _`opencmiss_setup_type`:
#
# OPENCMISS_SETUP_TYPE
# --------------------
#
# Set the type of OpenCMISS installation to create installation for.  The value of this variable must be one of
# the known OpenCMISS setup types [|standard|, libraries, dependencies, cmake_modules].
#
# The default value is 'standard'.

set(OPENCMISS_SETUP_TYPE "standard" CACHE STRING "The type of OpenCMISS installation to setup.")

##
# .. _`opencmiss_independent`:
#
# OPENCMISS_INDEPENDENT
# ---------------------
#
# A boolean valued variable to set whether the installation should be setup with independent roots or not.  If the 
# value is false a single root variable :cmake:`OPENCMISS_ROOT` is used under which the entire installation of OpenCMISS libraries
# will be placed.
#
# See also: :cmake:`OPENCMISS_SETUP_TYPE`

set(OPENCMISS_INDEPENDENT FALSE CACHE BOOL "Setup with independent locations for libraries, dependencies, modules, and manage script.")

##
# .. _`opencmiss_perform_initial_build`:
#
# OPENCMISS_PERFORM_INITIAL_BUILD
# -------------------------------
#
# A boolean valued variable to set whether the initial configuration should be built once the setup of the OpenCMISS CMake modules 
# and manage projects has been finished.
#
# See also: :cmake:`OPENCMISS_MULTI_ARCHITECTURE`, :cmake:`OPENCMISS_CONFIG_BUILD_TYPE`

set(OPENCMISS_PERFORM_INITIAL_BUILD TRUE CACHE BOOL "Configure, build and install the default settings.")

##
# .. _`opencmiss_multi_architecture`:
#
# OPENCMISS_MULTI_ARCHITECTURE
# ----------------------------
#
# A boolean valued variable to set whether the installation should be setup for multiple architectures (multiple compiler toolchains, MPI).
# If the value is false a only a single architecture will be possible once a configuration has been created.  If the value is true the path to 
# the configuration, build, and install trees will have the path prepended with the details of the architecture (computer architectre/compilers in use/MPI in use).
#
# This option is available only if :cmake:`OPENCMISS_PERFORM_INITIAL_BUILD` is on.
#
# See also: :cmake:`OPENCMISS_PERFORM_INITIAL_BUILD`

set(OPENCMISS_MULTI_ARCHITECTURE FALSE CACHE BOOL "Setup for a multi architecture build.")

##
# .. _`opencmiss_config_build_type`:
#
# OPENCMISS_CONFIG_BUILD_TYPE
# ---------------------------
#
# Set the configuration build type to build.  In multiple configuration environments (like Microsoft Visual Studio) the configuration build type is 
# taken from the active build configuration.
#
# This option is available in single configuration environments and only if :cmake:`OPENCMISS_PERFORM_INITIAL_BUILD` is on.
#
# See also: :cmake:`OPENCMISS_PERFORM_INITIAL_BUILD`

set(OPENCMISS_CONFIG_BUILD_TYPE Release CACHE STRING "Set the configuration build type.")

##
# .. _`opencmiss_libraries`:
#
# OPENCMISS_LIBRARIES
# -------------------
#
# Set the OpenCMISS libraries to build.  The value of this variable must be one of
# the known OpenCMISS libraries build types [|all|, iron, zinc].
#
# The default value is 'all'.

set(OPENCMISS_LIBRARIES "zinc" CACHE STRING "Set which OpenCMISS libraries to build.")

##
# .. _`opencmiss_root`:
#
# OPENCMISS_ROOT
# --------------
#
# The location of the installation for the whole OpenCMISS libraries installation.
#
# Visibility of this variable is subject to the values of :cmake:`OPENCMISS_INDEPENDENT` and :cmake:`OPENCMISS_SETUP_TYPE`

set(OPENCMISS_ROOT "" CACHE PATH "The location of the OpenCMISS root root")

##
# .. _`opencmiss_libraries_root`:
#
# OPENCMISS_LIBRARIES_ROOT
# ------------------------
#
# The location of the installation for the OpenCMISS libraries.
#
# Visibility of this variable is subject to the values of :cmake:`OPENCMISS_INDEPENDENT` and :cmake:`OPENCMISS_SETUP_TYPE`

set(OPENCMISS_LIBRARIES_ROOT "" CACHE PATH "The location of the OpenCMISS root libraries")

##
# .. _`opencmiss_examples_root`:
#
# OPENCMISS_EXAMPLES_ROOT
# ------------------------
#
# The location of the installation for the OpenCMISS examples.
#
# Visibility of this variable is subject to the values of :cmake:`OPENCMISS_INDEPENDENT` and :cmake:`OPENCMISS_SETUP_TYPE`

set(OPENCMISS_EXAMPLES_ROOT "" CACHE PATH "The location of the OpenCMISS root examples")

##
# .. _`opencmiss_dependencies_root`:
#
# OPENCMISS_DEPENDENCIES_ROOT
# ---------------------------
#
# The location of the installation for the OpenCMISS dependencies installation.  This may include the cmake modules if 
# :cmake:`OPENCMISS_INDEPENDENT` is :cmake:`FALSE`.
#
# Visibility of this variable is subject to the values of :cmake:`OPENCMISS_INDEPENDENT` and :cmake:`OPENCMISS_SETUP_TYPE`

set(OPENCMISS_DEPENDENCIES_ROOT "" CACHE PATH "The location of the OpenCMISS root dependencies")

##
# .. _`opencmiss_manage_root`:
#
# OPENCMISS_MANAGE_ROOT
# ---------------------
#
# The location of the installation for the OpenCMISS manage installation.
#
# Visibility of this variable is subject to the values of :cmake:`OPENCMISS_INDEPENDENT` and :cmake:`OPENCMISS_SETUP_TYPE`

set(OPENCMISS_MANAGE_ROOT "" CACHE PATH "The location of the OpenCMISS root manage")

##
# .. _`opencmiss_cmake_modules_root`:
#
# OPENCMISS_CMAKE_MODULES_ROOT
# ----------------------------
#
# The location of the installation for the OpenCMISS CMake modules installation.
#
# Visibility of this variable is subject to the values of :cmake:`OPENCMISS_INDEPENDENT` and :cmake:`OPENCMISS_SETUP_TYPE`

set(OPENCMISS_CMAKE_MODULES_ROOT "" CACHE PATH "The location of the OpenCMISS root CMake modules")

##
# .. _`opencmiss_iron_root`:
#
# OPENCMISS_IRON_ROOT
# -------------------
#
# The location of the installation for the OpenCMISS Iron installation.
#
# Visibility of this variable is subject to the values of :cmake:`OPENCMISS_INDEPENDENT`, :cmake:`OPENCMISS_LIBRARIES` and :cmake:`OPENCMISS_SETUP_TYPE`

set(OPENCMISS_IRON_ROOT "" CACHE PATH "The location of the OpenCMISS root Iron")

##
# .. _`opencmiss_zinc_root`:
#
# OPENCMISS_ZINC_ROOT
# -------------------
#
# The location of the installation for the whole OpenCMISS Zinc installation.
#
# Visibility of this variable is subject to the values of :cmake:`OPENCMISS_INDEPENDENT`, :cmake:`OPENCMISS_LIBRARIES` and :cmake:`OPENCMISS_SETUP_TYPE`

set(OPENCMISS_ZINC_ROOT "" CACHE PATH "The location of the OpenCMISS root Zinc")

##
# .. _`opencmiss_dependencies_install_prefix`:
#
# OPENCMISS_DEPENDENCIES_INSTALL_PREFIX
# -------------------------------------
#
# The prefix for the location of the installed OpenCMISS dependencies.
#
# Visibility of this variable is subject to the values of :cmake:`OPENCMISS_INDEPENDENT` and :cmake:`OPENCMISS_SETUP_TYPE`

set(OPENCMISS_DEPENDENCIES_INSTALL_PREFIX "" CACHE PATH "The prefix for the location of the installed OpenCMISS dependencies")

##
# .. _`opencmiss_cmake_modules_install_prefix`:
#
# OPENCMISS_CMAKE_MODULES_INSTALL_PREFIX
# --------------------------------------
#
# The prefix for the location of the installed OpenCMISS dependencies.
#
# Visibility of this variable is subject to the values of :cmake:`OPENCMISS_INDEPENDENT` and :cmake:`OPENCMISS_SETUP_TYPE`

set(OPENCMISS_CMAKE_MODULES_INSTALL_PREFIX "" CACHE PATH "The prefix for the location of the installed OpenCMISS CMake modules")
