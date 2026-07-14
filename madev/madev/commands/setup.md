---
description: MAdev 회사 초기 세팅 — 에이전트 팀 활성화 + 회사 매뉴얼(CLAUDE.md) 설치 + 작업 폴더 준비
---

MAdev 회사의 초기 세팅을 순서대로 수행하라.

## 1. 에이전트 팀 환경 활성화
`~/.claude/settings.json` 파일을 열어라 (없으면 새로 만들어라).
`env` 항목에 다음을 추가하되, **기존 JSON 구조와 다른 설정은 그대로 유지**하고 env 항목만 병합하라:

```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

## 2. 회사 매뉴얼 설치 (업종 프리셋 + 대화형 채움)
현재 프로젝트 루트에 `CLAUDE.md`가 있는지 확인하라.
- **없으면**:
  1. **업종 프리셋을 고르게 하라** — 사용자에게 한 줄로 묻는다: "사업 유형이 무엇인가요? (1) 블로그/콘텐츠 광고수익 (2) 이커머스/쇼핑몰 (3) SaaS/웹앱 (4) 기타(직접 입력)". 대답에 따라 `${CLAUDE_PLUGIN_ROOT}/templates/presets/{blog|commerce|saas}.md`를 읽는다. (4)면 프리셋 없이 아래 3줄을 직접 인터뷰한다.
  2. `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.company.md`를 읽어 프로젝트 루트에 `CLAUDE.md`로 복사하되, **§1 회사 소개·§13 배포 규칙·§14 프로젝트별 정보**를 고른 프리셋 내용으로 교체한다. 프리셋의 빈 값(사이트 URL·스택 등)은 사용자에게 짧게 물어 채우고, 확인 못 한 값은 빈칸+`⚠️`로 남긴다.
  3. §1의 채용 공고 3줄(목표·매일 업무·결과물)은 반드시 사용자 사업에 맞게 확정한다 — 이 3줄이 모든 직원의 판단 기준이다.
- **이미 있으면**: 덮어쓰지 말고, 템플릿의 **핵심 운영 규율**(§2 조직도 · §3 업무분배 · §4 가동게이트 · §5 작업폴더 · §6 운영로그 · §7 검수 · §8 세션재개 · §9 축적지식) 중 기존 파일에 없는 섹션만 골라 기존 파일 끝에 추가할지 사용자에게 물어보라. (가동게이트·작업폴더·세션재개가 빠지면 이 플러그인의 핵심 기능이 설치되지 않는다.)

## 3. 작업 폴더 준비
프로젝트에 다음 폴더가 없으면 생성하라: `docs/plans`, `docs/seo`, `docs/marketing`, `docs/cs`, `docs/standup`, `docs/reports`, `design`, `content`, `work`
그리고 `work/learnings.md`가 없으면 헤더만 있는 파일로 생성하라 (내용: `# 회사 축적지식 — 재사용 가능한 교훈만 append. 일회성·특정작업 한정은 적지 않는다.`).

## 4. (선택) 알림 연동 안내
사용자가 원하면 `${CLAUDE_PLUGIN_ROOT}/adapters/notify.env.example`을 참고해 Discord 웹훅을 설정할 수 있다고 1줄 안내하라. **미설정이어도 회사는 정상 동작한다(fail-open).** 강요하지 마라.

## 4b. (선택) 외부 자문단 안내
`codex` CLI 또는 `agy`(Antigravity)가 설치돼 있으면 `/madev:consult`·`/madev:audit`가 외부 이종 백엔드(codex·gemini)를 활용한다고 1줄 안내하라. `codex`가 PATH에 있는지 `command -v codex`로 확인해 알려줘도 좋다. **둘 다 없어도 회사는 Claude만으로 정상 동작한다(fail-open)** — 설치를 강요하지 마라.

## 5. 세팅 확인 보고
다음을 표로 보고하라:
- settings.json 환경변수 적용 여부 (실제 파일 내용을 읽어 확인한 증거 포함)
- CLAUDE.md 설치 여부
- 생성된 폴더 목록 + `work/learnings.md`
- 채용된 직원 9명 목록 (master, planner, designer, developer, cs, marketer, seo, writer, inspector)

마지막에 안내하라: "환경변수 적용을 위해 클로드 코드를 재시작해 주세요. 재시작 후 `/madev:standup`으로 아침 회의를, `/madev:assign <작업>`으로 다단계 작업을 시작할 수 있습니다."
