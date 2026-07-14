---
description: 다단계 작업 착수 — 작업폴더를 만들고 마스터가 최소 팀에 분배·검수하며 규율대로 진행
argument-hint: "<작업 목표 (예: 랜딩 페이지 신규 제작과 배포)>"
---

여러 단계·여러 팀이 필요한 작업을 **규율대로** 착수하라. work-memory 스킬의 착수 절차를 따른다.

작업 목표: $ARGUMENTS

master 에이전트에게 전달할 지시:

1. **작업폴더 생성**: `work/<작업명>/`에 파일을 만든다 — `task.md`(목표·완료 기준·필요한 **최소 팀**·status: in_progress) / `context.md`(현재 스냅샷, 짧게) / `log.md`(운영 로그, append-only).

2. **가동 게이트**: 2개 팀 이상이거나 긴 작업이면, 어느 팀을 왜 몇 라운드 돌릴지 계획을 한 줄로 사용자에게 알리고 **동의를 받은 뒤** 착수한다. 동의를 `log.md`에 `[승인]`으로 기록한다.

3. **분배·실행**: 최소 팀만 순서/병렬로 가동한다. **codex 담당(개발·CS)·gemini 담당(디자인·콘텐츠) 작업의 외부 호출은 이 명령을 실행 중인 오케스트레이터 세션(=master 역할)이 직접** 한다 — 부서 서브에이전트나 더 깊은 레벨로 내리지 마라(중첩 위임은 도구·MCP·env 접근 불가로 실패한다). 이 레벨에선 `${CLAUDE_PLUGIN_ROOT}`가 유효하니 `mcp__codex__codex` / `bash "${CLAUDE_PLUGIN_ROOT}/adapters/gemini.sh"`(반드시 `bash`로 실행)를 **부서 spawn보다 먼저** 시도하고, 관측 가능한 실패(도구·명령 부재 / exit≠0 / timeout / 빈 응답 / 거부) 시에만 Claude 부서로 폴백한다. 앞 팀 결과가 다음 팀 입력이면 지시서에 포함한다. 팀 산출물은 `work/<작업명>/results/<팀>.md`에 저장한다. 매 가동 완료를 `log.md`에 `[가동] <팀> 완료 → results/<팀>.md | model=… outcome=… rework=…`로 기록한다(값이 없으면 n/a).

4. **검수**: 결과물을 직접 열어 증거를 확인한다(evidence-report 스킬). 중요한 작업이면 inspector에게 독립 감사를 맡긴다. 검수 결과를 `log.md`에 `[검수]`로 기록한다.

5. **마무리**: `task.md`의 status를 done으로 바꾸고 `log.md`에 `[완료]`를 남긴다. 다음에도 쓸 교훈이 있으면 `work/learnings.md`에 한 줄 append한다. 사용자에게 ✅ 완료(증거) / ⚠️ 미확인 / ❌ 실패·보류 / 📋 다음 할 일로 보고한다.
