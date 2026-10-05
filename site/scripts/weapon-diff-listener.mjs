// One-shot local listener for balance_diff_export.lua's "/tb_export_weapon_diff"
// chat command. Run this, then trigger the command in-game - it POSTs the diff JSON
// to http://localhost:4545/weapon-diff, this writes it to weapon-diff.json next to
// this script, and the process exits. Re-run before each export.
//
// Usage: node scripts/weapon-diff-listener.mjs
import { createServer } from 'node:http';
import { writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const OUTPUT_PATH = path.join(__dirname, 'weapon-diff.json');
const PORT = 4545;

// Recursively sorts object keys alphabetically (arrays keep their original index
// order - allowed_chain_actions/armor_modifier-style arrays are positionally
// meaningful, sorting them would corrupt the data). This is done here rather than
// Lua-side because a mod-inserted damage profile's field order (from table.merge_recursive)
// doesn't match a vanilla-defined profile's field order, and Lua/cjson don't give
// control over key order the way rebuilding the object in JS does - so a profile's
// "before" (vanilla) and "after" (modded) blocks were rendering with their fields in
// different relative positions, making a manual side-by-side read painful even when
// only one or two fields actually differed.
function sortKeysDeep(value) {
  if (Array.isArray(value)) {
    return value.map(sortKeysDeep);
  }
  if (value !== null && typeof value === 'object') {
    const sorted = {};
    for (const key of Object.keys(value).sort()) {
      sorted[key] = sortKeysDeep(value[key]);
    }
    return sorted;
  }
  return value;
}

const server = createServer((req, res) => {
  if (req.method !== 'POST' || req.url !== '/weapon-diff') {
    res.writeHead(404).end();
    return;
  }

  const chunks = [];
  req.on('data', (chunk) => chunks.push(chunk));
  req.on('end', () => {
    const body = Buffer.concat(chunks).toString('utf8');

    try {
      const diff = JSON.parse(body);
      // Stable path order across every category, not just the DamageProfileTemplates
      // entries the Lua side already sorts - array position isn't otherwise
      // meaningful here (unlike the arrays sortKeysDeep leaves alone), so re-ordering
      // by path is free.
      diff.sort((a, b) => (a.path < b.path ? -1 : a.path > b.path ? 1 : 0));

      const sorted = sortKeysDeep(diff);
      writeFileSync(OUTPUT_PATH, JSON.stringify(sorted, null, 2), 'utf8');
      console.log(`Wrote ${diff.length} change(s) to ${path.relative(process.cwd(), OUTPUT_PATH)}`);
      res.writeHead(200).end();
    } catch (err) {
      console.error('Failed to parse/write diff:', err);
      res.writeHead(500).end();
    } finally {
      server.close();
    }
  });
});

server.listen(PORT, () => {
  console.log(`Listening on http://localhost:${PORT}/weapon-diff - run /tb_export_weapon_diff in-game now.`);
});
