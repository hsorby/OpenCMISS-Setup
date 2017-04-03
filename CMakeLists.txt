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
cmake_policy(SET CMP0054 NEW)

include(ExternalProject)

set(VISIBLE_GUI_ENTRIES OPENCMISS_LIBRARIES OPENCMISS_ROOT OPENCMISS_LIBRARIES_ROOT OPENCMISS_DEPENDENCIES_ROOT OPENCMISS_MANAGE_ROOT OPENCMISS_CMAKE_MODULES_ROOT OPENCMISS_IRON_ROOT OPENCMISS_ZINC_ROOT OPENCMISS_DEPENDENCIES_INSTALL_PREFIX OPENCMISS_CMAKE_MODULES_INSTALL_PREFIX)
set(VISIBLE_default_GUI_ENTRIES OPENCMISS_ROOT OPENCMISS_LIBRARIES)
set(VISIBLE_default_IND_GUI_ENTRIES OPENCMISS_LIBRARIES OPENCMISS_LIBRARIES_ROOT OPENCMISS_DEPENDENCIES_ROOT OPENCMISS_MANAGE_ROOT OPENCMISS_CMAKE_MODULES_ROOT)
set(VISIBLE_libraries_GUI_ENTRIES OPENCMISS_LIBRARIES OPENCMISS_LIBRARIES_ROOT OPENCMISS_DEPENDENCIES_INSTALL_PREFIX)
set(VISIBLE_libraries_IND_GUI_ENTRIES OPENCMISS_LIBRARIES OPENCMISS_ZINC_ROOT OPENCMISS_IRON_ROOT OPENCMISS_MANAGE_ROOT OPENCMISS_CMAKE_MODULES_INSTALL_PREFIX OPENCMISS_DEPENDENCIES_INSTALL_PREFIX)
set(VISIBLE_dependencies_GUI_ENTRIES OPENCMISS_DEPENDENCIES_ROOT)
set(VISIBLE_dependencies_IND_GUI_ENTRIES OPENCMISS_DEPENDENCIES_ROOT OPENCMISS_MANAGE_ROOT OPENCMISS_CMAKE_MODULES_ROOT)
set(VISIBLE_cmake_modules_GUI_ENTRIES OPENCMISS_CMAKE_MODULES_ROOT)
set(VISIBLE_cmake_modules_IND_GUI_ENTRIES OPENCMISS_CMAKE_MODULES_ROOT)

set(SETUP_PROJECTS CMAKE_MODULES MANAGE)

set(MANAGE_ORG OpenCMISS)
set(CMAKE_MODULES_ORG OpenCMISS)
set(MANAGE_REPO ${MANAGE_ORG}/manage)
set(CMAKE_MODULES_REPO ${CMAKE_MODULES_ORG}/cmake_modules)
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

# Basic test for multi-configuration capable environments
if (MSVC OR XCODE)
    set(_MULTI_CONFIG_ENV TRUE)
else ()
    set(_MULTI_CONFIG_ENV FALSE)
endif ()

# Clean up GUI options
mark_as_advanced(QT_QMAKE_EXECUTABLE)
if (APPLE)
    mark_as_advanced(CMAKE_OSX_ARCHITECTURES)
    mark_as_advanced(CMAKE_CODEBLOCKS_EXECUTABLE)
    mark_as_advanced(CMAKE_OSX_DEPLOYMENT_TARGET)
    mark_as_advanced(CMAKE_OSX_SYSROOT)
endif ()

include(Options)

set(SETUP_TYPES default libraries dependencies cmake_modules)
set_property(CACHE OPENCMISS_SETUP_TYPE PROPERTY STRINGS ${SETUP_TYPES})
if (DEFINED SETUP_TYPE)
    string(TOLOWER ${SETUP_TYPE} _LOWER_SETUP_TYPE)
    if (${_LOWER_SETUP_TYPE} IN_LIST SETUP_TYPES)
        set(OPENCMISS_SETUP_TYPE ${_LOWER_SETUP_TYPE} CACHE STRING "The type of OpenCMISS installation to setup." FORCE)
    endif ()
endif ()

set(LIB_BUILD_TYPES all iron zinc)
set_property(CACHE OPENCMISS_LIBRARIES PROPERTY STRINGS ${LIB_BUILD_TYPES})
if (DEFINED LIBRARIES)
	string(TOLOWER ${LIBRARIES} _LOWER_LIBRARIES)
	if (${_LOWER_LIBRARIES} IN_LIST LIB_BUILD_TYPES)
		set(OPENCMISS_LIBRARIES ${_LOWER_LIBRARIES} CACHE STRING "Set which OpenCMISS libraries to build." FORCE)
	endif ()
endif ()

if (OPENCMISS_PERFORM_INITIAL_BUILD)
    set(OPENCMISS_VERSION "develop" CACHE STRING "The branch or tag to setup.  Must be one of: ${KNOWN_OPENCMISS_VERSIONS}")
    set(OPENCMISS_MULTI_ARCHITECTURE FALSE CACHE BOOL "Setup for a multi architecture build.")
    if (NOT _MULTI_CONFIG_ENV)
        set(OPENCMISS_CONFIG_BUILD_TYPE Release CACHE STRING "Set the configuration build type.")
        set_property(CACHE OPENCMISS_CONFIG_BUILD_TYPE PROPERTY STRINGS Release RelWithDebInfo Debug MinSizeRel)
    endif ()
else ()
    unset(OPENCMISS_VERSION CACHE)
    unset(OPENCMISS_MULTI_ARCHITECTURE CACHE)
    unset(OPENCMISS_CONFIG_BUILD_TYPE CACHE)
endif ()

if (OPENCMISS_INDEPENDENT)
    set(IND_MARKER _IND)
endif ()

set(_VISIBLE_LIST VISIBLE_${OPENCMISS_SETUP_TYPE}${IND_MARKER}_GUI_ENTRIES)
foreach(_R ${VISIBLE_GUI_ENTRIES})
    if ("${_R}" IN_LIST ${_VISIBLE_LIST})
        set(${_R} "" CACHE PATH "The location of the OpenCMISS root ${_R}")
    else ()
        unset(${_R} CACHE)
    endif ()
endforeach()

if (DEFINED OPENCMISS_IRON_ROOT AND OPENCMISS_LIBRARIES STREQUAL zinc)
	unset(OPENCMISS_IRON_ROOT CACHE)
endif ()
if (DEFINED OPENCMISS_ZINC_ROOT AND OPENCMISS_LIBRARIES STREQUAL iron)
	unset(OPENCMISS_ZINC_ROOT CACHE)
endif ()

# Internalise some variables that don't have any meaning here
set(CMAKE_BUILD_TYPE "Release" CACHE INTERNAL "Internalise CMAKE_BUILD_TYPE")
set(CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE INTERNAL "Internalise CMAKE_INSTALL_PREFIX")
set(CMAKE_CONFIGURATION_TYPES ${CMAKE_CONFIGURATION_TYPES} CACHE INTERNAL "Internalise CMAKE_CONFIGURATION_TYPES")

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
message(STATUS "Using GitHub protocol: ${GITHUB_PROTOCOL}")

set(ALL_ROOTS OPENCMISS_ROOT OPENCMISS_LIBRARIES_ROOT OPENCMISS_DEPENDENCIES_ROOT OPENCMISS_MANAGE_ROOT OPENCMISS_CMAKE_MODULES_ROOT OPENCMISS_ZINC_ROOT OPENCMISS_IRON_ROOT)
# Make all paths CMake paths:
foreach(_path_var ${${_VISIBLE_LIST}})
    file(TO_CMAKE_PATH "${${_path_var}}" ${_path_var})
endforeach()

# Check sanity of configuration.
set(VALID_CONFIG TRUE)
set(ERROR_MSG)
foreach(_path_var ${${_VISIBLE_LIST}})
    if (NOT "${_path_var}" STREQUAL "OPENCMISS_LIBRARIES" AND NOT EXISTS ${${_path_var}})
        set(VALID_CONFIG FALSE)
        list(APPEND ERROR_MSG "Location ${_path_var}: '${${_path_var}}' does not exist")
    endif ()
endforeach()

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

# Basic test for multi-configuration capable environments
if (_MULTI_CONFIG_ENV)
    mark_as_advanced(CMAKE_CONFIGURATION_TYPES)
    set(MULTICONFIG_BUILD_CONFIG --config <CONFIG>)
else ()
    set(SINGLE_ARCHITECUTRE_BUILD_TYPE /release)
    set(SINGLE_BUILD_CONFIG -DCMAKE_BUILD_TYPE=Release)
endif ()

# Everything should be valid from here onwards.
if (DEFINED OPENCMISS_ROOT)
    set(OPENCMISS_MANAGE_SOURCE_DIR "${OPENCMISS_ROOT}/src/manage")
    set(OPENCMISS_MANAGE_BINARY_DIR "${OPENCMISS_ROOT}/build/manage${SINGLE_ARCHITECUTRE_BUILD_TYPE}")
    set(OPENCMISS_CMAKE_MODULES_SOURCE_DIR "${OPENCMISS_ROOT}/src/cmake_modules")
    set(OPENCMISS_CMAKE_MODULES_BINARY_DIR "${OPENCMISS_ROOT}/build/cmake_modules${SINGLE_ARCHITECUTRE_BUILD_TYPE}")
    set(OPENCMISS_CMAKE_MODULE_PATH "${OPENCMISS_ROOT}/install/share/cmake")
else ()
    set(OPENCMISS_MANAGE_SOURCE_DIR "${OPENCMISS_MANAGE_ROOT}/src")
    set(OPENCMISS_MANAGE_BINARY_DIR "${OPENCMISS_MANAGE_ROOT}/build${SINGLE_ARCHITECUTRE_BUILD_TYPE}")
    set(OPENCMISS_CMAKE_MODULES_SOURCE_DIR "${OPENCMISS_CMAKE_MODULES_ROOT}/src")
    set(OPENCMISS_CMAKE_MODULES_BINARY_DIR "${OPENCMISS_CMAKE_MODULES_ROOT}/build${SINGLE_ARCHITECUTRE_BUILD_TYPE}")
    set(OPENCMISS_CMAKE_MODULE_PATH "${OPENCMISS_CMAKE_MODULES_ROOT}/install/share/cmake")
endif ()

set(MANAGE_BUILD_CMD "")
set(MANAGE_INSTALL_CMD "")

if (OPENCMISS_PERFORM_INITIAL_BUILD)
    if (NOT OPENCMISS_MULTI_ARCHITECTURE)
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_USE_ARCHITECTURE_PATH=FALSE)
    endif ()

    if ("${OPENCMISS_SETUP_TYPE}" STREQUAL "libraries")
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_LIBRARIES_ONLY=TRUE)
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_DEPENDENCIES_INSTALL_PREFIX=${OPENCMISS_DEPENDENCIES_INSTALL_PREFIX})
    endif ()

    if ("${OPENCMISS_SETUP_TYPE}" STREQUAL "dependencies")
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_DEPENDENCIES_ONLY=TRUE)
    endif ()

    if ("${OPENCMISS_VERSION}" STREQUAL "develop")
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_DEVEL_ALL=YES)
    endif ()

    list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_BUILD_TYPE=${OPENCMISS_CONFIG_BUILD_TYPE})

    if ("${OPENCMISS_LIBRARIES}" STREQUAL "iron")
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_IRON_ONLY=TRUE)
    endif ()

    if ("${OPENCMISS_LIBRARIES}" STREQUAL "zinc")
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_ZINC_ONLY=TRUE)
    endif ()

    foreach(_E ${${_VISIBLE_LIST}})
        if (NOT "${_E}" STREQUAL "OPENCMISS_ROOT" AND NOT "${_E}" STREQUAL "OPENCMISS_MANAGE_ROOT" AND NOT "${_E}" STREQUAL "OPENCMISS_LIBRARIES")
            list(APPEND MANAGE_CONFIGURE_ARGS -D${_E}=${${_E}})
        endif () 
    endforeach()

    if (DEFINED OPENCMISS_ROOT)
    else ()
        #list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_LIBRARIES_ROOT=${OPENCMISS_LIBRARIES_ROOT})
        #list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_DEPENDENCIES_ROOT=${OPENCMISS_DEPENDENCIES_ROOT})
        #list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_CMAKE_MODULES_ROOT=${OPENCMISS_CMAKE_MODULES_ROOT})
        list(APPEND MANAGE_CONFIGURE_ARGS -DOPENCMISS_CMAKE_MODULE_PATH=${OPENCMISS_CMAKE_MODULE_PATH})
        list(APPEND CMAKE_MODULES_ARGS -DINSTALL_PREFIX=${OPENCMISS_CMAKE_MODULE_PATH})
    endif ()
    set(MANAGE_BUILD_CMD ${CMAKE_COMMAND} --build . --target do_config ${MULTICONFIG_BUILD_CONFIG})
    # set(MANAGE_BUILD_CMD "") # Remove me soon
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

if (NOT ${OPENCMISS_SETUP_TYPE} STREQUAL libraries)
    ExternalProject_Add(setup_modules
        ${DOWNLOAD_CMAKE_MODULES_CMD}
        SOURCE_DIR "${OPENCMISS_CMAKE_MODULES_SOURCE_DIR}"
        BINARY_DIR "${OPENCMISS_CMAKE_MODULES_BINARY_DIR}"
        CMAKE_COMMAND ${CMAKE_COMMAND}
        CMAKE_ARGS ${SINGLE_BUILD_CONFIG} ${CMAKE_MODULES_ARGS}
        BUILD_COMMAND ""
        INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install ${MULTICONFIG_BUILD_CONFIG}
    )
endif ()

if (NOT ${OPENCMISS_SETUP_TYPE} STREQUAL cmake_modules)
    ExternalProject_Add(setup_manage
        DEPENDS setup_modules
        ${DOWNLOAD_MANAGE_CMD}
        SOURCE_DIR "${OPENCMISS_MANAGE_SOURCE_DIR}"
        BINARY_DIR "${OPENCMISS_MANAGE_BINARY_DIR}"
        CMAKE_COMMAND ${CMAKE_COMMAND}
        CMAKE_ARGS ${SINGLE_BUILD_CONFIG} ${MANAGE_CONFIGURE_ARGS}
        BUILD_COMMAND "${MANAGE_BUILD_CMD}"
        INSTALL_COMMAND "${MANAGE_INSTALL_CMD}"
    )
endif ()

set(PRINT_SUMMARY TRUE)
if (PRINT_SUMMARY)
    message(STATUS "@")
    message(STATUS "@@@@@@@@@@@@@@@@@@@@@@@@ SUMMARY @@@@@@@@@@@@@@@@@@@@@@@@")
    message(STATUS "@")
    message(STATUS "@ OPENCMISS_SETUP_TYPE: ${OPENCMISS_SETUP_TYPE}")
    message(STATUS "@ OPENCMISS_INDEPENDENT: ${OPENCMISS_INDEPENDENT}")
    message(STATUS "@ OPENCMISS_PERFORM_INITIAL_BUILD: ${OPENCMISS_PERFORM_INITIAL_BUILD}")
    if (OPENCMISS_PERFORM_INITIAL_BUILD)
        message(STATUS "@ OPENCMISS_VERSION: ${OPENCMISS_VERSION}")
        message(STATUS "@ OPENCMISS_MULTI_ARCHITECTURE: ${OPENCMISS_MULTI_ARCHITECTURE}")
    endif ()
    message(STATUS "@")
    foreach(_E ${${_VISIBLE_LIST}})
        message(STATUS "@ ${_E}: ${${_E}}")
    endforeach()
    message(STATUS "@")
    if (NOT ${OPENCMISS_SETUP_TYPE} STREQUAL libraries)
        message(STATUS "@ OPENCMISS_CMAKE_MODULES_SOURCE_DIR: ${OPENCMISS_CMAKE_MODULES_SOURCE_DIR}")
        message(STATUS "@ OPENCMISS_CMAKE_MODULES_BINARY_DIR: ${OPENCMISS_CMAKE_MODULES_BINARY_DIR}")
        message(STATUS "@ OPENCMISS_CMAKE_MODULE_PATH: ${OPENCMISS_CMAKE_MODULE_PATH}")
        message(STATUS "@")
    endif ()
    if (OPENCMISS_PERFORM_INITIAL_BUILD)
        message(STATUS "@ MANAGE_CONFIGURE_ARGS: ${MANAGE_CONFIGURE_ARGS}")
        message(STATUS "@")
    endif ()
    message(STATUS "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    message(STATUS "@")
endif ()
