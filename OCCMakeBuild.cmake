# This script is intended to be used within the OpenCMISS build environment, called from OCCMakeCheck.cmake.
# Arguments passed to this script are:
# CMAKE_MODULE_PATH
# CMAKE_MIN_MAJOR_VERSION
# CMAKE_MIN_MINOR_VERSION
# CMAKE_MIN_PATCH_VERSION
# OPENCMISS_CMAKE_MIN_VERSION

#message(STATUS "Building CMake version ${OPENCMISS_CMAKE_MIN_VERSION} ..")
# Use the cmake binary with which this script was invoked as default 
set(MY_CMAKE_COMMAND ${CMAKE_COMMAND})

macro (printfinishmessage)
    message("@@@@@@@@@@@@@@@@@@@@@@@@@@ ATTENTION @@@@@@@@@@@@@@@@@@@@@@@@@@\n"
        " Successfully built CMake version ${OPENCMISS_CMAKE_MIN_VERSION}.\n"
        " Install directory: ${CMAKE_INSTALL_DIR}/bin/\n"
        " CMake binary: ${MY_CMAKE_EXECUTABLE}\n"
        " You can now start building OpenCMISS by re-invoking the CMake configuration step using the new CMake binary.\n"
        "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
endmacro ()
     
if (EXISTS "${OPENCMISS_ROOT}")
    set(CMAKE_INSTALL_DIR ${OPENCMISS_ROOT}/install/utilities/cmake)
else ()
    set(CMAKE_INSTALL_DIR ${OPENCMISS_DEPENDENCIES_ROOT}/install/cmake)
endif ()
set(MY_CMAKE_EXECUTABLE ${CMAKE_INSTALL_DIR}/bin/cmake${CMAKE_EXECUTABLE_SUFFIX})

# Add check to see if the mayhaps already built version is the desired one
if (EXISTS ${MY_CMAKE_EXECUTABLE})
    execute_process(COMMAND ${MY_CMAKE_EXECUTABLE} --version
        OUTPUT_VARIABLE OUT)
    string(REGEX MATCH "cmake version ([0-9.]*)" _MATCH "${OUT}")
    if (CMAKE_MATCH_1 VERSION_LESS OPENCMISS_CMAKE_MIN_VERSION)
        message(STATUS "Found already installed version ${CMAKE_MATCH_1}. Removing first..")
        file(REMOVE_RECURSE "${CMAKE_INSTALL_DIR}")
    endif ()
endif ()

# Check if the binary is already there and hint the user to it
if (EXISTS ${MY_CMAKE_EXECUTABLE})
    printfinishmessage()
else ()

    # Otherwise .. need compilation!
    
    set(CMAKE_INTERMEDIATE_VERSION_MAJ_MIN 2.8)
    set(CMAKE_INTERMEDIATE_VERSION ${CMAKE_INTERMEDIATE_VERSION_MAJ_MIN}.4)
    
    # compile intermediate version of cmake if present is too old
    if (CMAKE_VERSION VERSION_LESS ${CMAKE_INTERMEDIATE_VERSION})
        message(STATUS "Your CMake version is too old: ${CMAKE_VERSION}!\n"
                        "A newer version is required to build version ${OPENCMISS_CMAKE_MIN_VERSION}. Building now..")
        # set up the paths for an intermediate version of cmake
        set(CMAKE_TARBALL cmake-${CMAKE_INTERMEDIATE_VERSION}.tar.gz)
        if (EXISTS "${OPENCMISS_ROOT}")
            set(CMAKE_INTERMEDIATE_VERSION_INSTALL_DIR ${OPENCMISS_ROOT}/install/utilities/cmake-${CMAKE_INTERMEDIATE_VERSION})
        else ()
            set(CMAKE_INTERMEDIATE_VERSION_INSTALL_DIR ${OPENCMISS_DEPENDENCIES_ROOT}/install/cmake-${CMAKE_INTERMEDIATE_VERSION})
        endif ()
        set(_URL http://www.cmake.org/files/v${CMAKE_INTERMEDIATE_VERSION_MAJ_MIN}/${CMAKE_TARBALL})
        set(REQUIRED_CMAKE_SOURCE_DIR cmake_intermediate-v${CMAKE_INTERMEDIATE_VERSION})
        set(REQUIRED_CMAKE_BINARY_DIR cmake_intermediate-v${CMAKE_INTERMEDIATE_VERSION-build})

        ExternalProject_Add(cmake_intermediate
            EXCLUDE_FROM_ALL TRUE
            URL ${_URL}
            CMAKE_COMMAND ${CMAKE_COMMAND}
            CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INTERMEDIATE_VERSION_INSTALL_DIR}
            BUILD_COMMAND ${CMAKE_COMMAND} --build .
            INSTALL_COMMAND ${CMAKE_COMMAND} --build . --target install
        )
        get_filename_component(MY_CMAKE_COMMAND ${CMAKE_INTERMEDIATE_VERSION_INSTALL_DIR}/bin/cmake${CMAKE_EXECUTABLE_SUFFIX} REALPATH)
        set(INTERMEDIATE_DEPENDS DEPENDS cmake_intermediate)
    endif ()
    
    # check if ssl library is installed on the system before building final cmake version
    # Fixes the library detection, as no project has been initialized yet and thus
    # the find_library wont work correctly. this will probably bite someone sometime :-|
    if (UNIX)
        set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES} .a .so)
        set(CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_FIND_LIBRARY_PREFIXES} lib)
    endif ()

    find_package(OpenSSL QUIET)
    # can't build cmake without OpenSSL (otherwise, no https downloads)
    if (NOT OPENSSL_FOUND)
        # Alternative: if available, use PkgConfig to locate OpenSSL  
        find_package(PkgConfig QUIET)
        if (PKGCONFIG_FOUND OR PKG_CONFIG_FOUND)
            pkg_search_module(OPENSSL QUIET openssl)
        endif(PKGCONFIG_FOUND OR PKG_CONFIG_FOUND)
    endif ()
        
    if (OPENSSL_FOUND)
        message(STATUS "Found OpenSSL ${OPENSSL_VERSION}: ${OPENSSL_INCLUDE_DIR}")
    else ()
        message(FATAL_ERROR "No OpenSSL could be found on your system!
Building CMake for OpenCMISS requires OpenSSL to be available.
Please install OpenSSL before reinvoking the CMake build process.

Here are the openssl package names for selected systems:
Ubuntu - libssl-dev
RedHat - openssl-devel")
    endif ()
    
    # reset the paths for latest cmake version
    if (EXISTS "${OPENCMISS_ROOT}")
        set(CMAKE_INSTALL_DIR ${OPENCMISS_ROOT}/install/utilities/cmake)
    else ()
        set(CMAKE_INSTALL_DIR ${OPENCMISS_DEPENDENCIES_ROOT}/install/cmake)
    endif ()
    set(CMAKE_TARBALL cmake-${OPENCMISS_CMAKE_MIN_VERSION}.tar.gz)
    set(_URL http://www.cmake.org/files/v${OPENCMISS_CMAKE_VERSION_MAJ_MIN}/${CMAKE_TARBALL})

    ExternalProject_Add(cmake_required
        ${INTERMEDIATE_DEPENDS}
        EXCLUDE_FROM_ALL TRUE
        URL ${_URL}
        CMAKE_COMMAND ${MY_CMAKE_COMMAND}  
        CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_DIR} -DCMAKE_USE_OPENSSL=TRUE
        BUILD_COMMAND ${MY_CMAKE_COMMAND} --build .
        INSTALL_COMMAND ${MY_CMAKE_COMMAND} --build . --target install
    )
        
    # Run cmake
    add_custom_target(cmake_build    
        # ${INTERMEDIATE_CMD}
        COMMAND ${CMAKE_COMMAND} --build . --target cmake_required
    )
    set(finish_message "Success\n@@@@@@@@@@@@@@@@@@@@@@@@@@ ATTENTION @@@@@@@@@@@@@@@@@@@@@@@@@@\n"
        " Successfully built CMake version ${OPENCMISS_CMAKE_MIN_VERSION}.\n"
        " Install directory: ${CMAKE_INSTALL_DIR}/bin/\n"
        " CMake binary: ${MY_CMAKE_EXECUTABLE}\n"
        " You can now start building OpenCMISS by re-invoking the CMake configuration step using the new CMake binary.\n"
        "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    add_custom_target(cmake
        DEPENDS cmake_build
        COMMAND ""
        COMMENT "${finish_message}"
    )

endif ()

