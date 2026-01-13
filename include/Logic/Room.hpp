#pragma once

#include <QAbstractListModel>
#include <QDateTime>
#include <QString>
#include <QUrl>
#include <QtQmlIntegration/qqmlintegration.h>

#include <Quotient/events/encryptedevent.h>
#include <Quotient/events/eventcontent.h>
#include <Quotient/events/redactionevent.h>
#include <Quotient/events/roomevent.h>
#include <Quotient/events/roommemberevent.h>
#include <Quotient/events/roommessageevent.h>
#include <Quotient/events/stateevent.h>
#include <Quotient/events/stickerevent.h>
#include <Quotient/room.h>

// ============================================================================
// Enums - 暴露给 QML
// ============================================================================
namespace EventEnums {
Q_NAMESPACE
QML_ELEMENT

enum class EventType {
  Unknown,
  Message,
  State,
  Sticker,
  Redaction,
  Encrypted,
  Call
};
Q_ENUM_NS(EventType)

enum class MsgType {
  Unknown,
  Text,
  Emote,
  Notice,
  Image,
  File,
  Video,
  Audio,
  Location
};
Q_ENUM_NS(MsgType)
} // namespace EventEnums

// ============================================================================
// MessageView - 消息内容视图
// ============================================================================
class MessageView {
  Q_GADGET
  QML_VALUE_TYPE(messageView)

  Q_PROPERTY(EventEnums::MsgType msgType MEMBER msgType FINAL)
  Q_PROPERTY(QString plainBody MEMBER plainBody FINAL)
  Q_PROPERTY(QUrl mediaUrl MEMBER mediaUrl FINAL)
  Q_PROPERTY(QString mediaFileName MEMBER mediaFileName FINAL)
  Q_PROPERTY(QString mediaMimeType MEMBER mediaMimeType FINAL)
  Q_PROPERTY(qint64 mediaSize MEMBER mediaSize FINAL)
  Q_PROPERTY(QUrl thumbnailUrl MEMBER thumbnailUrl FINAL)
  Q_PROPERTY(int thumbnailWidth MEMBER thumbnailWidth FINAL)
  Q_PROPERTY(int thumbnailHeight MEMBER thumbnailHeight FINAL)

public:
  EventEnums::MsgType msgType = EventEnums::MsgType::Unknown;
  QString plainBody;

  QUrl mediaUrl;
  QString mediaFileName;
  QString mediaMimeType;
  qint64 mediaSize = 0;

  QUrl thumbnailUrl;
  int thumbnailWidth = 0;
  int thumbnailHeight = 0;

  bool operator==(const MessageView &) const = default;
};

// ============================================================================
// StateView - 状态事件视图
// ============================================================================
class StateView {
  Q_GADGET
  QML_VALUE_TYPE(stateView)

  Q_PROPERTY(QString stateKey MEMBER stateKey FINAL)
  Q_PROPERTY(QString stateType MEMBER stateType FINAL)
  Q_PROPERTY(QString summary MEMBER summary FINAL)

public:
  QString stateKey;
  QString stateType;
  QString summary;

  bool operator==(const StateView &) const = default;
};

// ============================================================================
// StickerView - 贴纸视图
// ============================================================================
class StickerView {
  Q_GADGET
  QML_VALUE_TYPE(stickerView)

  Q_PROPERTY(QString body MEMBER body FINAL)
  Q_PROPERTY(QUrl url MEMBER url FINAL)
  Q_PROPERTY(int width MEMBER width FINAL)
  Q_PROPERTY(int height MEMBER height FINAL)

public:
  QString body;
  QUrl url;
  int width = 0;
  int height = 0;

  bool operator==(const StickerView &) const = default;
};

// ============================================================================
// EventView - 顶层事件视图
// ============================================================================
class EventView {
  Q_GADGET
  QML_VALUE_TYPE(eventView)

  Q_PROPERTY(QString eventId MEMBER eventId FINAL)
  Q_PROPERTY(EventEnums::EventType type MEMBER type FINAL)
  Q_PROPERTY(QString sender MEMBER sender FINAL)
  Q_PROPERTY(QString senderDisplayName MEMBER senderDisplayName FINAL)
  Q_PROPERTY(QDateTime timestamp MEMBER timestamp FINAL)
  Q_PROPERTY(bool isRedacted MEMBER isRedacted FINAL)
  Q_PROPERTY(bool isLocalEcho MEMBER isLocalEcho FINAL)

  Q_PROPERTY(MessageView message MEMBER message FINAL)
  Q_PROPERTY(StateView state MEMBER state FINAL)
  Q_PROPERTY(StickerView sticker MEMBER sticker FINAL)

public:
  QString eventId;
  EventEnums::EventType type = EventEnums::EventType::Unknown;
  QString sender;
  QString senderDisplayName;
  QDateTime timestamp;
  bool isRedacted = false;
  bool isLocalEcho = false;

  MessageView message;
  StateView state;
  StickerView sticker;

  bool operator==(const EventView &) const = default;
};

// ============================================================================
// Room - 单个房间的事件列表模型
// ============================================================================
class Room : public QAbstractListModel {
  Q_OBJECT
  QML_ELEMENT

  Q_PROPERTY(int count READ rowCount NOTIFY countChanged FINAL)
  Q_PROPERTY(QString roomId READ roomId CONSTANT)
  Q_PROPERTY(QString displayName READ displayName NOTIFY displayNameChanged)

public:
  enum Role { EventRole = Qt::UserRole + 1 };
  Q_ENUM(Role)

  explicit Room(QObject *parent = nullptr)
      : QAbstractListModel(parent), m_room(nullptr) {}

  explicit Room(Quotient::Room *room, QObject *parent = nullptr)
      : QAbstractListModel(parent), m_room(nullptr) {
    setQuotientRoom(room);
  }

  void setQuotientRoom(Quotient::Room *room) {
    if (m_room == room)
      return;

    beginResetModel();
    if (m_room) {
      disconnect(m_room, nullptr, this, nullptr);
    }
    m_room = room;
    if (m_room) {
      connect(m_room, &Quotient::Room::aboutToAddNewMessages, this,
              [this](Quotient::RoomEventsRange events) {
                beginInsertRows({}, rowCount(),
                                rowCount() + static_cast<int>(events.size()) -
                                    1);
              });
      connect(m_room, &Quotient::Room::addedMessages, this, [this](int, int) {
        endInsertRows();
        emit countChanged();
      });
      connect(m_room, &Quotient::Room::aboutToAddHistoricalMessages, this,
              [this](Quotient::RoomEventsRange events) {
                beginInsertRows({}, 0, static_cast<int>(events.size()) - 1);
              });
      connect(m_room, &Quotient::Room::displaynameChanged, this,
              &Room::displayNameChanged);
    }
    endResetModel();
    emit countChanged();
  }

  Quotient::Room *quotientRoom() const { return m_room; }

  QString roomId() const { return m_room ? m_room->id() : QString(); }

  QString displayName() const {
    return m_room ? m_room->displayName() : QString();
  }

  int rowCount(const QModelIndex &parent = QModelIndex()) const override {
    Q_UNUSED(parent)
    return m_room ? static_cast<int>(m_room->messageEvents().size()) : 0;
  }

  QHash<int, QByteArray> roleNames() const override {
    return {{EventRole, "event"}};
  }

  QVariant data(const QModelIndex &idx, int role) const override {
    if (!idx.isValid() || role != EventRole || !m_room)
      return {};
    if (idx.row() < 0 || idx.row() >= rowCount())
      return {};

    const auto &eventIt = m_room->messageEvents().at(idx.row());
    return QVariant::fromValue(makeView(eventIt.event(), m_room));
  }

signals:
  void countChanged();
  void displayNameChanged();

private:
  static EventEnums::MsgType mapMsgType(Quotient::MessageEventType type) {
    using MT = Quotient::MessageEventType;
    switch (type) {
    case MT::Text:
      return EventEnums::MsgType::Text;
    case MT::Emote:
      return EventEnums::MsgType::Emote;
    case MT::Notice:
      return EventEnums::MsgType::Notice;
    case MT::Image:
      return EventEnums::MsgType::Image;
    case MT::File:
      return EventEnums::MsgType::File;
    case MT::Video:
      return EventEnums::MsgType::Video;
    case MT::Audio:
      return EventEnums::MsgType::Audio;
    case MT::Location:
      return EventEnums::MsgType::Location;
    default:
      return EventEnums::MsgType::Unknown;
    }
  }

  static EventView makeView(const Quotient::RoomEvent *e,
                            const Quotient::Room *room) {
    EventView v;
    v.eventId = e->id();
    v.sender = e->senderId();
    v.senderDisplayName = room->member(e->senderId()).displayName();
    v.timestamp = e->originTimestamp();
    v.isRedacted = e->isRedacted();
    v.isLocalEcho = false;

    if (e->is<Quotient::RoomMessageEvent>()) {
      const auto *msg = static_cast<const Quotient::RoomMessageEvent *>(e);
      v.type = EventEnums::EventType::Message;
      v.message.msgType = mapMsgType(msg->msgtype());
      v.message.plainBody = msg->plainBody();

      if (auto content = msg->content()) {
        if (const auto *fileBase =
                dynamic_cast<const Quotient::EventContent::FileContentBase *>(
                    content.get())) {
          v.message.mediaUrl = room->makeMediaUrl(e->id(), fileBase->url());
          if (const auto *fileContent =
                  dynamic_cast<const Quotient::EventContent::FileContent *>(
                      content.get())) {
            v.message.mediaFileName = fileContent->originalName;
            v.message.mediaMimeType = fileContent->mimeType.name();
            v.message.mediaSize = fileContent->payloadSize;
          }
        }
      }

      if (msg->hasThumbnail()) {
        auto thumbnail = msg->getThumbnail();
        v.message.thumbnailUrl = room->makeMediaUrl(e->id(), thumbnail.url());
        v.message.thumbnailWidth = thumbnail.imageSize.width();
        v.message.thumbnailHeight = thumbnail.imageSize.height();
      }
    } else if (e->is<Quotient::StickerEvent>()) {
      const auto *sticker = static_cast<const Quotient::StickerEvent *>(e);
      v.type = EventEnums::EventType::Sticker;
      v.sticker.body = sticker->body();
      v.sticker.url = room->makeMediaUrl(e->id(), sticker->url());
      v.sticker.width = sticker->image().imageSize.width();
      v.sticker.height = sticker->image().imageSize.height();
    } else if (e->is<Quotient::RedactionEvent>()) {
      v.type = EventEnums::EventType::Redaction;
    } else if (e->is<Quotient::EncryptedEvent>()) {
      v.type = EventEnums::EventType::Encrypted;
    } else if (e->is<Quotient::StateEvent>()) {
      const auto *state = static_cast<const Quotient::StateEvent *>(e);
      v.type = EventEnums::EventType::State;
      v.state.stateKey = state->stateKey();
      v.state.stateType = state->matrixType();
      v.state.summary = summarizeStateEvent(e, room);
    } else {
      v.type = EventEnums::EventType::Unknown;
    }

    return v;
  }

  static QString displayNameForUser(const Quotient::Room *room,
                                    const QString &userId) {
    if (!room || userId.isEmpty())
      return userId;
    const auto name = room->member(userId).displayName();
    return name.isEmpty() ? userId : name;
  }

  static QString summarizeMemberEvent(const Quotient::RoomMemberEvent *member,
                                      const Quotient::Room *room) {
    if (!member)
      return {};

    const auto targetId = member->userId();
    const auto actorId = member->senderId();

    const auto targetName = displayNameForUser(room, targetId);
    const auto actorName = displayNameForUser(room, actorId);

    if (member->isJoin())
      return QStringLiteral("%1 joined the room").arg(targetName);
    if (member->isLeave()) {
      if (actorId == targetId)
        return QStringLiteral("%1 left the room").arg(targetName);
      return QStringLiteral("%1 removed %2").arg(actorName, targetName);
    }
    if (member->isInvite())
      return QStringLiteral("%1 invited %2").arg(actorName, targetName);
    if (member->isRejectedInvite())
      return QStringLiteral("%1 declined the invite").arg(targetName);
    if (member->isBan())
      return QStringLiteral("%1 banned %2").arg(actorName, targetName);
    if (member->isUnban())
      return QStringLiteral("%1 unbanned %2").arg(actorName, targetName);
    if (member->isRename()) {
      const auto newName = member->newDisplayName();
      if (newName && !newName->isEmpty())
        return QStringLiteral("%1 changed their name to %2")
            .arg(targetName, *newName);
      return QStringLiteral("%1 changed their display name").arg(targetName);
    }
    if (member->isAvatarUpdate())
      return QStringLiteral("%1 updated their avatar").arg(targetName);

    return {};
  }

  static QString summarizeStateEvent(const Quotient::RoomEvent *event,
                                     const Quotient::Room *room) {
    if (!event)
      return {};

    if (event->is<Quotient::RoomMemberEvent>()) {
      return summarizeMemberEvent(
          static_cast<const Quotient::RoomMemberEvent *>(event), room);
    }

    return {};
  }

  Quotient::Room *m_room = nullptr;
};
