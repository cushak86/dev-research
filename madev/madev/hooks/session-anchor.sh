#!/usr/bin/env bash
# session-anchor.sh — madev 세션 재정박 넛지 (SessionStart · 비차단).
# 진행 중(status: in_progress)인 작업폴더가 있으면 /madev:resume 로 이어가라고 상기시킨다.
#
# 계약: 진행 중 작업이 없으면 아무것도 출력하지 않는다. 오류·도구 부재면 조용히 통과(fail-open).
set -euo pipefail

PROJ="${CLAUDE_PROJECT_DIR:-.}"
found=""

# work/*/task.md 중 status: in_progress 인 작업명을 모은다
for t in "$PROJ"/work/*/task.md; do
  [ -e "$t" ] || continue
  if grep -qiE 'status:[[:space:]]*in_progress' "$t" 2>/dev/null; then
    d="$(basename "$(dirname "$t")")"
    found="${found:+$found, }$d"
  fi
done

[ -n "$found" ] || exit 0

MSG="[madev] 진행 중인 작업이 있습니다: ${found}. 이어서 하려면 /madev:resume 로 재정박하세요(읽기 전 행동 금지: task→context→log→마지막 결과 순)."

if command -v jq >/dev/null 2>&1; then
  # SessionStart는 additionalContext로 컨텍스트에 주입한다.
  jq -n --arg m "$MSG" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$m}}' 2>/dev/null || printf '%s\n' "$MSG"
else
  printf '%s\n' "$MSG"
fi
exit 0
