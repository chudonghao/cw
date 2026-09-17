/// \file DefiniteInitialization.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#include "DefiniteInitialization.h"

#include <algorithm>
#include <cstddef>
#include <deque>
#include <limits>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>

#include <boost/assert.hpp>
#include <boost/container_hash/hash.hpp>

namespace cw {
namespace {

enum class InitializationState { Uninitialized, Initialized, Invalid };

struct AbstractState {
  InitializationState state;
  std::vector<std::size_t> conflict_origins;

  friend bool operator==(const AbstractState& left, const AbstractState& right) {
    return left.state == right.state && left.conflict_origins == right.conflict_origins;
  }
  friend bool operator!=(const AbstractState& left, const AbstractState& right) { return !(left == right); }
};

struct TrackedRoot {
  const VarDecl* variable{};
  const FunctionDecl* this_owner{};

  friend bool operator==(TrackedRoot left, TrackedRoot right) {
    return left.variable == right.variable && left.this_owner == right.this_owner;
  }
};

struct TrackedRootHash {
  std::size_t operator()(TrackedRoot root) const {
    std::size_t result = 0;
    boost::hash_combine(result, root.variable);
    boost::hash_combine(result, root.this_owner);
    return result;
  }
};

struct ObjectState {
  std::vector<AbstractState> leaves;

  friend bool operator==(const ObjectState& left, const ObjectState& right) { return left.leaves == right.leaves; }
  friend bool operator!=(const ObjectState& left, const ObjectState& right) { return !(left == right); }
};

enum class PathSegmentKind { Base, Field, ArrayElement };

/// One segment of a canonical path from a tracked root. Base segments identify
/// real base subobjects; they are not synthetic FieldDecl nodes. Array-element
/// segments preserve a locating projection without assigning per-index state;
/// access resolution therefore falls back to the enclosing atomic array range.
struct PathSegment {
  PathSegmentKind kind;
  const StructDecl* base{};
  const FieldDecl* field{};

  static PathSegment Base(const StructDecl& declaration) {
    return PathSegment{PathSegmentKind::Base, &declaration, nullptr};
  }
  static PathSegment Field(const FieldDecl& declaration) {
    return PathSegment{PathSegmentKind::Field, nullptr, &declaration};
  }
  static PathSegment ArrayElement() { return PathSegment{PathSegmentKind::ArrayElement, nullptr, nullptr}; }

  friend bool operator==(const PathSegment& left, const PathSegment& right) {
    return left.kind == right.kind && left.base == right.base && left.field == right.field;
  }
};

using SubobjectPath = std::vector<PathSegment>;

struct LayoutLeaf {
  SubobjectPath path;
  QualType type;
};

struct SubobjectRange {
  SubobjectPath path;
  std::size_t begin{};
  std::size_t end{};
  bool atomic{};
};

/// Flat immutable layout. Only leaves have states; aggregate completeness is
/// derived from its contiguous leaf range.
struct ObjectLayout {
  std::vector<LayoutLeaf> leaves;
  std::vector<SubobjectRange> ranges;
  bool valid{};
};

using Environment = std::unordered_map<TrackedRoot, ObjectState, TrackedRootHash>;

const StructDecl* AsStructDeclaration(QualType type) {
  if (!type || type.GetTypePtr()->GetKind() != TypeKind::Struct) {
    return nullptr;
  }
  return static_cast<const StructType*>(type.GetTypePtr())->GetDeclaration();
}

bool IsVoidType(QualType type) {
  return type && type.GetTypePtr()->GetKind() == TypeKind::Builtin &&
         static_cast<const BuiltinType*>(type.GetTypePtr())->GetBuiltinTypeKind() == BuiltinTypeKind::Void;
}

bool IsKnownObjectType(QualType type) {
  if (!type || IsVoidType(type)) {
    return false;
  }
  switch (type.GetTypePtr()->GetKind()) {
    case TypeKind::Builtin:
    case TypeKind::Pointer:
    case TypeKind::VirtualSlot:
    case TypeKind::Reference:
      return true;
    case TypeKind::Struct: {
      const StructDecl* structure = AsStructDeclaration(type);
      return structure &&
             (structure->triviality == TypeTriviality::Trivial || structure->triviality == TypeTriviality::NonTrivial);
    }
    case TypeKind::Array:
      return true;
    case TypeKind::ComptimeInt:
    case TypeKind::Null:
    case TypeKind::FunctionOverloadSet:
    case TypeKind::AddressOfFunctionOverloadSet:
    case TypeKind::Function:
      return false;
  }
  return false;
}

class FlatLayoutBuilder {
  ObjectLayout* layout_{};
  std::unordered_set<const StructDecl*> active_structures_;

 public:
  ObjectLayout BuildOrdinary(QualType type) {
    ObjectLayout result;
    layout_ = &result;
    result.valid = AppendOrdinary(type, {});
    layout_ = nullptr;
    return result;
  }

  ObjectLayout BuildConstructorThis(const StructType& type) {
    ObjectLayout result;
    layout_ = &result;
    const StructDecl* structure = type.GetDeclaration();
    result.valid = structure && AppendConstructionRoot(*structure, {});
    layout_ = nullptr;
    return result;
  }

 private:
  bool AppendAtomic(QualType type, const SubobjectPath& path) {
    if (!IsKnownObjectType(type)) {
      return false;
    }
    const std::size_t index = layout_->leaves.size();
    layout_->leaves.push_back(LayoutLeaf{path, type});
    layout_->ranges.push_back(SubobjectRange{path, index, index + 1, true});
    return true;
  }

  bool AppendOrdinary(QualType type, const SubobjectPath& path) {
    const StructDecl* structure = AsStructDeclaration(type);
    if (!structure) {
      return AppendAtomic(type, path);
    }
    if (structure->triviality == TypeTriviality::NonTrivial) {
      return AppendAtomic(type, path);
    }
    if (structure->triviality != TypeTriviality::Trivial) {
      return false;
    }
    if (!structure->base_type && structure->Fields.empty()) {
      return AppendAtomic(type, path);
    }
    return AppendTrivialAggregate(*structure, path);
  }

  bool AppendTrivialAggregate(const StructDecl& structure, const SubobjectPath& path) {
    if (!active_structures_.insert(&structure).second) {
      return false;
    }
    const std::size_t begin = layout_->leaves.size();
    if (structure.base_type && structure.base_type->GetDeclaration()) {
      SubobjectPath base_path = path;
      base_path.push_back(PathSegment::Base(*structure.base_type->GetDeclaration()));
      AppendOrdinary(QualType(structure.base_type), base_path);
    }
    for (const auto& field : structure.Fields) {
      if (!field) {
        continue;
      }
      SubobjectPath field_path = path;
      field_path.push_back(PathSegment::Field(*field));
      AppendOrdinary(field->type, field_path);
    }
    active_structures_.erase(&structure);
    layout_->ranges.push_back(SubobjectRange{path, begin, layout_->leaves.size(), false});
    return true;
  }

  bool AppendConstructionRoot(const StructDecl& structure, const SubobjectPath& path) {
    if (!active_structures_.insert(&structure).second) {
      return false;
    }
    const std::size_t begin = layout_->leaves.size();
    // A constructor establishes the direct base as one indivisible object.
    if (structure.base_type && structure.base_type->GetDeclaration()) {
      SubobjectPath base_path = path;
      base_path.push_back(PathSegment::Base(*structure.base_type->GetDeclaration()));
      AppendAtomic(QualType(structure.base_type), base_path);
    }
    for (const auto& field : structure.Fields) {
      if (!field) {
        continue;
      }
      SubobjectPath field_path = path;
      field_path.push_back(PathSegment::Field(*field));
      AppendOrdinary(field->type, field_path);
    }
    active_structures_.erase(&structure);
    layout_->ranges.push_back(SubobjectRange{path, begin, layout_->leaves.size(), false});
    return true;
  }
};

ObjectState MakeState(std::size_t leaf_count, InitializationState state) {
  ObjectState result;
  result.leaves.assign(leaf_count, AbstractState{state, {}});
  return result;
}

bool RangeHasState(const ObjectState& object, std::size_t begin, std::size_t end, InitializationState state) {
  const std::size_t last = std::min(end, object.leaves.size());
  for (std::size_t index = begin; index < last; ++index) {
    if (object.leaves[index].state == state) {
      return true;
    }
  }
  return false;
}

bool RangeIsEntirely(const ObjectState& object, std::size_t begin, std::size_t end, InitializationState state) {
  if (begin == end || end > object.leaves.size()) {
    return false;
  }
  for (std::size_t index = begin; index < end; ++index) {
    if (object.leaves[index].state != state) {
      return false;
    }
  }
  return true;
}

const ImplicitCastExpr* AsObjectDerivedToBaseCast(const Expr* expression) {
  if (!expression || expression->GetKind() != NodeKind::ImplicitCastExpr) {
    return nullptr;
  }
  const auto* cast = static_cast<const ImplicitCastExpr*>(expression);
  if (cast->conversion_kind != ImplicitConversionKind::DerivedToBase || !cast->type ||
      cast->type.GetTypePtr()->GetKind() != TypeKind::Struct || cast->base_path.empty()) {
    return nullptr;
  }
  return cast;
}

const Expr* SkipLocatingWrappers(const Expr* expression) {
  while (expression) {
    switch (expression->GetKind()) {
      case NodeKind::ParenExpr:
        expression = static_cast<const ParenExpr*>(expression)->SubExpr.get();
        break;
      case NodeKind::ImplicitCastExpr: {
        if (AsObjectDerivedToBaseCast(expression)) {
          return expression;
        }
        // NoOp is access to the same object, including through a base projection.
        expression = static_cast<const ImplicitCastExpr*>(expression)->SubExpr.get();
        break;
      }
      case NodeKind::MaterializeTemporaryExpr:
        expression = static_cast<const MaterializeTemporaryExpr*>(expression)->SubExpr.get();
        break;
      default:
        return expression;
    }
  }
  return nullptr;
}

bool IsPathPrefix(const SubobjectPath& prefix, const SubobjectPath& path) {
  return prefix.size() <= path.size() && std::equal(prefix.begin(), prefix.end(), path.begin());
}

const SubobjectRange* FindExactRange(const ObjectLayout& layout, const SubobjectPath& path) {
  for (const SubobjectRange& range : layout.ranges) {
    if (range.path == path) {
      return &range;
    }
  }
  return nullptr;
}

const SubobjectRange* FindAtomicPrefix(const ObjectLayout& layout, const SubobjectPath& path) {
  const SubobjectRange* result = nullptr;
  for (const SubobjectRange& range : layout.ranges) {
    if (!range.atomic || !IsPathPrefix(range.path, path)) {
      continue;
    }
    if (!result || result->path.size() < range.path.size()) {
      result = &range;
    }
  }
  return result;
}

bool FindFieldSuffix(const StructDecl& structure, const FieldDecl& field, SubobjectPath& suffix,
                     std::unordered_set<const StructDecl*>& visited) {
  if (!visited.insert(&structure).second) {
    return false;
  }
  for (const auto& direct_field : structure.Fields) {
    if (direct_field.get() != &field) {
      continue;
    }
    suffix.push_back(PathSegment::Field(field));
    visited.erase(&structure);
    return true;
  }
  if (structure.base_type && structure.base_type->GetDeclaration()) {
    const StructDecl& base = *structure.base_type->GetDeclaration();
    suffix.push_back(PathSegment::Base(base));
    if (FindFieldSuffix(base, field, suffix, visited)) {
      visited.erase(&structure);
      return true;
    }
    suffix.pop_back();
  }
  visited.erase(&structure);
  return false;
}

const VarDecl* AsVariable(const ValueDecl* declaration) {
  if (!declaration) {
    return nullptr;
  }
  switch (declaration->GetKind()) {
    case NodeKind::VarDecl:
    case NodeKind::ParmVarDecl:
    case NodeKind::ReturnVarDecl:
      return static_cast<const VarDecl*>(declaration);
    default:
      return nullptr;
  }
}

struct Access {
  TrackedRoot root;
  std::size_t begin{};
  std::size_t end{};
  SourceRange root_range{};
  bool exact{};
  bool valid{};
};

struct FindingKey {
  DefiniteInitializationFindingKind kind;
  const Node* owner;
  TrackedRoot root;

  friend bool operator==(const FindingKey& left, const FindingKey& right) {
    return left.kind == right.kind && left.owner == right.owner && left.root == right.root;
  }
};

struct FindingKeyHash {
  std::size_t operator()(const FindingKey& key) const {
    std::size_t result = 0;
    boost::hash_combine(result, key.kind);
    boost::hash_combine(result, key.owner);
    boost::hash_combine(result, key.root.variable);
    boost::hash_combine(result, key.root.this_owner);
    return result;
  }
};

bool FindingPrecedes(const DefiniteInitializationFinding& left, const DefiniteInitializationFinding& right) {
  if (left.program_point != right.program_point) {
    return left.program_point < right.program_point;
  }
  if (left.intra_program_order != right.intra_program_order) {
    return left.intra_program_order < right.intra_program_order;
  }
  const bool left_valid = left.range.IsValid();
  const bool right_valid = right.range.IsValid();
  if (left_valid != right_valid) {
    return left_valid;
  }
  if (!left_valid) {
    return false;
  }
  if (left.range.begin.file != right.range.begin.file) {
    return left.range.begin.file < right.range.begin.file;
  }
  return left.range.begin.pos < right.range.begin.pos;
}

bool EqualEnvironments(const Environment& left, const Environment& right) {
  if (left.size() != right.size()) {
    return false;
  }
  for (const auto& entry : left) {
    const auto it = right.find(entry.first);
    if (it == right.end() || it->second != entry.second) {
      return false;
    }
  }
  return true;
}

SourceRange PreferredRange(const Node& owner, TrackedRoot root) {
  if (owner.range.IsValid()) {
    return owner.range;
  }
  if (root.variable) {
    if (root.variable->name_range.IsValid()) {
      return root.variable->name_range;
    }
    return root.variable->range;
  }
  if (root.this_owner) {
    if (root.this_owner->GetKind() == NodeKind::ConstructorDecl) {
      return static_cast<const ConstructorDecl*>(root.this_owner)->name_range;
    }
    if (root.this_owner->GetKind() == NodeKind::DestructorDecl) {
      return static_cast<const DestructorDecl*>(root.this_owner)->name_range;
    }
    return root.this_owner->range;
  }
  return owner.range;
}

bool IsAssignmentOperatorCall(const OperatorCallExpr& expression) {
  if (expression.Args.size() != 2 || !expression.Args[0] || !expression.Args[1] || !expression.Callee ||
      expression.Callee->GetKind() != NodeKind::DeclRefExpr) {
    return false;
  }
  const ValueDecl* declaration = static_cast<const DeclRefExpr&>(*expression.Callee).declaration;
  if (!declaration) {
    return false;
  }
  switch (declaration->GetKind()) {
    case NodeKind::FunctionDecl:
    case NodeKind::VirtualFunctionDecl:
      return static_cast<const FunctionDecl*>(declaration)->name == "=";
    default:
      return false;
  }
}

bool GetAssignmentOperands(const Expr& expression, const Expr*& lhs, const Expr*& rhs) {
  if (expression.GetKind() == NodeKind::BinaryOperator) {
    const auto& binary = static_cast<const BinaryOperator&>(expression);
    if (!binary.IsSimpleAssignment()) {
      return false;
    }
    lhs = binary.LHS.get();
    rhs = binary.RHS.get();
    return true;
  }
  if (expression.GetKind() == NodeKind::OperatorCallExpr) {
    const auto& call = static_cast<const OperatorCallExpr&>(expression);
    if (!IsAssignmentOperatorCall(call)) {
      return false;
    }
    lhs = call.Args[0].get();
    rhs = call.Args[1].get();
    return true;
  }
  if (expression.GetKind() == NodeKind::ArrayAssignmentExpr) {
    const auto& assignment = static_cast<const ArrayAssignmentExpr&>(expression);
    lhs = assignment.LHS.get();
    rhs = assignment.RHS.get();
    return true;
  }
  return false;
}

class AnalysisEngine {
  const Decl& owner_;
  const FunctionDecl* function_;
  const CFG& cfg_;
  const ABIKind abi_;
  std::vector<Environment> inputs_;
  std::vector<Environment> outputs_;
  std::vector<bool> reachable_;
  std::vector<const VarDecl*> declarations_;
  std::unordered_set<const VarDecl*> indexed_declarations_;
  std::unordered_map<const Node*, std::vector<const VarDecl*>> scope_declarations_;
  std::unordered_map<const VarDecl*, const Node*> declaration_scopes_;
  std::unordered_set<const InitializationExpr*> valid_initializations_;
  std::unordered_map<const VarDecl*, ObjectLayout> variable_layouts_;
  ObjectLayout this_layout_;
  bool tracks_this_{};
  bool this_is_destructor_{};
  std::unordered_map<FindingKey, std::size_t, FindingKeyHash> finding_indices_;
  std::vector<DefiniteInitializationFinding> findings_;
  std::size_t current_program_point_{};
  std::size_t current_intra_program_order_{};

 public:
  AnalysisEngine(const Decl& owner, const CFG& cfg, ABIKind abi)
      : owner_(owner),
        function_(owner.GetKind() == NodeKind::TranslationUnitDecl ? nullptr
                                                                   : &static_cast<const FunctionDecl&>(owner)),
        cfg_(cfg),
        abi_(abi),
        inputs_(cfg.Blocks().size()),
        outputs_(cfg.Blocks().size()),
        reachable_(cfg.Blocks().size()) {
    if (function_) {
      IndexFunction();
    } else {
      IndexGlobals(static_cast<const TranslationUnitDecl&>(owner_));
    }
    IndexCFGDeclarations();
    ComputeReachability();
  }

  std::vector<DefiniteInitializationFinding> Run() {
    // Diagnose only the fixed point; intermediate loop states can produce transient conflicts.
    Solve();
    CollectFindings();
    return std::move(findings_);
  }

 private:
  TrackedRoot VariableRoot(const VarDecl& declaration) const { return TrackedRoot{&declaration, nullptr}; }
  TrackedRoot ThisRoot() const { return TrackedRoot{nullptr, tracks_this_ ? function_ : nullptr}; }

  const ObjectLayout* LayoutFor(TrackedRoot root) const {
    if (root.variable) {
      const auto it = variable_layouts_.find(root.variable);
      return it == variable_layouts_.end() ? nullptr : &it->second;
    }
    return root.this_owner == function_ && tracks_this_ ? &this_layout_ : nullptr;
  }

  QualType RootType(TrackedRoot root) const {
    if (root.variable) {
      return root.variable->type;
    }
    if (!function_ || root.this_owner != function_) {
      return {};
    }
    if (function_->GetKind() == NodeKind::ConstructorDecl) {
      return QualType(static_cast<const ConstructorDecl&>(*function_).target_type);
    }
    if (function_->GetKind() == NodeKind::DestructorDecl) {
      return QualType(static_cast<const DestructorDecl&>(*function_).target_type);
    }
    return {};
  }

  void AddDeclaration(const VarDecl& declaration) {
    if (!indexed_declarations_.insert(&declaration).second) {
      return;
    }
    declarations_.push_back(&declaration);
    ObjectLayout layout = FlatLayoutBuilder().BuildOrdinary(declaration.type);
    if (!layout.valid) {
      // Keep a declaration identity analyzable after an independent type or
      // inference error. The recovery root has no field structure and cannot
      // manufacture successful member effects, but a later whole-object use
      // can still be diagnosed as uninitialized.
      layout.valid = true;
      layout.leaves.push_back(LayoutLeaf{{}, {}});
      layout.ranges.push_back(SubobjectRange{{}, 0, 1, true});
    }
    variable_layouts_.emplace(&declaration, std::move(layout));
  }

  void IndexFunction() {
    if (function_->GetKind() == NodeKind::ConstructorDecl) {
      const auto& constructor = static_cast<const ConstructorDecl&>(*function_);
      if (constructor.target_type) {
        this_layout_ = FlatLayoutBuilder().BuildConstructorThis(*constructor.target_type);
        tracks_this_ = this_layout_.valid;
      }
    } else if (function_->GetKind() == NodeKind::DestructorDecl) {
      const auto& destructor = static_cast<const DestructorDecl&>(*function_);
      if (destructor.target_type) {
        this_layout_ = FlatLayoutBuilder().BuildOrdinary(QualType(destructor.target_type));
        tracks_this_ = this_layout_.valid;
        this_is_destructor_ = true;
      }
    }
    for (const auto& parameter : function_->ParmVars) {
      if (parameter) {
        AddDeclaration(*parameter);
      }
    }
    if (function_->ReturnVar) {
      AddDeclaration(*function_->ReturnVar);
    }
    if (function_->Body) {
      IndexCompound(*function_->Body);
    }
  }

  void IndexGlobals(const TranslationUnitDecl& translation_unit) {
    for (const auto& declaration : translation_unit.Decls) {
      if (!declaration || declaration->GetKind() != NodeKind::VarGroupDecl) {
        continue;
      }
      IndexVariableGroup(static_cast<const VarGroupDecl&>(*declaration), translation_unit);
    }
  }

  void IndexVariableGroup(const VarGroupDecl& group, const Node& scope) {
    auto& owned = scope_declarations_[&scope];
    for (const auto& variable : group.Vars) {
      if (!variable) {
        continue;
      }
      AddDeclaration(*variable);
      owned.push_back(variable.get());
      declaration_scopes_.emplace(variable.get(), &scope);
    }
    if (group.Body) {
      IndexCompound(*group.Body);
    }
  }

  void IndexCompound(const CompoundStmt& statement) {
    for (const auto& child : statement.Stmts) {
      if (!child) {
        continue;
      }
      switch (child->GetKind()) {
        case NodeKind::CompoundStmt:
          IndexCompound(static_cast<const CompoundStmt&>(*child));
          break;
        case NodeKind::ExprStmt: {
          const auto& expression_statement = static_cast<const ExprStmt&>(*child);
          if (expression_statement.Expr && expression_statement.Expr->GetKind() == NodeKind::InitializationExpr) {
            valid_initializations_.insert(static_cast<const InitializationExpr*>(expression_statement.Expr.get()));
          }
          break;
        }
        case NodeKind::DeclStmt: {
          const auto& declaration_statement = static_cast<const DeclStmt&>(*child);
          if (!declaration_statement.Decl || declaration_statement.Decl->GetKind() != NodeKind::VarGroupDecl) {
            break;
          }
          const auto& group = static_cast<const VarGroupDecl&>(*declaration_statement.Decl);
          IndexVariableGroup(group, statement);
          break;
        }
        case NodeKind::IfStmt: {
          const auto& conditional = static_cast<const IfStmt&>(*child);
          if (conditional.Then) {
            IndexCompound(*conditional.Then);
          }
          if (conditional.Else) {
            IndexCompound(*conditional.Else);
          }
          break;
        }
        case NodeKind::WhileStmt: {
          const auto& loop = static_cast<const WhileStmt&>(*child);
          if (loop.Body) {
            IndexCompound(*loop.Body);
          }
          break;
        }
        default:
          break;
      }
    }
  }

  void IndexCFGDeclarations() {
    for (const auto& block : cfg_.Blocks()) {
      for (const auto& element : block->Elements()) {
        if (element->GetKind() != CFGElementKind::Declaration) {
          continue;
        }
        AddDeclaration(static_cast<const CFGDeclarationElement&>(*element).GetDeclaration());
      }
    }
  }

  Access ResolveAccess(const Expr* expression) const {
    Access access;
    if (!expression) {
      return access;
    }

    // Peel projections from the use back to its tracked object root.
    SubobjectPath segments;
    const Expr* current = SkipLocatingWrappers(expression);
    while (current &&
           (current->GetKind() == NodeKind::MemberExpr || current->GetKind() == NodeKind::BaseSubobjectExpr ||
            current->GetKind() == NodeKind::SubscriptExpr || AsObjectDerivedToBaseCast(current))) {
      if (current->GetKind() == NodeKind::MemberExpr) {
        const auto& member = static_cast<const MemberExpr&>(*current);
        if (member.op == expr::arrow || !member.declaration) {
          return access;
        }
        segments.push_back(PathSegment::Field(*member.declaration));
        current = SkipLocatingWrappers(member.Base.get());
      } else if (current->GetKind() == NodeKind::BaseSubobjectExpr) {
        const auto& base = static_cast<const BaseSubobjectExpr&>(*current);
        if (base.op == expr::arrow || base.base_path.empty()) {
          return access;
        }
        for (auto declaration = base.base_path.rbegin(); declaration != base.base_path.rend(); ++declaration) {
          if (!*declaration) {
            return access;
          }
          segments.push_back(PathSegment::Base(**declaration));
        }
        current = SkipLocatingWrappers(base.Base.get());
      } else if (current->GetKind() == NodeKind::SubscriptExpr) {
        const auto& subscript = static_cast<const SubscriptExpr&>(*current);
        segments.push_back(PathSegment::ArrayElement());
        current = SkipLocatingWrappers(subscript.Base.get());
      } else {
        const auto& cast = static_cast<const ImplicitCastExpr&>(*current);
        for (auto declaration = cast.base_path.rbegin(); declaration != cast.base_path.rend(); ++declaration) {
          if (!*declaration) {
            return access;
          }
          segments.push_back(PathSegment::Base(**declaration));
        }
        current = SkipLocatingWrappers(cast.SubExpr.get());
      }
    }
    std::reverse(segments.begin(), segments.end());

    if (current && current->GetKind() == NodeKind::DeclRefExpr) {
      const VarDecl* declaration = AsVariable(static_cast<const DeclRefExpr&>(*current).declaration);
      if (!declaration) {
        return access;
      }
      access.root = VariableRoot(*declaration);
      access.root_range = current->range;
    } else if (current && current->GetKind() == NodeKind::ThisExpr) {
      if (!tracks_this_) {
        return access;
      }
      access.root = ThisRoot();
      access.root_range = current->range;
    } else {
      return access;
    }

    // Expand inherited field access into the canonical path used by the flat layout.
    const ObjectLayout* layout = LayoutFor(access.root);
    if (!layout) {
      return access;
    }
    SubobjectPath path;
    QualType current_type = RootType(access.root);
    if (current_type && current_type.GetTypePtr()->GetKind() == TypeKind::Reference) {
      current_type = QualType(static_cast<const ReferenceType*>(current_type.GetTypePtr())->GetReferentType());
    }
    for (const PathSegment& segment : segments) {
      if (segment.kind == PathSegmentKind::ArrayElement) {
        if (!current_type || current_type.GetTypePtr()->GetKind() != TypeKind::Array) {
          return access;
        }
        path.push_back(segment);
        current_type = static_cast<const ArrayType*>(current_type.GetTypePtr())->GetElementType();
        continue;
      }
      const StructDecl* structure = AsStructDeclaration(current_type);
      if (!structure) {
        return access;
      }
      if (segment.kind == PathSegmentKind::Base) {
        if (!structure->base_type || structure->base_type->GetDeclaration() != segment.base) {
          return access;
        }
        path.push_back(segment);
        current_type = QualType(structure->base_type);
      } else {
        SubobjectPath suffix;
        std::unordered_set<const StructDecl*> visited;
        if (!FindFieldSuffix(*structure, *segment.field, suffix, visited)) {
          return access;
        }
        path.insert(path.end(), suffix.begin(), suffix.end());
        current_type = segment.field->type;
      }
    }
    if (const SubobjectRange* range = FindExactRange(*layout, path)) {
      access.begin = range->begin;
      access.end = range->end;
      access.exact = true;
      access.valid = true;
      return access;
    }
    // Atomic objects and arrays share one state for all of their descendant accesses.
    if (const SubobjectRange* range = FindAtomicPrefix(*layout, path)) {
      access.begin = range->begin;
      access.end = range->end;
      access.valid = true;
    }
    return access;
  }

  Access WholeObjectAccess(const VarDecl& declaration) const {
    Access access;
    access.root = VariableRoot(declaration);
    const ObjectLayout* layout = LayoutFor(access.root);
    if (!layout) {
      return access;
    }
    const SubobjectRange* range = FindExactRange(*layout, {});
    if (!range) {
      return access;
    }
    access.begin = range->begin;
    access.end = range->end;
    access.exact = true;
    access.valid = true;
    return access;
  }

  Access ThisWholeAccess() const {
    Access access;
    access.root = ThisRoot();
    const ObjectLayout* layout = LayoutFor(access.root);
    if (!layout) {
      return access;
    }
    const SubobjectRange* range = FindExactRange(*layout, {});
    if (!range) {
      return access;
    }
    access.begin = range->begin;
    access.end = range->end;
    access.exact = true;
    access.valid = true;
    return access;
  }

  void ComputeReachability() {
    std::deque<const CFGBlock*> pending;
    pending.push_back(&cfg_.GetEntry());
    reachable_[cfg_.GetEntry().GetID()] = true;
    while (!pending.empty()) {
      const CFGBlock& block = *pending.front();
      pending.pop_front();
      for (const CFGEdge* edge : block.Successors()) {
        const CFGBlock& target = edge->GetTarget();
        if (reachable_[target.GetID()]) {
          continue;
        }
        reachable_[target.GetID()] = true;
        pending.push_back(&target);
      }
    }
  }

  Environment MergePredecessors(const CFGBlock& block) const {
    struct LeafSummary {
      bool has_uninitialized{};
      bool has_initialized{};
      bool has_invalid{};
      std::vector<std::size_t> conflict_origins;
    };
    struct ObjectSummary {
      std::vector<LeafSummary> leaves;
    };

    // Summarize each leaf over reachable predecessors before deciding its merged state.
    std::unordered_map<TrackedRoot, ObjectSummary, TrackedRootHash> summaries;
    for (const CFGEdge* edge : block.Predecessors()) {
      const CFGBlock& predecessor = edge->GetSource();
      if (!reachable_[predecessor.GetID()]) {
        continue;
      }
      for (const auto& entry : outputs_[predecessor.GetID()]) {
        ObjectSummary& object = summaries[entry.first];
        object.leaves.resize(entry.second.leaves.size());
        for (std::size_t index = 0; index < entry.second.leaves.size(); ++index) {
          LeafSummary& summary = object.leaves[index];
          const AbstractState& state = entry.second.leaves[index];
          switch (state.state) {
            case InitializationState::Uninitialized:
              summary.has_uninitialized = true;
              break;
            case InitializationState::Initialized:
              summary.has_initialized = true;
              break;
            case InitializationState::Invalid:
              summary.has_invalid = true;
              summary.conflict_origins.insert(summary.conflict_origins.end(), state.conflict_origins.begin(),
                                              state.conflict_origins.end());
              break;
          }
        }
      }
    }

    Environment result;
    for (auto& entry : summaries) {
      ObjectState object;
      object.leaves.resize(entry.second.leaves.size());
      for (std::size_t index = 0; index < entry.second.leaves.size(); ++index) {
        LeafSummary& summary = entry.second.leaves[index];
        const bool new_conflict = summary.has_uninitialized && summary.has_initialized;
        if (!summary.has_invalid && !new_conflict) {
          object.leaves[index] = AbstractState{
              summary.has_initialized ? InitializationState::Initialized : InitializationState::Uninitialized, {}};
          continue;
        }
        // Preserve merge origins so a later use does not become a duplicate conflict location.
        if (new_conflict) {
          summary.conflict_origins.push_back(block.GetID());
        }
        std::sort(summary.conflict_origins.begin(), summary.conflict_origins.end());
        summary.conflict_origins.erase(std::unique(summary.conflict_origins.begin(), summary.conflict_origins.end()),
                                       summary.conflict_origins.end());
        object.leaves[index] = AbstractState{InitializationState::Invalid, std::move(summary.conflict_origins)};
      }
      result.emplace(entry.first, std::move(object));
    }
    return result;
  }

  void Solve() {
    bool changed;
    do {
      changed = false;
      for (const auto& block : cfg_.Blocks()) {
        if (!reachable_[block->GetID()]) {
          continue;
        }
        Environment input = block.get() == &cfg_.GetEntry() ? Environment{} : MergePredecessors(*block);
        Environment output = input;
        TransferBlock(*block, output, false);
        if (!EqualEnvironments(input, inputs_[block->GetID()])) {
          inputs_[block->GetID()] = std::move(input);
          changed = true;
        }
        if (!EqualEnvironments(output, outputs_[block->GetID()])) {
          outputs_[block->GetID()] = std::move(output);
          changed = true;
        }
      }
    } while (changed);
    BOOST_ASSERT(!function_ || outputs_[cfg_.GetExit().GetID()].empty());
  }

  void SeedThis(Environment& environment) const {
    if (!tracks_this_) {
      return;
    }
    environment[ThisRoot()] =
        MakeState(this_layout_.leaves.size(),
                  this_is_destructor_ ? InitializationState::Initialized : InitializationState::Uninitialized);
  }

  void TransferBlock(const CFGBlock& block, Environment& environment, bool collect) {
    if (&block == &cfg_.GetEntry()) {
      SeedThis(environment);
    }
    for (const auto& element : block.Elements()) {
      current_program_point_ = element->GetProgramPoint();
      current_intra_program_order_ = 0;
      switch (element->GetKind()) {
        case CFGElementKind::Expression:
          TransferExpressionElement(static_cast<const CFGExpressionElement&>(*element), environment, collect);
          break;
        case CFGElementKind::Declaration:
          TransferDeclaration(static_cast<const CFGDeclarationElement&>(*element), environment, collect);
          break;
        case CFGElementKind::ScopeExit:
          TransferScopeExit(static_cast<const CFGScopeExitElement&>(*element), environment);
          break;
        case CFGElementKind::ResultCheck:
          if (collect) {
            CollectResultCheck(static_cast<const CFGResultCheckElement&>(*element), environment);
          }
          TransferResultCheck(static_cast<const CFGResultCheckElement&>(*element), environment);
          break;
      }
    }
  }

  void TransferDeclaration(const CFGDeclarationElement& element, Environment& environment, bool collect) {
    const VarDecl& declaration = element.GetDeclaration();
    const ObjectLayout* layout = LayoutFor(VariableRoot(declaration));
    if (!layout) {
      return;
    }
    InitializationState state = InitializationState::Uninitialized;
    if (element.GetForm() == CFGDeclarationForm::DirectInitialization) {
      CheckInitializationOrder(declaration, declaration.name_range, WholeObjectAccess(declaration), environment,
                               collect);
    }
    switch (element.GetForm()) {
      case CFGDeclarationForm::Parameter:
      case CFGDeclarationForm::DirectInitialization:
        state = InitializationState::Initialized;
        break;
      case CFGDeclarationForm::ReturnObject:
      case CFGDeclarationForm::Uninitialized:
      case CFGDeclarationForm::InitializerBlockResult:
        break;
    }
    environment[VariableRoot(declaration)] = MakeState(layout->leaves.size(), state);
  }

  void TransferScopeExit(const CFGScopeExitElement& element, Environment& environment) {
    const Node& scope = element.GetScope();
    if (&scope == function_) {
      environment.clear();
      return;
    }
    const auto it = scope_declarations_.find(&scope);
    if (it == scope_declarations_.end()) {
      return;
    }
    for (const VarDecl* declaration : it->second) environment.erase(VariableRoot(*declaration));
  }

  void TransferExpressionElement(const CFGExpressionElement& element, Environment& environment, bool collect) {
    const Expr& expression = element.GetExpression();
    // Child regions already emitted as CFG events must not be evaluated a second time.
    std::unordered_set<const Expr*> excluded(element.ExcludedSubexpressions().begin(),
                                             element.ExcludedSubexpressions().end());
    switch (element.GetContext()) {
      case CFGExpressionContext::Ordinary:
        WalkExpression(expression, excluded, environment, collect);
        break;
      case CFGExpressionContext::InitializationTarget:
        WalkInitializationTarget(expression, excluded, environment, collect);
        break;
    }
  }

  bool IsExcluded(const Expr& expression, const std::unordered_set<const Expr*>& excluded) const {
    return excluded.find(&expression) != excluded.end();
  }

  void WalkChild(const std::unique_ptr<Expr>& child, const std::unordered_set<const Expr*>& excluded,
                 Environment& environment, bool collect) {
    if (child) {
      WalkExpression(*child, excluded, environment, collect);
    }
  }

  void WalkArguments(const std::vector<std::unique_ptr<Expr>>& arguments,
                     const std::unordered_set<const Expr*>& excluded, Environment& environment, bool collect) {
    if (AreArgumentsEvaluatedRightToLeft(abi_)) {
      for (auto argument = arguments.rbegin(); argument != arguments.rend(); ++argument) {
        WalkChild(*argument, excluded, environment, collect);
      }
    } else {
      for (const auto& argument : arguments) WalkChild(argument, excluded, environment, collect);
    }
  }

  void WalkOrderedAssignmentOperands(const Expr* lhs, const Expr* rhs, const std::unordered_set<const Expr*>& excluded,
                                     Environment& environment, bool collect) {
    if (rhs) {
      WalkExpression(*rhs, excluded, environment, collect);
    }
    if (lhs) {
      WalkExpression(*lhs, excluded, environment, collect);
    }
  }

  void WalkExpression(const Expr& expression, const std::unordered_set<const Expr*>& excluded, Environment& environment,
                      bool collect) {
    if (IsExcluded(expression, excluded)) {
      return;
    }
    // Assignment reads its operands in language order even when represented as an operator call.
    const Expr* assignment_lhs = nullptr;
    const Expr* assignment_rhs = nullptr;
    if (GetAssignmentOperands(expression, assignment_lhs, assignment_rhs)) {
      WalkOrderedAssignmentOperands(assignment_lhs, assignment_rhs, excluded, environment, collect);
      return;
    }

    switch (expression.GetKind()) {
      case NodeKind::DeclRefExpr:
      case NodeKind::ThisExpr:
        CheckRead(expression, environment, collect);
        return;
      case NodeKind::ParenExpr:
        WalkChild(static_cast<const ParenExpr&>(expression).SubExpr, excluded, environment, collect);
        return;
      case NodeKind::UnaryOperator:
        WalkChild(static_cast<const UnaryOperator&>(expression).Operand, excluded, environment, collect);
        return;
      case NodeKind::BinaryOperator: {
        const auto& binary = static_cast<const BinaryOperator&>(expression);
        WalkChild(binary.LHS, excluded, environment, collect);
        WalkChild(binary.RHS, excluded, environment, collect);
        return;
      }
      case NodeKind::InitializationExpr: {
        const auto& initialization = static_cast<const InitializationExpr&>(expression);
        WalkChild(initialization.Source, excluded, environment, collect);
        if (initialization.Target && !IsExcluded(*initialization.Target, excluded)) {
          const Expr* target = initialization.Target->IgnoreParens();
          const bool non_lvalue_conditional = target && target->GetKind() == NodeKind::ConditionalOperator &&
                                              target->value_category != ValueCategory::LValue;
          if (non_lvalue_conditional) {
            WalkExpression(*initialization.Target, excluded, environment, collect);
          } else {
            WalkInitializationTarget(*initialization.Target, excluded, environment, collect);
          }
        }
        if (valid_initializations_.find(&initialization) != valid_initializations_.end()) {
          ApplyInitialization(initialization, environment, collect);
        }
        return;
      }
      case NodeKind::ImplicitResultInitializationExpr: {
        const auto& initialization = static_cast<const ImplicitResultInitializationExpr&>(expression);
        WalkChild(initialization.Source, excluded, environment, collect);
        ApplyResultInitialization(initialization, environment, collect);
        return;
      }
      case NodeKind::ConditionalOperator: {
        const auto& conditional = static_cast<const ConditionalOperator&>(expression);
        WalkChild(conditional.Cond, excluded, environment, collect);
        WalkChild(conditional.Then, excluded, environment, collect);
        WalkChild(conditional.Else, excluded, environment, collect);
        return;
      }
      case NodeKind::MemberExpr: {
        const auto& member = static_cast<const MemberExpr&>(expression);
        if (member.Base) {
          if (member.op == expr::arrow) {
            WalkExpression(*member.Base, excluded, environment, collect);
          } else {
            WalkLocatingBase(*member.Base, excluded, environment, collect);
          }
        }
        CheckRead(expression, environment, collect);
        return;
      }
      case NodeKind::BaseSubobjectExpr: {
        const auto& base = static_cast<const BaseSubobjectExpr&>(expression);
        if (base.Base) {
          if (base.op == expr::arrow) {
            WalkExpression(*base.Base, excluded, environment, collect);
          } else {
            WalkLocatingBase(*base.Base, excluded, environment, collect);
          }
        }
        CheckRead(expression, environment, collect);
        return;
      }
      case NodeKind::SubscriptExpr: {
        const auto& subscript = static_cast<const SubscriptExpr&>(expression);
        WalkSubscriptLocation(subscript, excluded, environment, collect);
        CheckRead(expression, environment, collect);
        return;
      }
      case NodeKind::ArrayValueExpr: {
        const auto& array = static_cast<const ArrayValueExpr&>(expression);
        for (const auto& element : array.Elements) WalkChild(element, excluded, environment, collect);
        return;
      }
      case NodeKind::CallExpr:
      case NodeKind::OperatorCallExpr: {
        const auto& call = static_cast<const CallExpr&>(expression);
        WalkChild(call.Callee, excluded, environment, collect);
        WalkArguments(call.Args, excluded, environment, collect);
        return;
      }
      case NodeKind::ReceiverCallExpr: {
        const auto& call = static_cast<const ReceiverCallExpr&>(expression);
        // Arrow dereference is already explicit; evaluate the receiver only once.
        WalkChild(call.Callee, excluded, environment, collect);
        if (!AreArgumentsEvaluatedRightToLeft(abi_)) {
          WalkChild(call.Receiver, excluded, environment, collect);
        }
        WalkArguments(call.Args, excluded, environment, collect);
        if (AreArgumentsEvaluatedRightToLeft(abi_)) {
          WalkChild(call.Receiver, excluded, environment, collect);
        }
        return;
      }
      case NodeKind::ConstructionExpr: {
        const auto& construction = static_cast<const ConstructionExpr&>(expression);
        WalkChild(construction.TargetAddress, excluded, environment, collect);
        WalkArguments(construction.Args, excluded, environment, collect);
        return;
      }
      case NodeKind::ArrayConstructionExpr:
        WalkChild(static_cast<const ArrayConstructionExpr&>(expression).Source, excluded, environment, collect);
        return;
      case NodeKind::ArrayAssignmentExpr:
        BOOST_ASSERT(false && "array assignment is handled before expression dispatch");
        return;
      case NodeKind::DestructorCallExpr: {
        const auto& call = static_cast<const DestructorCallExpr&>(expression);
        WalkChild(call.TargetAddress, excluded, environment, collect);
        WalkChild(call.Callee, excluded, environment, collect);
        for (const auto& argument : call.Args) WalkChild(argument, excluded, environment, collect);
        return;
      }
      case NodeKind::ImplicitCastExpr: {
        const auto& cast = static_cast<const ImplicitCastExpr&>(expression);
        if (AsObjectDerivedToBaseCast(&cast)) {
          if (cast.SubExpr) {
            WalkLocatingBase(*cast.SubExpr, excluded, environment, collect);
          }
          CheckRead(cast, environment, collect);
        } else {
          WalkChild(cast.SubExpr, excluded, environment, collect);
        }
        return;
      }
      case NodeKind::MaterializeTemporaryExpr:
        WalkChild(static_cast<const MaterializeTemporaryExpr&>(expression).SubExpr, excluded, environment, collect);
        return;
      case NodeKind::ImplicitOverloadSetSelectionExpr:
        // The selected function address is already a complete value.  Its
        // retained source subtree does not read a runtime object.
        return;
      default:
        return;
    }
  }

  void WalkLocatingBase(const Expr& expression, const std::unordered_set<const Expr*>& excluded,
                        Environment& environment, bool collect) {
    if (IsExcluded(expression, excluded)) {
      return;
    }
    switch (expression.GetKind()) {
      case NodeKind::DeclRefExpr:
      case NodeKind::ThisExpr:
        return;
      case NodeKind::ParenExpr: {
        const auto& parentheses = static_cast<const ParenExpr&>(expression);
        if (parentheses.SubExpr) {
          WalkLocatingBase(*parentheses.SubExpr, excluded, environment, collect);
        }
        return;
      }
      case NodeKind::MemberExpr: {
        const auto& member = static_cast<const MemberExpr&>(expression);
        if (!member.Base) {
          return;
        }
        if (member.op == expr::arrow) {
          WalkExpression(*member.Base, excluded, environment, collect);
        } else {
          WalkLocatingBase(*member.Base, excluded, environment, collect);
        }
        return;
      }
      case NodeKind::BaseSubobjectExpr: {
        const auto& base = static_cast<const BaseSubobjectExpr&>(expression);
        if (!base.Base) {
          return;
        }
        if (base.op == expr::arrow) {
          WalkExpression(*base.Base, excluded, environment, collect);
        } else {
          WalkLocatingBase(*base.Base, excluded, environment, collect);
        }
        return;
      }
      case NodeKind::SubscriptExpr:
        WalkSubscriptLocation(static_cast<const SubscriptExpr&>(expression), excluded, environment, collect);
        return;
      case NodeKind::ImplicitCastExpr: {
        const auto& cast = static_cast<const ImplicitCastExpr&>(expression);
        if (cast.SubExpr) {
          WalkLocatingBase(*cast.SubExpr, excluded, environment, collect);
        }
        return;
      }
      case NodeKind::MaterializeTemporaryExpr: {
        const auto& materialization = static_cast<const MaterializeTemporaryExpr&>(expression);
        if (materialization.SubExpr) {
          WalkLocatingBase(*materialization.SubExpr, excluded, environment, collect);
        }
        return;
      }
      default:
        WalkExpression(expression, excluded, environment, collect);
        return;
    }
  }

  void WalkInitializationTarget(const Expr& expression, const std::unordered_set<const Expr*>& excluded,
                                Environment& environment, bool collect) {
    if (IsExcluded(expression, excluded)) {
      return;
    }
    switch (expression.GetKind()) {
      case NodeKind::DeclRefExpr:
      case NodeKind::ThisExpr:
        return;
      case NodeKind::ParenExpr: {
        const auto& parentheses = static_cast<const ParenExpr&>(expression);
        if (parentheses.SubExpr) {
          WalkInitializationTarget(*parentheses.SubExpr, excluded, environment, collect);
        }
        return;
      }
      case NodeKind::MemberExpr: {
        const auto& member = static_cast<const MemberExpr&>(expression);
        if (member.Base) {
          if (member.op == expr::arrow) {
            WalkExpression(*member.Base, excluded, environment, collect);
          } else {
            WalkLocatingBase(*member.Base, excluded, environment, collect);
          }
        }
        return;
      }
      case NodeKind::BaseSubobjectExpr: {
        const auto& base = static_cast<const BaseSubobjectExpr&>(expression);
        if (base.Base) {
          if (base.op == expr::arrow) {
            WalkExpression(*base.Base, excluded, environment, collect);
          } else {
            WalkLocatingBase(*base.Base, excluded, environment, collect);
          }
        }
        return;
      }
      case NodeKind::ConditionalOperator: {
        const auto& conditional = static_cast<const ConditionalOperator&>(expression);
        WalkChild(conditional.Cond, excluded, environment, collect);
        if (conditional.Then && !IsExcluded(*conditional.Then, excluded)) {
          WalkInitializationTarget(*conditional.Then, excluded, environment, collect);
        }
        if (conditional.Else && !IsExcluded(*conditional.Else, excluded)) {
          WalkInitializationTarget(*conditional.Else, excluded, environment, collect);
        }
        return;
      }
      case NodeKind::SubscriptExpr: {
        const auto& subscript = static_cast<const SubscriptExpr&>(expression);
        WalkSubscriptLocation(subscript, excluded, environment, collect);
        return;
      }
      case NodeKind::UnaryOperator:
        WalkChild(static_cast<const UnaryOperator&>(expression).Operand, excluded, environment, collect);
        return;
      case NodeKind::ImplicitCastExpr: {
        const auto& cast = static_cast<const ImplicitCastExpr&>(expression);
        if (cast.SubExpr) {
          WalkInitializationTarget(*cast.SubExpr, excluded, environment, collect);
        }
        return;
      }
      case NodeKind::MaterializeTemporaryExpr: {
        const auto& materialization = static_cast<const MaterializeTemporaryExpr&>(expression);
        if (materialization.SubExpr) {
          WalkInitializationTarget(*materialization.SubExpr, excluded, environment, collect);
        }
        return;
      }
      default:
        WalkExpression(expression, excluded, environment, collect);
        return;
    }
  }

  void WalkSubscriptLocation(const SubscriptExpr& expression, const std::unordered_set<const Expr*>& excluded,
                             Environment& environment, bool collect) {
    if (expression.Base && !IsExcluded(*expression.Base, excluded)) {
      WalkLocatingBase(*expression.Base, excluded, environment, collect);
    }
    WalkChild(expression.Index, excluded, environment, collect);
  }

  void CheckRead(const Expr& expression, const Environment& environment, bool collect) {
    if (!collect) {
      return;
    }
    const Access access = ResolveAccess(&expression);
    if (!access.valid) {
      return;
    }
    const auto it = environment.find(access.root);
    if (it == environment.end() ||
        !RangeHasState(it->second, access.begin, access.end, InitializationState::Uninitialized)) {
      return;
    }
    AddFinding(DefiniteInitializationFindingKind::UninitializedRead, expression,
               access.root_range.IsValid() ? access.root_range : expression.range, access.root);
  }

  void ApplyInitialization(const InitializationExpr& expression, Environment& environment, bool collect) {
    if (!expression.Target || expression.Target->ContainsErrors()) {
      return;
    }
    const Access access = ResolveAccess(expression.Target.get());
    // A descendant of an atomic non-trivial leaf resolves for reads, but is not
    // an independently initializable subobject.
    if (!access.valid || !access.exact) {
      return;
    }
    // An empty current object is already complete by empty conjunction. A
    // `this := ...` statement is a delegation control operation, not a
    // repeated initialization of an empty range, even when its source failed.
    if (access.begin == access.end && expression.Target->GetKind() == NodeKind::ThisExpr) {
      return;
    }
    ApplyInitialization(expression, expression.Target->range, access, environment, collect);
  }

  void ApplyResultInitialization(const ImplicitResultInitializationExpr& expression, Environment& environment,
                                 bool collect) {
    if (!expression.Target) {
      return;
    }
    ApplyInitialization(expression, expression.range, WholeObjectAccess(*expression.Target), environment, collect);
  }

  void ApplyInitialization(const Node& owner, SourceRange range, const Access& access, Environment& environment,
                           bool collect) {
    if (!access.valid) {
      return;
    }
    const auto it = environment.find(access.root);
    if (it == environment.end()) {
      return;
    }
    ObjectState& object = it->second;
    if (RangeHasState(object, access.begin, access.end, InitializationState::Invalid)) {
      return;
    }
    if (!RangeIsEntirely(object, access.begin, access.end, InitializationState::Uninitialized)) {
      if (collect) {
        AddFinding(DefiniteInitializationFindingKind::RepeatedInitialization, owner, range, access.root);
      }
      return;
    }
    CheckInitializationOrder(owner, range, access, environment, collect);
    for (std::size_t index = access.begin; index < access.end; ++index) {
      object.leaves[index] = AbstractState{InitializationState::Initialized, {}};
    }
  }

  void CheckInitializationOrder(const Node& owner, SourceRange range, const Access& access,
                                const Environment& environment, bool collect) {
    if (!collect || !access.valid || owner.ContainsErrors()) {
      return;
    }
    if (const VarDecl* variable = access.root.variable) {
      if (!variable->type || variable->type.GetTypePtr()->GetKind() == TypeKind::Reference) {
        return;
      }
      const auto scope = declaration_scopes_.find(variable);
      if (scope != declaration_scopes_.end()) {
        for (const VarDecl* preceding : scope_declarations_.at(scope->second)) {
          if (preceding == variable) {
            break;
          }
          if (!preceding->type || preceding->type.GetTypePtr()->GetKind() == TypeKind::Reference) {
            continue;
          }
          const auto previous = environment.find(VariableRoot(*preceding));
          if (previous != environment.end() &&
              RangeHasState(previous->second, 0, previous->second.leaves.size(), InitializationState::Uninitialized)) {
            AddFinding(DefiniteInitializationFindingKind::OutOfOrderInitialization, owner, range,
                       VariableRoot(*preceding));
            return;
          }
        }
      }
    }
    // Within an object, flat-layout order places the base before fields and nested subobjects.
    const auto object = environment.find(access.root);
    if (object != environment.end() &&
        RangeHasState(object->second, 0, access.begin, InitializationState::Uninitialized)) {
      AddFinding(DefiniteInitializationFindingKind::OutOfOrderSubobjectInitialization, owner, range, access.root);
    }
  }

  void CollectResultCheck(const CFGResultCheckElement& element, const Environment& environment) {
    const Node& owner = element.GetResultOwner();
    if (HasInvalidTailMapping(element)) {
      return;
    }
    if (owner.GetKind() == NodeKind::FunctionDecl || owner.GetKind() == NodeKind::ConstructorDecl ||
        owner.GetKind() == NodeKind::DestructorDecl || owner.GetKind() == NodeKind::VirtualFunctionDecl) {
      if (owner.GetKind() == NodeKind::ConstructorDecl && tracks_this_ && !this_is_destructor_) {
        CheckResult(element.GetExitLocation(), ThisWholeAccess(), environment);
      }
      const auto& function = static_cast<const FunctionDecl&>(owner);
      if (function.ReturnVar && function.ReturnVar->Type && !function.ReturnVar->Type->ContainsErrors()) {
        CheckResult(element.GetExitLocation(), WholeObjectAccess(*function.ReturnVar), environment);
      }
      return;
    }
    if (owner.GetKind() != NodeKind::VarGroupDecl) {
      return;
    }
    const auto& group = static_cast<const VarGroupDecl&>(owner);
    for (const auto& variable : group.Vars) {
      if (variable && variable->Type && !variable->Type->ContainsErrors()) {
        CheckResult(element.GetExitLocation(), WholeObjectAccess(*variable), environment);
      }
    }
  }

  bool HasInvalidTailMapping(const CFGResultCheckElement& element) const {
    const Node& owner = element.GetResultOwner();
    if (owner.GetKind() == NodeKind::ConstructorDecl || owner.GetKind() == NodeKind::DestructorDecl) {
      return false;
    }
    const Node& location = element.GetExitLocation();
    if (location.GetKind() != NodeKind::CompoundStmt) {
      return false;
    }
    const auto& compound = static_cast<const CompoundStmt&>(location);
    if (compound.TailExprs.empty()) {
      return false;
    }
    if (owner.GetKind() == NodeKind::VarGroupDecl) {
      return compound.TailExprs.size() != static_cast<const VarGroupDecl&>(owner).Vars.size();
    }
    if (owner.GetKind() == NodeKind::FunctionDecl || owner.GetKind() == NodeKind::VirtualFunctionDecl) {
      return compound.TailExprs.size() != 1;
    }
    return false;
  }

  void PoisonUninitialized(const Access& access, Environment& environment) {
    if (!access.valid) {
      return;
    }
    const auto it = environment.find(access.root);
    if (it == environment.end()) {
      return;
    }
    const std::size_t last = std::min(access.end, it->second.leaves.size());
    for (std::size_t index = access.begin; index < last; ++index) {
      if (it->second.leaves[index].state == InitializationState::Uninitialized) {
        it->second.leaves[index] = AbstractState{InitializationState::Invalid, {}};
      }
    }
  }

  void TransferResultCheck(const CFGResultCheckElement& element, Environment& environment) {
    const Node& owner = element.GetResultOwner();
    if (owner.GetKind() == NodeKind::FunctionDecl || owner.GetKind() == NodeKind::ConstructorDecl ||
        owner.GetKind() == NodeKind::DestructorDecl || owner.GetKind() == NodeKind::VirtualFunctionDecl) {
      if (owner.GetKind() == NodeKind::ConstructorDecl && tracks_this_ && !this_is_destructor_) {
        PoisonUninitialized(ThisWholeAccess(), environment);
      }
      const auto& function = static_cast<const FunctionDecl&>(owner);
      if (function.ReturnVar) {
        PoisonUninitialized(WholeObjectAccess(*function.ReturnVar), environment);
      }
      return;
    }
    if (owner.GetKind() != NodeKind::VarGroupDecl) {
      return;
    }
    const auto& group = static_cast<const VarGroupDecl&>(owner);
    for (const auto& variable : group.Vars) {
      if (variable) {
        PoisonUninitialized(WholeObjectAccess(*variable), environment);
      }
    }
  }

  void CheckResult(const Node& exit_location, const Access& access, const Environment& environment) {
    if (!access.valid) {
      return;
    }
    const auto it = environment.find(access.root);
    if (it == environment.end() ||
        !RangeHasState(it->second, access.begin, access.end, InitializationState::Uninitialized)) {
      return;
    }
    AddFinding(DefiniteInitializationFindingKind::UninitializedResult, exit_location,
               PreferredRange(exit_location, access.root), access.root);
  }

  const Node& BlockLocation(const CFGBlock& block) const {
    if (block.GetAnchor()) {
      return *block.GetAnchor();
    }
    for (const auto& element : block.Elements()) {
      switch (element->GetKind()) {
        case CFGElementKind::Expression:
          return static_cast<const CFGExpressionElement&>(*element).GetExpression();
        case CFGElementKind::Declaration:
          return static_cast<const CFGDeclarationElement&>(*element).GetDeclaration();
        case CFGElementKind::ScopeExit:
          return static_cast<const CFGScopeExitElement&>(*element).GetScope();
        case CFGElementKind::ResultCheck:
          return static_cast<const CFGResultCheckElement&>(*element).GetExitLocation();
      }
    }
    if (block.GetTerminator()) {
      return *block.GetTerminator();
    }
    return owner_;
  }

  void CollectMergeFindings(const CFGBlock& block) {
    const Node& location = BlockLocation(block);
    for (const auto& entry : inputs_[block.GetID()]) {
      bool report = false;
      for (const AbstractState& leaf : entry.second.leaves) {
        if (leaf.state == InitializationState::Invalid &&
            std::binary_search(leaf.conflict_origins.begin(), leaf.conflict_origins.end(), block.GetID())) {
          report = true;
          break;
        }
      }
      if (report) {
        AddFinding(DefiniteInitializationFindingKind::ConflictingStates, location,
                   PreferredRange(location, entry.first), entry.first, false, BlockProgramPoint(block));
      }
    }
  }

  void CollectFindings() {
    for (const auto& block : cfg_.Blocks()) {
      if (!reachable_[block->GetID()]) {
        continue;
      }
      if (block.get() != &cfg_.GetEntry()) {
        CollectMergeFindings(*block);
      }
      Environment environment = inputs_[block->GetID()];
      TransferBlock(*block, environment, true);
    }
    std::stable_sort(findings_.begin(), findings_.end(), FindingPrecedes);
  }

  std::size_t BlockProgramPoint(const CFGBlock& block) const {
    if (block.GetAnchor()) {
      return block.GetAnchorProgramPoint();
    }
    if (!block.Elements().empty()) {
      return block.Elements().front()->GetProgramPoint();
    }
    if (block.GetTerminator()) {
      return block.GetTerminatorProgramPoint();
    }
    return std::numeric_limits<std::size_t>::max();
  }

  void AddFinding(DefiniteInitializationFindingKind kind, const Node& owner, SourceRange range, TrackedRoot root,
                  bool deduplicate = true, std::size_t program_point = 0) {
    if (!range.IsValid()) {
      range = PreferredRange(owner, root);
    }
    std::size_t intra_program_order = 0;
    if (program_point == 0) {
      program_point = current_program_point_;
      intra_program_order = current_intra_program_order_++;
    }
    DefiniteInitializationFinding finding{
        kind, &owner, range, root.variable, root.this_owner, program_point, intra_program_order};
    if (deduplicate) {
      const FindingKey key{kind, &owner, root};
      const auto existing = finding_indices_.find(key);
      if (existing != finding_indices_.end()) {
        if (FindingPrecedes(finding, findings_[existing->second])) {
          findings_[existing->second] = finding;
        }
        return;
      }
      finding_indices_.emplace(key, findings_.size());
    }
    findings_.push_back(finding);
  }
};

}  // namespace

std::vector<DefiniteInitializationFinding> DefiniteInitializationAnalysis::Run(const FunctionDecl& function,
                                                                               const CFG& cfg, ABIKind abi) {
  return AnalysisEngine(function, cfg, abi).Run();
}

std::vector<DefiniteInitializationFinding> DefiniteInitializationAnalysis::Run(
    const TranslationUnitDecl& translation_unit, const CFG& cfg, ABIKind abi) {
  return AnalysisEngine(translation_unit, cfg, abi).Run();
}

}  // namespace cw
