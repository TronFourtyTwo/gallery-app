add_definitions(-DTEST_SUITE)

if(NOT CTEST_TESTING_TIMEOUT)
    set(CTEST_TESTING_TIMEOUT 60)
endif()

include_directories(
    ${CMAKE_BINARY_DIR}
    ${gallery_src_SOURCE_DIR}
    ${gallery_album_src_SOURCE_DIR}
    ${gallery_core_src_SOURCE_DIR}
    ${gallery_database_src_SOURCE_DIR}
    ${gallery_event_src_SOURCE_DIR}
    ${gallery_media_src_SOURCE_DIR}
    ${gallery_medialoader_src_SOURCE_DIR}
    ${gallery_photo_src_SOURCE_DIR}
    ${gallery_util_src_SOURCE_DIR}
    ${gallery_video_src_SOURCE_DIR}
    ${GSTLIB_INCLUDE_DIRS}
    )

QT_WRAP_CPP(mediaobjectfactory MEDIAOBJECTFACTORY_MOCS
    ${gallery_src_SOURCE_DIR}/gallery-manager.h
    ${gallery_medialoader_src_SOURCE_DIR}/gallery-standard-image-provider.h
    ${gallery_medialoader_src_SOURCE_DIR}/photo-metadata.h
    ${gallery_medialoader_src_SOURCE_DIR}/preview-manager.h
    )

add_executable(mediaobjectfactory
    tst_mediaobjectfactory.cpp
    ${gallery_src_SOURCE_DIR}/media-object-factory.cpp
    ../stubs/photometa-data_stub.cpp
    ../stubs/preview-manager_stub.cpp
    ../stubs/gallery-standard-image-provider_stub.cpp
    ../stubs/gallery-thumbnail-image-provider_stub.cpp
    ../stubs/gallery-manager_stub.cpp
    ${MEDIAOBJECTFACTORY_MOCS}
    )

qt5_use_modules(mediaobjectfactory Widgets Core Quick Qml Test)
add_test(mediaobjectfactory mediaobjectfactory -xunitxml -o test_video.xml)
set_tests_properties(mediaobjectfactory PROPERTIES
    TIMEOUT ${CTEST_TESTING_TIMEOUT}
    ENVIRONMENT "QT_QPA_PLATFORM=minimal"
    )

target_link_libraries(mediaobjectfactory
    gallery-album
    gallery-core
    gallery-database
    gallery-event
    gallery-media
    gallery-photo
    gallery-qml
    gallery-util
    gallery-video
    ${GSTLIB_LDFLAGS}
    )