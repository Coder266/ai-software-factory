# Code conventions

For anyone writing or running application code — the implementer, and `/qa` when exercising
the app.

- **Backend:** Go, stdlib HTTP for now. Match the existing structure and style; prefer the
  stdlib over adding dependencies.
- **Frontend:** Vue 3 + Vite in `frontend/` — plain Vue with scoped CSS, no component
  framework. Dev server on `5173`.
- **Run locally (devcontainer):** `go run .` serves `:8080` (`/healthz` → `ok`); Postgres is
  at `db:5432` via `DATABASE_URL`.
- **Tests:** add or adjust tests with the change. Build and test green before opening or
  updating a PR: `go build ./...`, `go test ./...`, and the relevant `npm` scripts in
  `frontend/`. Never open a PR on a red build.
- **Scope:** keep the diff to one story; defer unrelated cleanups to their own story.
- **Sensitive data (hard rule):** never commit real bank statements or any `*.csv` outside
  `testdata/`. Prefer `testdata/sample_statement.csv` as the development default; for QA, use
  or create suitable synthetic test data under `testdata/` for the scenario. (See the
  "Sensitive data" section of `CLAUDE.md`.)
