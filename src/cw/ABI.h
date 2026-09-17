/// \file ABI.h
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: LGPL-3.0-only
/// \url https://github.com/chudonghao/cw

#pragma once

namespace cw {

/// ABI selection shared by semantic analysis and downstream consumers.
enum class ABIKind { Itanium, Microsoft };

constexpr bool AreParametersDestroyedInCallee(ABIKind abi) { return abi == ABIKind::Microsoft; }

/// CW chooses left-to-right argument evaluation for its Itanium configuration.
constexpr bool AreArgumentsEvaluatedRightToLeft(ABIKind abi) { return abi == ABIKind::Microsoft; }

}  // namespace cw
