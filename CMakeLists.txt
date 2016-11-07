########################################################
# Welcome to the OpenCMISS build system!
########################################################
# This script realises the top-level setup phase.
# One of it's jobs is to make sure you have the minimum cmake version available (if not, you can have us build it for you).
#
# The easiest thing to do is nothing: CMake will determine from the current environment the system's setup and try to use that.
# Otherwise, here's what you can configure at this stage:
#
# Configuration options
# ########################################################
# Specify any of the following variables on the command line via -DVARNAME=VALUE or set them in your CMake GUI.
# The values in brackets indicate the default values, where [] denotes not set and | separates alternatives.
#

cmake_minimum_required(VERSION 2.6 FATAL_ERROR)

project(OpenCMISS-Setup)

include(ExternalProject)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")

# This ensures that CMake is new enough before anything else is done
# If its too old, the script will stop with an appropriate error message.
# The option is to either come up with a sufficiently new version yourself,
# or to build cmake using the (then generated) "cmake" target.
include(OCCMakeCheck)
# Need to make this outside the include as the return is intended for the main level
if (NOT CMAKE_COMPATIBLE)
    return()
endif(NOT CMAKE_COMPATIBLE)

# Clean up GUI options
mark_as_advanced(QT_QMAKE_EXECUTABLE)
if (APPLE)
  mark_as_advanced(CMAKE_OSX_ARCHITECTURES)
  mark_as_advanced(CMAKE_CODEBLOCKS_EXECUTABLE)
  mark_as_advanced(CMAKE_OSX_DEPLOYMENT_TARGET)
  mark_as_advanced(CMAKE_OSX_SYSROOT)
endif ()

set(OPENCMISS_MULTIUSER FALSE CACHE BOOL "Setup for a multi-user installation, multi-user installations only sets up the modules and dependencies.")
set(OPENCMISS_INDEPENDENT FALSE CACHE BOOL "Setup with independent locations for libraries, dependencies, modules, and manage script.")
set(OPENCMISS_VERSION "develop" CACHE STRING "The branch or tag to setup.")
set(OPENCMISS_PERFORM_INITIAL_BUILD TRUE CACHE BOOL "Configure, build and install the default settings.")
set(OPENCMISS_MULTI_ARCHITECTURE FALSE CACHE BOOL "Setup for a multi architecture build.")

if (OPENCMISS_INDEPENDENT)
  set(OPENCMISS_LIBRARIES_ROOT "" CACHE PATH "The location for OpenCMISS libraires Iron and Zinc.")
  set(OPENCMISS_DEPENDENCIES_ROOT "" CACHE PATH "The location for the OpenCMISS dependencies.")
  set(OPENCMISS_MANAGE_ROOT "" CACHE PATH "The location for the OpenCMISS manage directory.")
  set(OPENCMISS_MODULES_ROOT "" CACHE PATH "The location for the OpenCMISS CMake modules.")
  unset(OPENCMISS_ROOT CACHE)
else ()
  set(OPENCMISS_ROOT "" CACHE PATH "Root directory for OpenCMISS.")
  unset(OPENCMISS_LIBRARIES_ROOT CACHE)
  unset(OPENCMISS_DEPENDENCIES_ROOT CACHE)
  unset(OPENCMISS_MODULES_ROOT CACHE)
  unset(OPENCMISS_MANAGE_ROOT CACHE)
endif ()

set(SETUP_PROJECTS MODULES MANAGE)

if (OPENCMISS_MULTIUSER)
    set(OPENCMISS_MULTI_ARCHITECTURE TRUE CACHE BOOL "Setup for a multi architecture build.")
else ()
    set(INDEPENDENT_ROOTS LIBRARIES MODULES DEPENDENCIES MANAGE)
endif ()

# Internalise some variables
set(CMAKE_BUILD_TYPE "" CACHE INTERNAL "Internalise CMAKE_BUILD_TYPE")
set(CMAKE_INSTALL_PREFIX "" CACHE INTERNAL "Internalise CMAKE_INSTALL_PREFIX")

find_package(Git)

set(GITHUB_ORGANISATION hsorby) # Should be 'OpenCMISS'
if (GIT_FOUND)
  set(GITHUB_PROTOCOL "git@github.com:")
  set(GITHUB_EXT ".git")
  set(GITHUB_BRANCH master)
else ()
  set(GITHUB_PROTOCOL "https://github.com/")
  set(GITHUB_BRANCH master)
endif ()

# Check sanity of configuration.
set(VALID_CONFIG TRUE)
set(ERROR_MSG)
if (DEFINED OPENCMISS_ROOT)
  if (NOT EXISTS ${OPENCMISS_ROOT})
    set(VALID_CONFIG FALSE)
    list(APPEND ERROR_MSG "OpenCMISS root location '${OPENCMISS_ROOT}' does not exist")
  endif ()
else ()
  foreach (ROOT ${INDEPENDENT_ROOTS})
    if (NOT EXISTS ${OPENCMISS_${ROOT}_ROOT})
      set(VALID_CONFIG FALSE)
      list(APPEND ERROR_MSG "${ROOT} root location '${OPENCMISS_${ROOT}_ROOT}' does not exist")
    endif ()
  endforeach ()
endif ()

if (NOT VALID_CONFIG)
	foreach (msg ${ERROR_MSG})
		message(SEND_ERROR "${msg}")
	endforeach ()
	message(FATAL_ERROR "Invalid configuration.")
endif ()

# Everything should be valid from here onwards.
if (DEFINED OPENCMISS_ROOT)
  set(OPENCMISS_LIBRARIES_ROOT "${OPENCMISS_ROOT}/src")
  set(OPENCMISS_MANAGE_SOURCE_DIR "${OPENCMISS_ROOT}/src/manage")
  set(OPENCMISS_MANAGE_BINARY_DIR "${OPENCMISS_ROOT}/build/manage")
  set(OPENCMISS_DEPENDENCIES_ROOT "${OPENCMISS_ROOT}/src/dependencies")
  set(OPENCMISS_MODULES_ROOT "${OPENCMISS_ROOT}/install/cmake")
else ()
  set(OPENCMISS_MANAGE_SOURCE_DIR "${OPENCMISS_MANAGE_ROOT}/src")
  set(OPENCMISS_MANAGE_BINARY_DIR "${OPENCMISS_MANAGE_ROOT}/build")
endif ()

set(MANAGE_CONFIGURE_CMD "")
set(MANAGE_BUILD_CMD "")
set(MANAGE_INSTALL_CMD "")

if (OPENCMISS_PERFORM_INITIAL_BUILD)
  set(MANAGE_CONFIGURE_CMD "${CMAKE_COMMAND}")

  if (NOT OPENCMISS_MULTI_ARCHITECTURE)
    list(APPEND MANAGE_CONFIGURE_CMD -DOC_USE_ARCHITECTURE_PATH=FALSE)
  endif ()

  if (DEFINED OPENCMISS_ROOT)
  else ()
    list(APPEND MANAGE_CONFIGURE_CMD -DOPENCMISS_LIBRARIES_ROOT=${OPENCMISS_LIBRARIES_ROOT})
    list(APPEND MANAGE_CONFIGURE_CMD -DOPENCMISS_DEPENDENCIES_ROOT=${OPENCMISS_DEPENDENCIES_ROOT})
  endif ()
  list(APPEND MANAGE_CONFIGURE_CMD "-DOPENCMISS_MODULE_PATH=${OPENCMISS_MODULES_ROOT}")
  list(APPEND MANAGE_CONFIGURE_CMD "${OPENCMISS_MANAGE_SOURCE_DIR}")
  set(MANAGE_BUILD_CMD ${CMAKE_COMMAND} --build .)
endif ()

foreach (SETUP_PROJECT ${SETUP_PROJECTS})
  if (${SETUP_PROJECT} STREQUAL "MODULES")
    set(REPOSITORY_NAME OpenCMISS-CMake-Modules)
    set(GITHUB_BRANCH ${OPENCMISS_VERSION})
  elseif (${SETUP_PROJECT} STREQUAL "MANAGE")
    set(REPOSITORY_NAME OpenCMISS-Manage)
    set(GITHUB_BRANCH ${OPENCMISS_VERSION})
  else ()
    set(REPOSITORY_NAME ${SETUP_PROJECT})
  endif ()
  set(GITHUB_REPO ${GITHUB_PROTOCOL}${GITHUB_ORGANISATION}/${REPOSITORY_NAME}${GITHUB_EXT})
  if (GIT_FOUND)
    set(DOWNLOAD_${SETUP_PROJECT}_CMD
      GIT_REPOSITORY ${GITHUB_REPO}
      GIT_TAG ${GITHUB_BRANCH}
    )
  else ()
    set(DOWNLOAD_${SETUP_PROJECT}_CMD
      URL ${GITHUB_REPO}/archive/${GITHUB_BRANCH}.zip
    )
  endif ()
endforeach()

ExternalProject_Add(setup_modules
  ${DOWNLOAD_MODULES_CMD}
  SOURCE_DIR "${OPENCMISS_MODULES_ROOT}"
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
)

ExternalProject_Add(setup_manage
  DEPENDS setup_modules
  ${DOWNLOAD_MANAGE_CMD}
  SOURCE_DIR "${OPENCMISS_MANAGE_SOURCE_DIR}"
  BINARY_DIR "${OPENCMISS_MANAGE_BINARY_DIR}"
  CONFIGURE_COMMAND "${MANAGE_CONFIGURE_CMD}"
  BUILD_COMMAND "${MANAGE_BUILD_CMD}"
  INSTALL_COMMAND "${MANAGE_INSTALL_CMD}"
)

