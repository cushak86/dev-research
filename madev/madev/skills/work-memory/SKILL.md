---
name: work-memory
description: 다단계·여러 팀 작업을 작업폴더(work/<작업>/, task·context·log·results)로 기억하고, 세션이 끊긴 뒤 하던 일을 재개할 때 사용. 착수(/madev:assign)·재개(/madev:resume) 시 적용.
---

# 작업폴더 = 회사의 기억

세션은 끊긴다. 기억은 파일에 남긴다. 여러 단계·여러 팀 작업은 `work/<작업명>/`에 상태를 기록해 언제든 이어서 일한다. 대화 맥락에만 의존하지 말 것.

## 폴더 구조

```
work/<작업명>/
├── task.md      # 목표 · status(pending/in_progress/done) · 가동 승인된 팀
├── context.md   # 현재 스냅샷만 (히스토리 X). 짧게 유지.
├── log.md       # 운영 로그. append-only.
└── results/     # 팀별 산출물: results/<team>.md (log에 경로를 반드시 기록)
```

## 착수 절차 (assign)

1. `task.md`에 목표·완료 기준·필요한 **최소 팀**을 적는다. status: in_progress.
2. 2개 팀 이상이면 가동 게이트(사용자 동의)를 거친 뒤 `log.md`에 `[승인]`을 기록한다.
3. 최소 팀만 가동하고, 매 가동 완료를 `log.md`에 계측과 함께 남긴다:
   `[가동] developer 완료 | model=codex outcome=검수통과 rework=0` (값이 없으면 n/a).
   팀 산출물은 `results/<team>.md`에 저장하고 **그 경로를 같은 log 줄에 남긴다**(다음 세션이 무엇을 읽을지 알 수 있도록).
4. 검수는 `[검수]`, 판단은 `[결정]`, 문제는 `[에러]`, 마무리는 `[완료]`로 기록한다.
5. 끝나면 `task.md` status: done. 재사용 교훈은 `work/learnings.md`에 한 줄 append한다.

## 재개 절차 (resume) — 읽기 전 행동 금지

1. `task.md`(목표·**status**·팀) → 2. `context.md`(현재) → 3. `log.md` 최근 항목 → 4. 마지막 팀 산출물(`results/<team>.md`, log에 기록된 경로) 순으로 읽는다.
- status와 log가 어긋나면 **log(정본)**를 믿고 status를 고친 뒤 `[결정]`을 기록한다.
- 특정 팀 결과만 미흡하면 그 팀만 다시 가동한다(나머지 결과는 보존).
- 실패·중단 지점부터 이어간다. **처음부터 다시 하지 않는다.**

## 규칙 (어기면 기억이 오염된다)

- `context.md`에 이력을 쌓지 말 것 — 그건 `log.md`의 역할이다. context는 "지금 어디까지 왔나"만.
- 지시서에 파일을 통째로 붙여넣지 말 것 — 경로로 참조한다.
- `log.md`는 고치거나 지우지 말고 **append만** 한다. 태그는 6종만: `[결정] [가동] [검수] [에러] [승인] [완료]`.
- 계측 누락·형식 편차를 막으려면 손으로 쓰지 말고 **`/madev:log <작업> <태그> <내용> [model=… outcome=… rework=…]`**(내부적으로 `adapters/worklog.sh` 실행)로 append한다. 스크립트가 타임스탬프를 붙이고 잘못된 태그를 거부한다. 스크립트를 못 쓰면 같은 표준 형식으로 직접 append(fail-open).
