######################################################################
# Automatically generated by qmake (2.01a) Mon Oct 24 15:04:00 2011
######################################################################

isEmpty(PREFIX) {
	PREFIX = /usr/local
}

TEMPLATE = app
TARGET = gallery
DEPENDPATH += . src
INCLUDEPATH += src
CONFIG += qt debug link_pkgconfig
QMAKE_CXXFLAGS += -Werror -Wno-unused-parameter
DEFINES += "INSTALL_PREFIX=\\\"$$PREFIX\\\""
QT += gui qml quick opengl sql
MOC_DIR = build
OBJECTS_DIR = build
RCC_DIR = build
QMAKE_RESOURCE_FLAGS += -root /rc
PKGCONFIG += exiv2
DEFINES += QT_USE_QSTRINGBUILDER

# Input

SOURCES += \
	src/main.cpp \
	src/album/album.cpp \
	src/album/album-default-template.cpp \
	src/album/album-collection.cpp \
	src/album/album-page.cpp \
	src/album/album-template.cpp \
	src/album/album-template-page.cpp \
	src/core/container-source.cpp \
	src/core/container-source-collection.cpp \
	src/core/data-collection.cpp \
	src/core/data-object.cpp \
	src/core/data-source.cpp \
	src/core/selectable-view-collection.cpp \
	src/core/source-collection.cpp \
	src/core/view-collection.cpp \
	src/database/album-table.cpp \
	src/database/database.cpp \
	src/database/media-table.cpp \
	src/database/photo-edit-table.cpp \
	src/event/event.cpp \
	src/event/event-collection.cpp \
	src/media/media-collection.cpp \
	src/media/media-source.cpp \
	src/media/preview-manager.cpp \
	src/photo/photo.cpp \
	src/photo/photo-metadata.cpp \
	src/qml/gallery-standard-image-provider.cpp \
	src/qml/qml-album-collection-model.cpp \
	src/qml/qml-event-collection-model.cpp \
	src/qml/qml-event-overview-model.cpp \
	src/qml/qml-media-collection-model.cpp \
	src/qml/qml-stack.cpp \
	src/qml/qml-view-collection-model.cpp \
	src/util/time.cpp \
	src/util/resource.cpp \
	src/util/imaging.cpp \
    src/photo/photo-edit-state.cpp \
    src/photo/photo-caches.cpp \
    src/gallery-application.cpp

HEADERS += \
	src/album/album.h \
	src/album/album-collection.h \
	src/album/album-default-template.h \
	src/album/album-page.h \
	src/album/album-template.h \
	src/album/album-template-page.h \
	src/core/container-source.h \
	src/core/container-source-collection.h \
	src/core/data-collection.h \
	src/core/data-object.h \
	src/core/data-source.h \
	src/core/selectable-view-collection.h \
	src/core/source-collection.h \
	src/core/view-collection.h \
	src/database/album-table.h \
	src/database/database.h \
	src/database/media-table.h \
	src/database/photo-edit-table.h \
	src/event/event.h \
	src/event/event-collection.h \
	src/media/media-collection.h \
	src/media/media-source.h \
	src/media/preview-manager.h \
	src/photo/photo.h \
	src/photo/photo-metadata.h \
	src/qml/gallery-standard-image-provider.h \
	src/qml/qml-album-collection-model.h \
	src/qml/qml-event-collection-model.h \
	src/qml/qml-event-overview-model.h \
	src/qml/qml-media-collection-model.h \
	src/qml/qml-stack.h \
	src/qml/qml-view-collection-model.h \
	src/util/collections.h \
	src/util/time.h \
	src/util/variants.h \
	src/util/resource.h \
	src/util/imaging.h \
    src/photo/photo-edit-state.h \
    src/photo/photo-caches.h \
    src/gallery-application.h

# Install

install_binary.path = $$PREFIX/bin/
install_binary.files = gallery
install_resources.path = $$PREFIX/share/gallery/
install_resources.files = rc/
INSTALLS = install_binary install_resources

OTHER_FILES += \
    rc/Capetown/Widgets/GalleryTab.qml
