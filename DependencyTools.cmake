function(prepare_tgz_dependency_library library)
    set(one_value_keywords TGZ_NAME SEARCH_PATH UNTAR_PATH LIB_FILE)
    cmake_parse_arguments(PTDL "" "${one_value_keywords}" "" ${ARGN})

    if ("${PTDL_SEARCH_PATH}" STREQUAL "")
        set(PTDL_SEARCH_PATH ${CMAKE_CURRENT_BINARY_DIR})
    endif ()
    if ("${PTDL_UNTAR_PATH}" STREQUAL "")
        set(PTDL_UNTAR_PATH ${CMAKE_CURRENT_BINARY_DIR})
    endif ()

    string(TOUPPER ${library} LIBRARY_UPPER)
    set(MISSING_VARS "")
    set(DETAILS "")
    set(${LIBRARY_UPPER}_FOUND TRUE)

    # find tgz file
    file(GLOB PDTL_LIB_TGZ_FILE "${PTDL_SEARCH_PATH}/${PTDL_TGZ_NAME}")
    if ("${PDTL_LIB_TGZ_FILE}" STREQUAL "")
        set(${LIBRARY_UPPER}_FOUND FALSE)
        set(MISSING_VARS "${MISSING_VARS} ${PTDL_TGZ_NAME}")
    else ()
        # if untarred directory not exists yet
        if (NOT EXISTS ${PTDL_UNTAR_PATH}/${library})
            # .. untar it
            execute_process(
                    COMMAND ${CMAKE_COMMAND} -E tar xzf ${PDTL_LIB_TGZ_FILE}
                    WORKING_DIRECTORY ${PTDL_UNTAR_PATH}
            )
        endif ()

        # find library and include directory
        find_file(${library}_LIBRARY ${PTDL_LIB_FILE} PATHS "${PTDL_UNTAR_PATH}/${library}" NO_DEFAULT_PATH PATH_SUFFIXES lib)
        if (${${library}_LIBRARY} STREQUAL "${library}_LIBRARY-NOTFOUND")
            set(${LIBRARY_UPPER}_FOUND FALSE)
            set(MISSING_VARS "${MISSING_VARS} ${library}_LIBRARY")
        else ()
            set(DETAILS "${DETAILS}[${${library}_LIBRARY}]")
        endif ()
        find_file(${library}_INCLUDE_DIR include PATHS "${PTDL_UNTAR_PATH}/${library}" NO_DEFAULT_PATH)
        if (${${library}_INCLUDE_DIR} STREQUAL "${library}_INCLUDE_DIR-NOTFOUND")
            set(${LIBRARY_UPPER}_FOUND FALSE)
            set(MISSING_VARS "${MISSING_VARS} ${library}_INCLUDE_DIR")
        else ()
            set(DETAILS "${DETAILS}[${${library}_INCLUDE_DIR}]")
        endif ()
    endif ()

    # print and pass the result to parent
    if (${LIBRARY_UPPER}_FOUND)
        find_package_message(${library} "Found ${library}: ${${library}_LIBRARY}" "${DETAILS}")

        add_library(${library} SHARED IMPORTED)
        set_target_properties(${library} PROPERTIES
                IMPORTED_LOCATION ${${library}_LIBRARY}
                INTERFACE_INCLUDE_DIRECTORIES ${${library}_INCLUDE_DIR}
                )
        set(${library}_LIBRARY ${${library}_LIBRARY} PARENT_SCOPE)
        set(${library}_INCLUDE_DIR ${${library}_INCLUDE_DIR} PARENT_SCOPE)
    else ()
        message(FATAL_ERROR "Could NOT find ${library} (missing: ${MISSING_VARS})")
    endif ()

    set(${LIBRARY_UPPER}_FOUND ${${LIBRARY_UPPER}_FOUND} PARENT_SCOPE)
endfunction()

function(prepare_proto_dependency artifact)
    set(one_value_keywords PROTO_NAME SEARCH_PATH)
    cmake_parse_arguments(PPD "" "${one_value_keywords}" "" ${ARGN})

    if ("${PPD_SEARCH_PATH}" STREQUAL "")
        set(PPD_SEARCH_PATH ${CMAKE_CURRENT_BINARY_DIR})
    endif ()

    string(TOUPPER ${artifact} ARTIFACT_UPPER)
    set(MISSING_VARS "")
    set(DETAILS "")
    set(${ARTIFACT_UPPER}_FOUND TRUE)

    # find proto file
    file(GLOB PPD_PROTO_FILE "${PPD_SEARCH_PATH}/${PPD_PROTO_NAME}")
    if (" ${PPD_PROTO_FILE}" STREQUAL "")
        set(${ARTIFACT_UPPER}_FOUND FALSE)
        set(MISSING_VARS "${MISSING_VARS} ${PPD_PROTO_NAME}")
    else ()
        # generate protobuf .h and .cpp
        protobuf_generate_cpp(${artifact}_SRC ${artifact}_HDR ${PPD_PROTO_FILE})
        get_filename_component(${artifact}_INCLUDE_DIR ${${artifact}_HDR} DIRECTORY)
        set(DETAILS "${DETAILS}[${${artifact}_SRC}]")
        set(DETAILS "${DETAILS}[${${artifact}_HDR}]")
        set(DETAILS "${DETAILS}[${${artifact}_INCLUDE_DIR}]")
    endif ()

    # print and pass the result to parent
    if (${ARTIFACT_UPPER}_FOUND)
        find_package_message(${artifact} "Found ${artifact}: ${${artifact}_SRC}" "${DETAILS}")

        set(${artifact}_SRC ${${artifact}_SRC} PARENT_SCOPE)
        set(${artifact}_HDR ${${artifact}_HDR} PARENT_SCOPE)
        set(${artifact}_INCLUDE_DIR ${${artifact}_INCLUDE_DIR} PARENT_SCOPE)
    else ()
        message(FATAL_ERROR "Could NOT find ${artifact} (missing: ${MISSING_VARS})")
    endif ()

    set(${ARTIFACT_UPPER}_FOUND ${${ARTIFACT_UPPER}_FOUND} PARENT_SCOPE)
endfunction()
