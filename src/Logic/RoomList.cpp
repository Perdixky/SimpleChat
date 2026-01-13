#include "Logic/RoomList.hpp"
#include "Logic/Room.hpp"

#include <Quotient/events/roommessageevent.h>
#include <Quotient/eventstats.h>

namespace {
QString lastMessagePreview(Quotient::Room *room) {
  if (!room)
    return {};

  const auto &events = room->messageEvents();
  for (auto it = events.rbegin(); it != events.rend(); ++it) {
    const auto *event = it->event();
    if (!event || event->isRedacted())
      continue;

    if (const auto *msg =
            Quotient::eventCast<const Quotient::RoomMessageEvent>(event)) {
      const auto body = msg->plainBody();
      if (!body.isEmpty())
        return body;

      using MsgType = Quotient::RoomMessageEvent::MsgType;
      switch (msg->msgtype()) {
      case MsgType::Image:
        return QStringLiteral("[Image]");
      case MsgType::File:
        return QStringLiteral("[File]");
      case MsgType::Video:
        return QStringLiteral("[Video]");
      case MsgType::Audio:
        return QStringLiteral("[Audio]");
      case MsgType::Location:
        return QStringLiteral("[Location]");
      default:
        break;
      }
    }
  }
  return {};
}

QDateTime lastMessageTime(Quotient::Room *room) {
  if (!room)
    return {};

  const auto &events = room->messageEvents();
  for (auto it = events.rbegin(); it != events.rend(); ++it) {
    const auto *event = it->event();
    if (!event || event->isRedacted())
      continue;

    if (Quotient::eventCast<const Quotient::RoomMessageEvent>(event)) {
      return event->originTimestamp();
    }
  }
  return {};
}
} // namespace

QVariant RoomList::data(const QModelIndex &idx, int role) const {
  if (!idx.isValid() || idx.row() < 0 || idx.row() >= rowCount())
    return {};

  auto *room = m_rooms.at(idx.row());

  switch (role) {
  case RoomRole:
    return QVariant::fromValue(getOrCreateRoomModel(room));

  case DisplayNameRole:
    return room->displayName();

  case LastMessageRole:
    return lastMessagePreview(room);

  case LastMessageTimeRole:
    return lastMessageTime(room);

  case UnreadCountRole:
    return room->unreadStats().notableCount;
  }

  return {};
}

Room *RoomList::getOrCreateRoomModel(Quotient::Room *room) const {
  if (!m_roomModels.contains(room)) {
    auto *model = new Room(room, const_cast<RoomList *>(this));
    m_roomModels[room] = model;
  }
  return m_roomModels[room];
}
