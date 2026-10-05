// Generates site/src/content/balance-changes/*.md from the $BEGIN_TB/$END_TB
// comment blocks in scripts/mods/TourneyBalance/changes/career_changes/ and
// .../thp_stagger_damage_changes/. Each block's content is already plain
// markdown - this extracts it, dedents it, and (for career changes) groups
// careers under a "# Hero Name" heading derived from the file's two-letter
// hero prefix, so each output page renders as one document with a clean
// heading hierarchy: page title (H1) > group (H2) > items (H3, bold names).
// Runs automatically via the predev/prebuild npm hooks - see package.json.
import { readdirSync, readFileSync, rmSync, mkdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const CHANGES_ROOT = path.resolve(__dirname, '../../scripts/mods/TourneyBalance/changes');
const CAREER_DIR = path.join(CHANGES_ROOT, 'career_changes');
const THP_DIR = path.join(CHANGES_ROOT, 'thp_stagger_damage_changes');
const OUTPUT_DIR = path.resolve(__dirname, '../src/content/balance-changes');

const HEROES = {
  es: 'Markus Kruber',
  dr: 'Bardin Goreksson',
  we: 'Kerillian',
  wh: 'Victor Saltzpyre',
  bw: 'Sienna Fuegonasus',
};

// Strips the common leading whitespace shared by every non-blank line, and
// rewrites bare "---" divider lines to "***". Both render as an identical
// <hr>, but "---" is also the YAML frontmatter delimiter - once multiple
// blocks are concatenated into one document, a bare "---" reads as a second
// frontmatter block to the markdown parser, which silently swallows
// everything up to the *next* "---" as frontmatter. "***" keeps the visual
// divider without that collision.
function dedent(block) {
  const lines = block
    .replace(/^\n/, '')
    .replace(/\s+$/, '')
    .split('\n')
    .map((l) => (l.trim() === '---' ? l.replace(/---/, '***') : l));
  const indents = lines.filter((l) => l.trim().length > 0).map((l) => l.match(/^[ \t]*/)[0].length);
  const minIndent = indents.length > 0 ? Math.min(...indents) : 0;
  return lines.map((l) => l.slice(minIndent)).join('\n');
}

function extractBody(filePath) {
  const source = readFileSync(filePath, 'utf8');
  const blockMatch = source.match(/\$BEGIN_TB\r?\n([\s\S]*?)\r?\n[ \t]*\$END_TB/i);
  if (!blockMatch) return null;
  const body = dedent(blockMatch[1]);
  return body || null;
}

// Promotes every heading in a block by one level (## -> #, ### -> ##, ...).
// Bold lines (talent/passive names) are left untouched - they're not headings.
function promoteHeadings(body) {
  return body
    .split('\n')
    .map((line) => line.replace(/^(#{1,6})(\s+)/, (_, hashes) => hashes.slice(1) + ' '))
    .join('\n');
}

function writePage(fileName, order, title, body) {
  const frontmatter = `---\ntitle: ${JSON.stringify(title)}\norder: ${order}\n---\n\n`;
  writeFileSync(path.join(OUTPUT_DIR, fileName), frontmatter + body.trim() + '\n', 'utf8');
}

function generateCareerChanges() {
  const files = readdirSync(CAREER_DIR)
    .filter((f) => f.endsWith('.lua'))
    .sort();

  const byHero = new Map();
  for (const file of files) {
    const prefixMatch = file.match(/^\d+_([a-z]+)_/);
    const heroName = prefixMatch && HEROES[prefixMatch[1]];
    if (!heroName) {
      console.warn(`Skipping ${file}: no known hero prefix`);
      continue;
    }

    const body = extractBody(path.join(CAREER_DIR, file));
    if (!body) continue;

    if (!byHero.has(heroName)) byHero.set(heroName, []);
    byHero.get(heroName).push(body);
  }

  const sections = [];
  for (const heroName of Object.values(HEROES)) {
    const careerBodies = byHero.get(heroName);
    if (!careerBodies || careerBodies.length === 0) continue;
    sections.push(`***\n\n# ${heroName}\n\n${careerBodies.join('\n\n')}`);
  }

  writePage('career-changes.md', 2, 'Career Changes', sections.join('\n\n'));
  return byHero.size;
}

function generateThpStaggerChanges() {
  const files = ['03_thp_talents_changes.lua', '04_stagger_talents_changes.lua'];
  const sections = [];
  for (const file of files) {
    const body = extractBody(path.join(THP_DIR, file));
    if (!body) continue;
    sections.push(promoteHeadings(body));
  }
  if (sections.length === 0) return 0;

  writePage('thp-stagger-changes.md', 1, 'THP & Stagger Changes', sections.join('\n\n'));
  return sections.length;
}

function main() {
  rmSync(OUTPUT_DIR, { recursive: true, force: true });
  mkdirSync(OUTPUT_DIR, { recursive: true });

  const heroCount = generateCareerChanges();
  const thpCount = generateThpStaggerChanges();

  console.log(`Generated career-changes.md (${heroCount} heroes) and thp-stagger-changes.md (${thpCount} sections) into ${path.relative(process.cwd(), OUTPUT_DIR)}`);
}

main();
