---
title: java-p2p
summary: Peer-to-peer file sharing over UDP, where a ring of super-nodes partitions the MD5 key space into a small DHT. Java 21, zero runtime dependencies, written from scratch.
category: featured
order: 3
year: 2022 · 2026
status: Next — desktop GUI
tags: [Java, Distributed Systems, DHT, UDP, Networking, JUnit]
repo: https://github.com/joaolaureano/java-p2p
stats:
  - value: '66'
    label: JUnit tests, in-process ring included
  - value: '15'
    label: v1 bugs found and fixed
  - value: '0'
    label: runtime dependencies
---

## What it does

Peers join a ring of super-nodes, share any file in a folder, and download each other's files
chunk by chunk over UDP. The ring stores only *who has what*; file content always travels
directly between peers.

Each resource is identified by the MD5 of its content. The ring splits the 2^128 key space into
equal slices, and the last node owns the remainder, so no hash is ever left without an owner
even when the node count doesn't divide 2^128.

## Protocol

Every datagram is a UTF-8 header line, optionally followed by a raw binary body, like a tiny
HTTP. Control messages are text; file data never is.

| Message | Direction | Reply |
|---|---|---|
| `create <nickname>` | peer → super-node | `OK` or an error |
| `heartbeat <nickname>` | peer → super-node, every 5 s | none; peers expire after 15 s |
| `register <hash> <size> <name>` | peer → super-node | routed around the ring to the owner |
| `list` | peer → super-node | every resource in the ring |
| `meta <hash>` | peer → peer | size, chunk count and name |
| `chunk <hash> <i>` | peer → peer | up to 8 KiB of raw bytes |

Requests the current node doesn't own travel the ring carrying their origin, and stop when they
come back to it.

## Reliable transfer on unreliable UDP

Downloads are pull-based and stop-and-wait: one chunk at a time, retried after 500 ms, up to five
times. Chunks land in a `.part` file, and only after size and MD5 both match is it renamed into
place. A request carries a hash, never a path, so a peer can only serve files it chose to share.

The test suite includes an uploader that **drops every third request**. The download must still
finish byte-identical.

## From coursework to a real codebase

The first version was a 2022 assignment for Distributed Systems. Reviewing it years later turned
up fifteen bugs, among them:

- the partition left the tail of the MD5 space without an owner for three nodes;
- ring messages never noticed they had returned to their origin, looping forever on unowned hashes;
- the next node was hard-coded as `localhost`, so it only ever worked on one machine;
- heartbeat expiry ran inside a `catch` block, so under traffic peers never expired.

v2 keeps the design, fixes every one of them, moves to Maven, Java 21 and CI. The original is
preserved under the `v1.0.0-original` tag.

## What's next

A desktop client in the style of a torrent app: files in the ring, per-chunk progress, connected
peers and seeding, so the protocol can be watched instead of read from logs.
