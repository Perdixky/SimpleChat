#pragma once

// Qt
#include <QMetaObject>
#include <QObject>
#include <QPointer>
#include <QTimer>

// STL
#include <atomic>
#include <optional>
#include <tuple>
#include <type_traits>
#include <utility>

// stdexec
#include <stdexec/concepts.hpp>
#include <stdexec/execution.hpp>

namespace Async {

namespace detail {

// =========================
// member function pointer traits
// =========================
template <class> struct memfn_traits;

template <class C, class R, class... A> struct memfn_traits<R (C::*)(A...)> {
  using object = C;
  using ret = R;
  using args_tuple = std::tuple<A...>;
};

template <class C, class R, class... A>
struct memfn_traits<R (C::*)(A...) const> : memfn_traits<R (C::*)(A...)> {};

// =========================
// Qt signal pointer concept
// =========================
template <class Sig>
concept QtSignalPtr =
    requires {
      typename memfn_traits<Sig>::object;
      typename memfn_traits<Sig>::ret;
      typename memfn_traits<Sig>::args_tuple;
    } && std::is_base_of_v<QObject, typename memfn_traits<Sig>::object> &&
    std::is_same_v<typename memfn_traits<Sig>::ret, void>;

template <class Sig>
concept QtErrorSignalPtr =
    QtSignalPtr<Sig> &&
    (std::tuple_size_v<typename memfn_traits<Sig>::args_tuple> >= 1);

template <class Sig>
concept QtStopSignalPtr =
    QtSignalPtr<Sig> &&
    (std::tuple_size_v<typename memfn_traits<Sig>::args_tuple> == 0);

template <class QObj, class Sig>
inline constexpr bool signal_belongs_v =
    std::is_base_of_v<typename memfn_traits<Sig>::object, QObj>;

template <class Sig>
inline constexpr std::size_t arity_v =
    std::tuple_size_v<typename memfn_traits<Sig>::args_tuple>;

// =========================
// tuple helpers
// =========================
template <class Tuple> struct decay_tuple;
template <class... A> struct decay_tuple<std::tuple<A...>> {
  using type = std::tuple<std::decay_t<A>...>;
};
template <class Tuple> using decay_tuple_t = typename decay_tuple<Tuple>::type;

// tuple<A...> -> set_value_t(A...)
template <class Tuple> struct value_sig_from_tuple;
template <class... A> struct value_sig_from_tuple<std::tuple<A...>> {
  using type = stdexec::set_value_t(A...);
};
template <class Tuple>
using value_sig_from_tuple_t = typename value_sig_from_tuple<Tuple>::type;

// concat completion_signatures
template <class A, class B> struct concat_sigs;
template <class... SA, class... SB>
struct concat_sigs<stdexec::completion_signatures<SA...>,
                   stdexec::completion_signatures<SB...>> {
  using type = stdexec::completion_signatures<SA..., SB...>;
};
template <class A, class B>
using concat_sigs_t = typename concat_sigs<A, B>::type;

// extract a pointer of exact Wanted type from runtime pack
template <class Wanted, class... Rest> Wanted extract_ptr(Rest... rest) {
  Wanted out = nullptr;
  if constexpr (sizeof...(Rest) > 0) {
    ((std::is_same_v<std::decay_t<Rest>, Wanted> ? (out = rest, true) : false),
     ...);
  }
  return out;
}

template <QtErrorSignalPtr EPtr>
using error_payload_t = decay_tuple_t<typename memfn_traits<EPtr>::args_tuple>;

template <class Tuple> struct error_sigs_from_tuple;

template <detail::QtErrorSignalPtr... EPtrs>
struct error_sigs_from_tuple<std::tuple<EPtrs...>> {
  using type = stdexec::completion_signatures<stdexec::set_error_t(
      error_payload_t<EPtrs>)...>;
};

template <class EPtr, class... A>
auto pack_error(A &&...a) -> error_payload_t<EPtr> {
  using P = error_payload_t<EPtr>;
  if constexpr (arity_v<EPtr> == 1) {
    return P{std::forward<A>(a)...};
  } else {
    return P{std::forward<A>(a)...}; // tuple<...>
  }
}

// tuple for-each with index
template <class Tuple, class F, std::size_t... I>
static void tuple_for_each_impl(Tuple &&t, F &&f, std::index_sequence<I...>) {
  (f(std::get<I>(t), std::integral_constant<std::size_t, I>{}), ...);
}
template <class Tuple, class F> static void tuple_for_each(Tuple &&t, F &&f) {
  tuple_for_each_impl(std::forward<Tuple>(t), std::forward<F>(f),
                      std::make_index_sequence<
                          std::tuple_size_v<std::remove_reference_t<Tuple>>>{});
}

} // namespace detail

// ============================================================================
// QObject sender
// API:
//   qObjectAsSender(obj, &Obj::value_signal);
//   qObjectAsSender(obj, &Obj::value_signal, &Obj::error_signal); // error:
//   void(Obj::*)(E) qObjectAsSender(obj, &Obj::value_signal,
//   &Obj::stop_signal);  // stop:  void(Obj::*)() qObjectAsSender(obj,
//   &Obj::value_signal, &Obj::stop_signal, &Obj::error_signal); // 顺序无关
// ============================================================================

template <stdexec::receiver R, stdexec::sender Sender>
class QObjectOperationState;

template <class QObj, detail::QtSignalPtr ValuePtr,
          class ErrorsTuple = std::tuple<>, class StopsTuple = std::tuple<>>
struct QObjectSender {
  static_assert(detail::signal_belongs_v<QObj, ValuePtr>,
                "value_signal must belong to QObj (or its base)");

  static constexpr bool has_error = std::tuple_size_v<ErrorsTuple> > 0;
  static constexpr bool has_stop = std::tuple_size_v<StopsTuple> > 0;

  using value_args_raw = typename detail::memfn_traits<ValuePtr>::args_tuple;
  using value_args = detail::decay_tuple_t<value_args_raw>;
  using value_sig = detail::value_sig_from_tuple_t<value_args>;

  using base_sigs = stdexec::completion_signatures<
      value_sig,
      stdexec::set_stopped_t() // 支持 stop_token（即使没传 stop_signal，也可能
      >;                       // stopped）

  using sender_concept = stdexec::sender_t;
  using completion_signatures = detail::concat_sigs_t<
      base_sigs, typename detail::error_sigs_from_tuple<ErrorsTuple>::type>;

  using errors_tuple = ErrorsTuple;
  using stops_tuple = StopsTuple;

  explicit QObjectSender(QObj *obj, ValuePtr v,
                         ErrorsTuple errors_tuple = std::make_tuple(),
                         StopsTuple stops_tuple = std::make_tuple())
      : obj_(obj), value_(v), errors_tuple_(errors_tuple),
        stops_tuple_(stops_tuple) {}

  template <stdexec::receiver R>
  auto connect(this const auto &self, R &&r) {
    using R_ = std::remove_cvref_t<R>;
    using S_ = std::remove_cvref_t<decltype(self)>;

    return QObjectOperationState<R_, S_>(std::forward<R_>(r), self);
  }

  QObj *obj_{};
  ValuePtr value_{};
  ErrorsTuple errors_tuple_;
  StopsTuple stops_tuple_;
};

template <stdexec::receiver R, stdexec::sender S> class QObjectOperationState {

public:
  using operation_state_concept = stdexec::operation_state_t;

  QObjectOperationState(R r, S s) : receiver_(std::move(r)), sender_(s) {}

  QObjectOperationState(const QObjectOperationState &) = delete;
  QObjectOperationState &operator=(const QObjectOperationState &) = delete;

  void start() noexcept {
    auto *o = sender_.obj_;

    // stop_token -> stopped (投递到 obj 线程)
    stop_cb_.emplace(stdexec::get_stop_token(stdexec::get_env(receiver_)),
                     stop_callback_t{this});

    // value
    value_conn_ = QObject::connect(
        o, sender_.value_, o,
        [this](auto... args) { complete_value(std::move(args)...); },
        Qt::AutoConnection);

    detail::tuple_for_each(sender_.errors_tuple_, [this, o](auto ptr, auto idx_tag) {
      constexpr std::size_t I = decltype(idx_tag)::value;
      using PtrT = decltype(ptr);
      error_conn_[I] = QObject::connect(
          o, ptr, o,
          [this](auto... errArgs) {
            complete_error(detail::pack_error<PtrT>(std::move(errArgs)...));
          },
          Qt::AutoConnection);
    });

    detail::tuple_for_each(sender_.stops_tuple_, [this, o](auto ptr, auto idx_tag) {
      constexpr std::size_t I = decltype(idx_tag)::value;
      stop_conn_[I] = QObject::connect(
          o, ptr, o, [this]() { complete_stopped(); }, Qt::AutoConnection);
    });

    // obj destroyed -> stopped (避免悬挂)
    destroyed_conn_ = QObject::connect(
        o, &QObject::destroyed, [this](QObject *) { complete_stopped(); });
  }

private:
  struct stop_callback_t {
    QObjectOperationState *self;
    void operator()() const {
      // 如果 obj 还活着，把完成投递到 obj 线程；否则直接完成
      if (auto *o = self->sender_.obj_) {
        QTimer::singleShot(0, o, [s = self]() { s->complete_stopped(); });
      } else {
        self->complete_stopped();
      }
    }
  };

  using stop_token_t = stdexec::stop_token_of_t<stdexec::env_of_t<R>>;
  using stop_cb_t =
      typename stop_token_t::template callback_type<stop_callback_t>;

  bool claim_once() { return !done_.test_and_set(std::memory_order_acq_rel); }

  void disconnect_all() {
    QObject::disconnect(*value_conn_);

    QObject::disconnect(*destroyed_conn_);

    value_conn_.reset();
    for (auto &conn : error_conn_)
      conn.reset();
    for (auto &conn : stop_conn_)
      conn.reset();

    destroyed_conn_.reset();
  }

  template <class... A> void complete_value(A &&...a) {
    if (!claim_once())
      return;
    disconnect_all();
    stdexec::set_value(std::move(receiver_), std::forward<A>(a)...);
  }

  template <class E> void complete_error(E &&e) {
    if (!claim_once())
      return;
    disconnect_all();
    stdexec::set_error(std::move(receiver_), std::forward<E>(e));
  }

  void complete_stopped() {
    if (!claim_once())
      return;
    disconnect_all();
    stdexec::set_stopped(std::move(receiver_));
  }

private:
  R receiver_;
  S sender_;

  std::optional<QMetaObject::Connection> value_conn_;
  std::array<std::optional<QMetaObject::Connection>,
             std::tuple_size_v<typename S::errors_tuple>>
      error_conn_;
  std::array<std::optional<QMetaObject::Connection>,
             std::tuple_size_v<typename S::stops_tuple>>
      stop_conn_;
  std::optional<QMetaObject::Connection> destroyed_conn_;

  std::optional<stop_cb_t> stop_cb_;
  std::atomic_flag done_ = ATOMIC_FLAG_INIT;
};

// ----------------
// qObjectAsSender: type-based inference (error only 1 arg)
// ----------------
template <class QObj, detail::QtSignalPtr ValuePtr>
auto qObjectAsSender(QObj *obj, ValuePtr value) {
  return QObjectSender<QObj, ValuePtr>(obj, value);
}

template <class QObj, detail::QtSignalPtr ValuePtr,
          detail::QtErrorSignalPtr... ErrorPtr>
auto qObjectAsSender(QObj *obj, ValuePtr value, ErrorPtr... error) {
  return QObjectSender<QObj, ValuePtr, std::tuple<ErrorPtr...>>(
      obj, value, std::make_tuple(error...));
}
//
// template <class QObj, detail::QtSignalPtr ValuePtr,
//           detail::QtStopSignalPtr... StopPtr>
// auto qObjectAsSender(QObj *obj, ValuePtr value, StopPtr... stop) {
//   return QObjectSender<QObj, ValuePtr, std::tuple<>, std::tuple<StopPtr...>>(
//       obj, value, std::make_tuple(), std::make_tuple(stop...));
// }
//
// template <class QObj, detail::QtSignalPtr ValuePtr,
//           detail::QtErrorSignalPtr... ErrorPtr,
//           detail::QtStopSignalPtr... StopPtr>
// auto qObjectAsSender(QObj *obj, ValuePtr value, ErrorPtr... errors,
//                      StopPtr... stops) {
//   static_assert(detail::signal_belongs_v<QObj, ValuePtr>,
//                 "value_signal must belong to QObj (or its base)");
//   static_assert((detail::signal_belongs_v<QObj, ErrorPtr> && ...),
//                 "error_signal must belong to QObj (or its base)");
//
//   return QObjectSender<QObj, ValuePtr, ErrorPtr..., StopPtr...>(
//       obj, value, errors..., stops...);
// }

} // namespace Async
