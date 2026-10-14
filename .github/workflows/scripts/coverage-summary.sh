#!/usr/bin/env bash
set -euo pipefail

REPORT_PATH="target/site/jacoco/jacoco.csv"

OUTPUT="${GITHUB_STEP_SUMMARY:-/dev/stdout}"

if [ ! -f "$REPORT_PATH" ]; then
  echo "::warning::JaCoCo report not found ($REPORT_PATH), skipping coverage summary."
  exit 0
fi

awk -F',' '
  function pct(covered, missed) {
    total = covered + missed
    return total > 0 ? covered / total * 100 : 0
  }
  NR > 1 {
    branch_missed  += $6
    branch_covered += $7
    line_missed    += $8
    line_covered   += $9
  }
  END {
    lp = pct(line_covered, line_missed)
    bp = pct(branch_covered, branch_missed)
    print "### 📊 Code coverage"
    print ""
    print "| Metric | Covered | Total | Coverage |"
    print "| :--- | ---: | ---: | ---: |"
    printf "| Lignes | %d | %d | %.1f%% |\n", line_covered, line_covered + line_missed, lp
    printf "| Branches | %d | %d | %.1f%% |\n", branch_covered, branch_covered + branch_missed, bp
  }
' "$REPORT_PATH" >> "$OUTPUT"