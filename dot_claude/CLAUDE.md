# Global Claude Config

## Obsidian Vault

The Obsidian CLI (`obsidian`) is available on the system. Use it when interacting with notes.

The vault is located at `~/Documents/obsidian vault/`.

### Feature Planning

When discussing or planning a new feature, create a note in the vault using the Feature template (`999-TEMPLATES/Feature.md`). Fill in the template sections (Why, MVP, Not doing, Approach) to align on scope before writing code.

### Bug Reports

When investigating or reporting a bug, create a note in the vault using the Problem template (`999-TEMPLATES/Problem.md`). Fill in the sections (What's happening, What I expected, What I've tried, What I think is going on) and update the Solution section after resolving it.

### Wiki Integration

The vault contains a persistent LLM-maintained wiki at `200-WIKI/`. See `200-WIKI/CLAUDE.md` for full schema.

**When working on project code:**
- Before diving into domain-specific work, read the relevant topic index at `200-WIKI/topics/<topic>/index.md` for context. Key mappings:
  - VEV / vev-server / vev-ocpi → `ev-charging/` (also linked from `333-VEV/`)
  - LibreStock / Effect migration → `effect-ts/`
  - Architecture decisions → `software-architecture/`
  - Dev tooling (jj, etc.) → `dev-tools/`
- When a conversation produces a useful synthesis, exploration, or resolved question that would benefit future work, offer to file it back as a wiki article.

**When to update the wiki:**
- After resolving a non-trivial technical question related to an existing topic
- After an audit or investigation that surfaces new domain knowledge
- After ingesting a new source (spec, article, book) — compile it into wiki articles
- Do not update the wiki for ephemeral or project-specific details (use project notes in `100-PROJECTS/` or `333-VEV/` instead)

**Project ↔ Wiki boundary:**
- `333-VEV/`, `100-PROJECTS/` = actionable work (audits, features, bugs, specs)
- `200-WIKI/` = compiled domain knowledge (protocols, patterns, concepts)
- Project index files link to relevant wiki topics via "Wiki Context" sections
- Don't duplicate — project notes reference wiki articles for domain context, wiki articles reference VEV for real-world examples
