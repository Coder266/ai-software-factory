#!/usr/bin/env bash
#
# Tests for .claude/bin/set-status — deterministic lifecycle plumbing.
#
# Drives the real script against throwaway fixture stories in temp git repos.
# Two flavours of run are used:
#   * SET_STATUS_NO_PUSH=1  — the script does the real edit+commit on `main` via a
#     throwaway worktree, but skips the push. The commit lands on the local `main`
#     branch, so assertions read the committed story via `git show main:<path>`.
#     The caller's working tree / branch is NOT touched.
#   * SET_STATUS_NO_COMMIT=1 — the script mutates the in-repo working copy in place
#     and skips git. Used only where we just need the file content (not the commit).
#
# Asserts: legal transitions accepted; illegal transitions rejected with the file
# left unchanged; '-> done' refused; frontmatter and the ## Status block stay in
# sync; a pre-existing ## QA section stays directly above ## Status; and — the
# branch-safety invariant — when invoked from a `story/<slug>` branch with a real
# (bare) remote, only `main` advances by exactly one story-doc commit while the
# story branch gains no commit and its working tree stays clean.
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

# fresh temp git repo per assertion group, on a `main` branch, so commits have
# somewhere to land.
new_repo() {
  local d
  d="$(mktemp -d)"
  git -C "$d" init -q -b main
  git -C "$d" config user.email t@t.test
  git -C "$d" config user.name test
  mkdir -p "$d/backlog/test-epic"
  printf '%s' "$d"
}

# story_path <repo> <id> -> the conventional fixture path within the repo.
story_path() { printf '%s/backlog/test-epic/%s-fixture.md' "$1" "$2"; }
# rel_path <repo> <id> -> the repo-relative fixture path (for `git show main:...`).
rel_path() { printf 'backlog/test-epic/%s-fixture.md' "$2"; }

# write a fixture story with a given status and optional trailing sections, then
# commit it on the current branch.
# args: <repo> <id> <status> [extra-tail]
write_story() {
  local repo="$1" id="$2" status="$3" tail="${4:-}"
  local f; f="$(story_path "$repo" "$id")"
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

run() { # run the script inside a repo with NO_PUSH, capture rc + output
  local repo="$1"; shift
  ( cd "$repo" && SET_STATUS_NO_PUSH=1 "$SCRIPT" "$@" ) 2>&1
}

# after a NO_PUSH run, dump the committed story from the local `main` branch.
main_story() { # <repo> <id>
  git -C "$1" show "main:$(rel_path "$1" "$2")" 2>/dev/null
}

# fm <text on stdin> -> frontmatter status value
fm() {
  awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f&&/^status:/{sub(/^status:[ ]*/,"");print;exit}'
}

# ---------------------------------------------------------------------------
# 1. legal transition: ready -> in-progress, frontmatter + block in sync (on main)
repo="$(new_repo)"; write_story "$repo" EXP-AAA001 ready >/dev/null
out="$(run "$repo" EXP-AAA001 in-progress)"; rc=$?
[ $rc -eq 0 ] && ok "legal ready->in-progress exits 0" || nok "legal ready->in-progress exits 0 (rc=$rc, out=$out)"
body="$(main_story "$repo" EXP-AAA001)"
[ "$(printf '%s' "$body" | fm)" = "in-progress" ] && ok "frontmatter updated to in-progress" || nok "frontmatter updated (got $(printf '%s' "$body" | fm))"
if printf '%s\n' "$body" | grep -q '^`in-progress` — .* _(20'; then ok "## Status block has new timestamped in-progress line"; else nok "## Status block updated"; fi
if printf '%s\n' "$body" | grep -q '^`ready` — seeded'; then ok "## Status history preserved"; else nok "## Status history preserved"; fi
# block last line matches frontmatter
last_status="$(printf '%s\n' "$body" | grep -oE '^`[a-z-]+`' | tail -1 | tr -d '`')"
[ "$last_status" = "$(printf '%s' "$body" | fm)" ] && ok "last ## Status line in sync with frontmatter" || nok "last ## Status line in sync (block=$last_status fm=$(printf '%s' "$body" | fm))"

# 2. QA bounce: under-review -> in-progress
repo="$(new_repo)"; write_story "$repo" EXP-AAA002 under-review >/dev/null
out="$(run "$repo" EXP-AAA002 in-progress)"; rc=$?
{ [ $rc -eq 0 ] && [ "$(main_story "$repo" EXP-AAA002 | fm)" = "in-progress" ]; } && ok "QA bounce under-review->in-progress accepted" || nok "QA bounce accepted (rc=$rc out=$out)"

# 3. new -> ready and in-progress -> under-review
repo="$(new_repo)"; write_story "$repo" EXP-AAA003 new >/dev/null
run "$repo" EXP-AAA003 ready >/dev/null; [ "$(main_story "$repo" EXP-AAA003 | fm)" = "ready" ] && ok "new->ready accepted" || nok "new->ready accepted"
repo="$(new_repo)"; write_story "$repo" EXP-AAA004 in-progress >/dev/null
run "$repo" EXP-AAA004 under-review >/dev/null; [ "$(main_story "$repo" EXP-AAA004 | fm)" = "under-review" ] && ok "in-progress->under-review accepted" || nok "in-progress->under-review accepted"

# ---------------------------------------------------------------------------
# 4. illegal transition: ready -> under-review (skip a stage), file unchanged
repo="$(new_repo)"; f="$(write_story "$repo" EXP-BBB001 ready)"
before="$(cat "$f")"
out="$(run "$repo" EXP-BBB001 under-review)"; rc=$?
[ $rc -ne 0 ] && ok "illegal ready->under-review exits non-zero" || nok "illegal ready->under-review exits non-zero (rc=$rc)"
[ "$(cat "$f")" = "$before" ] && ok "illegal transition leaves file unchanged" || nok "illegal transition leaves file unchanged"
# main did not advance either (still seed)
[ "$(git -C "$repo" rev-list --count main)" = "1" ] && ok "illegal transition leaves main unchanged" || nok "illegal transition leaves main unchanged"
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
# 7. ## QA section stays directly above ## Status after a transition (on main)
qa_tail=$'## QA\n_2026-01-02 00:00 — Changes requested_\n\n- [ ] something — fix it\n\n'
repo="$(new_repo)"; write_story "$repo" EXP-DDD001 under-review "$qa_tail" >/dev/null
run "$repo" EXP-DDD001 in-progress >/dev/null
body="$(main_story "$repo" EXP-DDD001)"
qa_line="$(printf '%s\n' "$body" | grep -n '^## QA$' | head -1 | cut -d: -f1)"
st_line="$(printf '%s\n' "$body" | grep -n '^## Status$' | head -1 | cut -d: -f1)"
if [ -n "$qa_line" ] && [ -n "$st_line" ] && [ "$qa_line" -lt "$st_line" ]; then
  ok "## QA stays immediately above ## Status"
else
  nok "## QA above ## Status (QA@$qa_line Status@$st_line)"
fi
# ## Status must still be the LAST heading
last_heading="$(printf '%s\n' "$body" | grep -E '^## ' | tail -1)"
[ "$last_heading" = "## Status" ] && ok "## Status remains the final section" || nok "## Status final section (last=$last_heading)"

# ---------------------------------------------------------------------------
# 8. usage / arg errors
run "$repo" >/dev/null 2>&1; [ $? -eq 2 ] && ok "no args -> usage exit 2" || nok "no args -> usage exit 2"
run "$repo" notanid ready >/dev/null 2>&1; [ $? -ne 0 ] && ok "bad id rejected" || nok "bad id rejected"
run "$repo" EXP-NOPE000 ready >/dev/null 2>&1; [ $? -ne 0 ] && ok "missing story rejected" || nok "missing story rejected"

# ---------------------------------------------------------------------------
# 9. BRANCH SAFETY — invoked from a story/<slug> branch with a real (bare) remote.
#    The story-doc commit must land on main only; the story branch must NOT gain a
#    commit and its working tree must stay clean. Exercises the real push path.
#
# Set up a working clone with a bare remote so the real `git push origin HEAD:main`
# runs (no SET_STATUS_NO_PUSH).
bare="$(mktemp -d)"; git init -q --bare -b main "$bare"
work="$(mktemp -d)"
git -C "$work" init -q -b main
git -C "$work" config user.email t@t.test
git -C "$work" config user.name test
git -C "$work" remote add origin "$bare"
mkdir -p "$work/backlog/test-epic"
# seed a story on main and publish it
{
  printf -- '---\nid: EXP-EEE001\ntitle: Fixture\nepic: test-epic\nstatus: ready\nestimate: 1d\nbranch: story/fixture\n---\n\n'
  printf '# EXP-EEE001 — Fixture\n\n## Description\n\nA fixture.\n\n'
  printf '## Status\n\n`ready` — seeded _(2026-01-01 00:00)_\n'
} > "$work/backlog/test-epic/EXP-EEE001-fixture.md"
git -C "$work" add -A >/dev/null 2>&1
git -C "$work" commit -qm seed >/dev/null 2>&1
git -C "$work" push -q origin main >/dev/null 2>&1

main_before="$(git -C "$work" rev-parse origin/main)"

# create + check out a story branch with an unrelated CODE commit (simulating the
# implementer working on its branch before flipping status).
git -C "$work" checkout -q -b story/xxx
printf 'package main\n' > "$work/code.go"
git -C "$work" add -A >/dev/null 2>&1
git -C "$work" commit -qm "code: wip" >/dev/null 2>&1
story_head_before="$(git -C "$work" rev-parse HEAD)"

# run the script while checked out on story/xxx (real push path, no NO_PUSH)
out="$( cd "$work" && "$SCRIPT" EXP-EEE001 in-progress 2>&1 )"; rc=$?
[ $rc -eq 0 ] && ok "branch-safety: script succeeds from story branch (rc=0)" || nok "branch-safety: script from story branch (rc=$rc out=$out)"

# the story branch did NOT gain a commit
[ "$(git -C "$work" rev-parse HEAD)" = "$story_head_before" ] && ok "branch-safety: story branch HEAD unchanged" || nok "branch-safety: story branch HEAD unchanged"
[ "$(git -C "$work" rev-parse --abbrev-ref HEAD)" = "story/xxx" ] && ok "branch-safety: still on story/xxx after run" || nok "branch-safety: still on story/xxx (on $(git -C "$work" rev-parse --abbrev-ref HEAD))"

# the story branch working tree is clean (no stray modified/added file)
[ -z "$(git -C "$work" status --porcelain)" ] && ok "branch-safety: story branch working tree clean" || nok "branch-safety: working tree clean (dirty: $(git -C "$work" status --porcelain))"

# the story file on the story branch is NOT modified (still 'ready')
[ "$(git -C "$work" show HEAD:backlog/test-epic/EXP-EEE001-fixture.md | fm)" = "ready" ] && ok "branch-safety: story file on story branch untouched" || nok "branch-safety: story file on story branch untouched"

# origin/main advanced by EXACTLY ONE commit, and it is the story-doc commit
git -C "$work" fetch -q origin >/dev/null 2>&1
main_after="$(git -C "$work" rev-parse origin/main)"
n="$(git -C "$work" rev-list --count "$main_before..$main_after")"
[ "$n" = "1" ] && ok "branch-safety: origin/main advanced by exactly one commit" || nok "branch-safety: origin/main advanced by exactly one commit (got $n)"
# that one commit touches only the story doc
changed="$(git -C "$work" diff --name-only "$main_before" "$main_after")"
[ "$changed" = "backlog/test-epic/EXP-EEE001-fixture.md" ] && ok "branch-safety: the main commit touches only the story doc" || nok "branch-safety: main commit touches only story doc (changed: $changed)"
# and main's story is now in-progress
[ "$(git -C "$work" show origin/main:backlog/test-epic/EXP-EEE001-fixture.md | fm)" = "in-progress" ] && ok "branch-safety: story on main is now in-progress" || nok "branch-safety: story on main now in-progress"
# the unrelated code commit did NOT leak onto main
git -C "$work" show origin/main:code.go >/dev/null 2>&1 && nok "branch-safety: code.go must NOT exist on main" || ok "branch-safety: unreviewed code commit did not leak onto main"

# no temp worktree leaked
[ -z "$(git -C "$work" worktree list --porcelain | grep -A1 "^worktree" | grep -v "^worktree $work\$" | grep "^worktree")" ] && ok "branch-safety: no temp worktree leaked" || nok "branch-safety: temp worktree leaked ($(git -C "$work" worktree list))"

# ---------------------------------------------------------------------------
printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
