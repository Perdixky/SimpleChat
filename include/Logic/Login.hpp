#pragma once

#include "Async/QtStdexec.hpp"
#include <QObject>
#include <Quotient/connection.h>
#include <exec/repeat_effect_until.hpp>
#include <stdexec/execution.hpp>

class Login : public QObject {
  Q_OBJECT
  Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
  Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
  explicit Login(Quotient::Connection *connection, QObject *parent = nullptr);

  bool isLoading() const { return is_loading_; }
  QString errorMessage() const { return error_message_; }

public:
  stdexec::sender auto login(const QStringView server,
                             const QStringView username,
                             const QStringView password) {
    using namespace Qt::StringLiterals;
    const stdexec::sender auto sender =
        stdexec::just(server, username, password) |
        stdexec::let_value([this](const QStringView server,
                                  const QStringView username,
                                  const QStringView password) {
          qDebug() << "Starting login to" << server << "as" << username;
          setIsLoading(true);
          conn_ptr_->loginWithPassword(u"@%1:%2"_s.arg(username, server),
                                       password.toString(),
                                       "SimpleChatClient/1.0");
          return Async::qObjectAsSender(conn_ptr_,
                                        &Quotient::Connection::connected,
                                        &Quotient::Connection::resolveError,
                                        &Quotient::Connection::loginError) |
                 stdexec::then([this]() noexcept {
                   qInfo() << "Login succeeded";
                   emit loginSucceeded();
                   setIsLoading(false);
                   return true;
                 }) |
                 stdexec::upon_error([this](const auto &error) noexcept {
                   setIsLoading(false);
                   QStringList errorDetails;
                   std::apply(
                       [&](const auto &...args) {
                         ((errorDetails << args), ...);
                       },
                       error);
                   const QString fullErrorMessage =
                       u"Login failed. Details: %1"_s.arg(
                           errorDetails.join(u"; "_s));
                   setErrorMessage(fullErrorMessage);
                   emit loginFailed(fullErrorMessage);
                   return false;
                 });
        }) |
        exec::repeat_effect_until();
    return sender;
  }

signals:
  void loginSucceeded();
  void loginFailed(const QString &error);
  void isLoadingChanged();
  void errorMessageChanged();

signals:
  void loginRequested(const QStringView server, const QStringView username,
                      const QStringView password);

public slots:
  void loginRequest(const QString &server, const QString &username,
                    const QString &password) {
    qDebug() << "Login request received for" << server << "as" << username;
    loginRequested(server, username, password);
  }

private:
  void setIsLoading(bool loading);
  void setErrorMessage(const QString &message);

  bool is_loading_{false};
  QString error_message_{};
  Quotient::Connection *conn_ptr_{nullptr};
};
