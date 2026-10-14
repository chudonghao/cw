/// \file DriverOptions.cpp
/// \copyright 2026 Donghao Chu
/// \license SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
/// \url https://github.com/chudonghao/cw

#include "DriverOptions.h"

#include <cstddef>
#include <string>

#include <llvm/ADT/ArrayRef.h>
#include <llvm/Option/Arg.h>
#include <llvm/Option/ArgList.h>
#include <llvm/Option/OptTable.h>
#include <llvm/Option/Option.h>
#include <llvm/Support/raw_ostream.h>

#include "cw/Diagnostic.h"

namespace cw::driver {
namespace options {

enum ID {
  OPT_INVALID = 0,
#define OPTION(...) LLVM_MAKE_OPT_ID(__VA_ARGS__),
#include "CWCOptions.inc"
#undef OPTION
  LastOption
};

}  // namespace options

namespace {

using namespace llvm::opt;
using namespace options;

#define OPTTABLE_STR_TABLE_CODE
#include "CWCOptions.inc"
#undef OPTTABLE_STR_TABLE_CODE

#define OPTTABLE_PREFIXES_TABLE_CODE
#include "CWCOptions.inc"
#undef OPTTABLE_PREFIXES_TABLE_CODE

#define OPTTABLE_PREFIXES_UNION_CODE
#include "CWCOptions.inc"
#undef OPTTABLE_PREFIXES_UNION_CODE

static constexpr OptTable::Info InfoTable[] = {
#define OPTION(...) LLVM_CONSTRUCT_OPT_INFO(__VA_ARGS__),
#include "CWCOptions.inc"
#undef OPTION
};

class DriverOptTable final : public PrecomputedOptTable {
 public:
  DriverOptTable()
      : PrecomputedOptTable(OptionStrTable, OptionPrefixesTable, InfoTable, OptionPrefixesUnion) {
    setDashDashParsing(true);
  }
};

const OptTable& GetOptionTable() {
  static const DriverOptTable table;
  return table;
}

bool Is(const Arg& argument, OptSpecifier option) { return argument.getOption().matches(option); }

std::string ArgumentSpelling(const Arg& argument, const InputArgList& arguments) {
  return argument.getAsString(arguments);
}

}  // namespace

std::optional<DriverConfig> DriverOptions::Parse(int argc, char* const argv[], DiagnosticEngine& diagnostics) {
  if (argc < 1) {
    diagnostics.Add(kErrorDiagnostic, "cannot parse an empty argument vector");
    return std::nullopt;
  }

  const OptTable& table = GetOptionTable();
  const llvm::ArrayRef<const char*> arguments(argv + 1, static_cast<std::size_t>(argc - 1));
  unsigned missing_index = 0;
  unsigned missing_count = 0;
  auto parsed = table.ParseArgs(arguments, missing_index, missing_count);

  if (missing_count != 0) {
    diagnostics.Add(kErrorDiagnostic,
                    "option '" + std::string(parsed.getArgString(missing_index)) + "' requires an argument");
  }
  for (const Arg* argument : parsed.filtered(OPT_UNKNOWN)) {
    diagnostics.Add(kErrorDiagnostic, "unknown argument '" + ArgumentSpelling(*argument, parsed) + "'");
  }
  if (diagnostics.HasErrors()) {
    return std::nullopt;
  }

  DriverConfig config;
  for (const Arg* argument : parsed) {
    const auto& option = argument->getOption();
    if (option.matches(OPT_INPUT)) {
      config.items.push_back({DriverItem::Kind::Input, argument->getValue()});
    } else if (Is(*argument, OPT_help)) {
      config.help = true;
    } else if (Is(*argument, OPT_target)) {
      config.target = argument->getValue();
    } else if (Is(*argument, OPT_c)) {
      config.compile_only = true;
    } else if (Is(*argument, OPT_S)) {
      config.assemble = true;
    } else if (Is(*argument, OPT_emit_llvm)) {
      config.emit_llvm = true;
    } else if (Is(*argument, OPT_o)) {
      config.output = argument->getValue();
    } else if (Is(*argument, OPT_L)) {
      config.items.push_back({DriverItem::Kind::LibraryPath, argument->getValue()});
    } else if (Is(*argument, OPT_l)) {
      config.items.push_back({DriverItem::Kind::Library, argument->getValue()});
    } else if (Is(*argument, OPT_isysroot)) {
      config.sysroot = argument->getValue();
    } else if (Is(*argument, OPT_mmacos_version_min_EQ)) {
      config.minimum_macos_version = argument->getValue();
    } else if (Is(*argument, OPT_Wl_COMMA)) {
      ArgStringList linker_values;
      argument->renderAsInput(parsed, linker_values);
      for (const char* value : linker_values) {
        config.items.push_back({DriverItem::Kind::LinkerOption, value});
      }
    } else if (Is(*argument, OPT_Xlinker)) {
      ArgStringList linker_values;
      argument->renderAsInput(parsed, linker_values);
      for (const char* value : linker_values) {
        config.items.push_back({DriverItem::Kind::LinkerOption, value});
      }
    } else {
      diagnostics.Add(kErrorDiagnostic,
                      "unsupported command-line option '" + ArgumentSpelling(*argument, parsed) + "'");
      return std::nullopt;
    }
  }
  return config;
}

void DriverOptions::PrintHelp(llvm::raw_ostream& output) {
  GetOptionTable().printHelp(output,
                             "cwc [options] [file ...] [-L dir] [-l name] [-o a.out]",
                             "CW language compiler");
  output << "Usage: cwc [--target=triple] [file ...] [-L dir] [-l name] [-o a.out]\n"
            "       cwc -c file.cw [-o file.o]\n"
            "       cwc -S -emit-llvm file.cw [-o file.ll]\n"
            "Native linking accepts CW sources (or -), .cwi interfaces, .o/.a/.dylib inputs and -l libraries.\n"
            "Sources and interfaces form one module; native linking also works without source inputs.\n"
            "Wasm linking accepts CW sources only; use -Wl, or -Xlinker for wasm-ld options.\n"
            "With -c or -S, multiple sources form one module and require -o.\n"
            "With -c, a companion .cwi is written beside the object; -o - is not supported.\n";
}

}  // namespace cw::driver
