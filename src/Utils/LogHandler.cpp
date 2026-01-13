#include "Utils/LogHandler.hpp"

#include <QDateTime>
#include <QDebug>
#include <QString>
#include <cstdio>
#include <cstdlib>

#ifdef Q_OS_WIN
#include <Windows.h>
#else
#include <unistd.h>
#endif

namespace LogHandler {
namespace {

#if defined(Q_OS_WIN) && !defined(NDEBUG)
void attachConsole() {
  if (AllocConsole()) {
    FILE *stream;
    freopen_s(&stream, "CONOUT$", "w", stdout);
    freopen_s(&stream, "CONOUT$", "w", stderr);
    freopen_s(&stream, "CONIN$", "r", stdin);

    // Enable ANSI escape sequences (Windows 10+)
    HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
    DWORD dwMode = 0;
    GetConsoleMode(hOut, &dwMode);
    SetConsoleMode(hOut, dwMode | ENABLE_VIRTUAL_TERMINAL_PROCESSING);
  }
}
#endif

void messageHandler(QtMsgType type, const QMessageLogContext &context,
                    const QString &msg) {
  const char *level = "INFO";
#ifdef Q_OS_WIN
  WORD color = FOREGROUND_GREEN;
#else
  const char *color = "";
  const char *reset = "";
  const bool use_color = isatty(fileno(stderr));
#endif

  switch (type) {
  case QtDebugMsg:
    level = "DEBUG";
#ifdef Q_OS_WIN
    color = FOREGROUND_GREEN | FOREGROUND_BLUE; // Cyan
#else
    color = "\x1b[36m";
#endif
    break;
  case QtInfoMsg:
    level = "INFO";
#ifdef Q_OS_WIN
    color = FOREGROUND_GREEN; // Green
#else
    color = "\x1b[32m";
#endif
    break;
  case QtWarningMsg:
    level = "WARN";
#ifdef Q_OS_WIN
    color = FOREGROUND_RED | FOREGROUND_GREEN; // Yellow
#else
    color = "\x1b[33m";
#endif
    break;
  case QtCriticalMsg:
    level = "CRITICAL";
#ifdef Q_OS_WIN
    color = FOREGROUND_RED; // Red
#else
    color = "\x1b[31m";
#endif
    break;
  case QtFatalMsg:
    level = "FATAL";
#ifdef Q_OS_WIN
    color = FOREGROUND_RED | FOREGROUND_INTENSITY; // Bright Red
#else
    color = "\x1b[1;31m";
#endif
    break;
  }

#ifndef Q_OS_WIN
  if (!use_color) {
    color = "";
    reset = "";
  } else {
    reset = "\x1b[0m";
  }
#endif

  const QString time_str =
      QDateTime::currentDateTime().toString("HH:mm:ss.zzz");
  QString location;
  if (context.file) {
    location = QString("%1:%2").arg(context.file).arg(context.line);
  }

  QString line = QString("[%1] [%2] %3").arg(time_str, level, msg);
  if (!location.isEmpty()) {
    line += QString(" (%1)").arg(location);
  }

#ifdef Q_OS_WIN
  HANDLE hConsole = GetStdHandle(STD_ERROR_HANDLE);
  if (hConsole != INVALID_HANDLE_VALUE) {
    SetConsoleTextAttribute(hConsole, color | FOREGROUND_INTENSITY);
  }
  fprintf(stderr, "%s\n", line.toLocal8Bit().constData());
  if (hConsole != INVALID_HANDLE_VALUE) {
    SetConsoleTextAttribute(
        hConsole, FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE);
  }
#else
  fprintf(stderr, "%s%s%s\n", color, line.toLocal8Bit().constData(), reset);
#endif

  if (type == QtFatalMsg) {
    abort();
  }
}

} // namespace

void install() {
#if defined(Q_OS_WIN) && !defined(NDEBUG)
  attachConsole();
#endif
  qInstallMessageHandler(messageHandler);
#if defined(Q_OS_WIN) && !defined(NDEBUG)
  qInfo() << "Debug console attached.";
#endif
}

} // namespace LogHandler
