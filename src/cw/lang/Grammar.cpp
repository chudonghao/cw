/// \file Grammar.cpp
/// \author Donghao Chu
/// \date 2025-01-10
/// \copyright 2025 Donghao Chu
/// \license Apache License, Version 2.0
/// \url https://github.com/chudonghao/cw

#include "Grammar.h"

#include <iostream>

namespace cw::lang {

void Grammar::Dump(std::ostream &os) const {
  // 输出文法
  os << "G: " << std::endl;
  os << "  S: " << SymbolName(S_) << "(" << S_ << ")" << std::endl;
  os << "  ε: " << SymbolName(ε_) << "(" << ε_ << ")" << std::endl;
  os << "  $: " << SymbolName($_) << "(" << $_ << ")" << std::endl;
  os << "  V_T: ";
  for (const auto &s : V_T_) {
    os << SymbolName(s) << "(" << s << ") ";
  }
  os << std::endl;

  os << "  V_N: ";
  for (const auto &s : V_N_) {
    os << SymbolName(s) << "(" << s << ") ";
  }
  os << std::endl;

  os << "  P: " << std::endl;
  for (int pi = 0; pi < P_.size(); ++pi) {
    os << "    " << SymbolName(P_[pi].l) << " -> ";
    for (const auto &s : P_[pi].r) {
      os << SymbolName(s) << " ";
    }
    os << "(" << pi << ")" << std::endl;
  }
}

void Grammar::DumpProduction(std::ostream &os, int pi) const {
  auto &p = P_[pi];
  os << SymbolName(p.l) << " ->";
  for (int i = 0; i < p.r.size(); ++i) {
    os << " " << SymbolName(p.r[i]);
  }
}

}  // namespace cw::lang