# Tokmak Repository Notes

Project planning and status now live in:

- `Docs/CurrentState.md`
- `Docs/Roadmap.md`

Tokmak is a SwiftUI-compatible framework for Embedded Swift using LVGL. It focuses on a static, reflection-free approach to UI tree management and reconciliation.

## Repository Rules

### Versioning and Commits
- We adhere to semantic versioning.
- Make as few commits as possible (ideally 0 or 1 per session). Do not flood the history. Bundle changes together.
- Commit messages must be simple: just a verb and minimal info (e.g., "Add LVGL layout and e-paper driver"). Do not use conventional prefixes like `feat:` or `refactor:`.
- **No Amending / Force Pushing:** Do not use `git commit --amend` or `git push -f`. Once a commit is pushed, leave it alone.
- **Author & Committer Requirement:** Automated commits should use the active coding agent identity, with author and committer set to match. For Codex sessions, use `OpenAI Codex <codex@checle.com>`. For Gemini sessions, use `Google Gemini <gemini@checle.com>`.
- Codex command format:
  `GIT_COMMITTER_NAME="OpenAI Codex" GIT_COMMITTER_EMAIL="codex@checle.com" git commit --author="OpenAI Codex <codex@checle.com>" -m "..."`
- Gemini command format:
  `GIT_COMMITTER_NAME="Google Gemini" GIT_COMMITTER_EMAIL="gemini@checle.com" git commit --author="Google Gemini <gemini@checle.com>" -m "..."`

## Hardware Direction

- The primary target display remains the Good Display GDEY037T03 (UC8253).
- Tokmak should keep hardware integration static and link-time driven rather than closure-based.
- The final firmware target owns the MCU SDK linkage and bridge symbols.
