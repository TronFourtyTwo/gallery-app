/*
 * Copyright (C) 2011-2012 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 * Jim Nelson <jim@yorba.org>
 * Lucas Beeler <lucas@yorba.org>
 */

import QtQuick 1.1
import Gallery 1.0
import "../Capetown"
import "../Capetown/Viewer"

PhotoViewer {
  id: galleryPhotoViewer

  // When the user clicks the back button.
  signal closeRequested()
  signal editRequested(variant photo) // The user wants to edit this photo.

  // NOTE: These properties should be treated as read-only, as setting them
  // individually can lead to bogus results.  Use setCurrentPhoto() or
  // setCurrentIndex() to initialize the view.
  property variant photo: null

  function setCurrentPhoto(photo) {
    setCurrentIndex(model.indexOf(photo));
  }
  
  onCurrentIndexChanged: {
    if (model)
      photo = model.getAt(currentIndex);
  }
  
  delegate: GalleryPhotoComponent {
    id: galleryPhotoComponent
    
    width: galleryPhotoViewer.width
    height: galleryPhotoViewer.height
    
    visible: true
    color: "black"
    
    opacity: {
      if (!galleryPhotoViewer.moving || galleryPhotoViewer.contentX < 0
        || index != galleryPhotoViewer.currentIndexForHighlight)
        return 1.0;
      
      return 1.0 - Math.abs((galleryPhotoViewer.contentX - x) / width);
    }
    
    isZoomable: true;
    
    mediaSource: model.mediaSource
    ownerName: "galleryPhotoViewer"
  }

  // Don't allow flicking while the chrome is actively displaying a popup
  // menu or the image is zoomed. When images are zoomed, mouse drags should
  // pan, not flick.
  interactive: !chrome.popupActive && (currentItem != null) &&
    (currentItem.state == "unzoomed")
  
  // Handles the Chrome overlay.  (The underlying PhotoViewer's MouseArea
  // is where flicking and zooming are handled.)
  //
  // Note that this involves some evil hacks to propogate the events to the
  // underlying MouseArea; this should be unecessary once we swich to Qt 5.
  // See this bug for more info: https://bugreports.qt-project.org/browse/QTBUG-13007
  MouseArea {
    id: galleryPhotoViewerMouseArea
    
    property bool wasPressed: false
    
    anchors.fill: parent
    
    Timer {
      id: chromeFadeWaitClock
      
      interval: 150
      running: false
      
      onTriggered: chrome.flipVisibility()
    }
    
    onClicked: {
      // TODO: remove when switching to Qt 5 (see above)
      mouseArea.clicked(mouse);
      
      // Trigger chrome if we aren't zoomed or we are but they didn't drag.
      if (currentItem.state == "unzoomed" || mouseArea.distance < 20)
        chromeFadeWaitClock.restart();
    }
    
    onDoubleClicked: {
      // TODO: remove when switching to Qt 5 (see above)
      mouseArea.doubleClicked(mouse);
      
      chromeFadeWaitClock.stop();
      chrome.state = "hidden";
    }
    
    onPressed: {
      // This signal works slightly differently than the others; since
      // pressed is a read-only bool, and signals don't act as proper functions
      // in QML, we use a workaround.  See PhotoViewer for more details.
      mouseArea.onPressedPublic(mouse);
    }
    
    onPositionChanged: {
      // TODO: remove when switching to Qt 5 (see above)
      mouseArea.positionChanged(mouse);
    }
    
    onReleased: {
      // TODO: remove when switching to Qt 5 (see above)
      mouseArea.released(mouse);
    }
  }
  
  ViewerChrome {
    id: chrome

    z: 10
    anchors.fill: parent

    toolbarsAreTextured: false
    toolbarsAreTranslucent: true
    toolbarsAreDark: true

    hasLeftNavigationButton: !galleryPhotoViewer.atXBeginning
    hasRightNavigationButton: !galleryPhotoViewer.atXEnd

    onLeftNavigationButtonPressed: galleryPhotoViewer.pageBack()
    onRightNavigationButtonPressed: galleryPhotoViewer.pageForward()

    popups: [ photoViewerShareMenu, photoViewerOptionsMenu,
      trashOperationDialog, popupAlbumPicker ]

    GenericShareMenu {
      id: photoViewerShareMenu

      popupOriginX: -gu(8.5)
      popupOriginY: -gu(6)

      onPopupInteractionCompleted: {
        chrome.hideAllPopups();
      }

      visible: false
    }

    PhotoViewerOptionsMenu {
      id: photoViewerOptionsMenu

      popupOriginX: -gu(0.5)
      popupOriginY: -gu(6)

      onPopupInteractionCompleted: {
        chrome.hideAllPopups();
      }

      visible: false

      onActionInvoked: {
        // See https://bugreports.qt-project.org/browse/QTBUG-17012 before you
        // edit a switch statement in QML.  The short version is: use braces
        // always.
        switch (name) {
          case "onEdit": {
            photoViewer.editRequested(photo);
            break;
          }
        }
      }
    }

    DeleteDialog {
      id: trashOperationDialog

      popupOriginX: -gu(24.5)
      popupOriginY: -gu(6)

      onPopupInteractionCompleted: {
        chrome.hideAllPopups();
      }

      visible: false

      onDeleteRequested: {
        model.destroyMedia(photo);

        if (model.count == 0)
          photoViewer.closeRequested();
      }
    }

    PopupAlbumPicker {
      id: popupAlbumPicker

      popupOriginX: -gu(17.5)
      popupOriginY: -gu(6)

      onPopupInteractionCompleted: {
        chrome.hideAllPopups();
      }

      onAlbumPicked: album.addMediaSource(photo)

      visible: false
    }

    onReturnButtonPressed: {
      resetVisibility(false);
      galleryPhotoViewer.currentItem.state = "unzoomed";
      closeRequested();
    }

    onShareOperationsButtonPressed: {
      cyclePopup(photoViewerShareMenu);
    }

    onMoreOperationsButtonPressed: {
      cyclePopup(photoViewerOptionsMenu);
    }

    onAlbumOperationsButtonPressed: {
      cyclePopup(popupAlbumPicker);
    }

    onTrashOperationButtonPressed: {
      cyclePopup(trashOperationDialog);
    }
  }
}