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

import QtQuick 2.0
import Gallery 1.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../Capetown"
import "../Capetown/Viewer"
import "Components"
import "Widgets"
import "../js/Gallery.js" as Gallery

Item {
  id: viewerWrapper

  property alias photo: galleryPhotoViewer.photo
  property alias model: galleryPhotoViewer.model
  property alias index: galleryPhotoViewer.index
  property alias currentIndexForHighlight:
      galleryPhotoViewer.currentIndexForHighlight
  
  // Set this when entering from an album.
  property variant album
  
  // Read-only
  // Set to true when an image is loaded and displayed.
  //
  // NOTE: The empty-model check does perform a useful function here and should NOT be
  // removed; for whatever reason, it's possible to get here and have what would have
  // been the current item be deleted, but not be null, and what it actually points to
  // is no longer valid and will result in an immediate segfault if dereferenced.
  //
  // Since there is no current item if there are no more photo objects left in the model,
  // the check catches this before we can inadvertently follow a stale pointer.
  property bool isReady: model != null && model.count > 0 &&
    (galleryPhotoViewer.currentItem ? galleryPhotoViewer.currentItem.isLoaded : false)

  signal closeRequested()
  signal editRequested(variant photo)

  function setCurrentIndex(index) {
    galleryPhotoViewer.setCurrentIndex(index);
  }

  function setCurrentPhoto(photo) {
    galleryPhotoViewer.setCurrentPhoto(photo);
  }

  function goBack() {
    galleryPhotoViewer.goBack();
  }

  function goForward() {
    galleryPhotoViewer.goForward();
  }
  
  anchors.fill: parent;

  Rectangle{
    color: "black"
    anchors.fill: parent
  }

  PhotoViewer {
    id: galleryPhotoViewer

    // When the user clicks the back button.
    signal closeRequested()
    signal editRequested(variant photo) // The user wants to edit this photo.

    // NOTE: These properties should be treated as read-only, as setting them
    // individually can lead to bogus results.  Use setCurrentPhoto() or
    // setCurrentIndex() to initialize the view.
    property variant photo: null
    
    property bool load: false
    
    function setCurrentPhoto(photo) {
      setCurrentIndex(model.indexOf(photo));
      load = true; // Load on first usage
    }

    function goBack() {
      galleryPhotoViewer.currentItem.state = "unzoomed";
      pageBack();
    }

    function goForward() {
      galleryPhotoViewer.currentItem.state = "unzoomed";
      pageForward();
    }

    anchors.fill: parent

    Connections {
      target: photo || null
      ignoreUnknownSignals: true
      onBusyChanged: galleryPhotoViewer.updateBusy()
    }

    // Internal: use to switch the busy indicator on or off.
    function updateBusy() {
      if (photo.busy) {
        busySpinner.visible = true;
      } else {
        busySpinner.visible = false;
      }
    }

    onCurrentIndexChanged: {
      if (model)
        photo = model.getAt(currentIndex);
      chromeBar.setBarShown(false);
    }

    delegate: ZoomablePhotoComponent {
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
      
      mediaSource: model.mediaSource
      load: galleryPhotoViewer.load

      ownerName: "galleryPhotoViewer"

      onClicked: chromeFadeWaitClock.restart()
      onZoomed: {
          chromeFadeWaitClock.stop();
          chromeBar.setBarShown(false);
      }
      onUnzoomed: {
          chromeFadeWaitClock.stop();
          chromeBar.setBarShown(false);
      }
    }

    // Don't allow flicking while the chrome is actively displaying a popup
    // menu, or the image is zoomed, or we're cropping. When images are zoomed,
    // mouse drags should pan, not flick.
    interactive: (currentItem != null) &&
                 (currentItem.state == "unzoomed") && cropper.state == "hidden"

    Timer {
      id: chromeFadeWaitClock

      interval: 250
      running: false

      onTriggered: chromeBar.setBarShown(!chromeBar.showChromeBar)
    }

    AnimatedImage {
      id: busySpinner

      visible: false
      anchors.centerIn: parent
      source: "../img/spin.mng"
    }

    ChromeBar {
        id: chromeBar
        z: 100
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        buttonsModel: ListModel {
            ListElement {
                label: "Edit"
                name: "edit"
                icon: "../img/edit.png"
            }
            ListElement {
                label: "Add"
                name: "disabled"
                icon: "../img/add.png"
            }
            ListElement {
                label: "Delete"
                name: "delete"
                icon: "../img/delete.png"
            }
            ListElement {
                label: "Share"
                name: "share"
                icon: "../img/share.png"
            }
        }
        showChromeBar: true

        onBackButtonClicked:  {
            galleryPhotoViewer.currentItem.state = "unzoomed";
            closeRequested();
        }

        onButtonClicked: {
            switch (buttonName) {
            case "share": {
                sharePopover.picturePath = viewerWrapper.photo.path;
                sharePopover.caller = button;
                sharePopover.show();
                break;
            }
            case "delete": {
                deletePopover.caller = button;
                deletePopover.show();
                break;
            }
            case "add": {
                chromeBar.setBarShown(false);
                popupAlbumPicker.visible = true;
                break;
            }
            case "edit": {
                editPopover.caller = button;
                editPopover.show();
                break;
            }
            }
        }

        SharePopover {
            id: sharePopover
            objectName: "sharePopover"
            visible: false
        }

        DeleteSinglePhotoPopover {
            visible: false
            id: deletePopover
            objectName: "deletePopover"
            album: viewerWrapper.album
            photo: viewerWrapper.photo
            model: viewerWrapper.model
            photoViewer: galleryPhotoViewer
        }

        EditPopover {
            id: editPopover
            objectName: "editPopover"
            visible: false
            photo: galleryPhotoViewer.photo
            cropper: viewerWrapper.cropper
        }
    }

    PopupAlbumPicker {
        id: popupAlbumPicker
        objectName: "popupAlbumPicker"

        popupOriginX: -units.gu(17.5)
        popupOriginY: -units.gu(6)

        onPopupInteractionCompleted: {
            visible = false;
        }

        onAlbumPicked: album.addMediaSource(photo)

        visible: false
    }

    onCloseRequested: viewerWrapper.closeRequested()
    onEditRequested: viewerWrapper.editRequested(photo)
  }

  property alias cropper: cropper
  CropInteractor {
    id: cropper
    
    property var targetPhoto

    function show(photo) {
      targetPhoto = photo;
      
      fadeOutPhotoAnimation.running = true;
    }

    function hide() {
      state = "hidden";
      galleryPhotoViewer.opacity = 0.0;
      galleryPhotoViewer.visible = true;
      fadeInPhotoAnimation.running = true;      
    }

    state: "hidden"
    states: [
      State { name: "shown";
        PropertyChanges { target: cropper; visible: true; }
        PropertyChanges { target: cropper; opacity: 1.0; }
      },
      State { name: "hidden";
        PropertyChanges { target: cropper; visible: false; }
        PropertyChanges { target: cropper; opacity: 0.0; }
      }
    ]
    
    Behavior on opacity {
      NumberAnimation { duration: Gallery.FAST_DURATION }
    }

    anchors.fill: parent

    MouseArea {
      id: blocker
      
      visible: cropper.state == "shown"
      anchors.fill: parent
      
      onClicked: { }
    }

    onCanceled: {
      photo.cancelCropping();

      hide();

      targetPhoto = null;
    }

    onCropped: {
      var qtRect = Qt.rect(rect.x, rect.y, rect.width, rect.height);
      photo.crop(qtRect);

      hide();

      targetPhoto = null;
    }
    
    onOpacityChanged: {
      if (opacity == 1.0)
        galleryPhotoViewer.visible = false
    }
    
    NumberAnimation {
      id: fadeOutPhotoAnimation
      
      from: 1.0
      to: 0.0
      target: galleryPhotoViewer
      property: "opacity"
      duration: Gallery.FAST_DURATION
      easing.type: Easing.InOutQuad
      
      onRunningChanged: {
        if (running == false) {
          var ratio_crop_rect = cropper.targetPhoto.prepareForCropping();
          cropper.enter(cropper.targetPhoto, ratio_crop_rect);
          cropper.state = "shown";
        }
      }
    }

    NumberAnimation {
      id: fadeInPhotoAnimation
      
      from: 0.0
      to: 1.0
      target: galleryPhotoViewer
      property: "opacity"
      duration: Gallery.FAST_DURATION
      easing.type: Easing.InOutQuad    
    }
  }
}
