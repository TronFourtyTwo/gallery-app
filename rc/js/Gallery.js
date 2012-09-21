/*
 * Copyright (C) 2012 Canonical Ltd
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
 */

var EVENT_TIMELINE_MEDIA_SOURCE_OPACITY = 0.8;
var EVENT_TIMELINE_EVENT_CARD_OPACITY = 1.0;

function getDeviceSpecific(key, form_factor, is_portrait) {
  // Big list of form factor-specific values.  'default' is used if the key
  // can't be found under any other form_factor (otherwise, form_factors should
  // match the FORM_FACTOR values passed from main.cpp).  Just add Portrait to
  // the end of a key to make it portrait-mode specific.
  var specifics = {
    'default': {
      // Size of thumbnails in event overview/media selector/etc.
      photoThumbnailWidth: gu(24),
      photoThumbnailHeight: gu(18),

      // Whitespace around photos in event overview/media selector/etc.
      photoGridTopMargin: gu(2), // Plus half of photoGridGutterHeight.
      photoGridLeftMargin: gu(2), // Plus half of photoGridGutterWidth.
      photoGridRightMargin: gu(2), // Plus half of photoGridGutterWidth.
      photoGridGutterWidth: gu(2),
      photoGridGutterHeight: gu(2),

      // Layout of thumbnails in event timeline.
      photoThumbnailWidthTimeline: gu(24),
      photoThumbnailHeightTimeline: gu(18),
      timelineFirstPhotoDistance: gu(25), // width + 1
      timelineSecondPhotoDistance: gu(25), // width + 1

      // Size of thumbnails in album overview.
      albumThumbnailWidth: gu(28),
      albumThumbnailHeight: gu(33),

      // Whitespace around photos in album overview.
      albumGridTopMargin: gu(2), // Plus half of albumGridGutterHeight.
      albumGridLeftMargin: gu(2), // Plus half of albumGridGutterWidth.
      albumGridRightMargin: gu(2), // Plus half of albumGridGutterWidth.
      albumGridGutterWidth: gu(6),
      albumGridGutterHeight: gu(8),

      // Whitespace around photos on album pages in the album viewer.
      albumPageTopMargin: gu(6),
      albumPageBottomMargin: gu(6),
      albumPageGutterMargin: gu(2), // Between spine and photo.
      albumPageOuterMargin: gu(3), // Between opposite edge and photo.
      albumPageInsideMargin: gu(4), // Between photos on one page.

      // Whitespace around photos on album pages in preview thumbnails.
      albumPreviewTopMargin: gu(2),
      albumPreviewBottomMargin: gu(2),
      albumPreviewGutterMargin: gu(1), // Between spine and photo.
      albumPreviewOuterMargin: gu(1), // Between opposite edge and photo.
      albumPreviewInsideMargin: gu(2), // Between photos on one page.
    },

    phone: {
      photoThumbnailWidth: gu(17),
      photoThumbnailHeight: gu(13),

      photoGridTopMargin: gu(2),
      photoGridLeftMargin: gu(4),
      photoGridRightMargin: gu(4),
      photoGridTopMarginPortrait: gu(1),
      photoGridLeftMarginPortrait: gu(1),
      photoGridRightMarginPortrait: gu(1),

      photoGridGutterWidth: gu(4),
      photoGridGutterHeight: gu(4),
      photoGridGutterWidthPortrait: gu(2),
      photoGridGutterHeightPortrait: gu(2),

      photoThumbnailWidthTimeline: gu(13),
      photoThumbnailHeightTimeline: gu(10),
      timelineFirstPhotoDistance: gu(10.5),
      timelineSecondPhotoDistance: gu(10),
      timelineFirstPhotoDistancePortrait: gu(3),
      timelineSecondPhotoDistancePortrait: gu(2),

      albumThumbnailWidth: gu(17),
      albumThumbnailHeight: gu(20),

      albumGridTopMargin: gu(1),
      albumGridLeftMargin: gu(4),
      albumGridRightMargin: gu(4),
      albumGridTopMarginPortrait: -gu(1), // gets added to a bigger positive value
      albumGridLeftMarginPortrait: gu(1),
      albumGridRightMarginPortrait: gu(1),

      albumGridGutterWidth: gu(4),
      albumGridGutterHeight: gu(6),
      albumGridGutterWidthPortrait: gu(2),
      albumGridGutterHeightPortrait: gu(6),

      albumPageTopMargin: gu(1),
      albumPageBottomMargin: gu(1),
      albumPageGutterMargin: gu(0.5),
      albumPageOuterMargin: gu(1),
      albumPageInsideMargin: gu(2),
      albumPageGutterMarginPortrait: gu(1),
      albumPageInsideMarginPortrait: gu(3),

      albumPreviewTopMargin: gu(1),
      albumPreviewBottomMargin: gu(1),
      albumPreviewGutterMargin: gu(1),
      albumPreviewOuterMargin: gu(1),
      albumPreviewInsideMargin: gu(1),
    },
  };

  if (is_portrait === undefined)
    is_portrait = isPortrait; // From GalleryApplication.

  if (!form_factor)
    form_factor = FORM_FACTOR; // From C++.
  if (form_factor === 'sidebar')
    form_factor = 'phone'; // Equivalent; saves typing above.
  if (specifics[form_factor] === undefined)
    form_factor = 'default';

  var portrait_key = key + 'Portrait';
  if (is_portrait && specifics[form_factor][portrait_key] !== undefined)
    return specifics[form_factor][portrait_key];
  if (is_portrait && specifics['default'][portrait_key] !== undefined)
    return specifics['default'][portrait_key];

  if (specifics[form_factor][key] !== undefined)
    return specifics[form_factor][key];
  if (specifics['default'][key] !== undefined)
    return specifics['default'][key];

  console.debug("Invalid key '" + key + "' passed to Gallery.getDeviceSpecific()");
  return undefined;
}

function isSmallFormFactor(form_factor) {
  if (!form_factor)
    form_factor = FORM_FACTOR; // From C++.

  return (form_factor === 'phone' || form_factor === 'sidebar');
}
