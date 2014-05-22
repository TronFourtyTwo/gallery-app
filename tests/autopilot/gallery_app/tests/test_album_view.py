# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.


"""Tests the album view of the gallery app"""

from testtools.matchers import Equals, GreaterThan, LessThan
from autopilot.matchers import Eventually

from gallery_app.emulators.album_view import AlbumView
from gallery_app.emulators.albums_view import AlbumsView
from gallery_app.emulators.media_selector import MediaSelector
from gallery_app.emulators import album_editor
from gallery_app.tests import GalleryTestCase

from time import sleep
from unittest import skip


class TestAlbumView(GalleryTestCase):
    """Tests the album view of the gallery app"""

    @property
    def album_view(self):
        return AlbumView(self.app)

    @property
    def albums_view(self):
        return AlbumsView(self.app)

    @property
    def media_selector(self):
        return MediaSelector(self.app)

    def setUp(self):
        self.ARGS = []
        super(TestAlbumView, self).setUp()
        self.switch_to_albums_tab()

    def test_album_view_open_photo(self):
        self.main_view.close_toolbar()
        self.open_first_album()
        self.main_view.close_toolbar()
        photo = self.album_view.get_first_photo()
        # workaround lp:1247698
        self.main_view.close_toolbar()
        self.click_item(photo)
        sleep(5)
        photo_view = self.main_view.wait_select_single("PopupPhotoViewer")
        self.assertThat(photo_view.visible, Eventually(Equals(True)))

    def test_album_view_flipping(self):
        self.main_view.close_toolbar()

        # For some reason here the album at position 0 in the autopilot list is
        # actually the second album, they seem to be returned in reverse order.
        self.open_album_at(0)
        self.main_view.close_toolbar()

        spread = self.album_view.get_spread_view()

        # check that we can page to the cover and back (we check for lesser
        # than 1 because it can either be 0 if we are on a one page spread
        # or -1 if we are on a two page spread, for example on desktop)
        self.album_view.swipe_page_left(1)
        self.assertThat(spread.viewingPage, Eventually(LessThan(1)))
        self.album_view.swipe_page_right(0)
        self.assertThat(spread.viewingPage, Eventually(Equals(1)))

        # drag to next page and check we have flipped away from page 1
        # can't check precisely for page 2 because depending on form factor
        # and orientation we might be displaying two pages at the same time
        self.album_view.swipe_page_right(1)
        self.assertThat(spread.viewingPage, Eventually(GreaterThan(1)))

    def test_add_photo(self):
        self.main_view.close_toolbar()
        self.open_first_album()
        num_photos_start = self.album_view.number_of_photos()
        self.assertThat(num_photos_start, Equals(1))

        # open media selector but cancel
        self.main_view.open_toolbar().click_button("addButton")
        self.media_selector.ensure_fully_open()

        self.main_view.get_toolbar().click_custom_button("cancelButton")
        sleep(1)

        num_photos = self.album_view.number_of_photos()
        self.assertThat(num_photos, Equals(num_photos_start))

        # open media selector and add a photo
        self.main_view.open_toolbar().click_button("addButton")
        self.media_selector.ensure_fully_open()

        photo = self.media_selector.get_second_photo()
        self.click_item(photo)
        self.main_view.get_toolbar().click_custom_button("addButton")

        self.assertThat(
            lambda: self.album_view.number_of_photos(),
            Eventually(Equals(num_photos_start + 1)))

    def test_add_photo_to_new_album(self):
        self.main_view.open_toolbar().click_button("addButton")
        self.ui_update()

        editor = self.app.select_single(album_editor.AlbumEditor)
        editor.ensure_fully_open()
        self.main_view.close_toolbar()
        editor.close()

        self.open_first_album()
        self.main_view.close_toolbar()
        num_photos_start = self.album_view.number_of_photos()
        self.assertThat(num_photos_start, Equals(0))

        plus = self.album_view.get_plus_icon_empty_album()
        # workaround lp:1247698
        self.main_view.close_toolbar()
        self.click_item(plus)
        self.media_selector.ensure_fully_open()

        photo = self.media_selector.get_second_photo()
        self.click_item(photo)
        self.main_view.get_toolbar().click_custom_button("addButton")

        self.assertThat(
            lambda: self.album_view.number_of_photos(),
            Eventually(Equals(num_photos_start + 1)))

    @skip("Temporarily disable as it fails in some cases, supposedly due to "
          "problems with the infrastructure")
    def test_save_state(self):
        self.main_view.close_toolbar()
        self.open_first_album()

        id = self.album_view.get_album_view().albumId

        self.ensure_app_has_quit()
        self.start_app()

        view = self.album_view.get_album_view()
        self.assertThat(view.visible, Eventually(Equals(True)))
        self.assertThat(view.albumId, Eventually(Equals(id)))

    @skip("Temporarily disable as it fails in some cases, supposedly due to "
          "problems with the infrastructure")
    def test_no_save_state_on_back(self):
        self.main_view.close_toolbar()
        self.open_first_album()
        self.main_view.open_toolbar().click_button("backButton")

        self.ensure_app_has_quit()
        self.start_app()

        view = self.album_view.get_animated_album_view()
        self.assertThat(view.isOpen, Equals(False))
