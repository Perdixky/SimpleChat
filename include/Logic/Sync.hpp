#include "Async/QtStdexec.hpp"
#include <Quotient/connection.h>
#include <exec/repeat_effect_until.hpp>
#include <stdexec/execution.hpp>

class Sync : public QObject {
  Q_OBJECT
  Q_PROPERTY(bool isSyncing READ isSyncing NOTIFY isSyncingChanged)
  Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
  explicit Sync(Quotient::Connection *connection, QObject *parent = nullptr)
      : QObject(parent), conn_ptr_(connection) {}

  bool isSyncing() const { return is_syncing_; }
  QString errorMessage() const { return error_message_; }

  stdexec::sender auto sync() {
    using namespace Qt::StringLiterals;
    const stdexec::sender auto sender =
        stdexec::just() | stdexec::let_value([this]() {
          qDebug() << "Starting sync...";
          setIsSyncing(true);
          conn_ptr_->sync();
          return Async::qObjectAsSender(conn_ptr_,
                                        &Quotient::Connection::syncDone,
                                        &Quotient::Connection::resolveError,
                                        &Quotient::Connection::syncError) |
                 stdexec::then([this]() noexcept {
                   qInfo() << "Sync completed successfully";
                   setIsSyncing(false);
                 }) |
                 stdexec::upon_error([this](const auto &error) noexcept {
                   QStringList errorDetails;
                   std::apply(
                       [&](const auto &...args) {
                         ((errorDetails << args), ...);
                       },
                       error);
                   const QString fullErrorMessage =
                       u"Sync failed. Details: %1"_s.arg(
                           errorDetails.join(u"; "_s));
                   setErrorMessage(fullErrorMessage);
                   setIsSyncing(false);
                   setErrorMessage(fullErrorMessage);
                 });
        });
    return sender;
  }

signals:
  void isSyncingChanged();
  void errorMessageChanged();

private:
  void setErrorMessage(const QString &message) {
    if (error_message_ != message) {
      error_message_ = message;
    }
  }
  void setIsSyncing(bool syncing) {
    if (is_syncing_ != syncing) {
      is_syncing_ = syncing;
    }
  }

private:
  Quotient::Connection *conn_ptr_;
  QString error_message_;
  bool is_syncing_{false};
};
