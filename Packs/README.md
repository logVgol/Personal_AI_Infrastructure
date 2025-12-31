<p align="center">
  <img src="icons/packs-v2.png" alt="PAI Packs" width="256">
</p>

# PAI Packs

> The best AI in the world should be available to everyone

Right now the most powerful AI setups are being built inside companies for efficiency and profits. But the purpose of technology is to serve humans—not the other way around.

**PAI Packs** are how we make that happen. Each pack is a battle-tested capability extracted from a production AI system, packaged so anyone can install it. Think of them like learning kung-fu in The Matrix—complete, tested capabilities you can download directly into your system.

These aren't theoretical examples or proof-of-concepts. They're the actual tools and systems running in production every day, now available to you. A full platform for magnifying yourself and your impact on the world.

---

## Why Packs?

The old approach was "here's my whole system—clone it and customize." That created a Jenga tower of dependencies where changing one piece broke three others.

**Packs are different:**
- **Self-contained** - Works without understanding the rest of the system
- **Independently installable** - Add what you need, skip what you don't
- **Platform-agnostic** - Works with Claude Code, OpenCode, Cursor, or custom systems
- **AI-installable** - Give your AI the pack file, it handles the rest

**The key insight:** Give your AI the complete context it needs, and it can integrate the pack into *your* system autonomously.

---

## System Architecture

<p align="center">
  <img src="icons/pai-system-architecture-v3.png" alt="PAI System Architecture" width="100%">
</p>

**PAI organizes capabilities in a clear hierarchy:**

```
PAI System
    └── Bundles (curated collections for specific goals)
            └── Packs (individual capabilities)
                    └── Contents (code, hooks, tools, workflows, config)
```

- **Bundles** group related packs that work well together
- **Packs** are self-contained capabilities you can install independently
- **Contents** are the actual code, hooks, tools, and configuration inside each pack

---

## What's in a Pack?

Each pack is a single markdown file containing everything needed to go from zero to working:

- **The Problem** - What challenge this pack solves
- **The Solution** - How it solves it (with architecture diagrams)
- **Complete Code** - All hooks, tools, libraries, and configuration
- **Installation Instructions** - Step-by-step for both AI and manual installation
- **Verification Steps** - How to confirm it's working
- **Examples** - Real usage scenarios
- **Customization** - How to personalize the pack for your specific needs

**Key principle:** Give your AI the pack file, and it can install the entire capability into your system autonomously.

### Customization Section

Many packs include a **Customization** section with:

- **Recommended Customization** - Personalization that significantly improves the pack's value (most users should do this)
- **Optional Customization** - Additional tweaks for advanced users

For example, the Art Skill pack recommends having an extended conversation with your AI about your aesthetic preferences, then capturing that in the Aesthetic.md file so all generated images reflect your personal style.

---

## Available Packs

| Pack | Version | Category | Bundle | Description |
|------|---------|----------|--------|-------------|
| [**kai-hook-system**](kai-hook-system.md) | 1.0.0 | Foundation | [Kai](../Bundles/Kai/) | Event-driven automation framework - the foundation for all hook-based capabilities |
| [**kai-history-system**](kai-history-system.md) | 1.0.0 | Infrastructure | [Kai](../Bundles/Kai/) | Granular context-tracking that captures all work, decisions, and learnings automatically |
| [**kai-core-install**](kai-core-install.md) | 1.0.0 | Core | [Kai](../Bundles/Kai/) | Skills + Identity + Architecture - the complete foundation with routing, response format, and tracking |
| [**kai-voice-system**](kai-voice-system.md) | 1.1.0 | Notifications | [Kai](../Bundles/Kai/) | Voice notifications with ElevenLabs TTS and prosody enhancement for natural speech |
| [**kai-observability-server**](kai-observability-server.md) | 1.0.0 | Observability | [Kai](../Bundles/Kai/) | Real-time multi-agent monitoring dashboard with WebSocket streaming |
| [**kai-art-skill**](kai-art-skill.md) | 1.0.0 | Creativity | [Kai](../Bundles/Kai/) | Visual content generation with Excalidraw hand-drawn aesthetic - diagrams, comics, illustrations |
| [**kai-agents-skill**](kai-agents-skill.md) | 1.0.0 | Delegation | [Kai](../Bundles/Kai/) | Dynamic agent composition - create custom agents with unique personalities, voices, and trait combinations |
| [**kai-prompting-skill**](kai-prompting-skill.md) | 1.0.0 | Methodology | [Kai](../Bundles/Kai/) | Meta-prompting system with Handlebars templates, Claude 4.x best practices, and the Ultimate Prompt Template |

---

## Installation Order

Packs have dependencies. Install in this order:

```
1. kai-hook-system            ← Foundation (no dependencies)
2. kai-history-system         ← Depends on hooks
3. kai-core-install           ← Depends on hooks, history
4. kai-prompting-skill        ← Depends on core-install
5. kai-voice-system           ← Depends on hooks, core-install
6. kai-agents-skill           ← Depends on core-install, optional voice-system
7. kai-art-skill              ← Depends on core-install
8. kai-observability-server   ← Optional, depends on hooks
```

**Or install the complete [Kai Bundle](../Bundles/Kai/)** which handles ordering automatically.

---

## How to Install a Pack

### Option 1: AI-Assisted (Recommended)

Give the pack file to your AI agent:

```
Install this pack into my system. Use PAI_DIR="~/.config/pai" and DA="MyAI".
```

Your AI will:
1. Check dependencies
2. Create directories
3. Save all code files
4. Configure hooks
5. Verify installation

### Option 2: Manual

Open any pack file and follow the "Installation" section step by step.

---

## Authentication

**All API keys live in ONE place: `$PAI_DIR/.env`**

Packs that require API keys (Voice, Art, etc.) all read from a single environment file. No keys should ever be stored in pack files, configs, or code.

```bash
# Copy the example and add your keys
cp ../.env.example $PAI_DIR/.env
nano $PAI_DIR/.env
```

See [.env.example](../.env.example) for the complete list of supported variables.

---

## Pack Categories

| Category | Purpose | Examples |
|----------|---------|----------|
| **Foundation** | Core infrastructure that other packs depend on | Hook System |
| **Infrastructure** | Systems that run automatically in the background | History System |
| **Observability** | Real-time monitoring and debugging tools | Observability Server |
| **Routing** | Intent detection and capability dispatch | Skill System |
| **Notifications** | User feedback and accessibility | Voice System |
| **Personality** | Identity, response format, principles | Identity |
| **Delegation** | Agent orchestration and parallel execution | Agents Skill |
| **Creativity** | Visual and creative content generation | Art Skill |
| **Methodology** | Prompt engineering and meta-prompting | Prompting Skill |

---

## Creating Your Own Pack

See [PAIPackTemplate.md](../Tools/PAIPackTemplate.md) for the complete pack specification.

**Quick checklist:**
- [ ] Single markdown file with YAML frontmatter
- [ ] 256x256 transparent icon in `icons/`
- [ ] Complete, working code (no snippets or placeholders)
- [ ] End-to-end implementation (no "beyond scope" gaps)
- [ ] Both AI-assisted and manual installation instructions
- [ ] Verification commands to confirm success

---

## Pack Quality Standards

Every pack in this directory must be:

1. **Complete** - Everything needed to install, no missing components
2. **Self-contained** - Works without external documentation
3. **Tested** - Verified working in production (extracted from Kai)
4. **Sanitized** - No personal data, credentials, or hardcoded paths
5. **Documented** - Clear problem statement, solution, and examples

---

## Related

- [**Bundles/**](../Bundles/) - Curated collections of packs
- [**PAIPackTemplate.md**](../Tools/PAIPackTemplate.md) - Full pack specification
- [**README.md**](../README.md) - PAI project overview

---

*Each pack is extracted from Daniel Miessler's production Kai system - battle-tested capabilities packaged for anyone to use.*
