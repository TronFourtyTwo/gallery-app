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

#include "qml-event-overview-model.h"
#include "data-object.h"
#include "selectable-view-collection.h"
#include "event.h"
#include "event-collection.h"
#include "variants.h"
#include "gallery-manager.h"

/*!
 * \brief QmlEventOverviewModel::QmlEventOverviewModel
 * \param parent
 */
QmlEventOverviewModel::QmlEventOverviewModel(QObject* parent)
    : QmlMediaCollectionModel(parent, DescendingComparator),
      ascending_order_(false), syncing_media_(false)
{
    // initialize ViewCollection as it stands now with Events
    MonitorNewViewCollection();

    // We need to know when events get removed from the system so we can remove
    // them too.
    QObject::connect(
                GalleryManager::instance()->event_collection(),
                SIGNAL(contentsChanged(const QSet<DataObject*>*,const QSet<DataObject*>*)),
                this,
                SLOT(on_events_altered(const QSet<DataObject*>*,const QSet<DataObject*>*)));
}

/*!
 * \brief QmlEventOverviewModel::RegisterType
 */
void QmlEventOverviewModel::RegisterType()
{
    qmlRegisterType<QmlEventOverviewModel>("Gallery", 1, 0, "EventOverviewModel");
}

/*!
 * \brief QmlEventOverviewModel::ascending_order
 * \return
 */
bool QmlEventOverviewModel::ascending_order() const
{
    return ascending_order_;
}

/*!
 * \brief QmlEventOverviewModel::set_ascending_order
 * \param ascending
 */
void QmlEventOverviewModel::set_ascending_order(bool ascending)
{
    if (ascending == ascending_order_)
        return;

    ascending_order_ = ascending;
    DataObjectComparator comparator =
            ascending_order_ ? AscendingComparator : DescendingComparator;

    set_default_comparator(comparator);
    BackingViewCollection()->setComparator(comparator);
}

/*!
 * \brief QmlEventOverviewModel::VariantFor
 * \param object
 * \return
 */
QVariant QmlEventOverviewModel::VariantFor(DataObject* object) const
{
    Event* event = qobject_cast<Event*>(object);

    return (event != NULL) ? QVariant::fromValue(event) : QmlMediaCollectionModel::VariantFor(object);
}

/*!
 * \brief QmlEventOverviewModel::FromVariant
 * \param var
 * \return
 */
DataObject* QmlEventOverviewModel::FromVariant(QVariant var) const
{
    DataObject* object = UncheckedVariantToObject<Event*>(var);

    return (object != NULL) ? object : QmlMediaCollectionModel::FromVariant(var);
}

/*!
 * \brief QmlEventOverviewModel::notify_backing_collection_changed
 */
void QmlEventOverviewModel::notify_backing_collection_changed()
{
    MonitorNewViewCollection();

    QmlViewCollectionModel::notify_backing_collection_changed();
}

/*!
 * \brief QmlEventOverviewModel::MonitorNewViewCollection
 */
void QmlEventOverviewModel::MonitorNewViewCollection()
{
    if (BackingViewCollection() == NULL)
        return;

    QObject::connect(
                BackingViewCollection(),
                SIGNAL(contentsChanged(const QSet<DataObject*>*,const QSet<DataObject*>*)),
                this,
                SLOT(on_event_overview_contents_altered(const QSet<DataObject*>*,const QSet<DataObject*>*)));

    QObject::connect(
                BackingViewCollection(),
                SIGNAL(selectionChanged(const QSet<DataObject*>*,const QSet<DataObject*>*)),
                this,
                SLOT(on_event_overview_selection_altered(const QSet<DataObject*>*,const QSet<DataObject*>*)));

    // seed existing contents with Events
    on_event_overview_contents_altered(&BackingViewCollection()->getAsSet(), NULL);
}

/*!
 * \brief QmlEventOverviewModel::on_events_altered
 * \param added
 * \param removed
 */
void QmlEventOverviewModel::on_events_altered(const QSet<DataObject*>* added,
                                              const QSet<DataObject*>* removed)
{
    SelectableViewCollection* view = BackingViewCollection();
    if (view == NULL)
        return;

    if (removed != NULL) {
        DataObject* object;
        foreach (object, *removed) {
            Event* event = qobject_cast<Event*>(object);
            Q_ASSERT(event != NULL);

            if (view->contains(event))
                view->remove(event);
        }
    }
}

/*!
 * \brief QmlEventOverviewModel::on_event_overview_contents_altered
 * \param added
 * \param removed
 */
void QmlEventOverviewModel::on_event_overview_contents_altered(
        const QSet<DataObject*>* added, const QSet<DataObject*>* removed)
{
    SelectableViewCollection* view = BackingViewCollection();

    if (added != NULL) {
        DataObject* object;
        foreach (object, *added) {
            MediaSource* source = qobject_cast<MediaSource*>(object);
            if (source == NULL)
                continue;

            QDate source_date = source->exposureDateTime().date();
            Event* event = GalleryManager::instance()->event_collection()->eventForDate(source_date);
            Q_ASSERT(event != NULL);

            if (!view->contains(event))
                view->add(event);
        }
    }
}

/*!
 * \brief QmlEventOverviewModel::on_event_overview_selection_altered
 * \param selected
 * \param unselected
 */
void QmlEventOverviewModel::on_event_overview_selection_altered(
        const QSet<DataObject*>* selected, const QSet<DataObject*>* unselected)
{
    // if an Event is selected, select all photos in that date
    SyncSelectedMedia(selected, true);

    // if an Event is unselected, unselect all photos in that date
    SyncSelectedMedia(unselected, false);
}

/*!
 * \brief QmlEventOverviewModel::SyncSelectedMedia
 * \param toggled
 * \param selected
 */
void QmlEventOverviewModel::SyncSelectedMedia(const QSet<DataObject*>* toggled,
                                              bool selected)
{
    if (toggled == NULL)
        return;

    // Don't recurse -- only take action from the selection made by the user, not
    // any other selections we've done internally.
    if (syncing_media_)
        return;

    syncing_media_ = true;

    SelectableViewCollection* view = BackingViewCollection();
    int count = view->count();

    // Walk the toggle group looking for Event's; when found, walk all the
    // MediaSources that follow and select or unselect them; when another
    // Event is found (or end of list), exit
    //
    // TODO: Select/Unselect in bulk operations for efficiency
    DataObject* object;
    foreach (object, *toggled) {
        Event* event = qobject_cast<Event*>(object);
        if (event == NULL)
            continue;

        int index = view->indexOf(event);
        for (int ctr = index + 1; ctr < count; ctr++) {
            MediaSource* media = qobject_cast<MediaSource*>(view->getAt(ctr));
            if (media == NULL)
                break;

            if (selected)
                view->select(media);
            else
                view->unselect(media);
        }
    }

    // The other case is when the user is selecting or deselecting media.  We
    // walk around looking for other media to see if we should select or deselect
    // the containing event.
    //
    // TODO: Select/Unselect in bulk operations for efficiency
    foreach (object, *toggled) {
        MediaSource* media = qobject_cast<MediaSource*>(object);
        if (media == NULL)
            break;

        int index = view->indexOf(media);
        bool all_match_selection = true;

        // First walk forward to the next event/end of list looking for differing
        // selection states in other media.
        for (int i = index + 1; i < count; ++i) {
            MediaSource* media = qobject_cast<MediaSource*>(view->getAt(i));
            if (media == NULL)
                break;

            if (view->isSelected(media) != selected) {
                all_match_selection = false;
                break;
            }
        }

        // Now walk backwards also checking media, and looking for the event.
        for (int i = index - 1; i >= 0; --i) {
            MediaSource* media = qobject_cast<MediaSource*>(view->getAt(i));
            Event* event = qobject_cast<Event*>(view->getAt(i));

            if (media != NULL) {
                if (view->isSelected(media) != selected)
                    all_match_selection = false;
            }

            if (event != NULL) {
                if (all_match_selection && selected)
                    view->select(event);
                else
                    view->unselect(event);
                break;
            }
        }
    }

    syncing_media_ = false;
}

/*!
 * \brief QmlEventOverviewModel::AscendingComparator
 * \param a
 * \param b
 * \return
 */
bool QmlEventOverviewModel::AscendingComparator(DataObject* a, DataObject* b)
{
    return EventComparator(a, b, true);
}

/*!
 * \brief QmlEventOverviewModel::DescendingComparator
 * \param a
 * \param b
 * \return
 */
bool QmlEventOverviewModel::DescendingComparator(DataObject* a, DataObject* b)
{
    return EventComparator(a, b, false);
}

/*!
 * \brief QmlEventOverviewModel::EventComparator
 * \param a
 * \param b
 * \param asc
 * \return
 */
bool QmlEventOverviewModel::EventComparator(DataObject* a, DataObject* b, bool asc)
{
    QDateTime atime = ObjectDateTime(a, asc);
    QDateTime btime = ObjectDateTime(b, asc);

    // use default comparator to stabilize order (reversing comparison for descending
    // order)
    bool lessThan;
    if (atime != btime)
        lessThan = atime < btime;
    else
        lessThan = DataCollection::defaultDataObjectComparator(a, b);

    return (asc) ? lessThan : !lessThan;
}

/*!
 * \brief QmlEventOverviewModel::ObjectDateTime
 * Since items in the list can be either a MediaSource or an Event,
 * determine dynamically and compare.  Since going in reverse chronological order,
 * use the event's end date/time for comparison (to place it before everything
 * else inside of it)
 * \param object
 * \param asc
 * \return
 */
QDateTime QmlEventOverviewModel::ObjectDateTime(DataObject* object, bool asc)
{
    MediaSource* media = qobject_cast<MediaSource*>(object);
    if (media != NULL)
        return media->exposureDateTime();

    // Events are different depending on ascending vs. descending; they should
    // always be at the head of the MediaSource span, so they need to use different
    // times to ensure that
    Event* event = qobject_cast<Event*>(object);
    if (event != NULL)
        return asc ? event->startDateTime() : event->endDateTime();

    return QDateTime();
}
