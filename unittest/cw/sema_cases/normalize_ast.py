#!/usr/bin/env python3
"""Normalize unstable addresses and source paths in a Clang AST dump."""

import argparse
import collections
import os
import re
from pathlib import Path


ADDRESS_PATTERN = re.compile(r"\b0x[0-9a-fA-F]+\b")
TRANSLATION_UNIT_PREFIX = "TranslationUnitDecl "
DIRECT_CHILD_PREFIXES = ("|-", "`-")


def normalize_addresses(text: str) -> str:
    address_counts = collections.Counter(
        match.group(0).lower() for match in ADDRESS_PATTERN.finditer(text)
    )
    repeated_addresses: dict[str, str] = {}

    def replace_address(match: re.Match[str]) -> str:
        address = match.group(0).lower()
        if address_counts[address] == 1:
            return "{{address}}"
        if address not in repeated_addresses:
            repeated_addresses[address] = (
                f"{{{{address:{len(repeated_addresses) + 1}}}}}"
            )
        return repeated_addresses[address]

    return ADDRESS_PATTERN.sub(replace_address, text)


def normalize_source_path(text: str, raw_ast_path: Path) -> str:
    source_path = raw_ast_path.with_suffix("")
    stable_path = source_path.name
    candidates = {
        str(source_path),
        source_path.as_posix(),
        str(source_path.resolve()),
        source_path.resolve().as_posix(),
    }
    for candidate in sorted(candidates, key=len, reverse=True):
        text = text.replace(candidate, stable_path)
    return text


def remove_top_level_builtin_declarations(text: str) -> str:
    lines = text.splitlines(keepends=True)
    if not lines or not lines[0].startswith(TRANSLATION_UNIT_PREFIX):
        return text

    root_lines: list[str] = []
    child_subtrees: list[list[str]] = []
    current_subtree = None

    for line in lines:
        if line.startswith(DIRECT_CHILD_PREFIXES):
            current_subtree = [line]
            child_subtrees.append(current_subtree)
        elif current_subtree is None:
            root_lines.append(line)
        else:
            current_subtree.append(line)

    retained_subtrees = [
        subtree for subtree in child_subtrees if "<invalid sloc>" not in subtree[0]
    ]

    for index, subtree in enumerate(retained_subtrees):
        is_last = index == len(retained_subtrees) - 1
        ancestor_prefix = "  " if is_last else "| "
        subtree[0] = ("`-" if is_last else "|-") + subtree[0][2:]
        for line_index in range(1, len(subtree)):
            line = subtree[line_index]
            if line.startswith(("| ", "  ")):
                subtree[line_index] = ancestor_prefix + line[2:]

    return "".join(root_lines + [line for subtree in retained_subtrees for line in subtree])


def normalize(input_path: Path, output_path: Path) -> None:
    text = input_path.read_text(encoding="utf-8")
    text = remove_top_level_builtin_declarations(text)
    text = normalize_source_path(text, input_path)
    text = normalize_addresses(text)

    temporary_path = output_path.with_name(f".{output_path.name}.tmp")
    try:
        temporary_path.write_text(text, encoding="utf-8")
        os.replace(temporary_path, output_path)
    finally:
        temporary_path.unlink(missing_ok=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="raw .ast input")
    parser.add_argument("output", type=Path, help="normalized .ast.txt output")
    arguments = parser.parse_args()
    normalize(arguments.input, arguments.output)


if __name__ == "__main__":
    main()
