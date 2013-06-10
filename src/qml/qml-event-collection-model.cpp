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

#include "qml-event-collection-model.h"
#include "event.h"
#include "event-collection.h"
#include "variants.h"
#include "gallery-manager.h"

/*!
 * \brief QmlEventCollectionModel::QmlEventCollectionModel
 * \param parent
 */
QmlEventCollectionModel::QmlEventCollectionModel(QObject* parent)
    : QmlViewCollectionModel(parent, "event", NULL)
{
    monitorSourceCollection(GalleryManager::instance()->eventCollection());
}

/*!
 * \brief QmlEventCollectionModel::VariantFor
 * \param object
 * \return
 */
QVariant QmlEventCollectionModel::variantFor(DataObject *object) const
{
    Event* event = qobject_cast<Event*>(object);

    return (event != NULL) ? QVariant::fromValue(event) : QVariant();
}

/*!
 * \brief QmlEventCollectionModel::FromVariant
 * \param var
 * \return
 */
DataObject* QmlEventCollectionModel::fromVariant(QVariant var) const
{
    return UncheckedVariantToObject<Event*>(var);
}
