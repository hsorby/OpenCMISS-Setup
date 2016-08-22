cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

project(OpenCMISS-Setup)

include(ExternalProject)

mark_as_advanced(QT_QMAKE_EXECUTABLE)
if (APPLE)
mark_as_advanced(CMAKE_OSX_ARCHITECTURES)
mark_as_advanced(CMAKE_CODEBLOCKS_EXECUTABLE)
mark_as_advanced(CMAKE_OSX_DEPLOYMENT_TARGET)
mark_as_advanced(CMAKE_OSX_SYSROOT)
endif()

set(OPENCMISS_MULTIUSER FALSE CACHE BOOL "Setup for a multi-user installation, multi-user installations only sets up the modules and dependencies.")
set(OPENCMISS_INDEPENDENT FALSE CACHE BOOL "Setup with independent locations for libraries, dependencies, and modules")
set(OPENCMISS_VERSION "develop" CACHE STRING "The branch or tag to setup.")

if (OPENCMISS_INDEPENDENT)
  set(OPENCMISS_LIBRARIES_ROOT "" CACHE PATH "The location for OpenCMISS libraires Iron and Zinc.")
  set(OPENCMISS_DEPENDENCIES_ROOT "" CACHE PATH "The location for the OpenCMISS dependencies.")
  set(OPENCMISS_MODULES_ROOT "" CACHE PATH "The location for the OpenCMISS CMake modules.")
  unset(OPENCMISS_ROOT CACHE)
else ()
  set(OPENCMISS_ROOT "" CACHE PATH "Root directory for OpenCMISS.")
  unset(OPENCMISS_LIBRARIES_ROOT CACHE)
  unset(OPENCMISS_DEPENDENCIES_ROOT CACHE)
  unset(OPENCMISS_MODULES_ROOT CACHE)
endif ()

if (OPENCMISS_MULTIUSER)
  unset(OPENCMISS_MULTICONFIG CACHE)
  set(INDEPENDENT_ROOTS MODULES DEPENDENCIES)
else ()
  set(INDEPENDENT_ROOTS LIBRARIES MODULES DEPENDENCIES)
  set(OPENCMISS_MULTICONFIG TRUE CACHE BOOL "Setup for a multi-config installation, setting to False sets up a fixed compiler and MPI installation.")
endif ()

# Internalise some variables
set(CMAKE_BUILD_TYPE "" CACHE INTERNAL "Internalise CMAKE_BUILD_TYPE")
set(CMAKE_INSTALL_PREFIX "" CACHE INTERNAL "Internalise CMAKE_INSTALL_PREFIX")


find_package(Git)
if (GIT_FOUND)
  set(GITHUB_PROTOCOL "git@github.com:")
  set(GITHUB_EXT ".git")
  set(GITHUB_BRANCH master)
  set(DOWNLOAD_CMD
    GIT_REPOSITORY ${GITHUB_REPO}
    GIT_TAG ${GITHUB_BRANCH}
  )
else ()
  set(GITHUB_PROTOCOL "https://github.com/")
  set(GITHUB_BRANCH master)
  set(DOWNLOAD_CMD
    URL ${GITHUB_REPO}archive/${GITHUB_BRANCH}.zip
  )
endif ()

set(GITHUB_REPO ${GITHUB_PROTOCOL}OpenCMISS/manage${GITHUB_EXT})

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

if (OPENCMISS_ROOT)
  set(MANAGE_DIR "${OPENCMISS_ROOT}/manage")
endif ()

if (NOT VALID_CONFIG)
	foreach (msg ${ERROR_MSG})
		message(SEND_ERROR "${msg}")
	endforeach ()
	message(FATAL_ERROR "Invalid configuration.")
endif ()

if (DEFINED OPENCMISS_ROOT)
else ()
endif ()
#ExternalProject_Add(setup-manage
#  ${DOWNLOAD_CMD}
#  SOURCE_DIR "${MANAGE_DIR}"
#  CONFIGURE_COMMAND ""
#  BUILD_COMMAND ""
#  INSTALL_COMMAND ""
#)

