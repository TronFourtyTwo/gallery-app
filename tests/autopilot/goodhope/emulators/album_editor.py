# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.


class AlbumEditor(object):
    """An emulator class that makes it easy to interact with the gallery app."""

    def __init__(self, app):
        self.app = app

    def get_qml_view(self):
        """Get the main QML view"""
        return self.app.select_single("QQuickView")

    def get_albums_tab(self):
        """Returns the 'Albums' tab."""
        return self.app.select_single("GalleryTab", objectName="toolbarAlbumsTab")

    def get_plus_icon(self):
        """Returns the 'plus' icon of the main view."""
        return self.app.select_single("StandardToolbarIconButton", objectName="toolbarPlusIcon")

    def get_album_editor(self):
        """Returns the album editor."""
        return self.app.select_single("AlbumEditor", objectName="mainAlbumEditor")

    def get_album_title_entry_field(self):
        """Returns the album title input box."""
        return self.app.select_many("TextEditOnClick", objectName="albumTitleField")[0]

    def get_album_subtitle_entry_field(self):
        """Returns the album subtitle input box."""
        return self.app.select_many("TextEditOnClick", objectName="albumSubtitleField")[0]

