import { getCollection } from 'astro:content';

export async function getSortedBalanceChanges() {
  const entries = await getCollection('balanceChanges');
  return entries.sort((a, b) => a.data.order - b.data.order);
}

// Maps a balanceChanges entry id to its page URL, relative to the site base.
export function hrefForBalanceChanges(id: string) {
  return id === 'career-changes' ? 'changes/' : `changes/${id}/`;
}
