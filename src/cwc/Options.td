//===--- Options.td - cwc command-line options ---------------------------===//
//
// Part of the cw project, under the Apache License v2.0 with LLVM Exceptions.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

include "llvm/Option/OptParser.td"

def LinkerInput : OptionFlag;

def help : Flag<["-", "--"], "help">,
  HelpText<"Display help information">;

def target : Joined<["--"], "target=">,
  MetaVarName<"<triple>">,
  HelpText<"Select the target triple (macOS arm64 or wasm32-unknown-unknown)">;
def target_legacy : Separate<["-"], "target">, Alias<target>;

def c : Flag<["-"], "c">,
  HelpText<"Compile to an object file and a companion .cwi interface">;
def S : Flag<["-"], "S">,
  HelpText<"Stop before assembly (requires -emit-llvm)">;
def emit_llvm : Flag<["-"], "emit-llvm">,
  HelpText<"Emit LLVM IR (requires -S)">;

def o : JoinedOrSeparate<["-"], "o">,
  MetaVarName<"<file>">,
  HelpText<"Write output to <file>; - writes LLVM IR to standard output">;
def output_EQ : Joined<["--"], "output=">, Alias<o>;
def output : Separate<["--"], "output">, Alias<o>;

def L : JoinedOrSeparate<["-"], "L">,
  Flags<[LinkerInput]>,
  MetaVarName<"<dir>">,
  HelpText<"Add a library search path">;
def library_directory_EQ : Joined<["--"], "library-directory=">, Alias<L>;
def library_directory : Separate<["--"], "library-directory">, Alias<L>;

def l : JoinedOrSeparate<["-"], "l">,
  Flags<[LinkerInput]>,
  MetaVarName<"<name>">,
  HelpText<"Link a library by name">;

def isysroot : JoinedOrSeparate<["-"], "isysroot">,
  MetaVarName<"<dir>">,
  HelpText<"Use the specified macOS SDK directory">;

def mmacos_version_min_EQ : Joined<["-"], "mmacos-version-min=">,
  MetaVarName<"<version>">,
  HelpText<"Set the minimum macOS deployment version">;
def mmacosx_version_min_EQ : Joined<["-"], "mmacosx-version-min=">,
  Alias<mmacos_version_min_EQ>;

def Wl_COMMA : CommaJoined<["-"], "Wl,">,
  Flags<[LinkerInput, RenderAsInput]>,
  HelpText<"Pass comma-separated options to the linker">;
def Xlinker : Separate<["-"], "Xlinker">,
  Flags<[LinkerInput, RenderAsInput]>,
  MetaVarName<"<arg>">,
  HelpText<"Pass one argument to the linker">;
