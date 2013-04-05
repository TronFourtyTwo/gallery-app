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
 * Charles Lindsay <chaz@yorba.org>
 */

#ifndef GALLERY_PHOTO_H_
#define GALLERY_PHOTO_H_

#include <QDateTime>
#include <QStack>

#include "media/media-source.h"
#include "photo/photo-metadata.h"
#include "photo/photo-edit-state.h"
#include "photo/photo-caches.h"

class PhotoPrivate;

/*!
 * \brief The Photo class
 */
class Photo : public MediaSource
{
    Q_OBJECT

    Q_PROPERTY(bool canUndo READ can_undo NOTIFY edit_stack_altered)
    Q_PROPERTY(bool canRedo READ can_redo NOTIFY edit_stack_altered)
    Q_PROPERTY(bool isOriginal READ is_original NOTIFY edit_stack_altered)

public:
    static bool IsValid(const QFileInfo& file);

    static Photo* Load(const QFileInfo& file);

    static Photo* Fetch(const QFileInfo& file);

    explicit Photo(const QFileInfo& file);
    virtual ~Photo();

    virtual QImage Image(bool respect_orientation);
    virtual Orientation orientation() const;
    virtual QDateTime exposure_date_time() const;

    virtual QUrl gallery_path() const;
    virtual QUrl gallery_preview_path() const;
    virtual QUrl gallery_thumbnail_path() const;

    void set_base_edit_state(const PhotoEditState& base);

    bool can_undo() const;
    bool can_redo() const;
    bool is_original() const;

    Q_INVOKABLE void revertToOriginal();
    Q_INVOKABLE void undo();
    Q_INVOKABLE void redo();
    Q_INVOKABLE void rotateRight();
    Q_INVOKABLE void autoEnhance();
    Q_INVOKABLE void exposureCompensation(qreal value);
    Q_INVOKABLE void colorBalance(qreal brightness, qreal contrast, qreal saturation, qreal hue);
    Q_INVOKABLE QVariant prepareForCropping();
    Q_INVOKABLE void cancelCropping();
    Q_INVOKABLE void crop(QVariant vrect);

signals:
    void edit_stack_altered();

protected:
    virtual void DestroySource(bool destroy_backing, bool as_orphan);

private:
    const PhotoEditState& current_state() const;
    QSize get_original_size(Orientation orientation);
    void make_undoable_edit(const PhotoEditState& state);
    void save(const PhotoEditState& state, Orientation old_orientation);
    void edit_file(const PhotoEditState& state);
    void create_cached_enhanced();
    QImage compensateExposure(const QImage& image, qreal compansation);
    QImage doColorBalance(const QImage& image, qreal brightness, qreal contrast, qreal saturation, qreal hue);
    void append_path_params(QUrl* url, Orientation orientation, const int size_level) const;
    void handle_simple_metadata_rotation(const PhotoEditState& state);
    bool file_format_has_metadata() const;
    bool file_format_has_orientation() const;
    void set_original_orientation(Orientation orientation);
    void set_file_timestamp(const QDateTime& timestamp);
    void set_exposure_date_time(const QDateTime& exposure_time);

    QString file_format_;
    QDateTime exposure_date_time_;
    QDateTime file_timestamp_;
    int edit_revision_; // How many times the pixel data has been modified by us.
    PhotoCaches caches_;

    // We cache this data to avoid an image read at various times.
    QSize original_size_;
    Orientation original_orientation_;

    PhotoPrivate * const d_ptr;
    Q_DECLARE_PRIVATE(Photo)
};

#endif  // GALLERY_PHOTO_H_
