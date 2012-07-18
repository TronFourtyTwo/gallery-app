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
 * Lucas Beeler <lucas@yorba.org>
 */

import QtQuick 1.1

PopupBox {
  id: popupDialog

  property alias explanatoryText: explanatoryText.text

  Text {
    id: explanatoryText

    anchors.top: parent.top
    anchors.topMargin: gu(2)
    anchors.left: parent.left
    anchors.leftMargin: gu(2)
    anchors.right: parent.right
    anchors.rightMargin: gu(2)
    height: gu(7)

    font.pixelSize: gu(2.25)

    color: "#818285"

    text: ""

    wrapMode: Text.WordWrap
  }
}