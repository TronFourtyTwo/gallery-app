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
QT += gui declarative opengl
MOC_DIR = build
OBJECTS_DIR = build
RESOURCES = rc/gallery.qrc
RCC_DIR = build
QMAKE_RESOURCE_FLAGS += -root /rc
PKGCONFIG += exiv2

install.path = $$PREFIX/bin/
install.files = gallery
INSTALLS = install

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
	src/util/time.cpp

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
	src/util/variants.h

OTHER_FILES += \
	rc/gallery.qrc \
	\
	rc/Capetown/qmldir \
	rc/Capetown/DissolveAnimation.qml \
	rc/Capetown/FadeInAnimation.qml \
	rc/Capetown/FadeOutAnimation.qml \
	\
	rc/qml/AddCreateOperationNavbarButton.qml \
	rc/qml/AddToNewAlbumButton.qml \
	rc/qml/AlbumCover.qml \
	rc/qml/AlbumEditor.qml \
	rc/qml/AlbumEditorTransition.qml \
	rc/qml/AlbumOpener.qml \
	rc/qml/AlbumOperationsToolbarButton.qml \
	rc/qml/AlbumPageComponent.qml \
	rc/qml/AlbumPageContents.qml \
	rc/qml/AlbumPageIndicator.qml \
	rc/qml/AlbumPageLayout.qml \
	rc/qml/AlbumPageLayoutLeftDoubleLandscape.qml \
	rc/qml/AlbumPageLayoutLeftPortrait.qml \
	rc/qml/AlbumPageLayoutRightPortrait.qml \
	rc/qml/AlbumPreviewComponent.qml \
	rc/qml/AlbumSpreadViewer.qml \
	rc/qml/AlbumViewer.qml \
	rc/qml/AlbumViewerOptionsMenu.qml \
	rc/qml/AlbumViewerShareMenu.qml \
	rc/qml/AlbumViewerTransition.qml \
	rc/qml/BinaryTabGroup.qml \
	rc/qml/Checkerboard.qml \
	rc/qml/CheckerboardDelegate.qml \
	rc/qml/EventCard.qml \
	rc/qml/EventCheckerboard.qml \
	rc/qml/EventCheckerboardPreview.qml \
	rc/qml/EventTimeline.qml \
	rc/qml/EventTimelineTransition.qml \
	rc/qml/ExpandAnimation.qml \
	rc/qml/FramePortrait.qml \
	rc/qml/Gallery.js \
	rc/qml/GalleryApplication.qml \
	rc/qml/GalleryOverviewNavigationBar.qml \
	rc/qml/GalleryPrimaryPushButton.qml \
	rc/qml/GallerySecondaryPushButton.qml \
	rc/qml/GalleryStandardNavbar.qml \
	rc/qml/GalleryStandardToolbar.qml \
	rc/qml/GalleryUtility.js \
	rc/qml/MattedPhotoPreview.qml \
	rc/qml/MediaSelector.qml \
	rc/qml/MenuItem.qml \
	rc/qml/MoreOperationsToolbarButton.qml \
	rc/qml/NavStack.qml \
	rc/qml/Overview.qml \
	rc/qml/Pager.qml \
	rc/qml/PhotoComponent.qml \
	rc/qml/PhotoViewer.qml \
	rc/qml/PhotoViewerOptionsMenu.qml \
	rc/qml/PhotoViewerShareMenu.qml \
	rc/qml/PhotoViewerTransition.qml \
	rc/qml/PopupActionCancelDialog.qml \
	rc/qml/PopupAlbumPicker.qml \
	rc/qml/PopupBox.qml \
	rc/qml/PopupMenu.qml \
	rc/qml/PopupPhotoViewer.qml \
	rc/qml/PushButton.qml \
	rc/qml/SelectionMenu.qml \
	rc/qml/SelectionOperationsToolbarButton.qml \
	rc/qml/ShareOperationsToolbarButton.qml \
	rc/qml/SlidingPane.qml \
	rc/qml/SwipeArea.qml \
	rc/qml/Tab.qml \
	rc/qml/Toolbar.qml \
	rc/qml/ToolbarIconButton.qml \
	rc/qml/TrashOperationToolbarButton.qml \
	rc/qml/ViewerChrome.qml \
	rc/qml/ViewerNavigationButton.qml
