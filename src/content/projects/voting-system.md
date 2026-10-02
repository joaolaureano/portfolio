---
title: Real-time voting
summary: Streaming vote tallying with Kafka and Flink, exactly one vote per voter, and receipts the voter can verify in their own browser through RFC 6962 Merkle inclusion proofs.
category: lab
order: 7
year: '2026'
tags: [Java, Go, Kafka, Flink, Merkle Tree, Exactly-once, Gatling]
repo: https://github.com/joaolaureano/voting_system
stats:
  - value: 49 ms
    label: p95 for 10,000 votes, 0 failures
  - value: 8,986
    label: distinct voters, tally exact
  - value: 226 ns
    label: per inclusion proof
---

## The pipeline

```
POST /votes ─► ingest-api ─► [votes.cast] ─► Flink ─┬─► results by candidate, state, city, party
                                               dedup └─► [votes.accepted] ─► merkle-service (Go)
                                                                                   │
                                                  voting-web ◄── GET /proof/{receipt}
                                                  (verifies in the browser)
```

Votes come in over REST and go to Kafka. A Flink job keeps state per voter, so the second vote
from anyone goes to `votes.rejected` with the receipt of the vote that actually counts. Running
tallies are published by candidate, state, city and party.

## Guarantees

| Guarantee | How it was checked |
|---|---|
| One vote per voter | 11,001 requests from 10,000 voters: tally closed at 8,986, the distinct ones, with 1,014 rejections |
| Exactly-once | task manager restarted during load: counts didn't inflate, dedup state preserved |
| Inclusion proof | an independent verifier in Python accepted valid proofs and rejected a forged leaf and a tampered path |
| Server-owned deadline | a vote injected straight into Kafka after closing was rejected as `ELECTION_CLOSED` |
| Verification in the browser | 14 checks in real Chrome: a proof tampered **by the server** is rejected on the voter's machine |

A vote is only confirmed after Kafka's ack (`acks=all`, idempotent producer). A `503` means the
vote is fine but wasn't recorded; resending is safe, because the duplicate is filtered at tallying.

## Inclusion proofs

The Go service seals each time window into an RFC 6962 Merkle tree, the structure behind
Certificate Transparency, chained to the previous window. With a receipt, the voter gets a proof
and checks it locally:

```
leaf = SHA-256(0x00 || receipt)
node = SHA-256(0x01 || left || right)
```

The prefixes prevent a leaf from being forged as an internal node. Profiling this service with
[pprof_advisor](/projects/pprof-advisor/) took proof generation from 14.86 ms to 226 ns on
100,000 leaves.

## Watermark stalls

Event-time windows stall without traffic: no new event, no watermark, no sealed window, and a
voter waits forever for a proof. Advancing time from the wall clock would break reproducibility of
the roots. The fix was to make time itself data: heartbeats flow through the same pipeline, so a
lone vote is sealed in about 45 seconds and the root stays reproducible.
