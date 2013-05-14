/*
 * Copyright (C) 2013 Canonical, Ltd.
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
#include <QString>

#include "util/resource.h"

class tst_Resource : public QObject
{
  Q_OBJECT

private slots:
    void maxTextureSize();
};

void tst_Resource::maxTextureSize()
{
    Resource resource(0);
    QCOMPARE(resource.maxTextureSize(), 0);
}

QTEST_MAIN(tst_Resource);

#include "tst_resource.moc"