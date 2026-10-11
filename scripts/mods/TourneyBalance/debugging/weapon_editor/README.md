# Weapon editor

In-game Imgui tool for tuning TourneyBalance weapons. You edit values while playing, check
breakpoints, then export the changes as Lua to paste into the weapon change files. Every
exported value carries a `-- vanilla:` comment.

Dev tool only: it is off in every commit and must never ship enabled.

## Setup

1. In `weapon_editor.lua`, set `local ENABLED = true` (keep it local - never commit it, and
   never commit a bundle built with it on).
2. Build, then **fully restart the game**. A VMF hot reload is not enough: the `we_*.lua`
   files are loaded with `require`, which keeps the old copies until restart.
3. Play solo or as host. The server calculates damage from its own tables, so edits only
   affect hits in games you host.

`weapon_editor.lua` is loaded before every change file (see `TourneyBalance.lua`), so the
vanilla snapshot it takes is untouched by TourneyBalance.

## Commands

| Command | What it does |
|---|---|
| `/tbwe` | Open/close the editor window |
| `/tbwe_breakpoints` | Show/hide the breakpoint window |
| `/tbwe_reequip` | Respawn the wielded weapon so wield/spawn-time fields apply |
| `/tbwe_export` | Copy all edits as Lua to the clipboard (also printed to the console log) |
| `/tbwe_status` | List pending edits, and what happened to last session's at launch |
| `/tbwe_revert_all` | Revert every edit to the TourneyBalance baseline |
| `/tbwe_reset_windows` | Move both windows back on screen (they vanish if dragged outside the game window) |

**F3** switches between using the windows (mouse cursor, game input blocked) and playing.
Chat can't be opened while the windows have input, so press F3 before typing a command.

## Finding things

- The editor opens on your **wielded weapon**. "Wielded weapon" re-selects it.
- **Search** finds weapon templates, `[explosion]` entries (`ExplosionTemplates`) and
  `[spread]` entries (`SpreadTemplates`).
- A weapon shows its **actions** (action_one, action_two, ...) and their sub-actions, each
  labelled with the damage profile(s) it uses. Other template fields (dodge buffs, ammo,
  block angles, stamina) are under **other template fields**.
- Fields that name something open it right below them: `damage_profile*` fields open the
  profile, `explosion_template` / `aoe` / `aoe_name` open the explosion, and
  `default_spread_template` / `spread_template_override` open the spread template.
- `*` after a name means something below it is edited.

## Editing

- **Numbers** are text fields showing the exact value. A value applies as soon as it parses
  as a number; unfinished input like `0.` or `-` waits.
- **Booleans** are checkboxes. `attack_template`, `boost_curve_type`, `charge_value`, damage
  profile and template-name fields are **dropdowns**. Other text fields need **apply**, so a
  half-typed value is never live.
- Edits apply to the next swing or hit - no re-equip needed - except fields only read when the
  weapon is wielded or spawned (template `buffs` such as dodge and movement, and `ammo_data`).
  Editing those shows a red warning with a **re-equip** button (also in the menu bar and as
  `/tbwe_reequip`). Ammo is kept as a percentage of the new maximum.
- Every edited field shows its **TB** value (as loaded from the files) and its **vanilla**
  value, plus a **revert** button. There are also revert buttons per weapon, per profile, per
  explosion/spread entry, in the **All edits** list, and **Revert all**.
- **Shared presets.** Vanilla profiles share `PowerLevelTemplates` presets (armor modifiers,
  crit, cleave). Editing a field inside one first copies the preset into that profile, so other
  weapons are unaffected. Weapon action tables shared between templates are only flagged
  ("Shared table - edits also change: ..."), because the change files share them too.

### Attack sheet

Opening a damage profile shows the **attack sheet** first: top-level fields
(`charge_value`, `melee_boost_override`, `shield_break`, ...), cleave, then one column per
target plus `default_target`. Rows cover power attack/impact, attack template, boost curve and
coefficients, headshot boost, armor modifiers per armor type (infantry, armored, monster,
player, berserker, super armor) and crit power modifiers. A target without its own
`armor_modifier` shows the profile's. The full raw tree is under **all fields**.

### Structure mode

Tick **structure mode** at the top to add or remove fields and entries:

- Every field gets **x** (remove). Below each table, **+ field** takes a name and a value:
  a number, `true` / `false`, text, or `{}` for an empty table.
- List entries (`targets`, `allowed_chain_actions`, ...) get **dup**, **up**, **down** and **x**,
  and the list gets **+ entry** (a copy of the last entry; an empty `targets` list starts from
  `default_target`, an empty chain action list from a default chain action).
- Removed fields stay listed as "(removed)" with a **revert** button.
- In the attack sheet, "-" cells become **+** (adds the game's default), plus **+ target**,
  **x** per target column and **own armor** / **drop own armor** per column.

### Forking a profile

Under a profile opened from an attack, **fork into a new tb_ profile** copies it under a new
name (suggested `tb_<weapon>_<attack>`) and points **this attack** or **all attacks of this
weapon using it** at the copy. It exports as a new `NewDamageProfileTemplates` block.
**delete fork** points the attacks back and removes it. A fork is also removed automatically
once no attack points at it anymore (e.g. after reverting the edits that pointed attacks at it,
or **Revert all**), so it no longer exports or comes back next session.

### Explosions and spread

- Weapon templates are built with `table.clone`, so each weapon fires its **own copy** of its
  explosion. The immediate blast uses that copy; lingering area damage (and other players)
  use `ExplosionTemplates[name]`. A copy is labelled "own copy of ExplosionTemplates.x" with a
  **link to global** button, which points the weapon at the global entry (as
  `bw_fireball.lua` does by hand). After linking, edits reach both. Linking discards edits made
  inside that weapon's copy.
- Spread templates are read live: edits apply immediately.
- Projectiles are likewise per-weapon copies that nothing looks up by name, so they are edited
  (and exported) under the weapon's action (`projectile_info`), not as a separate entry.

## Breakpoints

Click **breakpoints** on any attack (or `/tbwe_breakpoints`, which starts on the weapon's
first attack). The grid shows, per breed and target index:

    now | TB | vanilla

- **now** = live data with your edits, **TB** = as loaded from the files, **vanilla** = the
  profile the action used before TourneyBalance. All three use TourneyBalance's damage formula,
  so differences come only from the weapon data.
- Green = your edit beats the TB value, red = worse.
- Options: your power level or a typed one, difficulty, hit zone (torso/head), crit, stagger
  stacks (TB's 20% per stack), 1-5 targets, hits-to-kill or raw damage, and which categories
  to show: **Trash, Elite, Specials, Other, Boss, Lords** (taken from the categories used in
  `breakpoints.BREEDS`, so a new category there gets its own checkbox automatically).
- Cells include your **damage buffs** as they are when the grid refreshes (twice a second):
  talents and properties like Grail Knight's first-target perk (target 1 counts as the first
  hit), melee/2h power-ups and `damage_dealt`. Conditional buffs only show while active -
  e.g. Heroism's charged-heavy bonus appears while you hold a charged heavy.
- **hit log**: tick "record hits" to log real hits (damage dealt, stagger multiplier, damage
  buff multiplier, hits to kill). Each hit is checked twice: TB's damage formula, and the damage
  buff step that runs after it (`apply_buffs_to_damage`). Either disagreeing is flagged in red.
  Known gaps: instakill perks (Killing Shot, Murderous Prowess), buffs on the target (poison,
  bleed, balefire, target health), ranged falloff - these show up as mismatches.

## Exporting

`/tbwe_export` (or **Export to clipboard** in the menu) copies Lua grouped by what was edited:

| Edited | Export |
|---|---|
| Weapon fields | One line per field: `Weapons.x... = 0.45 -- vanilla: 0.5` (plus `prev TB:` if TB already changed it) |
| TB profiles (`NewDamageProfileTemplates`) | The whole `NewDamageProfileTemplates.tb_x = { ... }` block to replace the existing one, untouched presets kept as names, every field differing from the vanilla profile it replaced commented, plus a `-- changed:` summary |
| Forks | A new block to add, `-- vanilla:` against the forked profile |
| Vanilla profiles | One line per field, or the whole copied sub-table where a shared preset was copied |
| Explosion / spread entries | `ExplosionTemplates.x... = ...` / `SpreadTemplates.x... = ...` lines; explosion sections note weapons still on their own copy |
| Structural edits | A whole table (added field, rewritten list), `= nil` (removed) or `= ExplosionTemplates.x` (linked) |

Paste each part into the matching weapon change file, rebuild and restart.

## Restarting

Edits and forks are saved, so they survive a crash or restart. At launch the editor compares
each saved edit against what the files now load: edits already in the files are **dropped**,
the rest are **re-applied**. The chat message (and `/tbwe_status`) reports how many of each,
which doubles as a check that a paste landed.

## Files

| File | Contents |
|---|---|
| `weapon_editor.lua` | Entry point: `ENABLED`, snapshots, edit registry, copy-on-write, forks, persistence, re-equip, input, commands |
| `we_core.lua` | Shared helpers: paths, value formatting, edit encoding |
| `we_export.lua` | The Lua exporter (key order measured from the existing change files) |
| `we_ui.lua` | The editor window, attack sheet, structure mode |
| `we_breakpoints.lua` | Breakpoint grid and hit log |
