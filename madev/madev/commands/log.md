---
description: 운영 로그 한 줄 기록 — 표준 형식으로 work/<작업>/log.md 에 계측과 함께 append (누락·편차 방지)
argument-hint: "<작업명> <결정|가동|검수|에러|승인|완료> <내용> [model=… outcome=… rework=…]"
---

work-memory 규율의 운영 로그를 **표준 형식으로** 남겨라. 수기 편차·계측 누락을 막기 위해 헬퍼 스크립트로 append한다.

입력: $ARGUMENTS

1. 인자를 `<작업명> <태그> <내용> [key=val …]` 로 파싱한다. **태그는 6종만**: `결정 가동 검수 에러 승인 완료`. 인자가 모호하면 무엇이 빠졌는지 한 줄로 알리고 멈춘다.

2. **프로젝트 루트에서** 다음을 실행한다(반드시 `bash`로 — 실행권한 의존 제거):

   ```
   bash "${CLAUDE_PLUGIN_ROOT}/adapters/worklog.sh" "<작업명>" "<태그>" "<내용>" [key=val …]
   ```

   - 스크립트가 로컬 타임스탬프를 붙여 `work/<작업명>/log.md`에 append한다(파일 없으면 헤더 생성).
   - 태그가 6종이 아니면 스크립트가 거부한다(exit 2) — 그 경우 올바른 태그로 다시 부른다.
   - `${CLAUDE_PLUGIN_ROOT}`가 안 잡히면 명령이 알려준 어댑터 절대경로를 쓴다.

3. **가동(`[가동]`) 로그면 계측을 반드시 붙인다**: `model=… outcome=… rework=…` (값이 없으면 `n/a`). 예:
   `/madev:log landing 가동 "developer 완료 → results/developer.md" model=codex outcome=검수통과 rework=0`

4. append된 줄을 사용자에게 한 줄로 확인해준다. 스크립트가 실패하면(fail-open) 같은 표준 형식 `[YYYY-MM-DD HH:MM] [태그] 내용 | key=val …`으로 직접 append하고 실패 사유를 알린다.
