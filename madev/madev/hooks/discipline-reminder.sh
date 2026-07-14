#!/usr/bin/env bash
# discipline-reminder.sh — madev 규율 넛지 (PreToolUse · 비차단).
# 팀(서브에이전트=Task) 가동 직전에 가동 게이트·로그 계측·증거 검수 규율을 상기시킨다.
#
# 계약: 항상 allow(차단하지 않음). jq 미설치·파싱 실패·기타 오류면 조용히 통과(fail-open) —
#       규율 넛지는 회사 운영을 절대 막지 않는다. permissionDecision을 내리지 않아
#       사용자의 기존 권한 흐름(승인 프롬프트)도 바꾸지 않는다.
set -euo pipefail

INPUT="$(cat 2>/dev/null || true)"

# jq 없으면 조용히 통과(JSON을 안전하게 만들 수 없음)
command -v jq >/dev/null 2>&1 || exit 0

TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)"
[ "$TOOL" = "Task" ] || exit 0

MSG="[madev 규율] 팀 가동 알림 — 2팀 이상이거나 긴 작업이면 가동 게이트(사용자 동의 → log.md [승인])를 먼저 확인했는지 점검. 가동을 마치면 /madev:log <작업> 가동 \"<팀> 완료 → results/<팀>.md\" model=… outcome=… rework=… 로 계측을 남길 것. '완료' 주장은 증거로 직접 검수(evidence-report)하고, 확인 못 한 것은 ⚠️ 미확인으로."

# systemMessage만 반환 — 넛지를 띄우되 권한 결정은 하지 않는다.
jq -n --arg m "$MSG" '{systemMessage:$m}' 2>/dev/null || true
exit 0
