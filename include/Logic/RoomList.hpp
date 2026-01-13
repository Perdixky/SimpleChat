#pragma once

#include <QAbstractListModel>
#include <QHash>
#include <QtQmlIntegration/qqmlintegration.h>

#include <Quotient/connection.h>
#include <Quotient/room.h>

class Room;

class RoomList : public QAbstractListModel {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(int count READ rowCount NOTIFY countChanged FINAL)

public:
  enum Role {
    RoomRole = Qt::UserRole + 1,
    DisplayNameRole,
    LastMessageRole,
    LastMessageTimeRole,
    UnreadCountRole,
  };
  Q_ENUM(Role)

  explicit RoomList(Quotient::Connection *conn, QObject *parent = nullptr) : m_conn(conn), QAbstractListModel(parent) {}

  void setConnection(Quotient::Connection *conn) {
    // if (m_conn == conn)
    //   return;
    //
    // beginResetModel();
    // if (m_conn) {
    //   disconnect(m_conn, nullptr, this, nullptr);
    // }
    // m_conn = conn;
    // m_rooms.clear();
    // m_roomModels.clear();
    //
    // if (m_conn) {
    //   for (auto *room : m_conn->allRooms()) {
    //     addRoom(room);
    //   }
    //   connect(m_conn, &Quotient::Connection::newRoom, this,
    //           &RoomList::onNewRoom);
    //   connect(m_conn, &Quotient::Connection::leftRoom, this,
    //           &RoomList::onLeftRoom);
    // }
    // endResetModel();
    // emit countChanged();
  }

  int rowCount(const QModelIndex &parent = QModelIndex()) const override {
    Q_UNUSED(parent)
    return static_cast<int>(m_rooms.size());
  }

  QHash<int, QByteArray> roleNames() const override {
    return {
        {RoomRole, "room"},
        {DisplayNameRole, "displayName"},
        {LastMessageRole, "lastMessage"},
        {LastMessageTimeRole, "lastMessageTime"},
        {UnreadCountRole, "unreadCount"},
    };
  }

  QVariant data(const QModelIndex &idx, int role) const override;

  Q_INVOKABLE void sendMessage(const QString &roomId, const QString &text) {
    if (!m_conn)
      return;
    if (auto *room = m_conn->room(roomId)) {
      room->postText(text);
    }
  }

signals:
  void countChanged();

private slots:
  void onNewRoom(Quotient::Room *room) {
    beginInsertRows({}, rowCount(), rowCount());
    addRoom(room);
    endInsertRows();
    emit countChanged();
  }

  void onLeftRoom(Quotient::Room *room, Quotient::Room *) {
    const int idx = m_rooms.indexOf(room);
    if (idx < 0)
      return;
    beginRemoveRows({}, idx, idx);
    m_rooms.removeAt(idx);
    m_roomModels.remove(room);
    endRemoveRows();
    emit countChanged();
  }

private:
  void addRoom(Quotient::Room *room) {
    m_rooms.append(room);
    connect(room, &Quotient::Room::displaynameChanged, this, [this, room] {
      const int idx = m_rooms.indexOf(room);
      if (idx >= 0) {
        emit dataChanged(index(idx), index(idx), {DisplayNameRole});
      }
    });
    connect(room, &Quotient::Room::addedMessages, this, [this, room](int, int) {
      const int idx = m_rooms.indexOf(room);
      if (idx >= 0) {
        emit dataChanged(index(idx), index(idx),
                         {LastMessageRole, LastMessageTimeRole});
      }
    });
    connect(room, &Quotient::Room::unreadStatsChanged, this, [this, room] {
      const int idx = m_rooms.indexOf(room);
      if (idx >= 0) {
        emit dataChanged(index(idx), index(idx), {UnreadCountRole});
      }
    });
  }

  Room *getOrCreateRoomModel(Quotient::Room *room) const;

  Quotient::Connection *m_conn = nullptr;
  QList<Quotient::Room *> m_rooms;
  mutable QHash<Quotient::Room *, Room *> m_roomModels;
};
