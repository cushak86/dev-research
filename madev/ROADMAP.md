# MAdev 로드맵 · 추가제안

v1.0.0은 "규율을 회사 UX로 이식"에 집중했다. 아래는 다회차 검토(제3자 gemini + 감사팀 codex-critic)에서 나온 **다음 단계 개선안**이다. 각 항목은 가치·비용·트레이드오프와 함께, 즉시 반영하지 않고 로드맵으로 둔 이유를 밝힌다.

> **v1.4.0에서 반영(규율 훅·로그 헬퍼·업종 프리셋·어댑터 권한 — 인헨스)**: 이 로드맵 P0~P2 4건을 착수·반영했다. ① **어댑터 실행권한 버그 수정(E1)** — `gemini.sh`·`notify.sh`가 git에 `100644`(비실행)로 저장돼 `${CLAUDE_PLUGIN_ROOT}/adapters/gemini.sh` 직접 실행이 clone 직후 "Permission denied"로 실패, gemini 백엔드(디자인·콘텐츠) 경로가 항상 폴백으로 죽어있던 문제. `100755`로 커밋 + 명령/master 지시를 `bash "<경로>"` 호출로 변경(실행권한 유무와 무관·이중 안전장치). ② **규율 훅(E2, ROADMAP "규율을 도구 레벨로")** — 플러그인 번들 훅(`hooks/hooks.json`) 도입: PreToolUse/Task에 가동게이트·로그·검수 규율 넛지, SessionStart에 진행 중 작업 재개 상기. **비차단·fail-open**(jq·도구 부재 시 조용히 통과, 권한 흐름 불변)으로 1차 도입 — 하드 차단은 인터랙티브 실측 후 단계 확대. ③ **로그 헬퍼(E3, P1-1)** — `/madev:log` 명령 + `adapters/worklog.sh`: 표준 형식·타임스탬프·태그 검증으로 계측 누락 방지. ④ **업종 프리셋 온보딩(E6, P2-B9)** — `templates/presets/{blog,commerce,saas}.md` + setup 대화형 채움으로 매뉴얼 도메인 하드코딩 해소. `claude plugin validate --strict` 통과. 상세 분석: `docs/enhance/v1.4-analysis.md`.

> v1.0.0에서 **즉시 반영**한 것: 명령 frontmatter 규격 수정(로드 가능), 설치 시 핵심 규율 병합 범위 확대, 서브에이전트에 "매뉴얼 먼저 읽고 못 읽으면 미확인 보고" 강제, 마스터 역할 경계 문구 정정, 정기 스탠드업 게이트 예외, 작업폴더 `results/<팀>.md` 재진입 스키마.

> **v1.3.0에서 반영(외부 호출을 오케스트레이터로 이관 — worker 모델)**: v1.2.x는 외부 백엔드(codex·gemini) 호출을 **부서 서브에이전트**에 뒀는데, 이는 multi-agent가 배제한 "worker가 worker 호출"(중첩 위임)이라 서브에이전트가 플러그인 MCP·Bash·`CLAUDE_PLUGIN_ROOT`에 접근 못 해 **실런타임에서 codex/agy가 안 불렸다**(사용자 실환경 확인). 수정: multi-agent worker 모델(`call_worker.sh`: native/mcp는 오케스트레이터 직접 호출)대로 **외부 leaf 호출을 오케스트레이터 최상위(master·명령)로 이관**, 부서는 Claude-native 실행자/폴백으로. codex-critic 적대 리뷰 반영 — 부서 spawn 전 외부 먼저 시도(강제 순서), 폴백은 관측 가능 실패(도구·명령 부재/exit≠0/timeout/빈응답/거부)로만, 브리핑 모호성 제거(외부 도구 프롬프트에 부서 규격 인라인), plugin-root 우회 구체화. **주의(캐시)**: 업데이트 후 반영 안 되면 `plugin marketplace update`+`plugin update`+재시작, 그래도 안 되면 uninstall→install(버전별 캐시 갱신).

> **v1.2.1에서 반영(래퍼 opus 상향)**: v1.2.0에서 외부-우선 4부서(개발·CS·디자인·콘텐츠)의 Claude 래퍼를 haiku로 뒀더니 (a) 리로드·정의파일에 haiku로 노출돼 "최상위" 의도와 반대로 읽히고, (b) 위임 미작동 시 최약체 haiku가 직접 실행되는 문제 → **래퍼/폴백을 opus(effort high)로 상향**(9부서 전부 opus). 부수: 서브에이전트의 codex MCP·gemini 어댑터 실호출을 진단 서브에이전트로 실측 검증(둘 다 PONG 성공), codex MCP는 deferred라 developer·cs body에 "안 보이면 로드 후 호출" 하드닝. **주의**: v1.2.0→1.2.1 버전 인상 필수 — 미인상 시 `plugin update`가 캐시(구 haiku)를 재사용해 반영 안 됨.

> **v1.2.0에서 반영(부서 모델 재배정)**: 이종 백엔드를 옵션 자문에서 **부서 기본 실행**으로 승격 — 개발·CS=codex(GPT 최상위), 디자인·콘텐츠=gemini(최상위), 지휘·검증·전략(master·inspector·planner·marketer·seo)=Claude opus(effort xhigh/high). 외부-우선 부서는 Claude 래퍼(**opus**)가 지시·검수하고 미설치·미작동 시 opus로 폴백(fail-open — 서브에이전트는 Claude만 가능해 부서 model에 외부값을 못 넣어 opus 래퍼가 도구로 위임, 위임 실작동은 인터랙티브 검증 전). frontmatter `model`엔 외부값을 못 넣어 **body 위임으로 인코딩**, `effort:` 필드는 `claude plugin validate` 통과 실증. consult/audit 온디맨드 외부 자문은 그대로 유지. **미검증**: 서브에이전트의 외부 백엔드 실호출은 인터랙티브 세션 필요.

> **v1.1.1에서 반영(2차·3차 검증 + 토큰 최적화)**: codex-critic(2차)·gemini(3차) 재검증 결과 반영 — ① consult 외부 호출을 **명시 시에만**으로 제한(예상외 타사 과금 방지), ② audit 폴백 시 "Codex 독립 감사 미실행" 강제 경고(이종 검증 착각 방지), ③ gemini.sh 프롬프트를 argv→**stdin 전달**(ARG_MAX 해소 — 88KB 실측 통과, 타임아웃 GEMINI_TIMEOUT 설정화), ④ 외부 결과는 `[백엔드 검토 결과]` 원문 인용(화자 왜곡 방지), ⑤ 저장·log는 호출측 Claude 책임 명확화. **토큰**: description 최적화로 상시 ~1,677→~1,545 tok(−8%). 부서 카드 "회사 규율" 중복 블록은 비평 판정대로 유지(안전장치 > 절감).

> **v1.1.0에서 반영(이종 백엔드 이식)**: multi-agent의 이종 워커 풀을 회사화했다 — codex MCP 번들(`.mcp.json`) + gemini 어댑터(`adapters/gemini.sh`, agy) + `/madev:consult` 명령. `/madev:audit`는 codex를 우선(진짜 다른 벤더 감사), 미설치 시 Claude `inspector`로 폴백(fail-open). 설계 초기 "미이식" caveat이었던 항목을 정식 이식.

## P1 — 다음 버전 우선

### 1. 운영 로그 자동 기입 보조 (`/madev:log` 또는 로그 템플릿) — ✅ v1.4.0 반영
- **문제**: 팀 가동 계측(`[가동] … | model=… outcome=… rework=…`)을 에이전트가 매번 수기로 남기게 하면 누락 가능성이 높다(gemini·critic 공통 지적).
- **반영(v1.4.0)**: `/madev:log <작업> <태그> <내용> [key=val …]` 명령 + `adapters/worklog.sh`(타임스탬프 자동·태그 6종 검증·append-only 헤더 생성). 완전 자동 토큰 계측은 여전히 서브에이전트 환경 제약이나 형식 강제·누락 방지는 달성.
- **제안**: 로그 한 줄을 표준 형식으로 append하는 경량 명령/스킬. 완전 자동 토큰 계측은 서브에이전트 환경상 불가하나, 형식 강제·누락 방지는 가능.
- **가치 높음 / 비용 낮음 / 트레이드오프**: 여전히 수기 트리거이나 형식 일관성↑.
- **왜 로드맵**: v1은 "값 없으면 n/a" 폴백으로 fail-open 유지. 자동 수집은 Claude Code 서브에이전트 usage 노출 여부에 의존.

### 2. 위임 패킷 표준화
- **문제**: 마스터가 부서에 넘기는 지시서 구조가 자유형이라 편차가 크다.
- **제안**: 모든 서브에이전트에 동일 구조(목표·읽을 파일·할 일·결과물 형태·완료 기준·산출물 경로) brief를 전달하도록 템플릿화. v1의 "먼저 읽을 파일 명시"를 정식 패킷으로 승격.
- **가치 높음 / 비용 낮음 / 트레이드오프**: 프롬프트 길이 약간 증가.

## P2 — 안정화

### 3. `/madev:audit` 대상 확장
- 현재 기본값이 최근 스탠드업 보고서에 치우침. `work/*/log.md`·`docs/reports/`까지 탐색해 전수성 강화. **가치 중상 / 비용 중간(감사 시간↑)**.

### 4. 용어 사전 정리
- `미확인 / 확인 불가 / 검증 불가`, `검수통과 / 검증됨`, `허위 / 실패`가 문서 간 혼용. 단일 사전으로 통일. **가치 중간 / 비용 낮음 / 트레이드오프**: 표현 유연성 감소.

## P3 — 검토 후 결정

### 5. Windows 초심자용 알림 단순화
- `adapters/notify.sh`(bash)는 fail-open 데모지만 Windows 배포 UX와 어긋난다. PowerShell 버전 추가 또는 문서-only 축소를 저울질. **가치 낮음~중간 / 비용 낮음**.

### 6. 명령 통합 검토 (report/audit/standup)
- 세 명령의 검수·보고 기능이 일부 중복. 초심자용으로 통합하면 명령 수↓, 고급 운영 분리성↓. **가치 중간 / 비용 중간** — 사용 데이터를 보고 결정 권장.

## 규율을 도구 레벨로 (장기 방향) — 🔄 v1.4.0 1차 착수
gemini의 근본 제언: 규율이 "프롬프트에 쓰여 있음"과 "항상 실행됨" 사이에는 간극이 있다. 가동 게이트·검수를 **스킬(도구) 실행 조건**으로 강제(미통과 시 다음 스텝 실패)하면 자율판단 의존을 줄일 수 있다.
- **v1.4.0 착수(E2)**: 플러그인 번들 훅(`hooks/hooks.json`) 도입 — PreToolUse/Task 규율 넛지 + SessionStart 재개 상기. **비차단·fail-open**으로 1차 도입(권한 흐름·운영을 막지 않음).
- **다음 단계**: 하드 차단(예: 다중 팀 spawn 전 `[승인]` 마커 부재 시 PreToolUse deny, 배포 전 승인 확인)을 인터랙티브 실측 후 단계적으로 켠다. 오탐·과차단으로 운영을 막지 않도록 opt-in/화이트리스트와 함께.

---
_출처: 이 로드맵은 madev v1.0.0 구축 시 멀티에이전트 검토(claude-main 설계 · gemini 제3자 검토 · codex-critic 감사)에서 도출됨._
