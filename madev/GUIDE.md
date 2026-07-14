# MAdev — 규율 있는 AI 개발회사 플러그인 · 설치·운영·확장 가이드

ai-company의 "회사" UX에 멀티에이전트 오케스트레이션 규율(업무분배 라우팅·가동 게이트·작업폴더 기억·3중 증거검수·세션 재개·축적지식)을 얹은 클로드 코드 플러그인입니다.
설치하면 대표(마스터) 1명 + 부서 직원 7명 + **감사팀 1명**(모두 Claude)이 채용되고, 스탠드업·작업 착수·재개·검수·감사 명령이 함께 들어옵니다. 필요하면 **외부 codex·gemini 자문단**(이종 백엔드)까지 부를 수 있습니다(옵션 · 미설치 시 Claude로 폴백).

```
MAdev\                                   ← 마켓플레이스 (이 저장소)
├── .claude-plugin\marketplace.json      ← 마켓플레이스 정의
├── GUIDE.md                             ← 이 문서
├── README.md
└── madev\                               ← 플러그인 본체
    ├── .claude-plugin\plugin.json       ← 플러그인 정보
    ├── .mcp.json                        ← 외부 codex MCP 번들 (옵션·fail-open)
    ├── hooks\                           ← 규율 훅(v1.4·비차단): hooks.json + discipline-reminder.sh · session-anchor.sh
    ├── agents\                          ← 상주 직원 9명 (마스터 + 7개 부서 + 감사팀, 모두 Claude)
    ├── commands\                        ← 슬래시 명령 9개 (setup·standup·assign·resume·report·audit·consult·log·hire)
    ├── skills\                          ← evidence-report(검수), work-memory(작업폴더)
    ├── templates\CLAUDE.company.md      ← 회사 매뉴얼(오케스트레이션 규율)
    ├── templates\presets\               ← 업종 프리셋(v1.4): blog · commerce · saas
    └── adapters\                        ← notify.sh(알림) · gemini.sh(외부 gemini/agy) · worklog.sh(로그 헬퍼) — 선택·fail-open
```

---

## 1부. 설치 (5분)

### 1-1. 플러그인 설치

클로드 코드 대화창에서 순서대로 입력:

```
/plugin marketplace add D:\agents\sync\MAdev
/plugin install madev@madev-marketplace
```

설치 후 클로드 코드를 **재시작**하세요. `/plugin` 으로 설치 상태를 확인할 수 있습니다.

> **외부 백엔드(선택)**: `codex` CLI가 있으면 플러그인의 `.mcp.json`이 codex MCP를 자동 연결하고, `agy`(Antigravity)가 있으면 gemini 어댑터가 동작합니다. 둘 다 없어도 madev는 Claude만으로 정상 동작합니다(fail-open) — 설치는 선택입니다.

> 참고: 클로드 코드 버전이 낮으면 플러그인 기능이 없을 수 있습니다. "클로드 버전 확인해줘"라고 물어보고, 낮으면 `npm install -g @anthropic-ai/claude-code` 로 업데이트하세요.

### 1-2. 초기 세팅

**운영할 프로젝트 폴더**에서 클로드 코드를 열고:

```
/madev:setup
```

이 명령 하나가 처리하는 것:

| 항목 | setup이 하는 일 |
|------|----------------|
| 에이전트 팀 환경 | `~/.claude/settings.json`에 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` 추가 (기존 설정 보존) |
| 회사 매뉴얼 | `CLAUDE.company.md`를 프로젝트 `CLAUDE.md`로 설치 |
| 작업 폴더 | `docs/*`, `design`, `content`, `work` 생성 + `work/learnings.md` |

완료되면 클로드 코드를 한 번 더 재시작하세요 (환경변수 적용).

### 1-3. 채용 공고 작성

설치된 `CLAUDE.md`를 열어 **1번 섹션(회사 소개)** 세 줄과 **14번 섹션(프로젝트별 정보)**을 내 사업에 맞게 채우세요. 이걸 채워야 직원들이 헛짓을 안 합니다.

### 1-4. (선택) 알림 연동

Discord로 진행 알림을 받고 싶으면 `madev\adapters\notify.env.example`을 `notify.env`로 복사하고 웹훅 URL을 넣으세요. **설정하지 않아도 회사는 정상 동작합니다(fail-open).**

---

## 2부. 운영 — 매일 이렇게 씁니다

### 명령어 정리

| 명령 | 언제 | 예시 |
|------|------|------|
| `/madev:setup` | 최초 1회 (설치 직후) | `/madev:setup` |
| `/madev:standup` | 매일 아침, 일상 루틴 | `/madev:standup 오늘은 신규 글 2개 발행에 집중` |
| `/madev:assign` | 여러 단계·여러 팀 작업 착수 | `/madev:assign 랜딩 페이지 신규 제작과 배포` |
| `/madev:resume` | 하던 작업을 이어서 (특히 새 세션) | `/madev:resume` |
| `/madev:report` | 하루 마감, 주간 결산 | `/madev:report 이번 주` |
| `/madev:audit` | 보고가 수상할 때, 주 1회 정기 | `/madev:audit` |
| `/madev:consult` | 외부 codex·gemini 자문 | `/madev:consult codex 이 diff 감사` |
| `/madev:log` | 운영 로그 표준 형식 기록 | `/madev:log landing 가동 "writer 완료 → results/writer.md" model=gemini outcome=검수통과 rework=0` |
| `/madev:hire` | 새 부서가 필요할 때 | `/madev:hire 유튜브 스크립트 쓰는 영상팀` |

### 간단한 일 vs 복잡한 일 (핵심)

- **간단한 일** → 담당 팀을 지목: "seo 직원한테 사이트 노출 점검시켜줘". 게이트 없이 바로 처리됩니다.
- **복잡한 일** → `/madev:assign`: 마스터가 **작업폴더(`work/<작업>/`)**를 만들어 목표·상태·로그를 기억하고, 2개 팀 이상이면 **가동 게이트**(어느 팀을 왜 돌릴지 한 줄 동의)를 거친 뒤 최소 팀만 분배·검수합니다.

이 이중 구조가 이 플러그인의 핵심입니다: 작은 일은 가볍게, 큰 일은 규율대로.

### 세션이 끊겼을 때

작업 도중 세션이 끊기거나 다음 날 새로 켰다면 `/madev:resume`. 마스터가 `work/<작업>/`의 task·context·log를 **먼저 읽고**(재정박) 중단 지점부터 이어갑니다. 처음부터 다시 하지 않습니다.

### 거짓말 방지 (3중 검수)

1. **master 에이전트** — "결과물을 직접 열어 증거 확인", "미확인은 미확인으로" 가 시스템 프롬프트에 고정
2. **evidence-report 스킬** — 어떤 직원이든 완료 보고 전에 검수 절차 적용
3. **감사팀 + `/madev:audit`** — 작업을 한 팀과 **분리된** 감사자가 완료 보고를 전수 재검사. `codex`(외부·다른 벤더)가 있으면 그것으로 우선 감사(더 강한 독립성), 없으면 Claude `inspector`로 폴백

중요한 작업 뒤에는 `/madev:audit`을 한 번 돌려보는 습관을 권합니다. 외부 시각이 필요하면 `/madev:consult gemini …`로 제3자 검토를 받을 수 있습니다.

### 운영 로그로 회사 튜닝하기

`/madev:assign`으로 진행한 작업의 `work/<작업>/log.md`에는 팀 가동이 계측과 함께 남습니다
(`[가동] developer 완료 | model=codex outcome=검수통과 rework=0`). 시간이 쌓이면 어느 팀·어느 모델이 재작업(rework)이 잦았는지 데이터로 보고 지침을 손볼 수 있습니다.

### 아침 자동화

`/schedule` 로 "매일 아침 9시에 `/madev:standup` 실행"을 걸 수 있습니다. 세션을 켜둔 채 반복하려면 `/loop 1h /madev:standup` 도 가능합니다.

---

## 3부. 확장 — 회사 키우기

### 직원 성격 바꾸기

플러그인 안의 직원 파일을 직접 수정합니다 (예: `madev\agents\writer.md`).
- frontmatter의 `model`(Claude 별칭 opus/sonnet/haiku)과 `effort`(low/medium/high/xhigh)로 Claude 부서의 강도·비용을 조절합니다.
- 개발·CS(codex)·디자인·콘텐츠(gemini)는 **master(오케스트레이터)가 그 외부 백엔드를 직접 호출**해 처리합니다 — 부서 서브에이전트가 부르지 않습니다(중첩 위임은 런타임에서 도구 접근 불가로 실패). 그 부서의 `model: opus`는 **외부 미가동 시 폴백 실행자**용입니다(haiku 아님. 아래 배정 가이드).
- 감사팀(inspector)은 기본 `opus` + `effort: xhigh`입니다 — 적대적 검수는 강한 모델일수록 잘 잡습니다.
- 수정 후 재시작하면 반영됩니다.

### 모델 배정 가이드 (이종 백엔드 · worker 모델)

v1.2는 **각 역할을 가장 맞는 벤더에 배정**합니다:

| 계층 | 부서 | 백엔드 | 강도 |
|------|------|--------|------|
| 지휘·검증 | master · inspector | Claude **opus** | effort **xhigh** |
| 판단·전략 | planner · marketer · seo | Claude **opus** | effort **high** |
| 구현·처리 | developer · cs | **codex**(OpenAI GPT 최상위) · 폴백 opus | codex config / MCP `model` 파라미터 |
| 창작·집필 | designer · writer | **gemini**(Google 최상위) · 폴백 opus | agy 전역 `/model` |

원리: **판단·검증이 틀리면 회사 전체가 흔들리므로** 그 자리(master·inspector·기획·마케팅·SEO)엔 강한 Claude opus를 둡니다. 구현은 코드에 강한 codex, 창작은 gemini로 벤더를 다양화 — 같은 계열이 공유하는 맹점을 서로 잡습니다. 개발·CS·디자인·콘텐츠는 **master가 codex/gemini를 직접 호출**해 처리하고, 미설치·미작동이면 그 부서의 Claude(**opus**)로 폴백하며 그 사실을 결과에 명시합니다.

> ⚠️ **중요(v1.3.0 아키텍처 — worker 모델)**: Claude Code 서브에이전트는 **Claude 모델만** 됩니다(부서 `model`에 codex/gemini 불가). 게다가 **부서 서브에이전트가 codex/gemini를 직접 부르면 실런타임에서 실패**합니다 — 중첩 서브에이전트는 플러그인 MCP·Bash·`CLAUDE_PLUGIN_ROOT`에 접근하지 못하기 때문입니다(v1.2.x에서 codex/agy가 실제로 안 불린 원인). 그래서 v1.3.0은 multi-agent의 **worker 모델**을 따라 **외부 호출을 오케스트레이터(master·명령) 최상위가 직접** 합니다: codex=`mcp__codex__codex`, gemini=`adapters/gemini.sh`를 부서 spawn보다 **먼저** 시도하고, 관측 가능한 실패(도구·명령 부재/exit≠0/timeout/빈응답/거부) 시에만 Claude 부서(opus)로 폴백합니다. `/madev:consult codex|gemini`·`/madev:audit`도 같은 직접 호출 경로입니다.

**외부 "최상위 모델" 설정:**
- codex(개발·CS): 최상위 GPT는 `~/.codex/config.toml` 기본값 또는 MCP 호출 `model` 파라미터로 정합니다.
- gemini(디자인·콘텐츠): agy 모델은 **계정 전역**(`/model`)이라 per-call 고정이 안 됩니다 — agy에서 최상위 모델을 전역으로 켜 두세요. 아니면 부서가 그 전제를 결과에 명시합니다.

**튜닝:** `work/<작업>/log.md`의 `[가동] … model=… rework=N` 계측을 2~4주 모아, rework가 잦은 부서는 강도를 올리고(Claude는 effort↑, 외부는 상위 모델), 기계 검증 가능한 산출물이 안정적이면 비용을 낮춥니다.

⚠️ **창작팀 함정**: rework 지표는 *검증 가능한 실패*(빌드 깨짐·파일 없음·판정 불일치)만 잡습니다. 카피의 후킹력, 한국어 문장 품질, 디자인 감각 같은 **조용한 품질 저하는 지표에 잡히지 않습니다** — 검수를 통과해도 CTR·가독성은 떨어질 수 있습니다. 그래서 창작(designer·writer)은 gemini 최상위를 유지하고, 비용 때문에 함부로 낮추지 마세요.

### 9번째 직원 채용

```
/madev:hire 인스타 릴스 대본을 쓰는 숏폼팀
```

새 직원은 플러그인이 아니라 **프로젝트의 `.claude/agents/`**에 생성됩니다 — 플러그인 업데이트에 영향받지 않습니다. 채용 후 `CLAUDE.md` 조직도에 한 줄 추가하세요(명령이 안내합니다).

### 새 명령 추가

`madev\commands\` 에 마크다운 파일을 추가하면 `/madev:<파일명>` 명령이 됩니다.

### 버전 관리와 배포

자리 잡으면 git으로 관리하고 GitHub에 올려 다른 컴퓨터에서도 쓸 수 있습니다. 플러그인을 고칠 때마다 `plugin.json`과 `marketplace.json`의 `version`을 올리세요.

### 발전 로드맵 (권장)

1. **1주차**: 수동 운영 — `/madev:standup`으로 보고서 품질 관찰.
2. **2주차**: 큰 일은 `/madev:assign`으로 — 작업폴더·게이트·검수 습관 들이기.
3. **3주차**: 자동화 — `/schedule`로 스탠드업 + 주 1회 `/madev:audit`.
4. **4주차~**: 운영 로그(rework 계측)를 보고 지침 손보기, 필요한 부서 추가 채용.

---

## 4부. 문제 해결

| 증상 | 해결 |
|------|------|
| `/madev:...` 명령이 안 보임 | 재시작 → `/plugin`에서 설치·활성 확인 |
| 에이전트 팀이 동작 안 함 | `~/.claude/settings.json` env 확인 후 재시작. 버전 확인 |
| 직원이 매뉴얼을 무시함 | 프로젝트 루트에 `CLAUDE.md` 있는지 확인. 규칙은 짧고 단호하게 |
| 완료했다는데 결과물이 없음 | `/madev:audit` 실행 → 허위 항목 재작업 지시서가 나옴 |
| 다음 날 뭘 하던 중이었는지 모름 | `/madev:resume` — 작업폴더에서 상태 복구 |
| 비용이 부담됨 | Claude 부서는 `effort` 낮추거나 `model` 하향, 외부 부서(개발·CS·디자인·콘텐츠)는 상위 모델 대신 기본/경량 모델로. "오늘 필요한 팀만 가동" 원칙 확인 |
| 알림이 안 옴 | `adapters/notify.env` 설정 확인 (미설정이면 스킵이 정상 — fail-open) |
