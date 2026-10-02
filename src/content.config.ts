import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

const projects = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/projects' }),
  schema: z.object({
    title: z.string(),
    summary: z.string(),
    // featured: main work · app: deployed products · lab: architecture studies
    category: z.enum(['featured', 'app', 'lab']),
    order: z.number(),
    year: z.string(),
    tags: z.array(z.string()),
    repo: z.string().optional(),
    live: z.string().optional(),
    status: z.string().optional(),
    stats: z.array(z.object({ value: z.string(), label: z.string() })).default([]),
  }),
});

export const collections = { projects };
