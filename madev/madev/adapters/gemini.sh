#!/usr/bin/env bash
# gemini.sh — (선택) 외부 제3자·멀티모달 자문을 Google Gemini(Antigravity `agy` CLI, 헤드리스)로 요청.
# 사용:  gemini.sh "<프롬프트>"        또는        echo "<프롬프트>" | gemini.sh
# 결과는 stdout으로. 회사의 상주 직원(Claude)과 다른 벤더라, 같은 계열이 놓치는 맹점을 잡는다.
#
# fail-open: agy 미설치면 exit 3으로 신호만 주고 끝낸다(호출측이 Claude로 폴백). 회사 운영을 막지 않는다.
# 장문 안전: 프롬프트는 argv가 아니라 **stdin**으로 agy에 전달한다(ARG_MAX 한계 회피 — agy의 stdin 프롬프트 지원 실측 확인됨).
# 타임아웃: 기본 240s, 환경변수 GEMINI_TIMEOUT으로 조절.
# 주의: 검토 대상은 프롬프트에 인라인할 것. 파일·디렉토리 순회를 시키면 agy 헤드리스가 타임아웃한다.
set -euo pipefail

PROMPT="${1:-}"
if [ -z "$PROMPT" ] && [ ! -t 0 ]; then PROMPT="$(cat)"; fi
[ -n "$PROMPT" ] || { echo "usage: gemini.sh \"<프롬프트>\"" >&2; exit 64; }

if ! command -v agy >/dev/null 2>&1; then
  echo "gemini: agy(Antigravity) 미설치 → 외부 제3자 검토 스킵. 호출측은 Claude(inspector/담당 부서)로 폴백하라." >&2
  exit 3
fi

# stdin으로 전달 — 장문에서도 안전(printf는 셸 내장이라 ARG_MAX 비적용)
if command -v timeout >/dev/null 2>&1; then
  printf %s "$PROMPT" | timeout "${GEMINI_TIMEOUT:-240}" agy
else
  printf %s "$PROMPT" | agy
fi
