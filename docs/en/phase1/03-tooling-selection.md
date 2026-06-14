# 1.3 Tooling Selection

> Standards without tools are just intentions. Tools enforce standards automatically - even when the team is tired, rushed, or doesn't remember the rules.

> **Split with 1.2:** Code style *rules* live in [1.2 Laravel Standards](02-laravel-standards.md). The *tools that enforce them* - IDE, extensions, pre-commit, static analysis - live here.

---

## Goals

- Select an IDE that integrates AI natively and works well with Laravel
- Pick the AI assistant the team will actually use day-to-day
- Auto-format on save, auto-check on commit - zero manual effort required
- Make it structurally impossible to push code that fails style or static analysis

---

## IDE Selection

### Candidates

| IDE | Strengths | Weaknesses |
|-----|-----------|------------|
| **Anti-gravity** | AI-native, agentic workflows built-in, VS Code compatible, free | Newer, smaller community |
| Cursor | AI-integrated, familiar VS Code base, popular | Paid, AI is a subscription layer on top of the editor |
| VS Code | Free, huge extension ecosystem | No native AI - fully reliant on extensions |
| PhpStorm | Best PHP/Laravel code intelligence | Paid, heavy, not AI-native |

### Recommendation: Anti-gravity

Anti-gravity is an AI-native editor designed from the ground up for agent-assisted coding. Unlike Cursor - which layers AI on top of VS Code - Anti-gravity treats AI as a first-class part of the workflow.

**Key advantages for this migration:**

- Built for agentic coding - aligns directly with Phase 3 goals
- VS Code extension compatibility - existing extensions and settings still work
- Free - no per-seat subscription cost for the team
- Encourages AI-first thinking from day one

### Why Not Cursor?

Cursor is a solid choice and widely adopted - but it positions itself as the AI product, not just the tool. The team ends up dependent on Cursor's AI subscription rather than building skills with a model-agnostic workflow.

> Anti-gravity + Claude Code = a stack you control. Cursor = a stack someone else controls.

---

## AI Coding Assistant

### Claude Code vs Cursor AI

| | **Claude Code** | Cursor AI |
|--|-----------------|-----------|
| Model | Claude Opus 4.6 - best in class for code | GPT-4o / Claude (their choice) |
| Interface | Terminal + IDE agent | Embedded in Cursor only |
| Agentic capability | Full agent - reads, edits, runs commands | Composer mode (limited) |
| Context window | Up to 1M tokens | Limited context |
| Portability | Works in any terminal, any repo | Cursor-only |
| Cost | Per token (pay for what you use) | Monthly subscription |
| Team control | Full - you choose the model and prompts | Locked to Cursor's implementation |

### Recommendation: Claude Code

Claude Code is the AI tool for this migration. It runs as an agent - not just autocomplete - which means it can read your codebase, plan changes, run tests, and iterate. That's the foundation of Phase 3.

### Claude Code: Two Ways to Use It

Claude Code comes in two forms - use both, they complement each other.

#### 1. Claude Code VS Code Extension (Primary)

Install directly from the VS Code marketplace: **Claude Code** by Anthropic.

The extension integrates Claude Code into the IDE sidebar. You interact with it without leaving your editor.

**Best for:**
- Asking questions about the file you're looking at
- Requesting targeted edits with full IDE context (open tabs, selection, errors)
- Reviewing and accepting/rejecting AI changes inline
- Daily coding - the low-friction way to work with AI

**Install in VS Code / Anti-gravity:**
```
Extensions → Search "Claude Code" → Install
```

Then sign in with your Anthropic account or API key.

#### 2. Claude Code CLI (Terminal Agent)

Install globally via npm:
```bash
npm install -g @anthropic-ai/claude-code
```

Run from any project directory:
```bash
claude
```

**Best for:**
- Complex, multi-step tasks that span many files
- Agentic workflows - let Claude read, edit, run, and iterate autonomously
- Running in CI or scripted pipelines
- Tasks where you describe the goal and let the agent work through it

**Example session:**
```bash
claude "Refactor the OrderController to use Form Requests and an action class.
       Follow the conventions in CLAUDE.md. Run Pint after."
```

### CLI vs Extension - Quick Comparison

| | **VS Code Extension** | **CLI (Terminal)** |
|--|----------------------|--------------------|
| Interface | IDE sidebar | Terminal |
| Best for | Targeted edits, questions, inline review | Long autonomous tasks, multi-file refactors |
| Context | Current file + open tabs | Entire project (you control scope) |
| Control | High - you see every change | Variable - agent works independently |
| Phase fit | Phase 2 (supervised) | Phase 3 (agentic) |

> Start the team on the **extension** in Phase 2. Introduce the **CLI agent** in Phase 3 as confidence grows.

> For a comprehensive deep dive into all Claude Code features - Planning Mode, Edit Mode, Skills, Slash Commands, CLAUDE.md, MCP, Hooks, and more - see [1.5 Claude Code Deep Dive](05-claude-code.md).

---

## Model Selection

### The Model: Claude Opus 4.6

Use **Claude Opus 4.6** (`claude-opus-4-6`) as the default model for the team. It is the most capable model for complex, multi-file agentic coding tasks.

Configure it in Claude Code:
```bash
claude config set model claude-opus-4-6
```

### Why Opus 4.6 Over the Alternatives

| Model | Provider | Code Quality | Context | Agentic | Best For |
|-------|----------|-------------|---------|---------|----------|
| **Claude Opus 4.6** | Anthropic | ⭐⭐⭐⭐⭐ | 1M | ✅ Full | Complex tasks, multi-file, architecture decisions |
| Claude Sonnet 4.6 | Anthropic | ⭐⭐⭐⭐ | 200K | ✅ Full | Everyday tasks, faster response, lower cost |
| GPT-4o | OpenAI | ⭐⭐⭐⭐ | 128K | ⚠️ Partial | General purpose, broad ecosystem |
| GPT-o3 | OpenAI | ⭐⭐⭐⭐⭐ | 128K | ⚠️ Partial | Deep reasoning, slower |
| Gemini 2.0 Pro | Google | ⭐⭐⭐⭐ | 1M | ⚠️ Partial | Large context, Google Workspace integration |
| Gemini 2.5 Flash | Google | ⭐⭐⭐ | 1M | ⚠️ Partial | Fast, cheap, good for simple tasks |
| DeepSeek R2 | DeepSeek | ⭐⭐⭐⭐ | 128K | ❌ Limited | Cost-effective, strong on logic |

**Why Claude Opus 4.6 wins for agentic Laravel development:**

- **Best at following complex instructions** - multi-step refactors, architecture decisions, long tasks stay on track
- **1M token context** - can hold an entire feature's worth of files in one session
- **Full agentic tool use** - reads files, runs commands, writes tests, iterates without constant prompting
- **Respects your standards** - given a `CLAUDE.md` with your team conventions, it follows them consistently
- **Safety-first reasoning** - less likely to hallucinate breaking changes

### When to Use Sonnet Instead

Sonnet 4.6 is the right choice for:
- Quick questions and short tasks
- Explaining a block of code
- Generating a single migration or simple CRUD
- Situations where response speed matters

> **Rule of thumb:** Use Opus when the task has multiple steps or touches multiple files. Use Sonnet when it's a single focused question or small edit.

---

## VS Code Extensions

These apply to both Anti-gravity and VS Code. Add a shared `.vscode/extensions.json` to the repo so the IDE recommends them automatically to every team member.

### Required Extensions

| Extension | ID | Purpose |
|-----------|-----|---------|
| PHP Intelephense | `bmewburn.vscode-intelephense-client` | Code intelligence, go-to-definition, autocomplete |
| Laravel Pint | `open-in-browser.laravel-pint` | Auto-format PHP on save using Pint |
| PHPStan | `swordev.phpstan` | Inline static analysis errors |
| EditorConfig | `editorconfig.editorconfig` | Enforce `.editorconfig` rules automatically |
| Laravel Artisan | `ryannaddy.laravel-artisan` | Run artisan commands from the IDE |
| DotENV | `mikestead.dotenv` | Syntax highlighting for `.env` files |

### `.vscode/extensions.json`

Commit this file so the IDE auto-suggests extensions when someone opens the project:

```json
{
    "recommendations": [
        "bmewburn.vscode-intelephense-client",
        "open-in-browser.laravel-pint",
        "swordev.phpstan",
        "editorconfig.editorconfig",
        "ryannaddy.laravel-artisan",
        "mikestead.dotenv"
    ]
}
```

### `.vscode/settings.json`

Format on save with Pint, PHPStan enabled inline:

```json
{
    "editor.formatOnSave": true,
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "files.eol": "\n",
    "[php]": {
        "editor.defaultFormatter": "open-in-browser.laravel-pint"
    },
    "phpstan.enabled": true,
    "phpstan.configFile": "phpstan.neon",
    "intelephense.environment.phpVersion": "8.2"
}
```

*Commit `.vscode/settings.json` - shared IDE config is part of the project, not personal preference.*

---

## Code Quality Tools

### PHPStan + Larastan

[PHPStan](https://phpstan.org) catches bugs before they run. [Larastan](https://github.com/larastan/larastan) extends it with Laravel-specific rules (Eloquent, relationships, facades).

**Install:**
```bash
composer require --dev phpstan/phpstan larastan/larastan
```

**Configure** `phpstan.neon` in the project root:
```neon
includes:
    - vendor/larastan/larastan/extension.neon

parameters:
    paths:
        - app

    level: 5

    ignoreErrors:

    excludePaths:
        - app/Http/Middleware/RedirectIfAuthenticated.php
```

*Start at level 5. Increase to level 8+ once the codebase is clean.*

**Run manually:**
```bash
./vendor/bin/phpstan analyse
./vendor/bin/phpstan analyse --memory-limit=512M  # for large codebases
```

---

## Pre-commit Hooks

The hook runs automatically on every `git commit`. It blocks the commit if Pint or PHPStan fails. No need to remember to run checks manually.

### The Hook File

Store hooks in `.githooks/` (tracked by git - so every developer gets them automatically via composer):

**`.githooks/pre-commit`:**
```bash
#!/bin/bash

set -e

# Get staged PHP files only
STAGED_PHP=$(git diff --cached --name-only --diff-filter=ACM | grep "\.php$" || true)

if [ -z "$STAGED_PHP" ]; then
    exit 0
fi

echo "→ Checking code style (Pint)..."
./vendor/bin/pint --test $STAGED_PHP
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Code style issues found. Run: ./vendor/bin/pint"
    exit 1
fi

echo "→ Running static analysis (PHPStan)..."
./vendor/bin/phpstan analyse $STAGED_PHP --memory-limit=256M
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ PHPStan errors found. Fix them before committing."
    exit 1
fi

echo "✅ All checks passed."
```

*Make it executable once, then commit it:*
```bash
chmod +x .githooks/pre-commit
git add .githooks/pre-commit
```

---

## Composer Integration

Auto-install the git hook when anyone runs `composer install` or `composer update`. No manual setup required per developer.

**Add to `composer.json`:**
```json
{
    "scripts": {
        "post-install-cmd": [
            "@php -r \"copy('.githooks/pre-commit', '.git/hooks/pre-commit'); chmod('.git/hooks/pre-commit', 0755);\""
        ],
        "post-update-cmd": [
            "@php -r \"copy('.githooks/pre-commit', '.git/hooks/pre-commit'); chmod('.git/hooks/pre-commit', 0755);\""
        ]
    }
}
```

Now every developer who clones the repo and runs `composer install` gets the hook installed automatically.

**Verify it's installed:**
```bash
ls -la .git/hooks/pre-commit
cat .git/hooks/pre-commit
```

---

## Checklist - Done When

- [ ] Anti-gravity installed on all dev machines
- [ ] Claude Code installed (`npm install -g @anthropic-ai/claude-code`)
- [ ] `.vscode/extensions.json` committed - team prompted to install extensions
- [ ] `.vscode/settings.json` committed - format on save active for PHP
- [ ] PHPStan + Larastan installed, `phpstan.neon` committed
- [ ] `.githooks/pre-commit` committed and executable
- [ ] Composer `post-install-cmd` / `post-update-cmd` scripts added
- [ ] Every dev has run `composer install` - hook is active on their machine
- [ ] Test commit rejected when Pint or PHPStan fails
- [ ] PHPStan level set and agreed on by the team
