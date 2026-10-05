import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

const patchNotes = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/patch-notes' }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
  }),
});

const docs = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/docs' }),
  schema: z.object({
    title: z.string(),
    order: z.number().default(0),
  }),
});

const balanceChanges = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/balance-changes' }),
  schema: z.object({
    title: z.string(),
    order: z.number().default(0),
  }),
});

export const collections = { patchNotes, docs, balanceChanges };
