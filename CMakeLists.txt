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
cmake_policy(SET CMP0057 NEW)

include(ExternalProject)

set(SETUP_PROJECTS CMAKE_MODULES MANAGE)

set(MANAGE_REPO hsorby/OpenCMISS-Manage) # Should be 'OpenCMISS/something'
set(CMAKE_MODULES_REPO hsorby/OpenCMISS-CMake-Modules)
set(MANAGE_BRANCH develop)
set(CMAKE_MODULES_BRANCH develop)

set(KNOWN_OPENCMISS_VERSIONS develop)

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

include(OCFunctions)

# Clean up GUI options
mark_as_advanced(QT_QMAKE_EXECUTABLE)
if (APPLE)
    mark_as_advanced(CMAKE_OSX_ARCHITECTURES)
    mark_as_advanced(CMAKE_CODEBLOCKS_EXECUTABLE)
    mark_as_advanced(CMAKE_OSX_DEPLOYMENT_TARGET)
    mark_as_advanced(CMAKE_OSX_SYSROOT)
endif ()

set(OPENCMISS_INDEPENDENT FALSE CACHE BOOL "Setup with independent locations for libraries, dependencies, modules, and manage script.")
set(OPENCMISS_PERFORM_INITIAL_BUILD TRUE CACHE BOOL "Configure, build and install the default settings.")

if (OPENCMISS_INDEPENDENT)
    set(OPENCMISS_LIBRARIES_ROOT "" CACHE PATH "The location for OpenCMISS libraires Iron and Zinc.")
    set(OPENCMISS_DEPENDENCIES_ROOT "" CACHE PATH "The location for the OpenCMISS dependencies.")
    set(OPENCMISS_MANAGE_ROOT "" CACHE PATH "The location for the OpenCMISS manage directory.")
    set(OPENCMISS_CMAKE_MODULES_ROOT "" CACHE PATH "The location for the OpenCMISS CMake modules.")
    unset(OPENCMISS_ROOT CACHE)
else ()
    set(OPENCMISS_ROOT "${OPENCMISS_ROOT}" CACHE PATH "Root directory for OpenCMISS.")
    unset(OPENCMISS_LIBRARIES_ROOT CACHE)
    unset(OPENCMISS_DEPENDENCIES_ROOT CACHE)
    unset(OPENCMISS_CMAKE_MODULES_ROOT CACHE)
    unset(OPENCMISS_MANAGE_ROOT CACHE)
endif ()

if (OPENCMISS_PERFORM_INITIAL_BUILD)
    set(OPENCMISS_MULTI_USER FALSE CACHE BOOL "Setup for a multi-user installation, multi-user installations only sets up the modules and dependencies.")
    set(OPENCMISS_VERSION "develop" CACHE STRING "The branch or tag to setup.  Must be one of: ${KNOWN_OPENCMISS_VERSIONS}")
    set(OPENCMISS_MULTI_ARCHITECTURE FALSE CACHE BOOL "Setup for a multi architecture build.")
else ()
    unset(OPENCMISS_MULTI_USER CACHE)
    unset(OPENCMISS_VERSION CACHE)
    unset(OPENCMISS_MULTI_ARCHITECTURE CACHE)
endif ()

if (NOT OPENCMISS_MULTI_USER)
    set(INDEPENDENT_ROOTS LIBRARIES CMAKE_MODULES DEPENDENCIES MANAGE)
endif ()

# Internalise some variables
set(CMAKE_BUILD_TYPE "" CACHE INTERNAL "Internalise CMAKE_BUILD_TYPE")
set(CMAKE_INSTALL_PREFIX "" CACHE INTERNAL "Internalise CMAKE_INSTALL_PREFIX")

find_package(Git)

if (GIT_FOUND)
    if ( (NOT HAVE_SSH_GITHUB_ACCESS AND NOT SSH_GITHUB_ACCESS_CHECKED) OR FORCE_GITHUB_SSH_CHECK)
        check_ssh_github_access(HAVE_SSH_GITHUB_ACCESS)
        set(SSH_GITHUB_ACCESS_CHECKED TRUE CACHE BOOL "ssh access to github.com checked.")
        mark_as_advanced(SSH_GITHUB_ACCESS_CHECKED)
        message(STATUS "Have ssh access to GitHub.com: ${HAVE_SSH_GITHUB_ACCESS}")
    endif ()
    if (HAVE_SSH_GITHUB_ACCESS)
        set(GITHUB_PROTOCOL "git@github.com:")
    else ()
        set(GITHUB_PROTOCOL "https://github.com/")
    endif ()
    set(GITHUB_EXT ".git")
else ()
    set(GITHUB_PROTOCOL "https://github.com/")
endif ()

# Make all paths CMake paths:
foreach(_path_var OPENCMISS_ROOT OPENCMISS_LIBRARIES_ROOT OPENCMISS_DEPENDENCIES_ROOT OPENCMISS_MANAGE_ROOT OPENCMISS_CMAKE_MODULES_ROOT)
    if (DEFINED ${_path_var})
        file(TO_CMAKE_PATH "${${_path_var}}" ${_path_var})
    endif ()
endforeach()

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

if (NOT ${OPENCMISS_VERSION} IN_LIST KNOWN_OPENCMISS_VERSIONS)
    set(VALID_CONFIG FALSE)
    list(APPEND ERROR_MSG "${OPENCMISS_VERSION} is not a known OpenCMISS version.")
endif ()

if (NOT VALID_CONFIG)
    foreach (msg ${ERROR_MSG})
        message(SEND_ERROR "${msg}")
    endforeach ()
    message(FATAL_ERROR "Invalid configuration.")
endif ()

# Everything should be valid from here onwards.
if (DEFINED OPENCMISS_ROOT)
    set(OPENCMISS_MANAGE_SOURCE_DIR "${OPENCMISS_ROOT}/src/manage")
    set(OPENCMISS_MANAGE_BINARY_DIR "${OPENCMISS_ROOT}/build/manage")
    set(OPENCMISS_CMAKE_MODULES_SOURCE_DIR "${OPENCMISS_ROOT}/src/cmake_modules")
    set(OPENCMISS_CMAKE_MODULES_BINARY_DIR "${OPENCMISS_ROOT}/build/cmake_modules")
    set(OPENCMISS_CMAKE_MODULE_PATH "${OPENCMISS_ROOT}/install/share/cmake")
else ()
    set(OPENCMISS_MANAGE_SOURCE_DIR "${OPENCMISS_MANAGE_ROOT}/src")
    set(OPENCMISS_MANAGE_BINARY_DIR "${OPENCMISS_MANAGE_ROOT}/build")
    set(OPENCMISS_CMAKE_MODULES_SOURCE_DIR "${OPENCMISS_CMAKE_MODULES_ROOT}/src")
    set(OPENCMISS_CMAKE_MODULES_BINARY_DIR "${OPENCMISS_CMAKE_MODULES_ROOT}/build")
    set(OPENCMISS_CMAKE_MODULE_PATH "${OPENCMISS_CMAKE_MODULES_ROOT}/install/share/cmake")
endif ()

set(MANAGE_BUILD_CMD "")
set(MANAGE_INSTALL_CMD "")

# Basic test for multi-configuration capable environments
if (MSVC OR XCODE_VERSION)
    mark_as_advanced(CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_CONFIG --config Release)
    if (OPENCMISS_PERFORM_INITIAL_BUILD)
        list(APPEND MANAGE_BUILD_CMD --config Release)
    endif ()
else ()
    set(CMAKE_CONFIG_BUILD_TYPE -DCMAKE_BUILD_TYPE=Release)
endif ()

if (OPENCMISS_PERFORM_INITIAL_BUILD)
    if (NOT OPENCMISS_MULTI_ARCHITECTURE)
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_USE_ARCHITECTURE_PATH=FALSE)
    endif ()

    if (OPENCMISS_MULTI_USER)
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_DEPENDENCIES_ONLY=TRUE)
    endif ()

    if ("${OPENCMISS_VERSION}" STREQUAL "develop")
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_DEVEL_ALL=YES)
    endif ()

    if (DEFINED OPENCMISS_ROOT)
    else ()
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_LIBRARIES_ROOT=${OPENCMISS_LIBRARIES_ROOT})
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_DEPENDENCIES_ROOT=${OPENCMISS_DEPENDENCIES_ROOT})
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_CMAKE_MODULES_ROOT=${OPENCMISS_CMAKE_MODULES_ROOT})
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_CMAKE_MODULE_PATH=${OPENCMISS_CMAKE_MODULE_PATH})
        list(APPEND CMAKE_MODULES_ARGS -DOPENCMISS_CMAKE_MODULE_PATH=${OPENCMISS_CMAKE_MODULES_PATH})
    endif ()
    set(MANAGE_BUILD_CMD ${CMAKE_COMMAND} --build . --target do_config)
    set(MANAGE_CONFIGURE_SWITCHABLE_COMMAND
        CMAKE_COMMAND ${CMAKE_COMMAND}
        CMAKE_GENERATOR ${CMAKE_GENERATOR}
        CMAKE_ARGS ${CMAKE_CONFIG_BUILD_TYPE} ${MANAGE_CONFIGURE_ARGS}
        )
else ()
    # Turn configure stage of manage off
    set(MANAGE_CONFIGURE_SWITCHABLE_COMMAND CONFIGURE_COMMAND ${CMAKE_COMMAND} -E echo "Skipping configure step for 'setup_manage'")
endif ()

foreach (SETUP_PROJECT ${SETUP_PROJECTS})
    set(GITHUB_BRANCH ${${SETUP_PROJECT}_BRANCH})
    set(GITHUB_REPO ${${SETUP_PROJECT}_REPO})
    if ("${OPENCMISS_VERSION}" STREQUAL "develop")
        set(GITHUB_BRANCH ${OPENCMISS_VERSION})
    endif ()
    set(GITHUB_REPO ${GITHUB_PROTOCOL}${GITHUB_REPO}${GITHUB_EXT})
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
endforeach ()

ExternalProject_Add(setup_modules
    ${DOWNLOAD_CMAKE_MODULES_CMD}
    SOURCE_DIR "${OPENCMISS_CMAKE_MODULES_SOURCE_DIR}"
    BINARY_DIR "${OPENCMISS_CMAKE_MODULES_BINARY_DIR}"
    CMAKE_COMMAND ${CMAKE_COMMAND}
    CMAKE_GENERATOR ${CMAKE_GENERATOR}
    CMAKE_ARGS ${CMAKE_CONFIG_BUILD_TYPE} ${CMAKE_MODULES_ARGS}
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install ${CMAKE_BUILD_CONFIG}
    )

ExternalProject_Add(setup_manage
    DEPENDS setup_modules
    ${DOWNLOAD_MANAGE_CMD}
    SOURCE_DIR "${OPENCMISS_MANAGE_SOURCE_DIR}"
    BINARY_DIR "${OPENCMISS_MANAGE_BINARY_DIR}"
    ${MANAGE_CONFIGURE_SWITCHABLE_COMMAND}
    BUILD_COMMAND "${MANAGE_BUILD_CMD}"
    INSTALL_COMMAND "${MANAGE_INSTALL_CMD}"
    )

set(PRINT_SUMMARY TRUE)
if (PRINT_SUMMARY)
    message(STATUS "@")
    message(STATUS "@@@@@@@@@@@@@@@@@@@@@@@@ SUMMARY @@@@@@@@@@@@@@@@@@@@@@@@")
    message(STATUS "@")
    message(STATUS "@ OPENCMISS_INDEPENDENT: ${OPENCMISS_INDEPENDENT}")
    message(STATUS "@ OPENCMISS_PERFORM_INITIAL_BUILD: ${OPENCMISS_PERFORM_INITIAL_BUILD}")
    if (OPENCMISS_PERFORM_INITIAL_BUILD)
        message(STATUS "@ OPENCMISS_VERSION: ${OPENCMISS_VERSION}")
        message(STATUS "@ OPENCMISS_MULTI_ARCHITECTURE: ${OPENCMISS_MULTI_ARCHITECTURE}")
        message(STATUS "@ OPENCMISS_MULTI_USER: ${OPENCMISS_MULTI_USER}")
    endif ()
    message(STATUS "@")
    if (DEFINED OPENCMISS_ROOT)
        message(STATUS "@ OPENCMISS_ROOT: ${OPENCMISS_ROOT}")
    else ()
        message(STATUS "@ OPENCMISS_LIBRARIES_ROOT: ${OPENCMISS_LIBRARIES_ROOT}")
        message(STATUS "@ OPENCMISS_DEPENDENCIES_ROOT: ${OPENCMISS_DEPENDENCIES_ROOT}")
        message(STATUS "@ OPENCMISS_MANAGE_ROOT: ${OPENCMISS_MANAGE_ROOT}")
        message(STATUS "@ OPENCMISS_CMAKE_MODULES_ROOT: ${OPENCMISS_CMAKE_MODULES_ROOT}")
    endif ()
    message(STATUS "@ OPENCMISS_CMAKE_MODULES_SOURCE_DIR: ${OPENCMISS_CMAKE_MODULES_SOURCE_DIR}")
    message(STATUS "@ OPENCMISS_CMAKE_MODULES_BINARY_DIR: ${OPENCMISS_CMAKE_MODULES_BINARY_DIR}")
    message(STATUS "@ OPENCMISS_CMAKE_MODULE_PATH: ${OPENCMISS_CMAKE_MODULE_PATH}")
    message(STATUS "@")
    if (OPENCMISS_PERFORM_INITIAL_BUILD)
        message(STATUS "@ MANAGE_CONFIGURE_ARGS: ${MANAGE_CONFIGURE_ARGS}")
        message(STATUS "@")
    endif ()
    message(STATUS "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    message(STATUS "@")
endif ()
