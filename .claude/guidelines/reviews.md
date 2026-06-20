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
- **All pass:** report PASS; write nothing to the story; leave `status: under-review` for the
  human to ship.
- **Any failure:** append or replace a `## QA` section at the end of the story, timestamped
  to the minute (`YYYY-MM-DD HH:MM`):

  ```markdown
  ## QA
  _<YYYY-MM-DD HH:MM> — Changes requested_

  - [ ] <failing criterion> — expected: <...>; observed: <...>; fix: <concrete action>
  ```

  Do **not** change the `status` — the `## QA` section is itself the signal the implementer
  reads (it takes the story back to `in-progress` to fix). QA never edits code, never sets
  `done`, never merges.
