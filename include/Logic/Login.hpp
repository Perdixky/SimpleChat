#pragma once

#include <QObject>
#include <Quotient/connection.h>

class Login : public QObject {
  Q_OBJECT
  Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
  Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
  explicit Login(Quotient::Connection *connection, QObject *parent = nullptr);

  bool isLoading() const { return is_loading_; }
  QString errorMessage() const { return error_message_; }

  Q_INVOKABLE void login(const QString &server, const QString &username,
                         const QString &password);

signals:
  void loginSucceeded();
  void loginFailed(const QString &error);
  void isLoadingChanged();
  void errorMessageChanged();

private:
  void setIsLoading(bool loading);
  void setErrorMessage(const QString &message);

  bool is_loading_{false};
  QString error_message_{};
  Quotient::Connection *conn_ptr_{nullptr};
};
