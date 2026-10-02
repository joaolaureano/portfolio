#!/usr/bin/env bash
# Uploads dist/ and invalidates the cache.
# Hashed assets in _astro/ never change under the same name, so they are cached
# for a year; HTML is revalidated on every visit so a deploy shows up at once.
set -euo pipefail

: "${S3_BUCKET:?set S3_BUCKET (tofu output bucket)}"
: "${CLOUDFRONT_DISTRIBUTION_ID:?set CLOUDFRONT_DISTRIBUTION_ID (tofu output distribution_id)}"

cd "$(dirname "$0")/.."
[ -d dist ] || { echo "dist/ not found: run npm run build first" >&2; exit 1; }

aws s3 sync dist/_astro "s3://$S3_BUCKET/_astro" \
  --cache-control "public, max-age=31536000, immutable" --delete

aws s3 sync dist "s3://$S3_BUCKET" --exclude "_astro/*" \
  --cache-control "public, max-age=0, must-revalidate" --delete

aws cloudfront create-invalidation \
  --distribution-id "$CLOUDFRONT_DISTRIBUTION_ID" --paths "/*" \
  --query 'Invalidation.Id' --output text
