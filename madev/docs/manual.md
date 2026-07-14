# madev 매뉴얼 — 규율 있는 AI 개발회사 (Claude Code 플러그인)

> **한 줄**: 마스터(CEO) 1명 + 7개 부서 + 감사팀 1명(모두 Claude)으로 구성된, 멀티에이전트 오케스트레이션 규율을 내장한 배포형 Claude Code 플러그인. 필요하면 **codex·gemini 외부 자문단**(이종 백엔드)까지 부른다. `v1.1.0`.

이 문서는 madev의 **가치 · 정책 · 성능 · 사용법**을 한곳에 정리한 매뉴얼이다. 설치·운영의 축약본은 `GUIDE.md`, 향후 개선안은 `ROADMAP.md`를 참고하라.

---

## 1. 가치 (Value) — 왜 madev인가

### 해결하는 문제
일반적인 "AI 팀" 플러그인은 세 가지에서 무너진다.
1. **허위 완료 보고** — 하위 에이전트가 일이 안 끝나도 "완료했습니다"라고 한다.
2. **맥락 유실** — 세션이 끊기면 무엇을 하던 중이었는지 사라진다.
3. **비용 남발** — 요청마다 전 팀을 다 돌려 토큰을 낭비한다.

### madev의 답
역할극에 **규율**을 얹었다. 회사라는 친숙한 UX 위에, 멀티에이전트 오케스트레이션의 검증된 규율을 물리적 장치로 이식했다:
- **가동 게이트** — 비용 드는 팬아웃 전에 계획 동의를 받는다.
- **작업폴더(기억)** — 다단계 작업의 목표·상태·로그를 파일에 남겨 세션이 끊겨도 이어간다.
- **3중 증거검수** — "완료"는 증거로만 인정하고, 분리된 감사팀이 재검한다.

### 차별화
"AI 팀에 성격을 준" 것에 그치지 않고 **승인 게이트 + 작업폴더 기억 + 분리된 감사**라는 물리적 제약을 걸었다. 규칙이 프롬프트 문구가 아니라 절차와 파일로 존재한다.

### 누구를 위한 것인가
1인 개발자·부업 사이트 운영자·자동화 초심자가, 믿을 수 있고 비용을 통제할 수 있는 AI 팀을 원할 때.

---

## 2. 아키텍처 — 조직과 개념 매핑

### 조직도 (9명)

| 직원 | 부서 | 백엔드 | 역할 |
|------|------|------|------|
| **master** | 총괄(CEO) | Claude opus · xhigh | 오케스트레이터 — 업무분배·가동게이트·작업폴더·검수·보고 |
| **inspector** | 감사팀 | Claude opus · xhigh | 분리된 적대적 재검증 (허위 완료 보고 차단) |
| planner | 기획팀 | Claude opus · high | 전략·콘텐츠 기획·우선순위·요구사항 |
| marketer | 마케팅팀 | Claude opus · high | SNS 홍보·카드뉴스 기획·유입 |
| seo | SEO팀 | Claude opus · high | 검색 노출·서치 콘솔·색인 진단 |
| developer | 개발팀 | codex (OpenAI GPT 최상위) | 코드·빌드·배포·SEO 기술 |
| cs | CS팀 | codex (OpenAI GPT 최상위) | 문의·피드백·FAQ |
| designer | 디자인팀 | gemini (Google 최상위) | UI/UX·레이아웃·카드뉴스 시안 |
| writer | 콘텐츠팀 | gemini (Google 최상위) | 글 작성/발행·문구 |

개발·CS(codex)·디자인·콘텐츠(gemini)는 **master(오케스트레이터)가 그 외부 백엔드를 직접 호출**해 처리하고(부서 서브에이전트가 부르지 않음 — 중첩 위임은 런타임 실패), 미설치·미작동이면 그 부서의 Claude(opus)로 폴백한다.

라우팅·승인·기억은 별도 에이전트가 아니라 **마스터의 직무**로 흡수했다(단일 오케스트레이터 원칙). 오케스트레이션 역할로 추가한 것은 감사팀(inspector) 하나뿐이다.

### 외부 자문단 (옵션 · 이종 백엔드)

상주 직원(위 9명)은 모두 Claude다. 그 위에 **다른 벤더** 워커를 자문으로 부를 수 있다 — 같은 계열이 공유하는 맹점을 잡기 위해. 미설치면 자동으로 Claude로 폴백한다(fail-open).

| 워커 | 벤더 · 경로 | 역할 |
|------|------|------|
| **codex** | OpenAI · 번들 `.mcp.json`(MCP) | 보조 구현·코드 분석·테스트·로컬 검증·**독립 감사**. `/madev:audit`가 우선 호출 |
| **gemini** | Google · `adapters/gemini.sh`(agy) | 제3자 시각·이미지/스크린샷·장문 문서. `/madev:consult gemini …` |

> multi-agent의 이종 워커 풀(codex-main·codex-critic·gemini)을 그대로 이식한 계층이다. 단, Claude Code 플러그인의 `agents/*.md`는 Claude 모델만 지정 가능하므로, 외부 벤더는 서브에이전트가 아니라 **MCP·어댑터로 호출**한다.

### 개념 ↔ 회사 기제 매핑

| 오케스트레이션 규율 (원본) | → madev 회사 기제 |
|---|---|
| 워커 라우팅·최소 set | 마스터의 "필요 팀만 최소 가동" |
| 승인 게이트 | 가동 게이트 (2팀+·장기작업 전 동의) |
| file-as-memory (task/context/log) | 작업폴더 `work/<작업>/` |
| 검증 체크리스트 (never trust upstream) | 3중 증거검수 |
| adversarial critic (codex-critic) | 감사팀 inspector + 외부 codex 감사(우선) |
| 이종 백엔드 워커풀 (codex·gemini) | 외부 자문단 `/madev:consult` (옵션·fail-open) |
| usage 계측 → 튜닝 | 운영 로그 계측 (rework) |
| append-only + provenance | 운영 로그 6태그 |
| 재진입 프로토콜 | 세션 재개 `/madev:resume` |
| learnings (재사용 교훈) | 회사 축적지식 `work/learnings.md` |
| fail-open 어댑터 | 선택 연동 미설정 시 스킵 |

---

## 3. 정책 (Policy) — 회사 운영 규율

madev의 핵심은 아래 규율이다. 모두 회사 매뉴얼(`CLAUDE.md`)·스킬·명령에 내장되어 있다.

### 3.1 업무분배 라우팅
- **필요한 팀만 최소로** 가동한다. 전 팀 기본 가동 금지.
- 판단이 어려우면 master부터. 단일 팀으로 부족할 때만 확장.
- 앞 팀 결과가 다음 팀 입력이면 지시서에 포함.

### 3.2 가동 게이트 (비용)
- **2개 팀 이상**이거나 **긴 작업**을 시작하기 전, 어느 팀을 왜 몇 라운드 돌릴지 계획을 한 줄로 알리고 동의를 받는다.
- 한 팀짜리 간단한 일은 게이트 없이 바로.
- **예외**: 매일 정기 스탠드업의 통상 1라운드 루틴은 기본 승인. 범위 확장·배포·비용 큰 작업만 재승인.

### 3.3 3중 증거검수 (절대 원칙)
1. **결과물을 직접 열어 증거를 확인**하고 보고에 첨부. "완료했습니다"는 증거가 아니다.
2. 확인 못 한 것은 "완료"가 아니라 **⚠️ 미확인**으로 보고.
3. 중요한 작업은 **감사팀(inspector)**으로 독립 재검증.
- 판정 체계: **✅ 검증됨 / ⚠️ 미확인·검증불가 / 🚨 허위**.

### 3.4 작업폴더 = 회사의 기억
- 다단계 작업은 `work/<작업명>/`에: `task.md`(목표·status) · `context.md`(현재 스냅샷) · `log.md`(운영로그, append-only) · `results/<팀>.md`(팀 산출물, log에 경로 기록).
- `context.md`에 이력을 쌓지 않는다(그건 `log.md` 역할).

### 3.5 운영 로그 (log.md)
- append-only. 형식 `[YYYY-MM-DD HH:MM] [태그] 내용`.
- 태그 **6종만**: `[결정] [가동] [검수] [에러] [승인] [완료]`.
- 팀 가동 계측: `[가동] developer 완료 → results/developer.md | model=codex outcome=검수통과 rework=0` (값 없으면 n/a). → 어느 팀·모델이 재작업이 잦았는지 데이터로 튜닝.

### 3.6 세션 재개 (재진입)
- 하던 작업에 다시 들어갈 때 **읽기 전 행동 금지**. 순서: `task.md` → `context.md` → `log.md` 최근 → 마지막 팀 산출물.
- status와 log가 어긋나면 log(정본)를 믿고 status 정정.
- 중단 지점부터 이어간다. 처음부터 다시 하지 않는다.

### 3.7 fail-open
- Discord 알림 등 선택 연동은 설정이 없으면 **조용히 스킵**. 회사 운영을 막지 않는다.

### 3.8 배포 승인
- 프로덕션 반영(라이브 사이트)은 되돌리기 어렵다 → **명시적 승인** 후에만. 기본 배포는 `git push origin main`.

### 3.9 배포·버전 정책
- 로컬 폴더 또는 git 저장소를 marketplace로 등록해 배포. 플러그인 수정 시 `plugin.json`·`marketplace.json`의 `version`을 함께 올린다.

### 3.10 외부 자문단 라우팅 (이종 백엔드)
- 상주 직원(Claude)으로 부족한 **독립 감사·이종 시각**이 필요하면 codex·gemini를 `/madev:consult`로 부른다. **사용자가 백엔드를 명시(codex/gemini)하거나 "외부 자문·제3자 검토·독립 감사"를 명시 요청한 때만** 외부 호출한다 — 성격 추측으로 자동 호출하지 않는다(예상외 타사 과금 방지). 중요한 감사는 `/madev:audit`가 codex를 우선하고, **폴백 시 결과 첫머리에 "Codex 독립 감사 미실행·inspector 폴백"을 명시**한다.
- **비용 관리**: 외부 워커도 비용이 드니 중요한 감사·검증에만, 남용 금지(가동 게이트와 동일 정신).
- **fail-open**: `codex`/`agy` 미설치면 자동으로 Claude(inspector/담당 부서)로 폴백하고, 폴백했다는 사실을 결과에 명시한다. 설치를 강요하지 않는다.
- **단일 오케스트레이터**: 외부 워커 호출은 master/명령 층에서만 — 부서 서브에이전트가 워커를 재귀 호출하지 않는다.

---

## 4. 성능 (Performance) — 토큰 비용과 효율

`claude plugin details madev`로 측정한 실제 비용(추정치).

### 상시 로드 (always-on)
- **세션당 ~1,545 tok** — 설치 시 모든 세션에 더해지는 고정 비용(9 에이전트 + 스킬·명령 설명). v1.1.1에서 description 최적화로 ~1,677→~1,545(−8%). 외부 백엔드(codex·gemini) **호출 비용은 이 상시 로드에 포함되지 않고, 실제로 부를 때만** 그쪽 벤더 쪽에서 발생한다.

### 컴포넌트별 비용 (always-on / on-invoke)

| 컴포넌트 | 상시 | 호출 시 |
|---|---:|---:|
| work-memory (스킬) | ~190 | ~1.3k |
| master | ~140 | ~1.1k |
| evidence-report (스킬) | ~130 | ~830 |
| inspector | ~130 | ~530 |
| developer / seo | ~100 | ~690 / ~700 |
| planner / designer / marketer / cs | ~90 | ~590–670 |
| writer | ~80 | ~620 |
| setup (명령) | ~70 | ~1.3k |
| assign (명령) | ~60 | ~810 |
| standup / report / resume / audit (명령) | ~60 | ~560–760 |
| hire (명령) | ~50 | ~750 |

> **호출 시(on-invoke)** 비용은 그 스킬/에이전트가 실제로 발화할 때마다 지불된다.
> 위 on-invoke 수치는 v1.1.1 측정값(당시 부서 sonnet 기준)이다. v1.2에서 Claude opus 부서(기획·마케팅·SEO)는 이보다 오르고, 외부-우선 부서(개발·CS·디자인·콘텐츠)는 master가 codex/gemini를 직접 호출하므로 외부 벤더 비용이 들고, 폴백 시 Claude opus — 어느 쪽이든 sonnet 기준보다 오른다(비용 절감 아님).

### 효율 설계
- **최소 팀 가동**: 전 팀을 기본 가동하지 않으므로, 실제 지불은 "오늘 실제로 부른 팀"의 on-invoke 합계에 가깝다.
- **이종 백엔드 배정**: 지휘·검증·전략은 Claude `opus`(master·inspector=xhigh, 기획·마케팅·SEO=high), 구현·처리는 `codex`(GPT, 개발·CS), 창작·집필은 `gemini`(디자인·콘텐츠). 외부 부서 미설치 시 Claude 폴백.
- **계측으로 튜닝**: 운영 로그의 `rework` 값이 잦은 팀·모델을 데이터로 찾아 지침을 손본다.

### 모델 배정 가이드 (이종 백엔드 · worker 모델)

각 역할을 맞는 벤더에 배정한다: 지휘·검증·전략은 **Claude opus**(오판이 회사 전체를 흔드는 자리), 구현은 코드에 강한 **codex(GPT)**, 창작은 **gemini** — 벤더를 나눠 같은 계열의 맹점을 서로 잡는다. 개발·CS·디자인·콘텐츠는 **master가 codex/gemini를 직접 호출**해 처리하고(부서 서브에이전트가 부르면 런타임 실패 — v1.3.0 worker 모델), 미설치·미작동이면 그 부서의 Claude(opus)로 폴백한다.

- **외부 "최상위" 설정**: codex는 `~/.codex/config.toml` 기본값/MCP `model` 파라미터로, gemini(agy)는 **계정 전역 `/model`**로 정한다(agy는 per-call 고정 불가 — 전역을 최상위로 켜 둘 것).
- **튜닝**: `[가동] … model=… rework=N`(2~4주)로 rework 잦은 부서는 강도↑(Claude effort↑, 외부는 상위 모델), 기계 검증 가능한 산출물은 비용↓.

⚠️ **창작팀 함정**: rework 지표는 검증 가능한 실패만 잡는다. 후킹 문구·문장 품질·디자인 감각의 **조용한 저하는 지표에 안 잡힌다**(검수 통과해도 CTR·가독성 하락). 그래서 창작(designer·writer)은 gemini 최상위를 유지한다.

---

## 5. 사용법 (Usage)

### 5.1 설치
```
/plugin marketplace add D:\agents\sync\MAdev
/plugin install madev@madev-marketplace
```
설치 후 클로드 코드 **재시작**. (CLI: `claude plugin marketplace add <경로>` → `claude plugin install madev@madev-marketplace`.)

> **외부 백엔드(선택)**: `codex` CLI가 설치돼 있으면 플러그인의 `.mcp.json`이 codex MCP를 자동 연결하고, `agy`(Antigravity)가 있으면 gemini 어댑터가 동작한다. **둘 다 없어도 madev는 Claude만으로 정상 동작한다(fail-open).**

### 5.2 초기 세팅
운영할 프로젝트 폴더에서:
```
/madev:setup
```
- `~/.claude/settings.json`에 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` 추가(기존 보존)
- 회사 매뉴얼을 프로젝트 `CLAUDE.md`로 설치(기존 파일이 있으면 핵심 규율 §2~§10,§12~§14 중 없는 것만 추가 제안)
- `docs/*`·`design`·`content`·`work` 폴더 + `work/learnings.md` 생성

완료 후 재시작(환경변수 적용).

### 5.3 채용 공고 작성
설치된 `CLAUDE.md`의 **1번(회사 소개) 3줄**과 **14번(프로젝트별 정보)**을 내 사업에 맞게 채운다. 이 3줄이 모든 직원의 판단 기준이 된다.

### 5.4 명령어

| 명령 | 언제 | 예시 |
|------|------|------|
| `/madev:setup` | 최초 1회 | `/madev:setup` |
| `/madev:standup` | 매일 아침 루틴 | `/madev:standup 오늘은 신규 글 2개 발행` |
| `/madev:assign` | 다단계·여러 팀 작업 착수 | `/madev:assign 랜딩 페이지 신규 제작과 배포` |
| `/madev:resume` | 하던 작업 이어서 (새 세션) | `/madev:resume` |
| `/madev:report` | 하루 마감·주간 결산 | `/madev:report 이번 주` |
| `/madev:audit` | 보고가 수상할 때·주 1회 | `/madev:audit` |
| `/madev:consult` | 외부 codex·gemini 자문이 필요할 때 | `/madev:consult codex 이 diff 독립 감사` |
| `/madev:hire` | 새 부서가 필요할 때 | `/madev:hire 유튜브 스크립트 쓰는 영상팀` |

### 5.5 핵심 — 간단한 일 vs 복잡한 일
- **간단한 일** → 담당 팀 지목: "seo한테 노출 점검시켜줘". 게이트 없이 바로.
- **복잡한 일** → `/madev:assign`: 작업폴더 생성 → (2팀+면) 가동 게이트 → 최소 팀 분배·검수. 세션이 끊기면 `/madev:resume`로 중단 지점부터.

작은 일은 가볍게, 큰 일은 규율대로 — 이 이중 구조가 madev의 핵심이다.

### 5.6 거짓말 방지 (3중 검수)
1. master 프롬프트에 증거검수 고정
2. evidence-report 스킬을 완료 보고 전 적용
3. `/madev:audit` — 분리된 감사팀이 전수 재검사

### 5.7 확장
- **직원 성격**: `madev/agents/<이름>.md` 수정. Claude 부서는 `model`·`effort`로, 외부-우선 부서(개발·CS=codex, 디자인·콘텐츠=gemini)는 `model`이 라우터·폴백용이고 실제 강도는 codex config / agy 전역에서 조절.
- **새 직원**: `/madev:hire` → 프로젝트 `.claude/agents/`에 생성(플러그인 업데이트에 영향 없음).
- **새 명령**: `madev/commands/`에 마크다운 추가 → `/madev:<파일명>`.
- **자동화**: `/schedule`로 아침 스탠드업, `/loop 1h /madev:standup`.

---

## 6. 로드맵 (요약)
- **P1** — 운영 로그 자동 기입 보조(`/madev:log`), 위임 패킷 표준화.
- **P2** — `/madev:audit` 대상 확장, 용어 사전 정리.
- **P3** — Windows 초심자용 알림 단순화, 명령 통합 검토.
- **장기** — 규율을 프롬프트가 아닌 도구(스킬) 실행 조건으로 강제.

상세는 `ROADMAP.md`.

---

## 7. 문제 해결

| 증상 | 해결 |
|------|------|
| `/madev:...` 명령이 안 보임 | 재시작 → `/plugin`에서 설치·활성 확인 |
| 에이전트 팀 동작 안 함 | `~/.claude/settings.json` env 확인 후 재시작. 버전 확인 |
| 직원이 매뉴얼 무시 | 프로젝트 루트에 `CLAUDE.md` 있는지 확인. 규칙은 짧고 단호하게 |
| 완료했다는데 결과물 없음 | `/madev:audit` → 허위 항목 재작업 지시서 |
| 다음 날 뭘 하던지 모름 | `/madev:resume` — 작업폴더에서 상태 복구 |
| 비용 부담 | Claude 부서는 `effort`↓/`model`↓, 외부 부서(개발·CS·디자인·콘텐츠)는 상위 모델 대신 기본 모델로. "오늘 필요한 팀만" 원칙 |
| 알림이 안 옴 | `adapters/notify.env` 확인 (미설정이면 스킵이 정상 — fail-open) |
| 외부 자문(codex/gemini)이 안 붙음 | `codex`·`agy` 설치·PATH 확인 후 재시작. 미설치면 Claude로 폴백이 정상(fail-open) |

---

_madev v1.0.0 — 멀티에이전트 오케스트레이션 규율 × ai-company 회사 UX. 이 매뉴얼은 다회차 검토(설계 · 제3자 검토 · 감사)를 거쳐 작성됨._
