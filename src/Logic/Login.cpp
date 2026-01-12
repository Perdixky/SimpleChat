#include "Logic/Login.hpp"

#include "Async/QtStdexec.hpp"

using namespace Qt::StringLiterals;

Login::Login(Quotient::Connection *connection, QObject *parent)
    : QObject(parent), conn_ptr_(connection) {}

void Login::setIsLoading(bool loading) {
  if (is_loading_ != loading) {
    is_loading_ = loading;
    emit isLoadingChanged();
  }
}

void Login::setErrorMessage(const QString &message) {
  if (error_message_ != message) {
    error_message_ = message;
    emit errorMessageChanged();
  }
}

