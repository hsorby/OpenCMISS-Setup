cmake_minimum_required(VERSION 2.6 FATAL_ERROR)

project(OpenCMISS-Setup)

include(ExternalProject)

set(OPENCMISS_ROOT "" CACHE PATH "Root directory for OpenCMISS.")
set(OPENCMISS_DEVELOPER_MODE OFF CACHE BOOL "Set developer mode on (clone git repositories) or off (download zip archives)")


# Internalise some variables
set(CMAKE_BUILD_TYPE "" CACHE INTERNAL "Internalise CMAKE_BUILD_TYPE")
set(CMAKE_INSTALL_PREFIX "" CACHE INTERNAL "Internalise CMAKE_INSTALL_PREFIX")


if (OPENCMISS_DEVELOPER_MODE)
  find_package(Git)
  if (GIT_FOUND)
    set(GITHUB_PROTOCOL "git@github.com:")
    set(GITHUB_REPO ${GITHUB_PROTOCOL}OpenCMISS-Utilities/manage.git)
    set(GITHUB_BRANCH master)
    set(DOWNLOAD_CMD
      GIT_REPOSITORY ${GITHUB_REPO}
      GIT_TAG ${GITHUB_BRANCH}
    )
  else()
    message(FATAL_ERROR "Could not find Git. Git is required for developer mode")
  endif()
else()
  set(GITHUB_PROTOCOL "https://github.com/")
  set(GITHUB_REPO ${GITHUB_PROTOCOL}OpenCMISS-Utilities/manage/)
  set(GITHUB_BRANCH master)
  set(DOWNLOAD_CMD
    URL ${GITHUB_REPO}archive/${GITHUB_BRANCH}.zip
  )
endif()

if (OPENCMISS_ROOT)
  set(MANAGE_DIR "${OPENCMISS_ROOT}/manage")
endif()

ExternalProject_Add(setup-manage
  ${DOWNLOAD_CMD}
  SOURCE_DIR "${MANAGE_DIR}"
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
)

