---
name: skill-creation
description: Create new Claude Code skills. Use when the user wants to create a skill, add a slash command, or automate a workflow with a custom skill. Provides complete reference for SKILL.md format, frontmatter fields, and best practices.
---

# Creating Claude Code Skills

You are helping the user create a new Claude Code skill. This document contains everything
you need.

## Skill Structure

A skill is a directory containing a `SKILL.md` file:

```
.claude/skills/<skill-name>/
├── SKILL.md              # Required: Main instructions
├── reference.md          # Optional: Additional reference material
├── examples/             # Optional: Example files
│   └── sample.md
└── scripts/              # Optional: Helper scripts
    └── helper.py
```

## Skill Locations (Priority Order)

| Location   | Path                                     | Scope                  |
|------------|------------------------------------------|------------------------|
| Enterprise | Managed settings                         | All organization users |
| Personal   | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects      |
| Project    | `.claude/skills/<skill-name>/SKILL.md`   | Current project only   |

Higher priority locations override lower ones when names conflict.

## SKILL.md Format

Every `SKILL.md` has two parts:

### 1. YAML Frontmatter (between `---` markers)

```yaml
---
name: my-skill
description: What this skill does and when to use it. Claude reads this to decide when to invoke automatically.
---
```

### 2. Markdown Content

Step-by-step instructions Claude follows when the skill is invoked.

## Frontmatter Fields Reference

| Field                      | Required        | Default        | Description                                                                                     |
|----------------------------|-----------------|----------------|-------------------------------------------------------------------------------------------------|
| `name`                     | No              | directory name | Display name, becomes `/skill-name` command. Lowercase, numbers, hyphens only. Max 64 chars.    |
| `description`              | **Recommended** | -              | What the skill does and when to use it. Claude uses this to decide when to apply automatically. |
| `allowed-tools`            | No              | -              | Tools Claude can use without asking permission (e.g., `Read, Grep, Bash, Write, Edit, Glob`)    |
| `disable-model-invocation` | No              | `false`        | Set `true` to prevent Claude from invoking automatically (user must type `/skill-name`)         |
| `user-invocable`           | No              | `true`         | Set `false` to hide from `/` menu (Claude-only, automatic invocation)                           |
| `argument-hint`            | No              | -              | Hint shown in autocomplete (e.g., `[filename]`, `[issue-number]`)                               |
| `model`                    | No              | inherited      | Which model to use (`sonnet`, `opus`, `haiku`)                                                  |
| `context`                  | No              | -              | Set to `fork` to run in isolated subagent context                                               |
| `agent`                    | No              | -              | Subagent type when using `context: fork` (e.g., `Explore`, `Plan`)                              |
| `hooks`                    | No              | -              | Hooks scoped to this skill's lifecycle                                                          |

## Dynamic Content

### Arguments

Access arguments passed to the skill:

- `$ARGUMENTS` - All arguments as a string
- `$0` - Skill name
- `$1`, `$2`, etc. - Individual arguments

```yaml
---
name: fix-issue
argument-hint: [ issue-number ]
---
Fix GitHub issue #$ARGUMENTS following our coding standards.
```

### Shell Command Injection

Inject live command output with `` !`command` `` syntax:

```yaml
---
name: pr-summary
---
Summarize this PR:

  !`gh pr view --json title,body,additions,deletions`

Changed files:
  !`gh pr diff --stat`
```

## Examples

### Basic Skill

```yaml
---
name: explain-code
description: Explains code with diagrams and analogies. Use when explaining how code works or when user asks "how does this work?"
---

When explaining code:

  1. **Start with an analogy** - Compare to everyday life
  2. **Draw a diagram** - Use ASCII art for flow/structure
  3. **Walk through step-by-step** - Explain what happens
  4. **Highlight gotchas** - Common mistakes or misconceptions
```

### Skill with Tools

```yaml
---
name: find-todos
description: Find all TODO comments in the codebase
allowed-tools: Grep, Glob
---

Search for TODO, FIXME, HACK, and XXX comments:

  1. Use Grep to find all occurrences
  2. Group by file
  3. Summarize by priority/type
```

### Skill with Arguments

```yaml
---
name: create-component
description: Create a new React component with tests
argument-hint: [ ComponentName ]
allowed-tools: Write, Read
---

Create a new React component named $ARGUMENTS:

  1. Create `src/components/$ARGUMENTS/$ARGUMENTS.tsx`
  2. Create `src/components/$ARGUMENTS/$ARGUMENTS.test.tsx`
  3. Create `src/components/$ARGUMENTS/index.ts` barrel export
```

### Forked Context Skill

```yaml
---
name: deep-research
description: Thoroughly research a topic across the codebase
context: fork
agent: Explore
---

Research "$ARGUMENTS" thoroughly:

  1. Find all related files
  2. Understand the architecture
  3. Document findings
  4. Return a comprehensive summary
```

### Non-User-Invocable Skill (Claude-only)

```yaml
---
name: auto-format
description: Automatically format code after edits. Runs after any file modification.
user-invocable: false
---

After code changes, run the appropriate formatter:
  - TypeScript/JavaScript: prettier
  - Python: black
  - Rust: cargo fmt
  - Go: gofmt
```

### Skill That Requires User Invocation

```yaml
---
name: deploy
description: Deploy the application to production
disable-model-invocation: true
allowed-tools: Bash
---

Deploy to production:

  1. Run tests first
  2. Build the application
  3. Deploy using the configured method
  4. Verify deployment succeeded
```

## Best Practices

1. **Write clear descriptions** - Claude uses these to decide when to invoke automatically
2. **Be specific about tools** - List `allowed-tools` to avoid permission prompts
3. **Use argument hints** - Help users understand expected input
4. **Keep instructions actionable** - Write step-by-step what Claude should do
5. **Handle edge cases** - Include what to do if something fails
6. **Test your skill** - Invoke with `/skill-name` to verify behavior

## Naming Conventions

- Use lowercase with hyphens: `my-skill-name`
- Be descriptive but concise: `create-component`, `run-tests`, `fix-issue`
- Avoid generic names that might conflict: prefer `project-deploy` over just `deploy`

## Creating the Skill

1. Create the directory: `.claude/skills/<skill-name>/`
2. Create `SKILL.md` with frontmatter and instructions
3. Test by typing `/<skill-name>` in Claude Code
4. Iterate on the instructions based on results

## Common Patterns

### Ask Before Acting

```markdown
Before proceeding, ask the user:

1. Which option do they prefer?
2. Any specific requirements?
```

### Provide Options

```markdown
Present these options to the user:

- **Option A**: Description of A
- **Option B**: Description of B
```

### Verify Success

```markdown
After completing:

1. Verify the changes work
2. Run relevant tests
3. Report success or any issues
```
