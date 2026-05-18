# Project Instructions

## UI Workflow

Build and refactor UI as if it is being assembled in the Godot editor.

Prefer scene nodes, `.tscn` structure, reusable `.tres` resources, themes, StyleBoxes, ShaderMaterials, and exported/inspectable properties over runtime-only UI construction. When adding or changing major UI layout, controls, backgrounds, button states, table sections, or panel hierarchy, make the result visible and adjustable in the editor whenever practical.

Runtime code should primarily bind data, update labels/values, connect interactions, and toggle state. Avoid creating large UI hierarchies entirely in code unless the UI is genuinely dynamic or there is a clear reason. If runtime-created UI is necessary, keep it small, named consistently, and explain why it cannot reasonably live in the scene.

For image-backed UI elements, create reusable `.tres` StyleBoxTexture/resources and assign them to scene nodes so editor preview and runtime match. Do not rely on code-only theme overrides for important visuals if the same effect can be represented in the scene/resource inspector.

## Mechanics Documentation

`docs/mechanics.md` is the source of truth for gameplay mechanics.

Whenever a code, data, or scene change affects gameplay mechanics, progression, balance, or player-visible systemic behavior, check `docs/mechanics.md` in the same task and update it when needed.

Before adding a new mechanic or changing an existing one, briefly review the current mechanics and give design feedback when useful. Call out:

- Direct conflicts with existing mechanics, progression gates, balance assumptions, or scope
- Systems that will be affected indirectly
- Edge cases or exploit risks the change may create
- Existing mechanics that should be connected to the new change for a stronger design
- Simpler alternatives when the requested change is larger than needed

Keep this feedback concise and practical. Once the impact is clear, proceed with the implementation unless the user asks to discuss first or the change would create a serious design/scope conflict.

Mechanics-impacting areas include, but are not limited to:

- Rank requirements, unlocks, win/loss conditions, and progression gates
- Economy, prices, stock caps, production, consumption, recipes, and seasons
- Town prosperity, investment, population, growth, decline, and city status
- Contracts, rewards, deadlines, failure penalties, and contract tiers
- Factions, reputation, NPC relations, trade modifiers, and rivalry effects
- Travel time, travel risk, attacks, cargo loss, and route behavior
- Caravan capacity, upgrades, cargo rules, and player inventory behavior
- Trading Posts, depots, auto-buy/auto-sell rules, and passive trade
- Events, event modifiers, event timing, and event UI behavior
- NPC traders, trader AI, autonomous world behavior, and market interactions
- Item definitions in `data/items/` when they affect economy, categories, recipes, prices, or capacity

If a mechanics-affecting change does not require a documentation update, mention that explicitly in the final response.
