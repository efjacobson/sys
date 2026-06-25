#!/usr/bin/env bash
# split_pdf.sh — splits a PDF into one file per page
# Usage: ./split_pdf.sh input.pdf [output_dir]
#
# Requires: pdftk-java — brew install pdftk-java

set -euo pipefail

# ── Args ─────────────────────────────────────────────────────────────────────
INPUT="${1:-}"
OUTPUT_DIR="${2:-.}"

if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 input.pdf [output_dir]" >&2
  exit 1
fi

if [[ ! -f "$INPUT" ]]; then
  echo "Error: file not found: $INPUT" >&2
  exit 1
fi

if ! command -v pdftk &>/dev/null; then
  echo "Error: pdftk not found. Install it with: brew install pdftk-java" >&2
  exit 1
fi

# Resolve to absolute path before we cd anywhere
INPUT="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

BASENAME="$(basename "$INPUT" .pdf)"

# pdftk burst always writes to CWD, so cd there first
cd "$OUTPUT_DIR"
pdftk "$INPUT" burst output "${BASENAME}_%04d.pdf"

# burst also creates a doc_data.txt metadata file — remove it
rm -f doc_data.txt

echo "Done. Pages written to: $OUTPUT_DIR"
