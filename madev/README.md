# MAdev — 규율 있는 AI 개발회사 (Claude Code 플러그인)

대표(마스터) 1명 + 부서 직원 7명(기획·디자인·개발·CS·마케팅·SEO·콘텐츠) + **감사팀 1명**을 한 번에 채용하는 클로드 코드 플러그인입니다.
ai-company의 "회사" UX에 멀티에이전트 오케스트레이션 규율을 얹었습니다.

## 무엇이 다른가

일반 AI 팀 플러그인 + **오케스트레이션 규율**:

- **업무분배 라우팅** — 마스터가 필요한 팀만 최소로 가동 (전 팀 기본 가동 금지)
- **가동 게이트** — 2팀 이상·긴 작업 전 계획 동의 (비용 관리)
- **작업폴더 기억** — 다단계 작업은 `work/<작업>/`에 목표·상태·로그를 남겨 세션이 끊겨도 이어감
- **3중 증거검수** — 마스터 프롬프트 + evidence-report 스킬 + 분리된 감사팀(inspector, 또는 외부 codex 우선)
- **세션 재개** — `/madev:resume`로 콜드 세션에서 중단 지점부터 재정박 (+ 세션 시작 시 진행 중 작업 자동 상기 훅)
- **운영 로그·축적지식** — 팀 가동 계측(rework) + 재사용 교훈 누적. `/madev:log`로 표준 형식 append(누락 방지)
- **규율 훅 (v1.4)** — 팀 가동 직전 가동게이트·로그·검수 규율을 상기시키는 비차단 넛지(fail-open). 규율을 프롬프트에서 훅 레벨로
- **업종 프리셋 온보딩 (v1.4)** — 블로그·이커머스·SaaS 프리셋으로 회사 매뉴얼 §1·§13·§14를 사업에 맞게 자동 채움
- **이종 백엔드 (worker 모델)** — 지휘·검증·전략은 Claude opus, 개발·CS는 **codex**(OpenAI GPT), 디자인·콘텐츠는 **gemini**(Google). 외부 호출은 **오케스트레이터(master·명령)가 직접** 한다(부서 서브에이전트로 내리지 않음 — 중첩 위임은 런타임 실패). 미설치·실패면 Claude 부서(opus)로 폴백(fail-open). `/madev:consult`·`/madev:audit`도 같은 직접 호출 경로

## 설치

```
/plugin marketplace add D:\agents\sync\MAdev
/plugin install madev@madev-marketplace
```

재시작 후, 운영할 프로젝트 폴더에서:

```
/madev:setup
```

## 명령

| 명령 | 용도 |
|------|------|
| `/madev:setup` | 초기 세팅 (환경·매뉴얼·폴더, **업종 프리셋 온보딩**) |
| `/madev:standup` | 아침 스탠드업 (일상 루틴) |
| `/madev:assign` | 다단계 작업 착수 (라우팅+게이트+작업폴더) |
| `/madev:resume` | 세션 재개 (재진입) |
| `/madev:report` | 증거 기반 업무 보고 |
| `/madev:audit` | 감사팀 전수 재검사 (codex 우선·inspector 폴백) |
| `/madev:consult` | 외부 codex·gemini 자문 (이종 백엔드) |
| `/madev:log` | 운영 로그 표준 형식 append (계측 누락 방지) |
| `/madev:hire` | 신규 직원 채용 |

자세한 설치·운영·확장은 [GUIDE.md](GUIDE.md)를 보세요.
