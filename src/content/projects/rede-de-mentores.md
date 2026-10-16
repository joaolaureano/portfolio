---
title: Rede de Mentores
summary: A platform that connects mentors and students, from a 2020 university project, rebuilt on PostgreSQL and AWS Lambda with Terraform, direct-to-S3 uploads and asynchronous image resizing.
category: app
order: 6
year: 2020 · 2026
tags: [JavaScript, Node.js, Express, React, PostgreSQL, AWS, S3, Terraform]
repo: https://github.com/joaolaureano/rede-de-mentores
live: https://mentores.joaolaureano.dev
gallery:
  - src: ../../assets/projects/rede-de-mentores/01-sign-in.png
    alt: Sign-in page with the Rede de Mentores logo over a photo of the university building
    caption: Sign in
  - src: ../../assets/projects/rede-de-mentores/02-areas.png
    alt: Student home page listing the knowledge areas, from Carreira to Tecnologia, with a search box
    caption: A student starts from the knowledge areas
  - src: ../../assets/projects/rede-de-mentores/03-mentorships.png
    alt: Mentorships available in the Carreira area, each with its mentor, description and next time slots
    caption: Mentorships in an area, with the mentor and the next time slots
  - src: ../../assets/projects/rede-de-mentores/04-slots.png
    alt: A mentorship's page with its dates and times, available slots in blue and taken ones in gray
    caption: Picking an available slot
  - src: ../../assets/projects/rede-de-mentores/05-my-mentorships.png
    alt: Mentor's page listing their mentorships with the next time slots and buttons to delete, view and edit
    caption: A mentor's own mentorships
  - src: ../../assets/projects/rede-de-mentores/06-new-mentorship.png
    alt: New mentorship form with title, description, knowledge areas, online or in person, and weekly day and time
    caption: Publishing a new mentorship, which an administrator approves before it goes live
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
  isn't empty. Sign in as a student with `mentorado@demo.rededementores.dev` or as a mentor with
  `mentor@demo.rededementores.dev`, both with the password `demo1234`.
