# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
gt done               # Signal work complete (REQUIRED!)
```

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
- **ALWAYS run `gt done` after completing work** - This signals the system that you're finished!

## For Polecats: Work Completion (NEVER SKIP)

**작업 완료 후 반드시 실행:**
1. 코드 변경 시 테스트/린터 실행
2. `git add -A && git commit -m "message" && git push`
3. **`gt done` 실행** - 이것이 없으면 작업이 완료로 인식되지 않음!

⚠️ `gt done`을 호출하지 않으면:
- 대시보드에 작업이 진행 중으로 표시됨
- 다른 작업이 할당되지 않음
- 리소스가 낭비됨

Work is NOT complete until `gt done` succeeds. **Done means gone.**

