/// \file CFG.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

#include <cstddef>
#include <memory>
#include <type_traits>
#include <utility>
#include <vector>

#include "ast.h"

namespace cw {

/// \brief Kinds of source-level events stored in a CFG block.
enum class CFGElementKind {
  Expression,
  Declaration,
  ScopeExit,
  ResultCheck,
};

/// \brief Base class for one source-level CFG event.
class CFGElement {
  friend class CFGBlock;

  CFGElementKind kind_;
  std::size_t program_point_{};

 public:
  virtual ~CFGElement() = default;

  CFGElement(const CFGElement&) = delete;
  CFGElement& operator=(const CFGElement&) = delete;
  CFGElement(CFGElement&&) = delete;
  CFGElement& operator=(CFGElement&&) = delete;

  /// \brief Returns the concrete element kind.
  CFGElementKind GetKind() const { return kind_; }

  /// \brief Returns the stable structural program point assigned by the CFG.
  std::size_t GetProgramPoint() const { return program_point_; }

 protected:
  explicit CFGElement(CFGElementKind kind) : kind_(kind) {}
};

/// \brief The context in which an expression region is evaluated.
enum class CFGExpressionContext {
  Ordinary,
  InitializationTarget,
};

/// \brief A source-level expression region evaluated in one basic block.
///
/// Subexpressions represented by earlier CFG elements or control-flow regions
/// are listed in ExcludedSubexpressions(). An analysis walking GetExpression()
/// must not visit them again, while the root expression's own semantics still
/// occur at this program point.
class CFGExpressionElement final : public CFGElement {
  const Expr* expression_;  ///< Non-owning; the Semantic AST outlives this CFG.
  CFGExpressionContext context_;
  std::vector<const Expr*> excluded_subexpressions_;  ///< Non-owning separately evaluated roots.

 public:
  explicit CFGExpressionElement(const Expr& expression, CFGExpressionContext context = CFGExpressionContext::Ordinary,
                                std::vector<const Expr*> excluded_subexpressions = {});

  /// \brief Returns the non-owning expression root associated with this event.
  const Expr& GetExpression() const { return *expression_; }

  /// \brief Returns the context in which the expression region is evaluated.
  CFGExpressionContext GetContext() const { return context_; }

  /// \brief Returns subexpression roots represented elsewhere in the CFG.
  const std::vector<const Expr*>& ExcludedSubexpressions() const { return excluded_subexpressions_; }
};

/// \brief Source form that establishes one tracked object instance.
///
/// This describes the AST boundary rather than a data-flow state. The definite
/// initialization analysis decides the state effect associated with each form.
enum class CFGDeclarationForm {
  Parameter,
  ReturnObject,
  Uninitialized,
  DirectInitialization,
  InitializerBlockResult,
};

/// \brief Boundary at which one declaration establishes an object instance.
class CFGDeclarationElement final : public CFGElement {
  const VarDecl* declaration_;  ///< Non-owning declaration identity.
  CFGDeclarationForm form_;
  const Expr* initializer_;  ///< Non-owning direct initializer, if present.

 public:
  CFGDeclarationElement(const VarDecl& declaration, CFGDeclarationForm form, const Expr* initializer = nullptr);

  /// \brief Returns the declaration whose current object instance begins here.
  const VarDecl& GetDeclaration() const { return *declaration_; }

  /// \brief Returns the source form establishing the object.
  CFGDeclarationForm GetForm() const { return form_; }

  /// \brief Returns the paired direct initializer, when one exists.
  const Expr* GetInitializer() const { return initializer_; }
};

/// \brief Boundary at which declarations owned by a lexical scope leave it.
class CFGScopeExitElement final : public CFGElement {
  const Node* scope_;  ///< Non-owning source scope.

 public:
  explicit CFGScopeExitElement(const Node& scope);

  /// \brief Returns the compound statement or function whose scope is left.
  const Node& GetScope() const { return *scope_; }
};

/// \brief A normal exit at which result-object completeness is checked.
class CFGResultCheckElement final : public CFGElement {
  const Node* result_owner_;   ///< Non-owning result-block owner.
  const Node* exit_location_;  ///< Non-owning location of this exit.

 public:
  CFGResultCheckElement(const Node& result_owner, const Node& exit_location);

  /// \brief Returns the function or variable declaration group owning results.
  const Node& GetResultOwner() const { return *result_owner_; }

  /// \brief Returns the source node locating this particular normal exit.
  const Node& GetExitLocation() const { return *exit_location_; }
};

/// \brief Kinds of control-flow transfer represented by an edge.
enum class CFGEdgeKind {
  Unconditional,
  True,
  False,
};

class CFG;
class CFGEdge;

/// \brief One basic block in an execution-body CFG.
class CFGBlock {
  friend class CFG;

  std::size_t id_;
  std::vector<std::unique_ptr<CFGElement>> elements_;
  std::vector<const CFGEdge*> predecessors_;  ///< Non-owning edges in CFG.
  std::vector<const CFGEdge*> successors_;    ///< Non-owning edges in CFG.
  const Node* terminator_{};                  ///< Non-owning Semantic AST node.
  std::size_t* next_program_point_{};         ///< Non-owning counter owned by CFG.
  std::size_t terminator_program_point_{};    ///< Structural point assigned by SetTerminator().
  const Node* anchor_{};                      ///< Non-owning source control boundary.
  std::size_t anchor_program_point_{};        ///< Structural point assigned by SetAnchor().

 public:
  CFGBlock(const CFGBlock&) = delete;
  CFGBlock& operator=(const CFGBlock&) = delete;
  CFGBlock(CFGBlock&&) = delete;
  CFGBlock& operator=(CFGBlock&&) = delete;

  /// \brief Returns the stable block number assigned by the owning CFG.
  std::size_t GetID() const { return id_; }

  /// \brief Returns source-level events in execution order.
  const std::vector<std::unique_ptr<CFGElement>>& Elements() const { return elements_; }

  /// \brief Returns incoming edges owned by the CFG.
  const std::vector<const CFGEdge*>& Predecessors() const { return predecessors_; }

  /// \brief Returns outgoing edges owned by the CFG.
  const std::vector<const CFGEdge*>& Successors() const { return successors_; }

  /// \brief Returns the source control node terminating this block, if any.
  const Node* GetTerminator() const { return terminator_; }

  /// \brief Appends one event and returns it at its stable address.
  template <class Element, class... Args>
  Element& EmplaceElement(Args&&... args) {
    return EmplaceElementAt<Element>((*next_program_point_)++, std::forward<Args>(args)...);
  }

  /// \brief Appends one event at a previously reserved structural point.
  template <class Element, class... Args>
  Element& EmplaceElementAt(std::size_t program_point, Args&&... args) {
    static_assert(std::is_base_of_v<CFGElement, Element>);
    auto element = std::make_unique<Element>(std::forward<Args>(args)...);
    element->program_point_ = program_point;
    Element& result = *element;
    elements_.push_back(std::move(element));
    return result;
  }

  /// \brief Records the source node whose control decision ends this block.
  void SetTerminator(const Node& terminator);

  /// \brief Returns the terminator's structural program point, if present.
  std::size_t GetTerminatorProgramPoint() const { return terminator_program_point_; }

  /// \brief Records a source control boundary represented by an otherwise empty block.
  void SetAnchor(const Node& anchor);

  /// \brief Returns the source control boundary associated with this block, if any.
  const Node* GetAnchor() const { return anchor_; }

  /// \brief Returns the anchor's structural program point, if present.
  std::size_t GetAnchorProgramPoint() const { return anchor_program_point_; }

 private:
  CFGBlock(std::size_t id, std::size_t& next_program_point) : id_(id), next_program_point_(&next_program_point) {}
};

/// \brief One edge owned once by a CFG and referenced by both endpoint blocks.
class CFGEdge {
  friend class CFG;

  CFGBlock* source_;  ///< Non-owning block owned by the same CFG.
  CFGBlock* target_;  ///< Non-owning block owned by the same CFG.
  CFGEdgeKind kind_;

 public:
  CFGEdge(const CFGEdge&) = delete;
  CFGEdge& operator=(const CFGEdge&) = delete;
  CFGEdge(CFGEdge&&) = delete;
  CFGEdge& operator=(CFGEdge&&) = delete;

  /// \brief Returns the edge source.
  const CFGBlock& GetSource() const { return *source_; }

  /// \brief Returns the edge destination.
  const CFGBlock& GetTarget() const { return *target_; }

  /// \brief Returns the represented control-flow transfer kind.
  CFGEdgeKind GetKind() const { return kind_; }

 private:
  CFGEdge(CFGBlock& source, CFGBlock& target, CFGEdgeKind kind) : source_(&source), target_(&target), kind_(kind) {}
};

/// \brief Owning control-flow graph for a function or ordered global initialization.
class CFG {
  std::vector<std::unique_ptr<CFGBlock>> blocks_;
  std::vector<std::unique_ptr<CFGEdge>> edges_;
  CFGBlock* entry_{};
  CFGBlock* exit_{};
  std::size_t next_program_point_{1};

 public:
  CFG();
  ~CFG();

  CFG(const CFG&) = delete;
  CFG& operator=(const CFG&) = delete;
  CFG(CFG&&) = delete;
  CFG& operator=(CFG&&) = delete;

  /// \brief Creates an address-stable basic block.
  CFGBlock& CreateBlock();

  /// \brief Creates one edge and registers it with both endpoint blocks.
  CFGEdge& Connect(CFGBlock& source, CFGBlock& target, CFGEdgeKind kind);

  /// \brief Reserves a stable structural program point for a delayed boundary element.
  std::size_t ReserveProgramPoint() { return next_program_point_++; }

  /// \brief Returns the graph's unique entry block.
  CFGBlock& GetEntry() { return *entry_; }
  const CFGBlock& GetEntry() const { return *entry_; }

  /// \brief Returns the graph's unified exit block.
  CFGBlock& GetExit() { return *exit_; }
  const CFGBlock& GetExit() const { return *exit_; }

  /// \brief Returns all blocks in stable-number order.
  const std::vector<std::unique_ptr<CFGBlock>>& Blocks() const { return blocks_; }

  /// \brief Returns all graph edges in creation order.
  const std::vector<std::unique_ptr<CFGEdge>>& Edges() const { return edges_; }
};

}  // namespace cw
