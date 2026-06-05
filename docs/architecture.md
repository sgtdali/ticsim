# Architecture

## Project Overview

**TicSim** is a Godot 4.6 top-down trade simulation game. The player manages a caravan, trades between towns, builds reputation with factions, completes contracts, and climbs a rank ladder.

Entry point: `scenes/MainMenu.tscn` → `scenes/WorldMap.tscn`

---

## Autoload Order and Dependencies

Autoloads are registered in `project.godot` in this exact order. Order matters: each autoload may reference those above it at `_ready()` time.

| # | Autoload | Script | Role |
|---|----------|--------|------|
| 1 | `PlayerData` | `scripts/autoloads/PlayerData.gd` | Gold, inventory, caravan, faction/NPC relations, daily upkeep |
| 2 | `EconomyManager` | `scripts/autoloads/EconomyManager.gd` | Town data, prices, daily tick orchestrator; facade over sub-systems |
| 3 | `FactionManager` | `scripts/autoloads/FactionManager.gd` | Faction definitions, NPCs, tax rates, reputation effects |
| 4 | `ContractManager` | `scripts/autoloads/ContractManager.gd` | Contract generation, acceptance, completion, expiry |
| 5 | `TravelRiskManager` | `scripts/autoloads/TravelRiskManager.gd` | Attack chance calculation (cargo + faction rep) |
| 6 | `EventManager` | `scripts/autoloads/EventManager.gd` | Random town events (festival, famine, etc.) and their economic multipliers |
| 7 | `TraderManager` | `scripts/autoloads/TraderManager.gd` | Autonomous NPC traders (aldric/mira/torben) that move and trade independently |
| 8 | `EventBus` | `scripts/autoloads/EventBus.gd` | Thin signal bus for UI ↔ logic decoupling |
| 9 | `TradingPostManager` | `scripts/autoloads/TradingPostManager.gd` | Player-owned depots with auto-buy/sell rules |
| 10 | `RankManager` | `scripts/autoloads/RankManager.gd` | Rank progression (Peddler→Patrician), unlock gates |
| 11 | `CaravanMasterManager` | `scripts/autoloads/CaravanMasterManager.gd` | Hired caravan masters with routes between Trading Posts |

**Dependency summary:**
- `PlayerData` has no autoload dependencies.
- `EconomyManager` depends on `PlayerData` (and lazily resolves others).
- Almost everything else depends on both `PlayerData` and `EconomyManager`.
- `RankManager` depends on `EconomyManager`, `PlayerData`, `FactionManager`, `TradingPostManager`.
- `CaravanMasterManager` depends on `EconomyManager`, `PlayerData`, `TravelRiskManager`, `RankManager`.

---

## EconomyManager Sub-systems

`EconomyManager` is the central game-state node. It owns three sub-system objects (plain GDScript classes, not nodes):

| Sub-system | File | Responsibility |
|---|---|---|
| `MarketSystem` | `scripts/systems/MarketSystem.gd` | Price calculation (supply/demand curve), buy/sell transactions for player and NPCs |
| `TownSimulation` | `scripts/systems/TownSimulation.gd` | Production phase, consumption phase, population growth/decline, slot/upgrade costs |
| `InvestmentSystem` | `scripts/systems/InvestmentSystem.gd` | Prosperity tracking, gold→prosperity conversion, prosperity level thresholds |

All three are constructed in `EconomyManager._ready()`. `EconomyManager` exposes their functionality through a facade API, so other autoloads should call `EconomyManager.player_buy()` etc., not the sub-system objects directly.

---

## Daily Tick Flow

`EconomyManager.advance_day()` is called from `WorldMap.gd` once per game day. The order within each tick is:

1. `PlayerData.advance_day()` — rolls finance buckets, pays daily upkeep, applies debt
2. `TradingPostManager.process_day()` — auto-buy/sell rules execute
3. `TownSimulation.process_town_production_phase()` — production runs
4. `TownSimulation.process_town_consumption_phase()` — consumption runs
5. `TownSimulation.process_population_phase()` — every 30 days: population changes
6. `MarketSystem.recalculate_all_prices()` — prices update from new inventory levels
7. `InvestmentSystem.daily_prosperity_earned.clear()`
8. `TraderManager.process_day()` — NPC traders move and trade
9. `CaravanMasterManager.process_day()` — hired masters travel their routes
10. `ContractManager.process_day()` — expire old contracts, generate new ones
11. `EventManager.process_day()` — expire old events, possibly trigger new ones
12. `RankManager.check_rank_up()` — evaluate rank promotion conditions

---

## Scene Structure

```
scenes/
  MainMenu.tscn          — title screen
  WorldMap.tscn          — main gameplay scene (Node2D, script: WorldMap.gd)
  TownScene.tscn         — town interior panel (script: TownScene.gd)
  TownUI.tscn            — town UI shell with tab container (script: TownUI.gd)
  Player.tscn            — (legacy/placeholder)
  ui/
    TopBar.tscn          — gold/day/rank strip at top (script: TopBar.gd)
    top_bar_panel.tscn   — styled panel wrapper for TopBar
    MarketPanel.tscn     — market table popup
    MarketTablePreview.tscn
    TradeRoutePanel.tscn — master route editor (script: TradeRoutePanel.gd)
    AttackPopup.tscn     — travel attack notification
```

---

## Script Folder Structure

```
scripts/
  autoloads/        — singleton autoloads (see table above)
  systems/          — sub-system classes owned by EconomyManager
  data_models/      — Resource subclasses and plain data containers
    ItemData.gd         — Class model: id, display_name, category, base_price, stock_cap, base_daily_demand_per_1000_pop, is_natural_resource, slot_type, recipe_inputs (dynamically loaded from balance CSVs)
    TownData.gd         — (data container, not used as Resource at runtime)
    CaravanMaster.gd    — Resource: id, level, xp, hire_cost, daily_wage, skills
  ui/               — UI control scripts
    MarketTableView.gd
    TopBar.gd
    TradeRoutePanel.gd
    town_ui/        — tab scripts for TownUI
      TownTab.gd (base)
      MarketTab.gd
      InfoTab.gd
      InvestTab.gd
      ContractsTab.gd
      NPCTab.gd
      PostTab.gd
      UpgradeTab.gd
  controllers/      — WorldMap sub-controllers (split from WorldMap.gd)
    SidePanelController.gd
    FinancePanelController.gd
    TraderLabelController.gd
    EventLogController.gd
  tools/            — editor-only utilities
    RoadDataExporter.gd
  utils/
    MapUtils.gd
  WorldMap.gd       — main scene script; travel, input, UI layout, day timer
  TownScene.gd      — mounts TownUI, passes town_name context
  TownUI.gd         — tab switching, refresh coordination
  Player.gd         — (legacy)
  MainMenu.gd
```

---

## EventBus Signals

`EventBus` (`scripts/autoloads/EventBus.gd`) is a thin signal relay for UI ↔ logic communication. It does not hold state.

| Signal | Args | Purpose |
|--------|------|---------|
| `item_bought` | town_name, item, qty, price | Fired after player purchases |
| `item_sold` | town_name, item, qty, price | Fired after player sale |
| `town_invested` | town_name, gold_amount, prosperity_gained | Fired after investment |
| `contracts_changed` | — | Any contract list change |
| `contract_accepted` | contract_id | Player accepted a contract |
| `contract_completed` | contract_id | Contract successfully delivered |
| `contract_failed` | contract_id | Contract deadline passed |
| `open_town` | town_name | Request to open town UI |
| `close_town` | — | Request to close town UI |

---

## Key Data Shapes

### Town (runtime Dictionary inside `EconomyManager.towns`)
```
{
  "name": String,
  "faction": String,          # matches a FactionManager.FACTIONS key
  "population": int,
  "population_cap": int,
  "prosperity": int,          # 0–100
  "population_history": Array[int],
  "inventory": { item_id: qty },
  "prices": { item_id: float },
  "position": Vector2,        # map coordinates (0–2688 x 0–1536)
  "production_plan": { item_id: qty_per_day },
  "consumption_rules": { item_id: fraction_of_population },
  "slots": { "farm": { "max": int, "allocated": { item: count } }, "mine": {...} },
  "production_upgrades": { item_id: level },
  "stock_cap_upgrades": { item_id: level },
  "report": {},               # populated by TownSimulation each tick
}
```

### Item (Dynamically created from `items.csv`)
Fields: `id: String`, `display_name: String`, `category: String` (survival/comfort/production_input), `base_price: float`, `stock_cap: int`, `base_daily_demand_per_1000_pop: float`, `is_natural_resource: bool`, `slot_type: String`, `recipe_inputs: Dictionary { item_id: qty }`

### Contract (runtime Dictionary inside `ContractManager.contracts`)
Key fields: `id`, `type` (delivery/procurement), `source_town`, `target_town`, `required_item`, `required_quantity`, `deadline_duration`, `deadline_day`, `reward_gold`, `issuing_faction`, `difficulty_tier` (basic/standard/urgent), `status`

### CaravanMaster (Resource, `scripts/data_models/CaravanMaster.gd`)
Fields: `id`, `level`, `xp`, `hire_cost`, `daily_wage`, plus computed: `get_capacity()`, `get_bargaining_discount()`, `get_travel_multiplier()`, `get_courage_risk_reduction()`

---

## Factions and Towns

Three factions, three towns (loaded from `towns.csv` in `EconomyManager._init_towns()`, and `FactionManager._init_npcs()`):

| Town | Faction | Specialty | Map position |
|------|---------|-----------|--------------|
| Ashford | Northern Kingdom | Wheat, wood, bread | (480, 360) |
| Ironmere | Merchants Guild | Iron ore, iron bar, swords, tools | (2200, 440) |
| Stonebridge | Merchants Guild | Grapes, wine, must | (1380, 1080) |

Faction relations affect trade tax rates and reputation gain/loss side-effects. Trading with a faction's rival incurs a 30% reputation penalty with that rival.

---

## Rank System

Five ranks. Ranks and daily upkeeps are loaded dynamically from `ranks.csv`. Promotion is checked every day in `RankManager.check_rank_up()`. All conditions must be met simultaneously and player must be debt-free. Faction reputation requirements have been removed from progression.

| Rank | Index | Unlocks | Requirements (from CSV) | Upkeep (from CSV) |
|------|-------|---------|-------------|-------------------|
| Peddler | 0 | — | Starting rank | 0 gold/day |
| Trader | 1 | Caravan upgrades, up to 1 master | 500g | 3 gold/day |
| Merchant | 2 | Trading Posts, up to 2 masters | 1500g, 1 growing city | 8 gold/day |
| Guild Master | 3 | Urgent contracts, up to 4 masters | 4000g, 2 posts, 2 growing cities, 1 prosperous city | 20 gold/day |
| Patrician | 4 | Up to 6 masters (Victory) | 10000g, 3 prosperous cities | 0 gold/day |

Growing city = prosperity ≥ 30. Prosperous city = prosperity ≥ 65.

---

## Travel and Risk

Travel days between towns are loaded directly from `routes.csv` via `EconomyManager.get_route_travel_days()`, with a fallback to `distance / 200.0`.

Attack chance formula: `BASE_RISK (from routes.csv) + cargo_count × 0.018 - positive_faction_rep × 0.001`, clamped to [0, 0.50].

On attack: player loses cargo (amount determined by `AttackPopup`/`WorldMap`). CaravanMaster routes lose ~1/3 of each carried item. Careful-type NPC traders skip routes with risk > 15%.
