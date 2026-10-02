---
title: go-router
summary: A small, dependency-free HTTP router for Go on a compressed patricia trie, with lock-free lookups and a concurrency story verified under load rather than asserted.
category: featured
order: 2
year: 2023 – 2026
tags: [Go, HTTP, Radix Tree, Concurrency, Fuzzing, Load Testing]
repo: https://github.com/joaolaureano/go-router
stats:
  - value: '0'
    label: runtime dependencies
  - value: lock-free
    label: route lookups
  - value: 3 layers
    label: fuzz, benchmarks, load tests
---

## What it is

A router in the spirit of [chi](https://github.com/go-chi/chi): static routes and `{param}`
captures, groups, mounting and middleware chains, on top of the standard library only. It
started in 2023 as a way to learn how routers actually match paths, and grew into something I
would be comfortable depending on.

```go
r := router.NewRouter()
r.Get("/users/{id}", func(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("user " + context.Param(r, "id")))
})
r.Group("/admin", func(r *router.Router) {
    r.Use(requireAuth)
    r.Get("/stats", stats)
})
http.ListenAndServe(":3333", r)
```

## Design

- **Patricia trie matching.** A shared literal prefix, even across a `/`, collapses into one
  edge instead of one node per segment. The tree splits only at the byte where two routes first
  diverge.
- **Atomic tree swaps.** Registration builds a new tree and swaps it in atomically, so adding or
  mounting routes while serving traffic never exposes a half-built tree, and lookups never take
  a lock.
- **HTTP semantics done properly.** `HEAD` falls back to `GET`; `OPTIONS` on a known path answers
  `204` with a computed `Allow` header. Registering either explicitly always wins.
- **Groups and mounting.** `Group` shares a prefix and middleware; `Mount` grafts another
  router's routes, handlers and middleware intact, under a prefix.

## Verification

Beyond unit tests, the routing tree carries three layers:

1. **Fuzz tests** for route registration and lookup against arbitrary input.
2. **Benchmarks** for static, parameter, escaped and miss lookups, including parallel and
   large-fanout cases.
3. **Load tests** driven by [vegeta](https://github.com/tsenart/vegeta) that check correctness
   *under concurrent load*, including registering and mounting routes while traffic is in flight.

The last one is the point: "concurrency-safe" is a claim, and the load test is what makes it a
fact.
