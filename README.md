# Overview
Rules, skills, and guidelines for AI coding assistants – Claude, Cursor, and beyond.

## How to Use
To apply these standards to your own project, copy the relevant files or directories from this repository to your project's root.

### Claude
1. Navigate to `.claude/skills/` in this repository.
2. Copy the desired skill folder (e.g., `csharp-coding-standards`) into your project's `.claude/skills/` directory.
   - *Example path:* `C:\your-project\.claude\skills\csharp-coding-standards\SKILL.md`

### Cursor
1. Navigate to `.cursor/rules/` in this repository.
2. Copy the `.mdc` files into your project's `.cursor/rules/` directory.
   - *Example path:* `C:\your-project\.cursor\rules\csharp-coding-standards.mdc`

### Gemini
1. Navigate to `.gemini/skills/` in this repository.
2. Copy the desired skill folder into your project's `.gemini/skills/` directory.
   - *Example path:* `C:\your-project\.gemini\skills\csharp-coding-standards\SKILL.md`

---

## Maintenance & Automation
If you are contributing to this repository:

1. **Content First**: All source material is located in the `content/` directory.
2. **Synchronize**: Run the sync script to update all AI-specific formats:
   ```powershell
   .\scripts\sync_content.ps1
   ```
3. **Git Hooks**: To automate synchronization before every commit, install the pre-commit hook:
   ```powershell
   .\scripts\install-hooks.ps1
   ```

# References
- [Karpathy-Inspired Claude Code Guidelines](https://github.com/forrestchang/andrej-karpathy-skills)
