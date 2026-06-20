// Command expense-app is the entry point for the expense tracker.
//
// At this stage it is intentionally minimal: it proves the devcontainer and
// Postgres wiring work end to end. Real features (statement import,
// categorization, reporting) arrive as backlog stories.
package main

import (
	"log"
	"net/http"
	"os"
)

func main() {
	if dsn := os.Getenv("DATABASE_URL"); dsn != "" {
		log.Printf("DATABASE_URL is set (database reachable as host \"db\")")
	} else {
		log.Printf("warning: DATABASE_URL is not set")
	}

	http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok\n"))
	})

	addr := ":8080"
	log.Printf("listening on %s", addr)
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatal(err)
	}
}
