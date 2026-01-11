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

void Login::login(const QString &server, const QString &username,
                  const QString &password) {
  namespace ex = stdexec;
  const ex::sender auto sender =
      ex::just(server, username, password) |
      ex::let_value([this](const QString &server, const QString &username,
                           const QString &password) {
        qDebug() << "Starting login to" << server << "as" << username;
        setIsLoading(true);
        return Async::qObjectAsSender(conn_ptr_,
                                      &Quotient::Connection::connected,
                                      &Quotient::Connection::resolveError,
                                      &Quotient::Connection::loginError) |
               ex::then([this]() noexcept {
                 qInfo() << "Login succeeded";
                 emit loginSucceeded();
                 setIsLoading(false);
                 return true;
               }) |
               ex::upon_error([this](const auto &error) noexcept {
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
      });
}
