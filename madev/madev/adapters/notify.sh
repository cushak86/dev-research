#!/usr/bin/env bash
# notify.sh — (선택) 회사 라이프사이클 알림을 Discord 웹훅으로 전송.
# 사용: notify.sh <event> <message>
# fail-open: 웹훅 URL 미설정이면 조용히 스킵(exit 0). 회사 운영을 막지 않는다.
#   설정오류(비-웹훅 URL)·네트워크 실패만 비영점으로 끝난다.
set -euo pipefail

EVENT="${1:-info}"
MESSAGE="${2:-}"
[ -n "$MESSAGE" ] || { echo "usage: notify.sh <event> <message>" >&2; exit 64; }

# 설정: adapters/notify.env 에서 URL 한 줄만 literal 파싱(`. source` 금지 — 임의 코드 실행 방지). 기존 env 우선.
DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ENVFILE="$DIR/notify.env"
if [ -z "${DISCORD_WEBHOOK_URL:-}" ] && [ -f "$ENVFILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    case "$line" in
      DISCORD_WEBHOOK_URL=*)
        v="${line#DISCORD_WEBHOOK_URL=}"
        v="${v%\"}"; v="${v#\"}"
        DISCORD_WEBHOOK_URL="$v";;
    esac
  done < "$ENVFILE"
fi

# 미설정 → fail-open 스킵
[ -n "${DISCORD_WEBHOOK_URL:-}" ] || { echo "notify: 웹훅 미설정 → 스킵" >&2; exit 0; }

# https discord 웹훅만 허용 (오설정·SSRF 방지)
case "$DISCORD_WEBHOOK_URL" in
  https://discord.com/api/webhooks/*|https://discordapp.com/api/webhooks/*) ;;
  *) echo "notify: DISCORD_WEBHOOK_URL은 https discord 웹훅만 허용" >&2; exit 2;;
esac
command -v curl >/dev/null 2>&1 || { echo "notify: curl 필요" >&2; exit 5; }

# 한글(UTF-8) 깨짐 방지를 위해 페이로드를 파일로 전달(argv 재인코딩 회피).
PAYLOAD="$(mktemp)"; trap 'rm -f "$PAYLOAD"' EXIT
msg=${MESSAGE//\\/\\\\}; msg=${msg//\"/\\\"}
printf '{"username":"MAdev","content":"[%s] %s"}' "$EVENT" "$msg" > "$PAYLOAD"

code="$(curl -sS --connect-timeout 10 --max-time 30 -o /dev/null -w '%{http_code}' \
  -H 'Content-Type: application/json' --data @"$PAYLOAD" "$DISCORD_WEBHOOK_URL")" \
  || { echo "notify: 전송 실패(네트워크/타임아웃)" >&2; exit 1; }

case "$code" in
  200|204) echo "notify: '$EVENT' 전송 완료(HTTP $code)"; exit 0;;
  *)       echo "notify: 전송 실패(HTTP $code)" >&2; exit 1;;
esac
