# 1.5 Claude Code Deep Dive

> Claude Code is not autocomplete — it is a full coding agent that reads your codebase, plans changes, edits files, runs commands, and iterates. This section covers every feature your team needs to master.

> **Split with 1.3:** The *decision* to use Claude Code and the comparison with alternatives live in [1.3 Tooling Selection](03-tooling-selection.md). The *detailed feature reference* lives here.

---

## Goals

- Understand every major Claude Code capability before using it on production code
- Know when to use the CLI vs the VS Code Extension
- Configure CLAUDE.md, permissions, and memory for the team's workflow
- Be prepared for supervised AI use in Phase 2

---

## Terminal (CLI) vs VS Code Extension

Claude Code comes in two forms. Use both — they complement each other.

### CLI (Terminal Agent)

Run from any project directory:
```bash
npm install -g @anthropic-ai/claude-code
claude
```

**Best for:**
- Multi-file refactors spanning many files
- Autonomous tasks: "refactor this controller, update tests, run Pint"
- CI/CD scripting and automation
- Working over SSH or in environments without a GUI
- Long-running tasks where you describe the goal and let the agent work

### VS Code Extension

Install from the marketplace: **Claude Code** by Anthropic.

**Best for:**
- Single-file edits with inline diff preview
- Asking questions about the code you're looking at
- Quick fixes where you want to review each change before accepting
- Pair-programming style interaction — low friction, high control

### Running Both Simultaneously

- The extension and CLI can run in the same project at the same time
- They share the same `CLAUDE.md` and project context
- Tip: Use the extension for the current task, CLI for a parallel background task

### Quick Comparison

| | **VS Code Extension** | **CLI (Terminal)** |
|--|----------------------|--------------------|
| Interface | IDE sidebar | Terminal |
| Best for | Targeted edits, questions, inline review | Long autonomous tasks, multi-file refactors |
| Context | Current file + open tabs | Entire project (you control scope) |
| Control | High — you see every change | Variable — agent works independently |
| Phase fit | Phase 2 (supervised) | Phase 3 (agentic) |

> Start the team on the **extension** in Phase 2. Introduce the **CLI agent** in Phase 3 as confidence grows.

---

## Slash Commands Reference

Slash commands are typed directly in the Claude Code prompt. They control modes, manage sessions, and trigger workflows.

### Session & Navigation

| Command | Description |
|---------|-------------|
| `/help` | Show all available commands and usage |
| `/compact` | Compress conversation history to free up context window space |
| `/clear` | Clear the entire conversation and start fresh |
| `/status` | Show current session info — model, mode, token usage |
| `/cost` | Show token usage and cost for the current session |

### Model & Configuration

| Command | Description |
|---------|-------------|
| `/model` | Switch the active model mid-session (e.g., `/model sonnet`, `/model opus`) |
| `/config` | Open or modify Claude Code configuration |

### Modes

| Command | Description |
|---------|-------------|
| `/plan` | Enter Planning Mode — Claude explores and analyzes but does NOT edit files |
| `/fast` | Toggle fast mode (same model, faster output) |

### Coding Workflows

| Command | Description |
|---------|-------------|
| `/commit` | Stage changes, generate a commit message, and create a git commit |
| `/review` | Review code changes or a pull request with detailed feedback |
| `/pr-comments` | View and address PR review comments |

### File & Context

| Command | Description |
|---------|-------------|
| `/add-dir` | Add an additional working directory to the session context |
| `/release-notes` | Generate release notes from recent changes |

### Tools & Integrations

| Command | Description |
|---------|-------------|
| `/mcp` | Show connected MCP servers and their status |
| `/listen` | Listen for input from external sources |

### System

| Command | Description |
|---------|-------------|
| `/login` | Sign in to your Anthropic account |
| `/logout` | Sign out of the current session |
| `/doctor` | Run diagnostics to check Claude Code health and configuration |
| `/bug` | Report a bug to the Claude Code team |

> You can also type `/` in the prompt and Claude Code will show autocomplete suggestions for available commands.

---

## Planning Mode

### What It Is

A read-only mode where Claude explores, analyzes, and designs an implementation plan — but does **NOT** edit any files. Think of it as "let the AI study the problem before touching anything."

### When to Use It

- Before starting a complex refactor — let Claude map the codebase first
- Architecture decisions — ask Claude to explore and recommend an approach
- When you want analysis without risk of accidental changes
- Understanding unfamiliar code — Claude reads and explains without modifying

### How It Works

1. Enter planning mode with `/plan` or start with `claude --plan`
2. Claude can read files, search with grep/glob, run read-only commands
3. Claude outputs a structured plan with file lists and implementation steps
4. Review the plan, ask questions, refine
5. When satisfied, exit planning mode to begin execution

### Practical Example

```
/plan How should we refactor the OrderController to use Action classes?
Show me which files are involved and what the migration steps would be.
```

Claude will explore the codebase, identify all related files, and produce a step-by-step plan — without changing a single line.

---

## Edit Mode — How Claude Changes Files

### The Approve/Reject Flow

Every file edit Claude proposes goes through an approval cycle:

1. Claude proposes a change as a diff (you see exactly what will change)
2. You can **approve** (apply the change), **reject** (skip it), or **ask for revision**
3. Rejected edits are not applied — Claude can try a different approach based on your feedback

In the **VS Code Extension**, changes appear as inline diffs in the editor — just like a code review.

In the **CLI**, you see a terminal diff and confirm with `y` or `n`.

### Permission Modes

| Mode | Behavior | Best For |
|------|----------|---------|
| **Default** | Ask permission for each edit and command | Learning phase, sensitive code |
| **Auto-edit** | Auto-approve file edits, ask for commands | Trusted refactors |
| **YOLO / Full auto** | Auto-approve everything | Phase 3, well-tested codebases with CI safety nets |

### Keyboard Shortcuts (CLI)

| Key | Action |
|-----|--------|
| `y` / `Enter` | Approve the proposed change |
| `n` | Reject the proposed change |
| `e` | Edit the proposed change before applying |
| `Esc` | Interrupt Claude mid-response |
| `Shift+Tab` | Toggle between single-line and multi-line input |

---

## Thinking Mode / Extended Thinking

### What It Is

Extended thinking lets Claude reason through complex problems step-by-step before responding. Claude shows its internal reasoning chain, producing more thorough and considered answers.

### When to Use It

- Complex architectural decisions with multiple tradeoffs
- Debugging subtle issues where the cause is not obvious
- Multi-step refactors where order of operations matters
- When Claude's initial answer seems shallow or misses edge cases

### How It Works

- Thinking is controlled by the **effort** setting (see next section)
- Higher effort = more thinking = better results for hard problems
- Lower effort = faster responses for simple tasks
- Claude decides how much to think based on the task complexity when set to `auto`

---

## Effort Levels

### What They Control

Effort determines how much reasoning Claude applies to each response. Higher effort means more extended thinking, better results for complex tasks, but more tokens and slower responses.

### Choosing the Right Level

| Level | Best For | Speed | Token Cost |
|-------|---------|-------|-----------|
| `auto` | Let Claude decide (default, recommended) | Variable | Variable |
| `low` | Simple questions, quick lookups, explanations | Fast | Low |
| `medium` | Standard coding tasks, single-file edits | Medium | Medium |
| `high` | Complex refactors, architecture, hard debugging | Slow | High |

### Setting Effort

In the CLI, press `Shift+Tab` to access settings, or:

```bash
claude config set effort high
```

> **Rule of thumb:** Leave it on `auto`. Claude will think harder when it needs to. Override to `high` only when you know the task is complex and Claude isn't giving deep enough answers.

---

## CLAUDE.md — Project Instructions

### What It Is

A markdown file in your project root that Claude reads **automatically** at the start of every session. It contains team conventions, architecture rules, and coding standards. Think of it as "onboarding docs for your AI teammate."

### What to Put in It

```markdown
# CLAUDE.md

## Project Overview
E-commerce platform built with Laravel 11, PHP 8.2, MySQL 8.

## Architecture
- Controllers: thin, delegate to Action classes
- Business logic: app/Actions/{Domain}/{VerbNounAction}.php
- Validation: Form Requests, never validate in controllers
- Models: relationships and scopes only, no business logic

## Coding Standards
- Follow PSR-12 via Laravel Pint
- Use PHP 8.2+ features (enums, readonly, named arguments)
- Strict types in every file: declare(strict_types=1)

## Testing
- Use Pest, not PHPUnit
- Every Action must have a unit test
- Run: ./vendor/bin/pest

## Important Rules
- Never modify migrations that have been run in production
- Always use database transactions for multi-step operations
- Never use env() outside config files
```

### Placement and Hierarchy

| Location | Scope |
|----------|-------|
| Root `CLAUDE.md` | Applies to the entire project |
| `app/Actions/CLAUDE.md` | Applies only within that directory (additive) |
| `tests/CLAUDE.md` | Testing-specific instructions |

Claude reads **all applicable** CLAUDE.md files for the current context — root + any subdirectory-level ones.

### Team Convention

- **Commit** CLAUDE.md to the repository — it's shared team configuration
- **Review** changes to CLAUDE.md in PRs — it shapes AI behavior for everyone
- **Update** it as conventions evolve — it's a living document

---

## Memory

### What It Is

Persistent information Claude remembers **across sessions**, stored locally on the developer's machine. Unlike CLAUDE.md (which is shared via git), memory is personal to each developer.

### How It Works

- Tell Claude: *"Remember that our staging server is at staging.example.com"*
- Claude saves this to local memory files
- In future sessions, Claude recalls it automatically
- You can ask Claude to forget specific things

### Memory vs CLAUDE.md

| | **CLAUDE.md** | **Memory** |
|--|--------------|-----------|
| Shared with team | Yes (committed to git) | No (local to your machine) |
| Best for | Coding standards, architecture rules | Personal preferences, local environment details |
| Persists across | All developers, all sessions | Your sessions only |
| Updated by | PR review | Conversation |

> Use **CLAUDE.md** for everything the team should follow. Use **memory** for your personal context.

---

## Permissions

### Permission Model

Claude asks permission before performing potentially destructive actions. This is configurable per tool and per project.

### Configuration Options

| Setting | Effect |
|---------|--------|
| Per-tool approval | Approve each tool use individually (safest) |
| Auto-allow reads | Allow all read operations without prompting |
| Auto-allow writes | Allow file edits without prompting |
| Allow specific commands | e.g., allow `npm test`, `./vendor/bin/pint` |
| Deny list | Block specific tools or commands entirely |

### Recommended Setup by Phase

| Phase | Read Files | Edit Files | Run Commands |
|-------|-----------|------------|-------------|
| **Phase 1-2** | Auto-allow | Ask each time | Ask each time |
| **Phase 3 (early)** | Auto-allow | Auto-allow | Ask for new commands |
| **Phase 3 (mature)** | Auto-allow | Auto-allow | Auto-allow trusted commands |

### Configuring Permissions

```bash
# Allow read operations
claude config set permissions.allow-read true

# Allow specific commands without prompting
claude config set permissions.allow-commands "npm test,./vendor/bin/pint,./vendor/bin/pest"
```

---

## Model Selection

### Switching Models Mid-Session

```
/model                    # interactive selection
/model opus               # switch to Opus
/model sonnet             # switch to Sonnet
/model haiku              # switch to Haiku (fast, cheap)
```

### When to Switch

| Situation | Model |
|-----------|-------|
| Complex refactors, architecture decisions | **Opus** |
| Quick questions, explanations, simple edits | **Sonnet** |
| Rapid iterations, cost-sensitive tasks | **Haiku** |

### Model Comparison

| | **Opus 4.6** | **Sonnet 4.6** | **Haiku 4.5** |
|--|-------------|---------------|--------------|
| Context window | 1M tokens | 200K tokens | 200K tokens |
| Strength | Deepest reasoning, best for complex multi-file tasks | Great balance of speed and quality | Fastest, cheapest |
| Agentic capability | Full | Full | Full |
| Best for | Architecture decisions, complex refactors, multi-step debugging | Daily coding, standard features, code review | Quick questions, simple edits, explanations |
| Speed | Slower | Fast | Fastest |
| Cost | Highest | Medium | Lowest |
| When to use | Task has 3+ steps, touches 5+ files, or requires deep reasoning | Default for everyday work | Quick lookups, simple one-line changes |

### Default Configuration

```bash
claude config set model claude-opus-4-6      # default to Opus
claude config set model claude-sonnet-4-6    # default to Sonnet
```

> Cross-reference: See [1.3 Tooling Selection](03-tooling-selection.md) for the full model comparison table.

---

## MCP (Model Context Protocol)

### What It Is

MCP is a protocol that lets Claude connect to **external tools and data sources**. Think of it as "plugins" for Claude Code — extending what Claude can access beyond local files.

### Use Cases for Laravel Teams

| MCP Server | What It Provides |
|------------|-----------------|
| Database | Schema-aware queries, table structure inspection |
| Notion / Linear / Jira | Read tickets, update status, link PRs |
| Sentry | Read error reports, understand production issues |
| Playwright | Browser automation for testing |
| Custom internal APIs | Connect Claude to your own services |

### Configuration

MCP servers are defined in Claude Code's settings file:

```json
{
  "mcpServers": {
    "database": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-server-postgres", "postgresql://..."]
    }
  }
}
```

### Security Considerations

- Only connect MCP servers you trust
- Review what permissions each server grants
- MCP servers run locally — they do not send your data to Anthropic
- Use read-only database connections for safety

---

## Hooks

### What They Are

Scripts that run automatically **before or after** Claude uses a tool. Similar concept to git hooks, but for Claude's tool execution.

### Use Cases

| Hook Trigger | Example Use |
|-------------|-------------|
| Before file edit | Validate the target file isn't locked or protected |
| After file edit | Auto-format with Pint after every PHP file change |
| Before shell command | Validate the command is safe before execution |
| After shell command | Log all commands Claude runs for audit |

### Configuration

Hooks are defined in Claude Code's settings:

```json
{
  "hooks": {
    "postToolUse": [
      {
        "tool": "edit",
        "command": "./vendor/bin/pint $FILE"
      }
    ]
  }
}
```

### Why Hooks Matter

- Enforce standards automatically — even when Claude forgets
- Audit trail — log what Claude does for team review
- Safety net — block dangerous operations before they happen

---

## Git Worktrees

### What They Are

Git worktrees let you check out **multiple branches simultaneously** in separate directories. Claude Code can work in a worktree for isolated branch work without affecting your main working directory.

### Why Use Them with Claude Code

- Work on a feature yourself while Claude refactors in another worktree
- No branch switching — no stashing — no context loss
- Each worktree has its own working directory but shares the git history

### Setup

```bash
# Create a worktree for a feature branch
git worktree add ../my-project-feature feature/PROJ-101-new-feature

# Run Claude in the isolated worktree
cd ../my-project-feature
claude
```

### When to Use

- Parallel AI tasks on different features
- Reviewing Claude's work on a branch without leaving your current work
- Phase 3: running multiple Claude agents on different features simultaneously

---

## Subagents

### What They Are

Claude can spawn **sub-tasks** that run in parallel. Each subagent handles a specific part of a larger task independently.

### How They Work

1. Claude identifies parts of the task that can run in parallel
2. Each subagent works independently (e.g., "explore the auth module" while another "explores the payment module")
3. Results are collected and merged
4. You still approve the final changes

### When They Activate

- Large-scale search-and-analyze tasks across a big codebase
- Exploring multiple independent areas simultaneously
- Tasks where parallelism is safe (no file conflicts between subtasks)

> You don't need to configure subagents — Claude uses them automatically when beneficial.

---

## Context Management

### How the Context Window Works

- Claude has a finite context window (1M tokens for Opus, 200K for Sonnet)
- Every message, file read, and tool output consumes tokens
- When context fills up, earlier conversation details get compressed automatically

### /compact — Reclaim Context

The `/compact` command compresses conversation history:

- Keeps essential information (decisions, current task, key findings)
- Discards verbose tool outputs and intermediate steps
- Use it when Claude starts repeating itself or losing track

### Best Practices

| Practice | Why |
|----------|-----|
| Start focused — tell Claude exactly what you need | Avoids wasting context on exploration |
| Avoid reading unnecessary files | Each file read costs tokens |
| Use `/compact` proactively during long sessions | Prevents context overflow |
| Break very large tasks into multiple sessions | Better than one overloaded session |
| Keep CLAUDE.md concise | It's re-read at the start of every session |
| Use `/clear` to start completely fresh | When the conversation has drifted too far |

---

## Multi-file Operations

### How Claude Handles Complex Refactors

1. Claude reads the relevant files and builds a mental model of the code
2. Plans the changes across all files (especially in Planning Mode)
3. Proposes edits file by file — you review each diff
4. Tracks dependencies between files (e.g., renaming a method updates all call sites)

### Best Practices

- **Give clear scope:** "Refactor the User module" not "fix everything"
- **Use CLAUDE.md** to define the target architecture — Claude follows it
- **Review multi-file diffs carefully** — check the edges (imports, type hints, references)
- **For very large refactors:** use Planning Mode first, then execute in phases
- **Run tests after each phase** — catch issues early

---

## Checklist — Done When

- [ ] Every developer has used Claude Code CLI at least once
- [ ] Every developer has used the VS Code Extension at least once
- [ ] Team understands the difference between CLI and Extension use cases
- [ ] Team knows the main slash commands: `/plan`, `/model`, `/compact`, `/commit`, `/clear`, `/help`
- [ ] `CLAUDE.md` created and committed to the project repository
- [ ] `CLAUDE.md` reviewed and agreed on by the team
- [ ] Permissions configured appropriately for the current phase
- [ ] Team knows how to use Planning Mode for exploration before editing
- [ ] Team knows how to switch models with `/model`
- [ ] Team knows how to manage context with `/compact` and `/clear`
- [ ] At least one multi-file refactor completed under supervision
- [ ] Team is ready for Phase 2 supervised AI introduction
