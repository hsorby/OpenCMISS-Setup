cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

project(OpenCMISS-Setup)

include(ExternalProject)

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
set(OPENCMISS_SINGLE_ARCHITECTURE TRUE CACHE BOOL "Setup for a single architecture build.")
set(OPENCMISS_PERFORM_INITIAL_BUILD TRUE CACHE BOOL "Configure, build and install the default settings.")

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

if (OPENCMISS_MULTIUSER)
  unset(OPENCMISS_MULTICONFIG CACHE)
  set(INDEPENDENT_ROOTS MODULES DEPENDENCIES)
else ()
  set(INDEPENDENT_ROOTS LIBRARIES MODULES DEPENDENCIES MANAGE)
  set(OPENCMISS_MULTICONFIG TRUE CACHE BOOL "Setup for a multi-config installation, setting to False sets up a fixed compiler and MPI installation.")
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

set(MANAGE_CONFIGURE_CMD "${CMAKE_COMMAND}")

# Everything should be valid from here onwards.
if (DEFINED OPENCMISS_ROOT)
  set(OPENCMISS_LIBRARIES_ROOT "${OPENCMISS_ROOT}/src")
  set(OPENCMISS_MANAGE_ROOT "${OPENCMISS_LIBRARIES_ROOT}/manage")
  set(OPENCMISS_MANAGE_BINARY_DIR "${OPENCMISS_ROOT}/build/manage")
  set(OPENCMISS_DEPENDENCIES_ROOT "${OPENCMISS_ROOT}/src/dependencies")
  set(OPENCMISS_INSTALL_ROOT "${OPENCMISS_ROOT}/install")
  set(OPENCMISS_MODULES_ROOT "${OPENCMISS_INSTALL_ROOT}/cmake/opencmiss")
else ()
  set(OPENCMISS_MANAGE_BINARY_DIR "${OPENCMISS_MANAGE_ROOT}-build")
endif ()

if (OPENCMISS_SINGLE_ARCHITECTURE)
  list(APPEND MANAGE_CONFIGURE_CMD -DOC_USE_ARCHITECTURE_PATH=FALSE)
endif ()

if (OPENCMISS_PERFORM_INITIAL_BUILD)
  list(APPEND MANAGE_CONFIGURE_CMD "-DOPENCMISS_MODULE_PATH=${OPENCMISS_MODULES_ROOT}")
  list(APPEND MANAGE_CONFIGURE_CMD "${OPENCMISS_MANAGE_ROOT}")
  set(MANAGE_BUILD_CMD "")
  set(MANAGE_INSTALL_CMD "")
endif ()

foreach (ROOT ${INDEPENDENT_ROOTS})
  if (${ROOT} STREQUAL "MODULES")
    set(REPOSITORY_NAME OpenCMISS-CMake-Modules)
    set(GITHUB_BRANCH ${OPENCMISS_VERSION})
  elseif (${ROOT} STREQUAL "MANAGE")
    set(REPOSITORY_NAME OpenCMISS-Manage)
    set(GITHUB_BRANCH ${OPENCMISS_VERSION})
  else ()
    set(REPOSITORY_NAME ${ROOT})
  endif ()
  set(GITHUB_REPO ${GITHUB_PROTOCOL}${GITHUB_ORGANISATION}/${REPOSITORY_NAME}${GITHUB_EXT})
  if (GIT_FOUND)
    set(DOWNLOAD_${ROOT}_CMD
      GIT_REPOSITORY ${GITHUB_REPO}
      GIT_TAG ${GITHUB_BRANCH}
    )
  else ()
    set(DOWNLOAD_${ROOT}_CMD
      URL ${GITHUB_REPO}/archive/${GITHUB_BRANCH}.zip
    )
  endif ()
endforeach()

ExternalProject_Add(setup-modules
  ${DOWNLOAD_MODULES_CMD}
  SOURCE_DIR "${OPENCMISS_MODULES_ROOT}"
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
)

ExternalProject_Add(setup-manage
  DEPENDS setup-modules
  ${DOWNLOAD_MANAGE_CMD}
  SOURCE_DIR "${OPENCMISS_MANAGE_ROOT}"
  BINARY_DIR "${OPENCMISS_MANAGE_BINARY_DIR}"
  CONFIGURE_COMMAND "${MANAGE_CONFIGURE_CMD}"
  BUILD_COMMAND "${MANAGE_BUILD_CMD}"
  INSTALL_COMMAND "${MANAGE_INSTALL_CMD}"
)

