#!/usr/bin/env bash
set -euo pipefail


print_invalid_option_msg() {
echo -e "*** Invalid option(s) and/or parameter(s) detected ***\n" >&2
}

print_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Compresses all .pdf files in the script’s directory into
a fresh ./compressed_files/ folder and emits a log.

Options:
  -p, --preset PRE         PDFSETTINGS preset. One of:
                           screen, ebook, printer, prepress, default
  -c, --color COL          Color strategy: Gray or LeaveColorUnchanged
      --gray               Shortcut for --color=Gray
  -i, --filter-image       Add -dFILTERIMAGE
  -t, --filter-text        Add -dFILTERTEXT
  -v, --filter-vector      Add -dFILTERVECTOR
  -h, --help               Show this help and exit

Examples:
  # screen preset + gray + image filter
  $0 --preset=screen --gray --filter-image

  # ebook preset, keep colors, text+vector filters
  $0 -p ebook -i -v

  # default preset + LeaveColorUnchanged
  $0

  # "--gray" takes precedent over "-c LeaveColorUnchanged" where both are supplied
  (The following three items are equivalent)
  $0 -c LeaveColorUnchanged --gray
  $0 -c Gray
  $0 --gray
EOF
  exit 0
}

# ─── Defaults ──────────────────────────────────────────────────────────────
preset="/default"
color="LeaveColorUnchanged"
filters=()

# ─── getopt Setup ──────────────────────────────────────────────────────────
LONG_OPTS="preset:,color:,gray,filter-image,filter-text,filter-vector,help"
SHORT_OPTS="p:c:itvh"

if ! parsed=$(getopt -o "$SHORT_OPTS" -l "$LONG_OPTS" -n "$(basename "$0")" -- "$@"); then
  print_invalid_option
  print_help
fi
eval set -- "$parsed"

# ─── Parse flags ───────────────────────────────────────────────────────────
while true; do
  case "$1" in
    -p|--preset)
      case "${2#/}" in
        screen|ebook|printer|prepress|default)
          preset="/${2#/}" ;;
        *)
          print_invalid_option_msg
          print_help
          ;;
      esac
      shift 2
      ;;
    -c|--color)
      case "$2" in
        Gray|LeaveColorUnchanged)
          color="$2" ;;
        *)
          print_invalid_option_msg
          print_help
          ;;
      esac
      shift 2
      ;;
    --gray)
      color="Gray"; shift ;;
    -i|--filter-image)
      filters+=( -dFILTERIMAGE ); shift ;;
    -t|--filter-text)
      filters+=( -dFILTERTEXT ); shift ;;
    -v|--filter-vector)
      filters+=( -dFILTERVECTOR ); shift ;;
    -h|--help)
      print_help
      ;;
    --)
      shift
      break
      ;;
    *)
      print_invalid_option_msg
      print_help
      ;;
  esac
done

# ─── Reject any stray positional args ──────────────────────────────────────
if [ "$#" -gt 0 ]; then
  print_invalid_option_msg
  print_help
fi

# ─── Locate script folder & prepare output dir ─────────────────────────────
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out_dir="$script_dir/compressed_files"
rm -rf "$out_dir"
mkdir -p "$out_dir"

# ─── Log header ─────────────────────────────────────────────────────────────
log="$out_dir/compression_report.log"
{
  echo "Compression Report - $(date)"
  printf "%-80s %15s %15s %10s\n" "Filename" "Original(bytes)" "Compressed(bytes)" "Ratio(%)"
  printf "%-80s %15s %15s %10s\n" "--------" "--------------" "----------------" "--------"
} >"$log"

# ─── Helper to get file size ────────────────────────────────────────────────
get_size() {
  if stat -c%s "$1" &>/dev/null; then
    stat -c%s "$1"
  else
    stat -f%z "$1"
  fi
}

# ─── Define common Ghostscript options (without input/output) ─────────────
gs_cmd=(
  gs -q -dNOPAUSE -dBATCH -dQUIET
  -sDEVICE=pdfwrite
  -dPDFSETTINGS="$preset"
  -sColorConversionStrategy="$color"
  "${filters[@]}"
)

# ─── Echo the exact command about to run ───────────────────────────────
echo "Running Ghostscript command:"
printf '  %q ' "${gs_cmd[@]}"
echo && echo

# ─── Loop PDF files ─────────────────────────────────────────────────────────
shopt -s nullglob
for input in "$script_dir"/*.pdf; do
  filename=$(basename "$input")
  output="$out_dir/$filename"

  # Build full command by appending output & input
  exec_cmd=( "${gs_cmd[@]}" -o "$output" "$input" )

  # execute it
  "${exec_cmd[@]}"

  # sizes & ratio
  orig=$(get_size "$input")
  comp=$(get_size "$output")
  if [ "$orig" -gt 0 ]; then
    ratio=$(awk -v o="$orig" -v c="$comp" 'BEGIN { printf "%.2f", (c/o)*100 }')
  else
    ratio="N/A"
  fi

  # append to log
  printf "%-80s %15d %15d %10s\n" \
    "$filename" "$orig" "$comp" "$ratio" \
    >>"$log"
done

echo "Done: compressed $(ls -1 "$out_dir"/*.pdf 2>/dev/null | wc -l) files."
echo "See report: $log"
