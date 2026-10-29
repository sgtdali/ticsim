# Project Instructions

## Project Status

ticsim changed direction on 2026-10-29. It is now a modern-industrial company production & logistics tycoon on a procedurally generated, country-sized grid map, targeting Song of Syx–level simulation depth.

- **Current phase:** Stage 1 — world simulation without a player (see `docs/design/vision.md`).
- **Legacy code:** The abandoned medieval trading-sim prototype (GDScript code, scenes, data, art assets, balance sim) was removed on 2026-10-29. It survives only in git history; do not restore it or use it as a reference for new systems.

## Architecture Reference

`docs/architecture.md` is the source of truth for codebase structure.

Before adding new systems, data tables, scenes, or tools — and before asking "where does X live?" or "how does Y connect to Z?" — read `docs/architecture.md` first. It documents:

- Layer separation (Sim / Viewer / Tools)
- Folder layout
- Core types (World, Clock, IDs, RNG, Money)
- Data tables and their fields
- System list and tick schedule
- Determinism and performance rules

When a code change adds a new system or data table, alters the tick schedule, or changes a data shape, update `docs/architecture.md` in the same task.

## Simulation Code Rules

The simulation is written in C# and must run headless.

- Simulation code never references Godot nodes, scenes, or the scene tree. The Viewer reads simulation state; it never writes it.
- Data-oriented: entities are `struct` arrays addressed by integer IDs. No per-tick heap allocation in hot paths.
- Deterministic: each system uses its own seeded RNG stream (never a global `Random`); parallel work writes to per-thread buffers merged in a fixed order; money is an integer (`long`, kuruş); no logic depends on dictionary iteration order or wall-clock time.
- Periodic work (daily/weekly/monthly) is spread across ticks, not run in a single tick.
- Every system reports its per-tick time to the profiler; the budget is defined in `docs/architecture.md`.
- Tunable numbers live in definition/config files under `data/defs/`, not hardcoded in C#.

## Design Mode

When the user says **"tasarım modu aktif"**, enter design mode and follow the instructions in `docs/design/GUIDE.md`:

- Do not write code or modify any file outside `docs/design/`.
- Read `docs/design/_index.md` to see open questions, conflicts and parked ideas.
- When a topic is raised, read the relevant `docs/design/*.md` file, summarize the current state, then enter the discussion.
- As decisions are reached, update the relevant file, add the decision to `docs/design/decision_log.md`, and append a summary to the file's "Tartışma Notları" section.
- Keep `_index.md` current: remove answered questions, add new questions and conflicts as they emerge.

When the user says **"tasarım modu deaktif"**, return to normal mode: design restrictions are lifted, coding resumes.

## UI Workflow (Viewer and later game UI)

Build and refactor UI as if it is being assembled in the Godot editor.

Prefer scene nodes, `.tscn` structure, reusable `.tres` resources, themes, StyleBoxes, ShaderMaterials, and exported/inspectable properties over runtime-only UI construction. When adding or changing major UI layout, controls, backgrounds, button states, table sections, or panel hierarchy, make the result visible and adjustable in the editor whenever practical.

Runtime code should primarily bind data, update labels/values, connect interactions, and toggle state. Avoid creating large UI hierarchies entirely in code unless the UI is genuinely dynamic or there is a clear reason. If runtime-created UI is necessary, keep it small, named consistently, and explain why it cannot reasonably live in the scene.

Map rendering is the exception: tiles, entities and overlays for a ~2500² map are drawn in code (chunked TileMap/MultiMesh or custom drawing) for performance.

For image-backed UI elements, create reusable `.tres` StyleBoxTexture/resources and assign them to scene nodes so editor preview and runtime match.

## Mechanics Documentation

`docs/mechanics.md` is the source of truth for **implemented** gameplay mechanics. `docs/design/` holds designed but not necessarily implemented mechanics.

Whenever a code, data, or definition change affects simulation mechanics, balance, or systemic behavior, check `docs/mechanics.md` in the same task and update it (including the implementation status table). If the implementation deviates from `docs/design/`, say so explicitly.

Before adding a new mechanic or changing an existing one, briefly review the current mechanics and design docs and give design feedback when useful. Call out:

- Direct conflicts with existing mechanics, design decisions (`docs/design/decision_log.md`), or scope
- Systems that will be affected indirectly
- Edge cases, exploit risks, or economic runaway risks (money supply, monopolies, stagnation)
- Effects on determinism or the performance budget
- Simpler alternatives when the requested change is larger than needed

Keep this feedback concise and practical. Once the impact is clear, proceed with the implementation unless the user asks to discuss first or the change would create a serious design/scope conflict.

Mechanics-impacting areas include, but are not limited to:

- Goods, recipes, quality, brand, cargo classes, spoilage
- Households, needs bars, seasons, professions, wages, growth, migration
- Retail stores, city exchanges, order matching, fees and commissions
- Company AI decisions, personalities, bankruptcy, new entrants, investment pool
- Infrastructure, public network, tolls, congestion, pathfinding, dispatch, vehicles
- Map generation, resources, city growth, import safety net
- Research levels, unlocks, patents
- Health metrics, alarms, and Stage 1 exit criteria
- Definition files in `data/defs/`

If a mechanics-affecting change does not require a documentation update, mention that explicitly in the final response.
