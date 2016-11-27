# This is a slow function don't call it if you don't have to.
function(CHECK_SSH_GITHUB_ACCESS VAR_NAME)
    find_program(SSH_EXE ssh)
    mark_as_advanced(SSH_EXE)
    if (SSH_EXE)
        # This command always fail as github doesn't allow ssh access
        execute_process(
            COMMAND ${SSH_EXE} git@github.com
            RESULT_VARIABLE _RESULT
            OUTPUT_VARIABLE _OUT
            ERROR_VARIABLE _ERR
            )
        # So check the contents of the error message for a success message
        if ("${_ERR}" MATCHES "successfully authenticated")
            set(HAVE_SSH_ACCESS TRUE)
        else ()
            set(HAVE_SSH_ACCESS FALSE)
        endif ()
    else ()
        set(HAVE_SSH_ACCESS FALSE)
    endif ()
    set(${VAR_NAME} ${HAVE_SSH_ACCESS} PARENT_SCOPE)
endfunction()

