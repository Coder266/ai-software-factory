#!/usr/bin/env bash
#
# Tests for .claude/bin/set-status — deterministic lifecycle plumbing.
#
# Drives the real script against throwaway fixture stories in a temp git repo,
# with SET_STATUS_NO_PUSH=1 so transitions commit locally but never hit a remote.
# Asserts: legal transitions accepted; illegal transitions rejected with the file
# left unchanged; '-> done' refused; frontmatter and the ## Status block stay in
# sync; and a pre-existing ## QA section stays directly above ## Status.
#
# Run: bash .claude/bin/set-status_test.sh   (exit 0 = all pass)

set -u

# Resolve the script under test relative to this test file (CWD-independent).
test_dir="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$test_dir/set-status"

pass=0
fail=0

ok()   { printf 'ok   - %s\n' "$1"; pass=$((pass+1)); }
nok()  { printf 'FAIL - %s\n' "$1"; fail=$((fail+1)); }

# fresh temp git repo per assertion group, so commits have somewhere to land
new_repo() {
  local d
  d="$(mktemp -d)"
  git -C "$d" init -q
  git -C "$d" config user.email t@t.test
  git -C "$d" config user.name test
  mkdir -p "$d/backlog/test-epic"
  printf '%s' "$d"
}

# write a fixture story with a given status and optional trailing sections.
# args: <repo> <id> <status> [extra-tail]
write_story() {
  local repo="$1" id="$2" status="$3" tail="${4:-}"
  local f="$repo/backlog/test-epic/${id}-fixture.md"
  {
    printf -- '---\n'
    printf 'id: %s\n' "$id"
    printf 'title: Fixture\n'
    printf 'epic: test-epic\n'
    printf 'status: %s\n' "$status"
    printf 'estimate: 1d\n'
    printf 'branch: story/fixture\n'
    printf -- '---\n\n'
    printf '# %s — Fixture\n\n' "$id"
    printf '## Description\n\nA fixture.\n\n'
    printf '%s' "$tail"
    printf '## Status\n\n`%s` — seeded _(2026-01-01 00:00)_\n' "$status"
  } > "$f"
  git -C "$repo" add -A >/dev/null 2>&1
  git -C "$repo" commit -qm seed >/dev/null 2>&1
  printf '%s' "$f"
}

run() { # run the script inside a repo, capture rc + output
  local repo="$1"; shift
  ( cd "$repo" && SET_STATUS_NO_PUSH=1 "$SCRIPT" "$@" ) 2>&1
}

# fm <file> -> frontmatter status value
fm() {
  awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f&&/^status:/{sub(/^status:[ ]*/,"");print;exit}' "$1"
}

# ---------------------------------------------------------------------------
# 1. legal transition: ready -> in-progress, frontmatter + block in sync
repo="$(new_repo)"; f="$(write_story "$repo" EXP-AAA001 ready)"
out="$(run "$repo" EXP-AAA001 in-progress)"; rc=$?
[ $rc -eq 0 ] && ok "legal ready->in-progress exits 0" || nok "legal ready->in-progress exits 0 (rc=$rc, out=$out)"
[ "$(fm "$f")" = "in-progress" ] && ok "frontmatter updated to in-progress" || nok "frontmatter updated (got $(fm "$f"))"
if grep -q '^`in-progress` — .* _(20' "$f"; then ok "## Status block has new timestamped in-progress line"; else nok "## Status block updated"; fi
if grep -q '^`ready` — seeded' "$f"; then ok "## Status history preserved"; else nok "## Status history preserved"; fi
# block last line matches frontmatter
last_status="$(grep -oE '^`[a-z-]+`' "$f" | tail -1 | tr -d '`')"
[ "$last_status" = "$(fm "$f")" ] && ok "last ## Status line in sync with frontmatter" || nok "last ## Status line in sync (block=$last_status fm=$(fm "$f"))"

# 2. QA bounce: under-review -> in-progress
repo="$(new_repo)"; f="$(write_story "$repo" EXP-AAA002 under-review)"
out="$(run "$repo" EXP-AAA002 in-progress)"; rc=$?
{ [ $rc -eq 0 ] && [ "$(fm "$f")" = "in-progress" ]; } && ok "QA bounce under-review->in-progress accepted" || nok "QA bounce accepted (rc=$rc out=$out)"

# 3. new -> ready and in-progress -> under-review
repo="$(new_repo)"; f="$(write_story "$repo" EXP-AAA003 new)"
run "$repo" EXP-AAA003 ready >/dev/null; [ "$(fm "$f")" = "ready" ] && ok "new->ready accepted" || nok "new->ready accepted"
repo="$(new_repo)"; f="$(write_story "$repo" EXP-AAA004 in-progress)"
run "$repo" EXP-AAA004 under-review >/dev/null; [ "$(fm "$f")" = "under-review" ] && ok "in-progress->under-review accepted" || nok "in-progress->under-review accepted"

# ---------------------------------------------------------------------------
# 4. illegal transition: ready -> under-review (skip a stage), file unchanged
repo="$(new_repo)"; f="$(write_story "$repo" EXP-BBB001 ready)"
before="$(cat "$f")"
out="$(run "$repo" EXP-BBB001 under-review)"; rc=$?
[ $rc -ne 0 ] && ok "illegal ready->under-review exits non-zero" || nok "illegal ready->under-review exits non-zero (rc=$rc)"
[ "$(cat "$f")" = "$before" ] && ok "illegal transition leaves file unchanged" || nok "illegal transition leaves file unchanged"
echo "$out" | grep -q "ready" && echo "$out" | grep -q "in-progress" && ok "rejection names current + legal next" || nok "rejection names current + legal next (out=$out)"

# 5. illegal backward / no-op same status
repo="$(new_repo)"; f="$(write_story "$repo" EXP-BBB002 in-progress)"
before="$(cat "$f")"
run "$repo" EXP-BBB002 in-progress >/dev/null 2>&1; rc=$?
{ [ $rc -ne 0 ] && [ "$(cat "$f")" = "$before" ]; } && ok "no-op same-status rejected, file unchanged" || nok "no-op same-status rejected (rc=$rc)"

# ---------------------------------------------------------------------------
# 6. -> done always refused, file unchanged
repo="$(new_repo)"; f="$(write_story "$repo" EXP-CCC001 under-review)"
before="$(cat "$f")"
out="$(run "$repo" EXP-CCC001 done)"; rc=$?
[ $rc -ne 0 ] && ok "-> done refused (non-zero exit)" || nok "-> done refused (rc=$rc)"
[ "$(cat "$f")" = "$before" ] && ok "-> done leaves file unchanged" || nok "-> done leaves file unchanged"
echo "$out" | grep -qi "ship" && ok "-> done message points to /ship" || nok "-> done points to /ship (out=$out)"

# ---------------------------------------------------------------------------
# 7. ## QA section stays directly above ## Status after a transition
qa_tail=$'## QA\n_2026-01-02 00:00 — Changes requested_\n\n- [ ] something — fix it\n\n'
repo="$(new_repo)"; f="$(write_story "$repo" EXP-DDD001 under-review "$qa_tail")"
run "$repo" EXP-DDD001 in-progress >/dev/null
# grab headings in order
order="$(grep -nE '^## (QA|Status)$' "$f" | sed 's/:.*## /:/')"
qa_line="$(grep -n '^## QA$' "$f" | head -1 | cut -d: -f1)"
st_line="$(grep -n '^## Status$' "$f" | head -1 | cut -d: -f1)"
if [ -n "$qa_line" ] && [ -n "$st_line" ] && [ "$qa_line" -lt "$st_line" ]; then
  ok "## QA stays immediately above ## Status"
else
  nok "## QA above ## Status (QA@$qa_line Status@$st_line)"
fi
# ## Status must still be the LAST heading
last_heading="$(grep -E '^## ' "$f" | tail -1)"
[ "$last_heading" = "## Status" ] && ok "## Status remains the final section" || nok "## Status final section (last=$last_heading)"

# ---------------------------------------------------------------------------
# 8. usage / arg errors
run "$repo" >/dev/null 2>&1; [ $? -eq 2 ] && ok "no args -> usage exit 2" || nok "no args -> usage exit 2"
run "$repo" notanid ready >/dev/null 2>&1; [ $? -ne 0 ] && ok "bad id rejected" || nok "bad id rejected"
run "$repo" EXP-NOPE000 ready >/dev/null 2>&1; [ $? -ne 0 ] && ok "missing story rejected" || nok "missing story rejected"

# ---------------------------------------------------------------------------
printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
