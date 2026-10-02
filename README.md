# portfolio

Source of [joaolaureano.dev](https://joaolaureano.dev): a static site built with
[Astro](https://astro.build), served from S3 and CloudFront, provisioned with OpenTofu and
deployed by GitHub Actions through OIDC, so no AWS key is stored anywhere.

No framework runs in the browser. The only JavaScript is the theme toggle and the tag filter.

## Editing content

| What | Where |
|---|---|
| Name, bio links, avatar, analytics | `src/data/site.ts` (`site`) |
| Experience, education, skills | `src/data/site.ts` |
| Hero text and section copy | `src/pages/index.astro` |
| Projects | `src/content/projects/*.md`, one file per project |

A project is a Markdown file. The frontmatter feeds the card on the home page, the body becomes
`/projects/<file-name>/`:

```md
---
title: go-router
summary: One or two sentences for the card and the page header.
category: featured        # featured | app | lab
order: 2                  # position on the home page
year: 2023 – 2026
status: Evolving          # optional pill
tags: [Go, HTTP, Concurrency]
repo: https://github.com/joaolaureano/go-router
live: https://example.com # optional
stats:                    # optional, shown at the top of the project page
  - value: '0'
    label: runtime dependencies
---

## Any heading

Free Markdown: tables, code blocks, links.
```

The schema lives in `src/content.config.ts`; a missing or mistyped field fails the build.

A ```` ```mermaid ```` block in the body renders as a diagram in the site's colours. Mermaid is
only downloaded on pages that have one, and diagrams redraw when the theme changes.

Tags used by two or more projects appear in the home page filter. The others show up when
someone follows a tag link from a project page.

## Running locally

Requires Node.js 22.12+.

```sh
npm install
npm run dev       # http://localhost:4321, reloads on save
npm run build     # static output in dist/
npm run preview   # serves dist/
```

## Infrastructure

`infra/` creates the Route 53 zone, an ACM certificate, a private S3 bucket read by CloudFront
through Origin Access Control, a CloudFront Function for clean URLs and the www redirect, and an
IAM role GitHub Actions assumes to deploy.

First deploy, once the domain is registered:

```sh
cd infra
tofu init

# 1. Create only the zone, then set its name servers at the registrar.
#    (Route 53 Domains does this by itself.)
tofu apply -target=aws_route53_zone.site
tofu output name_servers

# 2. Once the delegation is live, create everything else.
#    Certificate validation waits for DNS, so this can take a few minutes.
tofu apply
```

Then set three repository variables (Settings → Secrets and variables → Actions → Variables)
from `tofu output`:

| Variable | Output |
|---|---|
| `AWS_DEPLOY_ROLE_ARN` | `deploy_role_arn` |
| `S3_BUCKET` | `bucket` |
| `CLOUDFRONT_DISTRIBUTION_ID` | `distribution_id` |

From then on every push to `main` builds and deploys. Pull requests only build. A manual deploy
is `npm run build && S3_BUCKET=… CLOUDFRONT_DISTRIBUTION_ID=… scripts/deploy.sh`.

Running cost: the hosted zone is US$0.50 a month; S3, CloudFront and ACM stay at cents or free.

## Analytics

Off by default. To turn on [GoatCounter](https://www.goatcounter.com) (free, no cookies, no
banner needed), create a site there and put its code in `site.goatcounter` in
`src/data/site.ts`. Links shared with `?ref=<something>` show up as referrers.
