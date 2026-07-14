#!/usr/bin/env bash
# worklog.sh — 표준 형식으로 work/<작업>/log.md 에 운영 로그 한 줄을 append (계측 누락·형식 편차 방지).
# 사용:  worklog.sh <작업명> <태그> <내용> [key=val ...]
#   예:  worklog.sh landing 가동 "developer 완료 → results/developer.md" model=codex outcome=검수통과 rework=0
#
# 태그는 6종만 허용: 결정 가동 검수 에러 승인 완료  (그 외는 exit 2로 거부 — 오염 방지)
# append-only: 기존 줄을 고치거나 지우지 않는다. 파일이 없으면 헤더만 만들어 새로 연다.
# CWD 기준 상대경로(work/<작업>) — 프로젝트 루트에서 실행할 것.
set -euo pipefail

TASK="${1:-}"; TAG="${2:-}"; MSG="${3:-}"
if [ -z "$TASK" ] || [ -z "$TAG" ] || [ -z "$MSG" ]; then
  echo "usage: worklog.sh <작업명> <결정|가동|검수|에러|승인|완료> <내용> [key=val ...]" >&2
  exit 64
fi

case "$TAG" in
  결정|가동|검수|에러|승인|완료) ;;
  *) echo "worklog: 태그는 6종만 허용(결정 가동 검수 에러 승인 완료) — 받은 값: '$TAG'" >&2; exit 2;;
esac

shift 3 || true
META=""
if [ "$#" -gt 0 ]; then META="$*"; fi   # key=val 들을 공백으로 이어붙임

# 타임스탬프는 실행 호스트(사용자 머신) 로컬 시각
TS="$(date '+%Y-%m-%d %H:%M')"

DIR="work/$TASK"
mkdir -p "$DIR"
LOG="$DIR/log.md"
[ -f "$LOG" ] || printf '# %s — 운영 로그 (append-only · 태그 6종: 결정 가동 검수 에러 승인 완료)\n\n' "$TASK" > "$LOG"

LINE="[$TS] [$TAG] $MSG"
[ -n "$META" ] && LINE="$LINE | $META"

printf '%s\n' "$LINE" >> "$LOG"
echo "worklog: appended → $LOG"
printf '%s\n' "$LINE"
