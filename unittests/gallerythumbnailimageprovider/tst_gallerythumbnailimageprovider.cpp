/*
 * Copyright (C) 2012 Canonical, Ltd.
 *
 * Authors:
 *  Guenter Schwann <guenter.schwann@canonical.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QtTest/QtTest>
#include <QFileInfo>
#include <QUrl>

#include "gallery-application.h"
#include "gallery-thumbnail-image-provider.h"

GalleryApplication* GalleryApplication::instance_ = 0;

class tst_GalleryThumbnailImageProvider : public QObject
{
  Q_OBJECT
private slots:
  void initTestCase();
  void ToURL();
};

void tst_GalleryThumbnailImageProvider::initTestCase()
{
  GalleryThumbnailImageProvider::Init();
}

void tst_GalleryThumbnailImageProvider::ToURL()
{
  GalleryThumbnailImageProvider* provider = GalleryThumbnailImageProvider::instance();
  QFileInfo fi("/tmp/test.jpg");
  QUrl url = provider->ToURL(fi);
  QUrl expect("image://gallery-thumbnail//tmp/test.jpg");
  QCOMPARE(url, expect);
}


QTEST_MAIN(tst_GalleryThumbnailImageProvider);

#include "tst_gallerythumbnailimageprovider.moc"
