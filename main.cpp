#include <QDebug>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickStyle>
#include <QQuickWindow>

#include "Async/QtStdexec.hpp"
#include "Logic/Login.hpp"
#include "Logic/Room.hpp"
#include "Logic/RoomList.hpp"
#include "Logic/Sync.hpp"
#include "Utils/LogHandler.hpp"
#include <Quotient/connection.h>
#include <Quotient/quotient_common.h>
#include <exec/repeat_effect_until.hpp>
#include <stdexec/execution.hpp>

using namespace Qt::StringLiterals;
//
// #ifndef Q_OS_ANDROID
// void logToFile(const QString &msg) {
//     QFile file("debug.log");
//     file.open(QIODevice::WriteOnly | QIODevice::Append);
//     QTextStream out(&file);
//     out << QDateTime::currentDateTime().toString() << ": " << msg << "\n";
//     file.close();
// }
//
// void messageHandler(QtMsgType type, const QMessageLogContext &context, const
// QString &msg) {
//     Q_UNUSED(context);
//     QString txt;
//     switch (type) {
//         case QtDebugMsg: txt = QString("Debug: %1").arg(msg); break;
//         case QtWarningMsg: txt = QString("Warning: %1").arg(msg); break;
//         case QtCriticalMsg: txt = QString("Critical: %1").arg(msg); break;
//         case QtFatalMsg: txt = QString("Fatal: %1").arg(msg); break;
//         default: txt = msg; break;
//     }
//     logToFile(txt);
// }
// #endif
//
// int main(int argc, char *argv[])
// {
// #ifndef Q_OS_ANDROID
//     qInstallMessageHandler(messageHandler);
//     QFile::remove("debug.log");
//     logToFile("=== Application Starting ===");
//
//     // 启用透明窗口支持 (仅桌面端需要)
//     QQuickWindow::setDefaultAlphaBuffer(true);
// #endif
//
//     QGuiApplication app(argc, argv);
// #ifndef Q_OS_ANDROID
//     logToFile("QGuiApplication created");
// #endif
//
//     app.setOrganizationName("ModernChat");
//     app.setApplicationName("Modern Chat");
//     app.setApplicationVersion("1.0.0");
//
//     QQuickStyle::setStyle("Basic");
// #ifndef Q_OS_ANDROID
//     logToFile("Style set to Basic");
// #endif
//
//     QQmlApplicationEngine engine;
// #ifndef Q_OS_ANDROID
//     logToFile("QQmlApplicationEngine created");
// #endif
//
//     QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
//         &app, []() {
// #ifndef Q_OS_ANDROID
//             logToFile("QML object creation FAILED!");
// #endif
//             QCoreApplication::exit(-1);
//         },
//         Qt::QueuedConnection);
//
//     QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
//         &app, [](QObject *obj, const QUrl &objUrl) {
//             if (!obj) {
// #ifndef Q_OS_ANDROID
//                 logToFile(QString("Failed to load:
//                 %1").arg(objUrl.toString()));
// #endif
//                 QCoreApplication::exit(-1);
//             }
// #ifndef Q_OS_ANDROID
//             else {
//                 logToFile(QString("Successfully loaded:
//                 %1").arg(objUrl.toString()));
//             }
// #endif
//         },
//         Qt::QueuedConnection);
//
//     const QUrl url(u"qrc:/qt/qml/ModernChat/qml/Main.qml"_s);
// #ifndef Q_OS_ANDROID
//     logToFile(QString("Loading QML from: %1").arg(url.toString()));
// #endif
//
//     engine.load(url);
// #ifndef Q_OS_ANDROID
//     logToFile(QString("engine.load() completed. Root objects:
//     %1").arg(engine.rootObjects().size()));
// #endif
//
//     if (engine.rootObjects().isEmpty()) {
// #ifndef Q_OS_ANDROID
//         logToFile("ERROR: No root objects created!");
// #endif
//         return -1;
//     }
//
// #ifndef Q_OS_ANDROID
//     logToFile("Starting event loop...");
// #endif
//     return app.exec();
// }

auto main(int argc, char **argv) -> int {
  LogHandler::install();

  QGuiApplication app(argc, argv);

  app.setOrganizationName("SimpleChat");
  app.setApplicationName("Simple Chat");
  app.setApplicationVersion("1.0.0");

  QQuickStyle::setStyle("Basic");

  QQuickWindow::setDefaultAlphaBuffer(true);

  Quotient::Connection connection;

  Login login(&connection);
  Sync sync(&connection);
  RoomList roomList(&connection);

  QQmlApplicationEngine engine;

  qmlRegisterUncreatableMetaObject(Quotient::staticMetaObject, "Quotient", 1, 0,
                                   "Quotient", "Enums only");
  qmlRegisterUncreatableMetaObject(EventEnums::staticMetaObject, "ModernChat",
                                   1, 0, "EventEnums", "Enums only");

  engine.rootContext()->setContextProperty("login", &login);
  engine.rootContext()->setContextProperty("connection", &connection);
  engine.rootContext()->setContextProperty("roomList", &roomList);

  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
      []() { QCoreApplication::exit(-1); }, Qt::AutoConnection);

  const QUrl url(u"qrc:/qt/qml/ModernChat/qml/Main.qml"_s);
  engine.load(url);

  if (engine.rootObjects().isEmpty()) {
    return -1;
  }

  auto timer = QTimer();

  const stdexec::sender auto login_sender =
      Async::qObjectAsSender(&login, &Login::loginRequested) |
      stdexec::let_value([&](const QStringView server,
                             const QStringView username,
                             const QStringView password) noexcept {
        return login.login(server, username, password);
      }) |
      exec::repeat_effect_until() | stdexec::let_value([&]() noexcept {
        roomList.setConnection(&connection);
        return sync.sync() | exec::repeat_effect_until();
      }) |
      stdexec::then([&]() noexcept { sync.setFirstSyncDone(true); }) |
      stdexec::let_value([&]() noexcept {
        return sync.sync() | stdexec::let_value([&](const bool) {
                 return Async::qObjectAsSender(&timer, &QTimer::timeout);
               }) |
               exec::repeat_effect();
      });

  timer.start(300);

  stdexec::start_detached(login_sender);

  return app.exec();
}

// 原有的控制台测试代码（已注释）
// auto main(int argc, char **argv) -> int {
//   QCoreApplication app(argc, argv);
//   qSetMessagePattern("[%{time hh:mm:ss.zzz}] %{type} | "
//                      "%{file}:%{line} - %{message}");
//
//   Quotient::Connection conn(&app);
//
//   const stdexec::sender auto connect_sender =
//       Async::qObjectAsSender(&conn, &Quotient::Connection::connected,
//                              &Quotient::Connection::resolveError,
//                              &Quotient::Connection::loginError) |
//       stdexec::then([&]() noexcept {
//         qInfo() << "Connected.";
//         QCoreApplication::quit();
//       }) |
//       stdexec::let_error(
//           [&](const auto &error) { // 有错就直接用另一个 sender 退出
//             auto dbg = qFatal();
//             dbg << "Connection failed.";
//             std::apply(
//                 [&](const auto &...args) {
//                   ((dbg.noquote() << "Error details:" << args), ...);
//                 },
//                 error);
//
//             return stdexec::just();
//           });
//
//   stdexec::start_detached(connect_sender);
//
//   conn.loginWithPassword("@perdixky:chat.neboer.site", "264819691Az",
//                          "ModernChat");
//
//   return app.exec();
// }
