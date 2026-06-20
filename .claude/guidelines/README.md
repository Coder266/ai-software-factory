# Guidelines

Shared standards the AI-factory agents and commands follow. These are the **single source
of truth** — commands and agents reference the subset relevant to them instead of restating
it, so there's one place to change a rule.

| file | what it covers | used by |
|------|----------------|---------|
| `story-format.md` | story file location, frontmatter, sections, `status` lifecycle | `/refine` (author); implementer, `/review`, `/qa`, `/ship` (read) |
| `code.md` | backend/frontend conventions, tests, running locally, sensitive data | implementer; `/qa` |
| `commits-and-prs.md` | branch + commit + PR conventions, attribution, merging | implementer; `/ship` |
| `reviews.md` | code-review and QA standards | `/review`; `/qa` |

Durable preferences and learnings live **in this repo** (here or in `CLAUDE.md`), never in
home-folder agent memory.
