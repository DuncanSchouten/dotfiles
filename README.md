# Dotfiles

Personal configuration files and settings.

## Structure

```
dotfiles/
├── claude/
│   └── commands/
│       └── commit.md    # Smart commit slash command for Claude Code
└── README.md
```

## Claude Commands

Custom slash commands for [Claude Code](https://claude.com/claude-code).

### Installation

The commands are automatically symlinked from this repository:

```bash
~/.claude/commands/commit.md -> ~/GitHub/dotfiles/claude/commands/commit.md
```

### Available Commands

#### `/commit` - Smart Git Commit

Intelligent git commit command with:
- **Semantic grouping**: Analyzes diffs to group related changes
- **Smart consolidation**: Suggests merging small, related changes
- **Security filtering**: Automatically excludes .env files, keys, secrets
- **File arguments**: Can commit specific files or all changes
- **Conventional commits**: Generates well-formatted commit messages

**Usage:**
```bash
/commit                    # Analyze and commit all changes
/commit file1.ts file2.ts  # Commit specific files only
```

**Features:**
- Automatically excludes `.env*`, `*.key`, `*.pem`, credential files
- Groups changes by semantic purpose (feat/fix/docs/refactor)
- Suggests consolidating small groups (typos, formatting)
- Creates multiple commits when appropriate
- Follows conventional commit format

See [claude/commands/commit.md](claude/commands/commit.md) for full specification.

## Initial Setup (First Time)

After creating your dotfiles repository locally, push it to GitHub:

### Option A: Using GitHub CLI (Recommended)

```bash
cd ~/GitHub/dotfiles
gh repo create dotfiles --private --source=. --push
```

### Option B: Manual GitHub Setup

1. Create a new repository on [GitHub](https://github.com/new):
   - Repository name: `dotfiles`
   - Visibility: Private (recommended) or Public
   - **Don't** initialize with README, .gitignore, or license (we already have these)

2. Push your local repository:
   ```bash
   cd ~/GitHub/dotfiles
   git remote add origin git@github.com:YOUR_USERNAME/dotfiles.git
   git push -u origin main
   ```

## Setup on New Machine

1. Clone this repository:
   ```bash
   git clone <your-repo-url> ~/GitHub/dotfiles
   ```

2. Run the setup script:
   ```bash
   cd ~/GitHub/dotfiles
   ./setup.sh
   ```

Or manually create symlinks:
   ```bash
   mkdir -p ~/.claude/commands
   ln -sf ~/GitHub/dotfiles/claude/commands/*.md ~/.claude/commands/
   ```

## Adding New Commands

1. Create new command in `claude/commands/`:
   ```bash
   touch claude/commands/new-command.md
   ```

2. Edit the command file following Claude Code slash command format

3. Symlink to Claude directory:
   ```bash
   ln -sf ~/GitHub/dotfiles/claude/commands/new-command.md ~/.claude/commands/
   ```

4. Commit and push:
   ```bash
   git add claude/commands/new-command.md
   git commit -m "feat(claude): add new-command slash command"
   git push
   ```

## Updating Commands

Commands are symlinked, so edits in `~/GitHub/dotfiles/` automatically reflect in `~/.claude/commands/`.

To update:
1. Edit the file in `~/GitHub/dotfiles/claude/commands/`
2. Test the command in Claude Code
3. Commit changes:
   ```bash
   git add -p
   git commit -m "feat(claude): improve commit command"
   git push
   ```

## License

Personal dotfiles - feel free to use as inspiration for your own setup.
