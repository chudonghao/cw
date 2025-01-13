
#include "Grammar.h"

namespace cw::lang {

enum Symbol : int {
  Start = 0,
  Empty = 1,
};

static ProductionVec<Symbol> CWProductions() {
  // TODO
  ProductionVec<Symbol> ps;
  return ps;
}

struct CWLanguage {
  static ProductionVec<Symbol> &Productions();
};

}  // namespace cw::lang
