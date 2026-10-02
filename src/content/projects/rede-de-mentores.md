---
title: Rede de Mentores
summary: A platform that connects mentors and students, from a 2020 university project, rebuilt on PostgreSQL and AWS Lambda with Terraform, direct-to-S3 uploads and asynchronous image resizing.
category: app
order: 6
year: 2020 · 2026
tags: [JavaScript, Node.js, Express, React, PostgreSQL, AWS Lambda, S3, Terraform]
repo: https://github.com/joaolaureano/rede-de-mentores
live: https://d1eym4la2wj9yi.cloudfront.net
---

## The product

Mentors sign up, list their areas and publish mentorships with available days and times. An
administrator approves each one before it becomes visible. Students browse by area and book a
slot, in person or online.

It was built at [AGES](https://tools.ages.pucrs.br/rede-de-mentores/wiki/-/wikis/home) in the
first semester of 2020. The original is preserved under the `v1` tag; what follows is the rebuild.

## What changed

- **Firestore → PostgreSQL on Neon.** The data layer became repositories, and the API responses
  the frontend depends on stayed exactly the same.
- **Heroku → AWS, provisioned with Terraform.** CloudFront serves the frontend from S3 and the
  API from Lambda; secrets live in SSM Parameter Store.
- **Claim-check image uploads.** Images no longer pass through the API. The browser asks for a
  ticket, uploads straight to S3, and the API only receives the reference. A separate Lambda
  resizes the image asynchronously.
- **Security fixes.** The API no longer returns password hashes, users can no longer promote
  themselves to administrator, and editing a profile no longer wipes the password.
- **Ready to try.** A seed populates areas, mentors, mentees and mentorships, so the deployed app
  isn't empty.
