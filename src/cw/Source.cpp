#include "Source.h"

namespace cw {

std::string_view LineSource(const Source &source, int pos) {
  const auto &content = source.content;
  const char *begin = content.data();
  const char *end = begin + content.size();
  if (begin == end) return {};

  if (pos < 0) pos = 0;
  if (pos > static_cast<int>(content.size())) pos = static_cast<int>(content.size());
  const char *cur = begin + pos;

  const char *line_begin = cur;
  while (line_begin > begin && *(line_begin - 1) != '\n') {
    --line_begin;
  }

  const char *line_end = cur;
  while (line_end < end && *line_end != '\n') {
    ++line_end;
  }

  return std::string_view(line_begin, static_cast<size_t>(line_end - line_begin));
}

}  // namespace cw
