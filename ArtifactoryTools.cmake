include(Artifactory)

function(artifactory_fetch_and_check)
    set(one_value_keywords REPO GROUP NAME VERSION)
    cmake_parse_arguments(AFC "" "${one_value_keywords}" "" ${ARGN})

    artifactory_fetch(ARTIFACT_FILES
            REPO ${AFC_REPO}
            GROUP ${AFC_GROUP}
            NAME ${AFC_NAME}
            VERSION ${AFC_VERSION}
            )

    if (NOT ARTIFACT_FILES)
        message(FATAL_ERROR "No '${AFC_NAME}' artifact was not found")
    else ()
        message(STATUS "'${AFC_NAME}' artifact(s) downloaded: ${ARTIFACT_FILES}")
    endif ()
endfunction()

function(artifactory_fetch_and_get_tgz)
    set(one_value_keywords REPO GROUP NAME VERSION TARGET_DIR)
    cmake_parse_arguments(AFGT "" "${one_value_keywords}" "" ${ARGN})

    if ("${AFGT_TARGET_DIR}" STREQUAL "")
        set(AFGT_TARGET_DIR ${CMAKE_CURRENT_BINARY_DIR})
    endif ()

    # if target .tgz not exists yet
    if (NOT EXISTS ${AFGT_TARGET_DIR}/${AFGT_NAME}-${AFGT_VERSION}.tgz)
        artifactory_fetch_and_check(
                REPO ${AFGT_REPO}
                GROUP ${AFGT_GROUP}
                NAME ${AFGT_NAME}
                VERSION ${AFGT_VERSION}
        )

        file(GLOB_RECURSE ARTIFACT_FILE "${ARTIFACTORY_CACHE_DIR}/${AFGT_NAME}-${AFGT_VERSION}.tgz")
        file(COPY ${ARTIFACT_FILE} DESTINATION ${AFGT_TARGET_DIR})
    endif ()
endfunction()

function(artifactory_fetch_and_get_proto)
    set(one_value_keywords REPO GROUP NAME VERSION TARGET_DIR)
    cmake_parse_arguments(AFGP "" "${one_value_keywords}" "" ${ARGN})

    if ("${AFGP_TARGET_DIR}" STREQUAL "")
        set(AFGP_TARGET_DIR ${CMAKE_CURRENT_BINARY_DIR})
    endif ()

    # if target .proto not exists yet
    if (NOT EXISTS ${AFGP_TARGET_DIR}/${AFGP_NAME}.proto)
        artifactory_fetch_and_check(
                REPO ${AFGP_REPO}
                GROUP ${AFGP_GROUP}
                NAME ${AFGP_NAME}
                VERSION ${AFGP_VERSION}
        )

        file(GLOB_RECURSE ARTIFACT_FILE "${ARTIFACTORY_CACHE_DIR}/${AFGP_NAME}-${AFGP_VERSION}.proto")
        file(COPY ${ARTIFACT_FILE} DESTINATION ${AFGP_TARGET_DIR}/tmp)
        file(RENAME ${AFGP_TARGET_DIR}/tmp/${AFGP_NAME}-${SLR_REQ_API_VERSION}.proto ${AFGP_TARGET_DIR}/${AFGP_NAME}.proto)
    endif ()
endfunction()
