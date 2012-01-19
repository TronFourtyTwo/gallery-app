/*
 * Copyright (C) 2011 Canonical Ltd
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

Rectangle {
  id: album_viewer
  objectName: "album_viewer"
  
  property variant album
  
  anchors.fill: parent

  PlaceholderPopupMenu {
    id: addPhotosMenu

    z: 20
    anchors.bottom: toolbar.top
    x: toolbar.moreOperationsPopupX - width;

    itemTitle: "Add photos"

    state: "hidden"

    onItemChosen: {
      navStack.switchToMediaSelector(album)
    }
  }


  AlbumViewMasthead {
    id: masthead
    objectName: "masthead"

    albumName: template_pager.albumName

    areItemsSelected: gridCheckerboard.selectedCount > 0

    x: 0
    y: 0
    width: parent.width

    onViewModeChanged: {
      if (isTemplateView) {
        template_pager.visible = true;
        gridCheckerboard.visible = false;
      } else {
        template_pager.visible = false;
        gridCheckerboard.visible = true;
      }
    }

    onSelectionInteractionCompleted: {
      gridCheckerboard.state = "normal";
      gridCheckerboard.unselectAll();
    }

    onDeselectAllRequested: {
      gridCheckerboard.unselectAll();
    }
  }
  
  ListView {
    id: template_pager
    objectName: "template_pager"
    
    property string albumName

    anchors.top: masthead.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    
    visible: true
    
    orientation: ListView.Horizontal
    snapMode: ListView.SnapOneItem
    cacheBuffer: width * 2
    flickDeceleration: 50
    keyNavigationWraps: true
    highlightMoveSpeed: 2000.0
    
    model: (album) ? album.pages : null
    
    delegate: Loader {
      id: loader
      
      width: template_pager.width
      height: template_pager.height
      
      source: qmlRC
      
      onLoaded: {
        item.mediaSourceList = mediaSourceList;
        item.width = template_pager.width;
        item.height = template_pager.height;
        item.gutter = 24;
        template_pager.albumName = owner.name;
      }
    }

    onCurrentIndexChanged: album.currentPage = currentIndex

    function updateCurrentIndex() {
      // Add one to ensure the hit-test is inside the delegate's boundaries
      currentIndex = indexAt(contentX + 1, contentY + 1);
    }

    onModelChanged: {
      updateCurrentIndex();
    }

    onVisibleChanged: {
      updateCurrentIndex();
    }

    onCountChanged: {
      updateCurrentIndex();
    }

    onMovementEnded: {
      updateCurrentIndex();
    }
  }
  
  Checkerboard {
    id: gridCheckerboard
    objectName: "gridCheckerboard"
    
    anchors.top: masthead.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.topMargin: 24
    anchors.bottomMargin: 0
    anchors.leftMargin: 22
    anchors.rightMargin: 22
    
    visible: false
    
    allowSelection: true
    
    model: MediaCollectionModel {
      forCollection: album
    }
    
    delegate: PhotoComponent {
      anchors.centerIn: parent
      
      width: parent.width
      height: parent.height
      
      mediaSource: modelData.mediaSource
      isCropped: true
      isPreview: true
    }

    MouseArea {
      id: mouse_blocker
      objectName: "mouse_blocker"

      anchors.fill: parent

      onClicked: {
        if (addPhotosMenu.state == "shown" || album_picker.state == "shown") {
          addPhotosMenu.state = "hidden"
          album_picker.state = "hidden"
          return;
        }
      }

      visible: (addPhotosMenu.state == "shown" || album_picker.state == "shown")
    }

    onInSelectionModeChanged: {
      masthead.isSelectionInProgress = inSelectionMode
    }
    
    onActivated: navStack.switchToPhotoViewer(object, model)
  }

  AlbumPickerPopup {
    id: album_picker
    objectName: "album_picker"

    y: parent.height - height - toolbar.height
    x: toolbar.albumOperationsPopupX - width

    designated_model: AlbumCollectionModel {
    }

    state: "hidden"

    onNewAlbumRequested: {
      gridCheckerboard.model.createAlbumFromSelected();
      gridCheckerboard.state = "normal";
      gridCheckerboard.unselectAll();
      state = "hidden"
    }

    onSelected: {
      album.addSelectedMediaSources(gridCheckerboard.model);
      gridCheckerboard.state = "normal";
      gridCheckerboard.unselectAll();
    }
  }

  GalleryStandardToolbar {
    id: toolbar
    objectName: "toolbar"

    hasFullIconSet: (gridCheckerboard.visible && gridCheckerboard.selectedCount > 0)
    useContrastOnWhiteColorScheme: gridCheckerboard.visible
    isTranslucent: true

    z: 10
    anchors.bottom: parent.bottom

    onReturnButtonPressed: {
      album_picker.visible = false
      masthead.isSelectionInProgress = false
      masthead.areItemsSelected = false
      gridCheckerboard.state = "normal";
      gridCheckerboard.unselectAll();

      navStack.goBack();
    }

    onMoreOperationsButtonPressed: addPhotosMenu.flipVisibility();

    onAlbumOperationsButtonPressed: album_picker.flipVisibility();
  }
}