# Review & QA standards

## Code review (`/review`)
Review the PR diff against the story's **Acceptance Criteria**:
- For each criterion, judge whether the diff plausibly satisfies it: `met / unmet / unclear`.
- Also flag: correctness bugs and edge cases (empty / malformed / duplicate CSV rows, large
  files, currency, timezones), **scope creep** beyond this story, convention mismatches, and
  any sensitive data (real statements or non-`testdata/` `*.csv`) leaking into the diff.
- **Output is GitHub PR comments only.** Never edit code or the story, never change the
  `status`, never use `--fix`. The implementer addresses the comments; the implementer (not
  the reviewer) moves the status.

## QA (`/qa`)
Verify the *running* behavior against each acceptance criterion, with concrete evidence
(what you did, observed vs. expected). Use `testdata/sample_statement.csv`, never real data.
- **Test the story the way a real user would exercise it** — whatever that means for the
  story: click through the UI, hit endpoints with `curl`, run the CLI, rebuild the
  devcontainer, etc. The QA environment can run the real thing (including Docker), so drive
  the actual behavior rather than inspecting the diff. Static inspection is the reviewer's
  job; QA's value is confirming it works when run.
- **All pass:** report PASS; write nothing to the story; leave `status: under-review` for the
  human to ship.
- **Any failure:** insert or replace a `## QA` section **immediately above the final
  `## Status` block** (never appended at end-of-file — `## Status` stays last; see the
  canonical section order in `story-format.md`), timestamped to the minute
  (`YYYY-MM-DD HH:MM`):

  ```markdown
  ## QA
  _<YYYY-MM-DD HH:MM> — Changes requested_

  - [ ] <failing criterion> — expected: <...>; observed: <...>; fix: <concrete action>
  ```

  Do **not** change the `status` — the `## QA` section is itself the signal the implementer
  reads (the implementer takes the story back to `in-progress` by running
  `.claude/bin/set-status <EXP-id> in-progress` to fix). QA
  never edits code, never changes `status`, never sets `done`, never merges.
