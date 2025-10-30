---
allowed-tools: Bash(git *), Read(*), Grep(*)
description: Smart git commit with semantic grouping and consolidation
---

## Arguments

- **FILES** (optional): Space-separated list of files to commit
  - If provided: Only analyze and commit specified files
  - If empty: Analyze all changed files from `git status`

## Context

- Current git status: !`git status`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Process

### Step 1: Gather Changed Files

1. If FILES argument provided:
   - Use specified files
   - Verify files are actually modified: !`git status --porcelain {files}`

2. If no FILES argument:
   - Get all changed files: !`git status --porcelain`

### Step 2: Safety Checks & Filtering

**AUTOMATICALLY EXCLUDE (with warning):**
- `.env*` files (all environment files)
- `*.key`, `*.pem` (certificates/keys)
- Files matching `*secret*`, `*password*`, `*credential*` (case-insensitive)

**Display warning if excluded:**
```
⚠️  Excluded from commit (security):
  - .env.development (environment file)
  - secrets.json (credential file)
```

**CHECK and WARN (require confirmation):**
- Large files (>10MB): !`find {files} -type f -size +10M`
- Binary files that seem unusual
- Files outside normal project structure

**If no files remain after filtering:**
- Show message: "No files to commit after safety filtering"
- Exit

### Step 3: Analyze Diffs for Semantic Grouping

For each file that passed safety checks:

1. **Read the diff**: Use `git diff HEAD {file}` or Read tool
2. **Analyze the change semantically** by examining:
   - File path and type (migration, test, doc, source code)
   - Diff content (what changed, why, impact)
   - Related files (if multiple files change same module)

3. **Classify into semantic groups** based on:
   - **Type**: feat, fix, docs, refactor, test, chore, style
   - **Scope**: What area/module is affected (migration, types, backend, frontend, config)
   - **Purpose**: What does this accomplish?

**Grouping heuristics:**
- Migrations (backend/drizzle/*.sql) → Usually separate group per migration or related migrations
- Documentation (.md files) → Group by topic or consolidate if minor
- Type definitions (*types.ts, *.model.ts) → Group with related feature
- Tests (*test.ts, *.spec.ts) → Group with code they test OR separate if standalone
- Configuration files → Usually separate unless clearly related to feature
- Related feature files (e.g., service + controller + types) → Single group

### Step 4: Smart Consolidation

After initial grouping, evaluate:

**Small Group Criteria:**
- 1-2 files
- Changes are minor (< 20 lines total)
- Type is fix/docs/style/chore

**Consolidation Logic:**
1. Count semantic groups
2. Identify small groups
3. If there are 2+ small groups that could logically merge:
   - Suggest consolidation
   - Example: "fix: typo in README.md" + "fix: typo in CLAUDE.md" → "docs: fix typos (2 files)"

**Preserve as separate if:**
- Group is substantial (3+ files OR >50 lines changed)
- Group represents distinct feature/fix
- Migration files (always keep migrations separate)
- Explicitly different types (feat vs fix)

### Step 5: Present Grouping Plan

Display proposed commit groups:

```
Analyzing N files...

Proposed commits:

✓ Commit 1: feat(migration): add entity_question_link audit columns
  Files (2):
  - backend/drizzle/0026_add_missing_audit_columns.sql
  - shared/src/modules/assessments/questions/question.model.ts
  Lines: +45, -3

✓ Commit 2: docs(specs): mark Phase 1 complete in tasks.md
  Files (1):
  - .kiro/specs/application-node-linking/tasks.md
  Lines: +14, -5

⚠️  Small groups detected:

Group A: style: fix formatting in utils.ts (1 file, 5 lines)
Group B: style: fix formatting in helpers.ts (1 file, 3 lines)

Recommendation: Merge into "style: fix formatting (2 files)"
Accept merge? (y/n/custom)
```

**User options:**
- `y` - Accept all proposed commits and merges
- `n` - Keep all groups separate (no merging)
- `custom` - Provide custom grouping instructions

### Step 6: Create Commits

For each approved commit group:

1. **Stage files**: `git add <file1> <file2> ...`
2. **Generate commit message** following conventional commits:
   ```
   <type>(<scope>): <description>

   - Detail 1
   - Detail 2

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

3. **Create commit**: `git commit -m "..."`
4. **Verify**: `git log -1 --stat`

### Step 7: Summary

Display all commits created:
```
✅ Created 3 commits:

1. abc123f feat(migration): add entity_question_link audit columns
2. def456a docs(specs): mark Phase 1 complete in tasks.md
3. ghi789b style: fix formatting (2 files)

Recent commits:
!`git log --oneline -5`
```

## Commit Message Format

Follow conventional commits with enhancements:

**Type:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `refactor` - Code refactoring
- `test` - Adding/updating tests
- `chore` - Maintenance tasks
- `style` - Formatting, missing semicolons, etc.
- `perf` - Performance improvements

**Scope (optional but recommended):**
- `migration` - Database migrations
- `types` - Type definitions
- `api` - API changes
- `ui` - User interface
- Module name (e.g., `assessments`, `questions`)

**Description:**
- Imperative mood ("add" not "added")
- No period at the end
- Max 72 characters
- Describe what, not how

**Body (for complex changes):**
- Bullet points for multiple changes
- Explain why if not obvious
- Reference issues/PRs if applicable

## Error Handling

**If grouping analysis is unclear:**
1. Fall back to directory-based grouping
2. Show warning: "⚠️ Unable to determine semantic grouping, using directory-based groups"
3. Present for approval before committing

**If git operations fail:**
1. Show clear error message
2. Suggest remediation steps
3. Don't leave repository in inconsistent state

**If user cancels:**
1. Don't create any commits
2. Leave working directory unchanged
3. Show message: "Commit cancelled. No changes staged."

## Examples

### Example 1: Multiple related changes
```
User: /commit

Analyzing 5 files...

✓ Commit 1: feat(auth): implement JWT refresh token rotation
  Files (4):
  - backend/src/modules/auth/auth.service.ts (+45, -12)
  - backend/src/modules/auth/auth.controller.ts (+23, -5)
  - backend/src/modules/auth/types/auth.types.ts (+15, -0)
  - backend/__tests__/modules/auth/refresh.test.ts (+67, -0)

✓ Commit 2: docs: update authentication guide
  Files (1):
  - docs/authentication.md (+34, -8)

Accept? (y/n)
```

### Example 2: Small groups needing consolidation
```
User: /commit

Analyzing 6 files...

✓ Commit 1: feat(migration): add user preferences table
  Files (1):
  - backend/drizzle/0027_user_preferences.sql (+42, -0)

⚠️  Small groups detected:
Group A: fix: typo in README.md (1 file, 2 lines)
Group B: fix: typo in CONTRIBUTING.md (1 file, 1 line)
Group C: style: format package.json (1 file, 3 lines)

Recommendation:
- Merge Groups A+B → "docs: fix typos (2 files)"
- Keep Group C separate

Accept merge? (y/n/custom)
```

### Example 3: Specific files
```
User: /commit backend/src/auth.ts backend/src/types.ts

Analyzing 2 specified files...

✓ Commit 1: feat(auth): add role-based permissions
  Files (2):
  - backend/src/auth.ts (+34, -5)
  - backend/src/types.ts (+12, -2)

Accept? (y/n)
```
