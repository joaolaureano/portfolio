---
title: memorization
summary: A spaced-repetition flashcard app with text, image and audio cards, Anki export and a one-click demo account. Built spec-first with GitHub Spec Kit, with an AI architect orchestrating AI workers.
category: featured
order: 4
year: '2026'
tags: [TypeScript, React, Fastify, PostgreSQL, AWS, OpenTofu, Spec-Driven Development]
repo: https://github.com/joaolaureano/memorization
live: https://d2mp2j3zeufjr0.cloudfront.net
gallery:
  - src: ../../assets/projects/memorization/01-home.png
    alt: Home page with a greeting and today's study schedule
    caption: Home, with today's schedule
  - src: ../../assets/projects/memorization/02-decks.png
    alt: Deck list with search, review-status filter and actions
    caption: Decks, with search and filters
  - src: ../../assets/projects/memorization/03-image-card.png
    alt: Study session showing an image card, the Brazilian flag, with its answer revealed and four rating buttons
    caption: Image card, answer revealed, with the next review interval on each rating
  - src: ../../assets/projects/memorization/04-audio-card.png
    alt: Study session showing an audio card with a player for a birdsong
    caption: Audio card, played only on request
  - src: ../../assets/projects/memorization/05-summary.png
    alt: Session summary with the success rate and cards grouped by rating
    caption: Session summary
  - src: ../../assets/projects/memorization/06-statistics.png
    alt: Statistics for the last 7 days with a daily chart and the latest sessions
    caption: Statistics and session history
  - src: ../../assets/projects/memorization/07-week.png
    alt: Weekly schedule with each day's commitments
    caption: Weekly schedule from study routines
  - src: ../../assets/projects/memorization/08-temporary-deck.png
    alt: Temporary deck builder with two decks added to the selection
    caption: Temporary deck mixing cards from several decks
  - src: ../../assets/projects/memorization/09-export.png
    alt: Export page with all decks selected and the Anki package format
    caption: Export to Anki, with media and review progress
stats:
  - value: '30'
    label: specs, each approved before any code
  - value: '3'
    label: card types (text, image and audio)
  - value: '3'
    label: interface languages
---

## Why it exists

This started as coursework for *Trends in Software Engineering*: can Spec-Driven Development keep
an AI-assisted codebase honest? Every feature began as a specification written with
[GitHub Spec Kit](https://github.com/github/spec-kit). I acted as Product Owner, Claude Code as
architect, and AI workers wrote the code under a written constitution.

## What it does

- **Decks and cards**: text, image and audio cards, with search and filters.
- **Spaced repetition**: SM-2 with a four-level rating decides when each card comes back.
- **Temporary decks**: mix cards from several decks into one shuffled session.
- **Study schedule**: weekly routines per deck, today's commitments and a week calendar.
- **Statistics and history**: hit rate, a daily chart and the record of every session.
- **Anki export**: one or all decks as an `.apkg` file, with media and review progress.
- **Try it**: "Sign in as Test" creates a disposable account with three demo decks (English,
  flags and Brazilian birdsongs), erased on sign-out.
- **Accounts**: sign up, a sliding session, password change and full account deletion.
- **Interface** in Portuguese, English and Spanish, from 360 px phones to desktop, usable by
  keyboard and screen reader.

## Architecture

```mermaid
flowchart TD
    U([Browser]) -->|HTTPS| CF[CloudFront]
    CF -->|/ and assets| S3[(S3<br/>React SPA)]
    CF -->|/api/* + origin secret| L[Lambda<br/>Fastify API]
    L -->|secrets on cold start| SSM[SSM Parameter Store]
    L -->|verified TLS| DB[(Neon<br/>PostgreSQL)]
    L -->|signed URLs| M[(private S3<br/>images and audio)]
    EB[EventBridge, daily] -->|demo cleanup| L
```

- **One API, two runtimes.** The same Fastify app runs locally on SQLite and in the cloud on
  PostgreSQL (Neon), behind a storage port with two real adapters and a shared test battery.
- **CloudFront as the single entry point.** It serves the React SPA from S3 and forwards `/api/*`
  to a Lambda, injecting an origin secret without which the Lambda answers 403.
- **The browser uploads and plays media directly from S3**, a private bucket, through
  short-lived signed URLs; the API only signs them and validates each upload.
- **Scheduled cleanup.** An EventBridge rule invokes the same Lambda to remove abandoned demo
  accounts; a bucket lifecycle rule expires generated exports.
- **Secrets in SSM Parameter Store**, read once on cold start. Infrastructure in OpenTofu;
  GitHub Actions runs the database migrations, then ships the code.
- **Passwords** salted per user, HMAC-SHA256 with a server secret, then scrypt; the session lives
  in an `HttpOnly`, `SameSite=Strict` cookie.
- **Tests** in Vitest and Testing Library, plus Playwright end-to-end in a real browser against
  the real API and database, including layout checks at phone widths and 200% zoom.
