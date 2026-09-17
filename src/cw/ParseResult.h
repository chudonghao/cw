/// \file ParseResult.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <memory>
#include <type_traits>
#include <utility>

namespace cw {

/// \brief Transient owning parse result.
///
/// ParseResult is the return type of parse functions, modeled after Clang's
/// ActionResult. It wraps a std::unique_ptr<T> together with an \c invalid flag
/// and exposes three \b independent dimensions:
/// - parse completeness: \c Complete() / \c Incomplete() (only the \c invalid
///   flag; whether this layer parsed to its expected end without being
///   interrupted, orthogonal to the other two dimensions).
/// - node presence: \c Get() (a null node is a legal absence, not an error).
/// - subtree front-end errors: \c ContainsErrors().
///
/// These dimensions are decoupled: a complete parse may still hold no node or
/// hold a node whose subtree contains errors, and node presence never implies
/// completeness. The \c invalid flag is consumed at
/// the storage seam and is \b not stored in the AST: the persistent error
/// signal lives on the node itself (Node::contains_errors), where later
/// front-end phases may also aggregate fatal errors.
///
/// It is move-only (like unique_ptr) and intentionally does \b not provide any
/// conversion to bool; callers must use the explicit predicates.
template <class T>
class ParseResult {
  template <class U>
  friend class ParseResult;

  std::unique_ptr<T> ptr_{};  ///< Owned node (null when unset).
  bool invalid_ = false;      ///< This parse layer stopped before its expected end.

 public:
  /// \brief Constructs an unset ParseResult.
  ParseResult() = default;

  /// \brief Constructs an unset ParseResult from nullptr.
  ParseResult(std::nullptr_t) {}

  /// \brief Takes ownership of an existing unique_ptr (usable when non-null,
  /// unset when null), with \c invalid unset.
  explicit ParseResult(std::unique_ptr<T> ptr) : ptr_(std::move(ptr)) {}

  ParseResult(const ParseResult&) = delete;
  ParseResult& operator=(const ParseResult&) = delete;

  ParseResult(ParseResult&&) noexcept = default;
  ParseResult& operator=(ParseResult&&) noexcept = default;

  /// \brief Move-converts from a ParseResult<U> when U* is convertible to T*.
  ///
  /// The wrapped unique_ptr performs the U->T move and the invalid flag is
  /// carried over, so a ParseResult of a derived type can be moved into a
  /// ParseResult of a base type.
  template <class U, class = std::enable_if_t<std::is_convertible_v<U*, T*> && !std::is_same_v<U, T>>>
  ParseResult(ParseResult<U>&& other) noexcept : ptr_(other.Take()), invalid_(other.invalid_) {}

  ~ParseResult() = default;

  /// \brief Dereferences the held node. Undefined when no node is held.
  T& operator*() const { return *ptr_; }

  /// \brief Accesses the held node. Undefined when no node is held.
  T* operator->() const { return ptr_.get(); }

  /// \brief Returns the raw pointer to the held node (may be null).
  T* Get() const { return ptr_.get(); }

  /// \brief Relinquishes ownership of the held node.
  std::unique_ptr<T> Take() { return std::move(ptr_); }

  /// \brief Returns true when this layer parsed to its expected end without
  /// being interrupted.
  ///
  /// Reflects only the \c invalid dimension. \c Complete does \b not imply a
  /// node is held (\c Get may be null) nor that the subtree is error-free
  /// (\c ContainsErrors may be true); those are independent concerns.
  bool Complete() const { return !invalid_; }

  /// \brief Returns true when the parse was interrupted (the negation of
  /// Complete()).
  bool Incomplete() const { return invalid_; }

  /// \brief Returns true when this result carries an error to propagate upward.
  ///
  /// True when the layer itself was interrupted (\c invalid) or the held node's
  /// subtree contains fatal front-end errors. Shares the name with
  /// Node::ContainsErrors() to unify the term, but additionally folds in the
  /// transient \c invalid (parse-layer interruption) dimension that an AST
  /// node does not carry.
  bool ContainsErrors() const { return invalid_ || (ptr_ != nullptr && ptr_->contains_errors); }

  /// \brief Marks this result as a failed parse and returns it for one-line use.
  ///
  /// Sets the \c invalid flag and, when a node is held, stamps contains_errors
  /// onto it so an invalid result can never carry an unflagged node.
  /// Returns *this as an rvalue to allow `return r.Invalidate();`.
  ParseResult&& Invalidate() {
    invalid_ = true;
    if (ptr_) {
      ptr_->contains_errors = true;
    }
    return std::move(*this);
  }
};

/// \brief Constructs a usable ParseResult<T>, replacing std::make_unique<T>.
template <class T, class... Args>
ParseResult<T> MakeNode(Args&&... args) {
  return ParseResult<T>(std::make_unique<T>(std::forward<Args>(args)...));
}

}  // namespace cw
