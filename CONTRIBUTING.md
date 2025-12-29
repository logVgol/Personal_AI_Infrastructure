# Contributing to Personal AI Infrastructure (PAI)

First off, thank you for considering contributing to PAI! It's people like you who make PAI such a powerful tool for everyone.

The mission of PAI is to provide the foundation for building a Personal AI System that understands your larger goals and context, gets better over time, and works for *you* because it's *yours*. We want to democratize the most powerful AI setups, moving them from inside corporations to the hands of individuals.

---

## Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

---

## How Can I Contribute?

### Reporting Bugs
- **Search First:** Check existing [Issues](https://github.com/danielmiessler/Personal_AI_Infrastructure/issues) to see if the bug has already been reported.
- **Use the Template:** Follow the bug report template provided in the issue creation view.
- **Be Specific:** Include reproduction steps, your environment (OS, Bun version, Claude Code version), and any relevant logs from `history/raw-outputs/`.
- **Core vs. Example:** Distinguish if the bug is in a **Core Guarantee** (e.g., Hook System) or an **Example Skill** (see [PAI_CONTRACT.md](PAI_CONTRACT.md)).

### Suggesting Features
- **Use the Template:** Follow the feature request template.
- **Problem Statement:** Clearly explain the problem the feature solves and the use cases it enables.
- **Alignment:** Ensure the feature aligns with the [Thirteen Founding Principles](README.md#🏗️-the-thirteen-founding-principles).

### Pull Requests
1. **Fork and Branch:** Create a branch from `main` with a descriptive name (e.g., `feat/new-research-agent` or `fix/hook-path-resolution`).
2. **Adhere to Standards:** Follow the coding standards and principles outlined below.
3. **Self-Test:** Your PR **must** pass the health check: `bun .claude/hooks/self-test.ts`.
4. **Update Docs:** If you add a skill or feature, include a `SKILL.md` or update relevant documentation.

---

## Development Setup

### Prerequisites
- **Bun:** The primary runtime (NOT Node.js).
- **TypeScript:** For all logic and hooks.
- **Claude Code:** The underlying AI platform.
- **Git:** For version control.

### Setup Instructions
```powershell
# 1. Clone your fork
git clone https://github.com/your-username/Personal_AI_Infrastructure.git
cd Personal_AI_Infrastructure

# 2. Run the PAI setup wizard
# On Windows:
& ".\setup.ps1"
# On macOS/Linux:
./setup.sh

# 3. Install dependencies
bun install

# 4. Verify the installation
bun .claude/hooks/self-test.ts
```

*Note: PAI defaults to using `~/.claude` as the root directory (`PAI_DIR`). If you are developing in a different folder, ensure your `PAI_DIR` environment variable or `settings.json` is configured correctly.*

---

## Development Workflow

### Branch Naming
- `feature/description` - New functionality
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code cleanup/restructuring

### Commit Messages
We follow [Conventional Commits](https://www.conventionalcommits.org/):
```
type(scope): subject

body (optional)
```
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.

---

## Coding Standards

### The Thirteen Principles
Contributors should strictly follow the architecture documentation in [`.claude/skills/CORE/CONSTITUTION.md`](.claude/skills/CORE/CONSTITUTION.md). Key highlights:
1. **Clear Thinking First:** Plan the logic before writing code.
2. **UNIX Philosophy:** Build small, focused tools that do one thing well.
3. **Code Before Prompts:** If logic can be deterministic code, write it as code. Use prompts for orchestration.
4. **TitleCase Naming:** Use TitleCase for skill directories and major files (e.g., `Research/`, `SkillSystem.md`).

### Style Guide
- **Language:** TypeScript for all scripts and hooks.
- **Formatting:** Clean, readable code. Avoid excessive comments; focus on *why* logic exists.
- **Paths:** Always use the centralized path resolution system in `.claude/hooks/lib/pai-paths.ts`. Use `${PAI_DIR}` for portability.

---

## Testing

### Writing Tests
- **Unit Tests:** Use [Vitest](https://vitest.dev/) for testing complex logic in hooks or tools.
- **Health Checks:** Add checks to `self-test.ts` if adding core infrastructure guarantees.
- **Skill Evals:** For AI-heavy skills, consider adding evaluation prompts or tests to ensure quality responses.

### Running Tests
```bash
bun test                 # Run vitest (if configured)
bun .claude/hooks/self-test.ts # Run PAI health checks
```

---

## Pull Request Process

1. **Self-Review:** Before submitting, review your code against the [PAI_CONTRACT.md](PAI_CONTRACT.md).
2. **Sanitize:** **CRITICAL:** Ensure no secrets, API keys, or personal data are included in your PR.
3. **Documentation:** Ensure all new skills follow the [SkillSystem.md](.claude/skills/CORE/SkillSystem.md) guidelines.
4. **Validation:** Ensure the PR includes a description of how it was tested and that `self-test.ts` passes.

---

## Protected Content

Certain files are protected to maintain the integrity of the PAI template (see `PAI_CONTRACT.md`). Avoid modifying these unless specifically addressing a core infrastructure bug:
- `PAI_CONTRACT.md`
- `README.md`
- `.claude/hooks/self-test.ts`
- `.pai-protected.json`

---

## Community

- **Discussions:** Use [GitHub Discussions](https://github.com/danielmiessler/Personal_AI_Infrastructure/discussions) for general questions.
- **Discord:** Join our community of AI-augmented humans (link in README).

---

**Start clean. Start small. Build the AI infrastructure you need.**
