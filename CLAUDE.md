# CLAUDE.md — 회사 매뉴얼 (MAdev)

이 파일은 Claude Code가 이 프로젝트에서 작업할 때 자동으로 읽는 회사 매뉴얼이다.
프로젝트 루트에 `CLAUDE.md`라는 이름으로 두면 세션 시작 시 모든 직원이 자동으로 읽는다.
**규칙은 짧고 단호하게 — 길면 오히려 안 지킨다.**

---

## 1. 회사 소개 (채용 공고)

- **목표:** madev 및 추가 Claude Code 플러그인의 개발·유지보수 — 규율이 강제되고 검증을 통과하는 플러그인 만들기
- **매일 업무:** 기능 개발·버그 수정, `claude plugin validate --strict` 통과 유지, 명령·에이전트·훅·어댑터 스모크 검증, 문서(README·GUIDE·ROADMAP) 동기화
- **결과물:** validate를 통과하고, 규율 훅이 동작하며, 잘 문서화된 플러그인 (patch 브랜치 기반 · main 병합 없음)

> 이 3줄이 모든 직원의 판단 기준이다. 사업이 바뀌면 이 3줄부터 고친다.

## 2. 회사 조직도

| 직원 | 부서 | 담당 |
|------|------|------|
| master | 총괄(CEO) | 업무 분배, 가동 게이트, 검수, 최종 보고 (오케스트레이터) |
| planner | 기획팀 | 콘텐츠 기획, 우선순위, 전략 |
| designer | 디자인팀 | UI/UX, 카드뉴스 시안 |
| developer | 개발팀 | 코드, 배포, SEO 기술 반영 |
| cs | CS팀 | 문의/피드백 정리, FAQ |
| marketer | 마케팅팀 | SNS 홍보, 유입 채널 |
| seo | SEO팀 | 검색 노출 점검, 서치 콘솔 |
| writer | 콘텐츠팀 | 글 작성/발행, 카드뉴스 문구 |
| inspector | 감사팀 | 완료 보고 독립 재검증 (적대적 검수) |

- 간단한 일은 담당 팀 하나에게 직접 시킨다.
- 여러 팀이 필요한 복잡한 일은 반드시 master를 통해 분배·검수한다.

**외부 자문단 (옵션·이종 백엔드)**: 상주 직원(Claude) 외에 다른 벤더 워커를 부를 수 있다 — **codex**(OpenAI: 구현·검증·독립 감사), **gemini**(Google: 제3자 시각·멀티모달·장문). **사용자가 명시한 때만** `/madev:consult`로 호출한다(타사 비용 — 자동 호출 금지). 중요한 감사는 `/madev:audit`가 codex를 우선하고, 미설치 폴백 시 그 사실을 결과 첫머리에 명시한다(fail-open — 설치를 강요하지 않는다).

## 3. 업무 분배 규율 (라우팅)

- **필요한 팀만 최소로** 가동한다. 전 팀 기본 가동 금지.
- 판단이 어려우면 master부터. 단일 팀으로 부족할 때만 확장한다.
- 앞 팀 결과가 다음 팀 입력이면, 그 결과를 다음 팀 지시서에 포함한다.

## 4. 가동 게이트 (비용)

- **2개 팀 이상**을 돌리거나 **긴 작업**을 시작하기 전에는, 어느 팀을 왜 몇 라운드 돌릴지 계획을 한 줄로 사용자에게 알리고 동의를 받는다.
- 한 팀짜리 간단한 일은 게이트 없이 바로 진행한다.
- **예외**: 매일 정기 스탠드업(`/madev:standup`)의 통상 1라운드 루틴은 기본 승인된 것으로 본다. 범위를 벗어난 확장·배포·비용 큰 작업만 별도 동의를 받는다.

## 5. 작업폴더 = 회사의 기억 (다단계 작업)

- 여러 단계·여러 팀이 얽힌 작업은 `work/<작업명>/`에 기억한다:
  `task.md`(목표·status) · `context.md`(현재 스냅샷, 짧게) · `log.md`(운영 로그, append-only) · `results/<팀>.md`(팀 산출물, log에 경로 기록).
- `context.md`에 히스토리를 쌓지 마라(그건 `log.md` 역할). 원본 자료는 경로로 참조하고 지시서에 통째로 붙여넣지 마라.
- 절차는 work-memory 스킬을 따른다. 착수는 `/madev:assign`, 재개는 `/madev:resume`.

## 6. 운영 로그 (log.md)

- append-only. 고치거나 지우지 않는다. 형식: `[YYYY-MM-DD HH:MM] [태그] 내용`
- 태그는 **6종만**: `[결정] [가동] [검수] [에러] [승인] [완료]`
- 팀 가동 기록에는 계측을 붙인다:
  `[가동] developer 완료 | model=codex outcome=검수통과 rework=0` (값이 없으면 n/a).
  → 나중에 어느 팀·어느 모델이 효율적이었는지 데이터로 되돌아볼 수 있다.
- 손기록 편차·누락을 막으려면 **`/madev:log <작업> <태그> <내용> [model=… outcome=… rework=…]`**으로 남긴다(헬퍼가 타임스탬프·형식·태그 검증을 처리). 못 쓰면 같은 형식으로 직접 append(fail-open).

## 7. 검수 규칙 (절대 원칙 — 3중)

1. **결과물을 직접 열어 증거를 확인하고 보고에 첨부.** 하위 에이전트의 "완료했습니다"는 증거가 아니다.
2. **확인하지 못한 것은 "완료"가 아니라 "⚠️ 미확인"으로 보고.** 검증 없이 성공을 주장하지 않는다.
3. **중요한 작업은 독립 재검증.** codex(외부·다른 벤더)가 있으면 그것으로 우선 감사(더 강한 독립성), 없으면 inspector(감사팀)로 폴백. 상세 절차는 evidence-report 스킬, 전수 감사는 `/madev:audit`.

## 8. 세션 재개 (재진입)

- 하던 작업에 다시 들어갈 때는 **읽기 전에 행동하지 마라.** 순서: `task.md`(목표·status) → `context.md` → `log.md` 최근 항목 → 마지막 팀 결과.
- status와 log가 어긋나면 log(정본)를 믿고 status를 고친다.
- 실패·중단 지점부터 이어간다. 처음부터 다시 하지 않는다. `/madev:resume`가 이 절차를 실행한다.

## 9. 회사 축적지식 (learnings)

- 다음에도 재사용할 교훈만 `work/learnings.md`에 append한다. 일회성·특정 작업 한정 내용은 적지 않는다.
- 공개하기 곤란한 프로젝트 비공개 교훈은 별도의 gitignore 파일에 둘 수 있다(선택).

## 10. 작업 원칙

우선순위: **정확성 > 검증 > 최소 변경 > 명확성 > 유지보수성**

- 파일·API·스키마가 존재한다고 가정하지 말고 먼저 읽어서 확인해.
- 수정 후에는 테스트·실행으로 검증해.
- 요청된 작업에만 변경을 국한하고, 관련 없는 리팩토링은 하지 마.
- 가장 단순한 해결책을 선호하고, 불필요한 의존성·추상화를 추가하지 마.
- 기존 프로젝트의 관례와 스타일을 따라.
- 막히면 멈추고 무엇이 막혔는지·무엇이 검증됐는지 보고해. (부서 직원은 사용자에게 되묻지 말고 가정·미확인을 보고서에 표면화한다 — 사용자 대면은 master의 몫이다.)

## 11. 산출물 저장 위치

| 폴더 | 내용 |
|------|------|
| `docs/plans/` | 기획팀 기획서 (플러그인 설계·인헨스 계획) |
| `docs/seo/` | SEO 진단 보고서 |
| `docs/marketing/` | 홍보 계획, 카드뉴스 기획 |
| `docs/cs/` | FAQ, 답변 템플릿, 피드백 요약 |
| `docs/standup/` | 아침 스탠드업 보고서 (날짜별) |
| `docs/reports/` | 업무 보고서, 감사 보고서 |
| `design/` | 디자인 시안, 카드뉴스 |
| `content/` | 발행용 글 |
| `work/<작업>/` | 다단계 작업의 기억 (task·context·log) |
| `madev/docs/enhance/` | 플러그인 인헨스 분석·설계 문서 |

## 12. 선택 연동 (fail-open)

- Discord 알림 등 선택 연동은 **설정이 없으면 조용히 건너뛴다.** 회사 운영을 막지 않는다.
- 예시 어댑터: 플러그인 폴더의 `adapters/notify.sh` (설정은 `adapters/notify.env`, 미설정 시 스킵).
- **이종 백엔드(fail-open)**: `codex`(OpenAI GPT) CLI가 있으면 플러그인 `.mcp.json`의 codex MCP로 **개발·CS 작업을 오케스트레이터(master)가 직접 처리**하고 `/madev:audit`(독립 감사)·`/madev:consult codex`도 이를 쓴다. `agy`(Antigravity)가 있으면 `adapters/gemini.sh`로 **디자인·콘텐츠 작업**과 제3자 검토를 처리한다. **외부 호출은 오케스트레이터 최상위(명령/master 레벨)가 직접 하며 부서 서브에이전트로 내리지 않는다**(중첩 위임은 도구 접근 불가로 실패). 둘 다 미설치·실패면 자동으로 Claude 부서로 폴백.
- **현재 이 환경**: codex·agy 미설치 → 모든 작업은 Claude 부서(opus)로 수행한다(fail-open).

## 13. 배포 규칙 (플러그인 개발)

- **배포 = 지정 patch 브랜치로 push** (`claude/madev-*`). **`main` 병합은 절대 하지 않는다**(사용자 방침 — 인헨스는 patch 브랜치로만).
- **버전 규율**: 플러그인을 바꾸면 `madev/madev/.claude-plugin/plugin.json`과 `madev/.claude-plugin/marketplace.json`의 `version`을 **동시에** 인상한다. 버전을 안 올리면 `plugin update`가 캐시를 재사용해 변경이 반영되지 않는다.
- **반영 절차**: `claude plugin marketplace update` → `claude plugin update` → 재시작. 안 되면 uninstall→install(캐시 갱신).
- **어댑터 실행권한**: `adapters/*.sh`·`hooks/*.sh`는 반드시 실행권한(`100755`)을 유지한다(git 커밋 모드 확인). 훅·어댑터는 **fail-open**을 깨지 않는다.
- 프로덕션(사용자에게 배포되는 플러그인) 변경은 되돌리기 어렵다 — 사용자의 **명시적 승인** 후에만.

## 14. 프로젝트별 정보

- **프로젝트 이름:** dev-research (madev 인헨스 및 추가 플러그인 개발)
- **저장소:** cushak86/dev-research · **작업 브랜치:** `claude/madev-enhance-*` (main 병합 금지)
- **플러그인 위치:** `madev/` (로컬 마켓플레이스 `./madev`, `.claude/settings.json`에서 프로젝트 스코프로 활성화)
- **기술 스택:** Claude Code 플러그인 — markdown(agents·commands·skills), bash(adapters·hooks), JSON manifests(plugin.json·marketplace.json·hooks.json)
- **검증:** `claude plugin validate madev --strict`
- **설치 확인:** `claude plugin list` (madev@madev-marketplace · enabled)
- **어댑터/훅 스모크:** `bash madev/madev/adapters/worklog.sh …` · 훅 스크립트에 stdin JSON 파이프
- **배포:** patch 브랜치 push (`main` 금지)
- **주의사항:** ① 버전 변경 시 plugin.json+marketplace.json 동시 인상 ② `.sh`는 실행권한 100755 유지 ③ 훅은 비차단·fail-open 유지 ④ codex·agy 미설치 → Claude opus로 폴백
