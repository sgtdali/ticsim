extends Node

const MAX_UPGRADE_LEVEL := 3
const BASE_UPGRADE_MULTIPLIER := 0.10
const INPUT_CRITICAL_THRESHOLD := 0.25
const POPULATION_TICK_DAYS := 30
const PROSPERITY_MAX := 100
const PROSPERITY_LEVEL_2_THRESHOLD := 30
const PROSPERITY_LEVEL_3_THRESHOLD := 65
const PROSPERITY_DECAY_PER_TICK := 1
const GOLD_PER_PROSPERITY_POINT := 25.0
const MAX_DAILY_PROSPERITY_GAIN := 50

const SEASON_MULTIPLIERS := {
	"spring": {"wheat": 1.15, "grapes": 1.10, "wood": 1.00},
	"summer": {"wheat": 1.10, "grapes": 1.20, "wood": 0.95},
	"autumn": {"wheat": 1.00, "grapes": 0.95, "wood": 1.05},
	"winter": {"wheat": 0.70, "grapes": 0.60, "wood": 1.10},
}

var items_data: Dictionary = {}
var BASE_PRICES: Dictionary = {}
var towns: Dictionary = {}
var current_day := 1

signal economy_updated
signal new_day

var _player: Node
var _events: Node

# Sub-systems
var market: MarketSystem
var simulation: TownSimulation
var investment: InvestmentSystem

func _ready() -> void:
	_player = get_node("/root/PlayerData")
	_events = get_node_or_null("/root/EventManager")
	
	market = MarketSystem.new(self)
	simulation = TownSimulation.new(self)
	investment = InvestmentSystem.new(self)
	
	_load_items_data()
	_init_towns()

func _load_items_data() -> void:
	var dir = DirAccess.open("res://data/items")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var res = load("res://data/items/" + file_name) as ItemData
				if res:
					items_data[res.id] = res
					BASE_PRICES[res.id] = res.base_price
			file_name = dir.get_next()

func _init_towns() -> void:
	towns = {
		"Ashford": {
			"name": "Ashford", "faction": "Northern Kingdom", "population": 120, "population_cap": 180,
			"prosperity": 0, "population_history": [],
			"inventory": {"wheat": 30, "flour": 8, "wood": 15}, "prices": {}, "position": Vector2(480, 360),
			"production_plan": {"wheat": 6, "wood": 4, "flour": 2},
			"consumption_rules": {"bread": 0.05, "tool": 0.006},
			"production_upgrades": {}, "stock_cap_upgrades": {}, "report": {},
		},
		"Ironmere": {
			"name": "Ironmere", "faction": "Merchants Guild", "population": 200, "population_cap": 280,
			"prosperity": 0, "population_history": [],
			"inventory": {"iron_ore": 20, "iron_bar": 5, "sword": 2}, "prices": {}, "position": Vector2(2200, 440),
			"production_plan": {"iron_ore": 5, "iron_bar": 2, "tool": 1, "sword": 1},
			"consumption_rules": {"wheat": 0.04, "flour": 0.03, "wood": 0.025},
			"production_upgrades": {}, "stock_cap_upgrades": {}, "report": {},
		},
		"Stonebridge": {
			"name": "Stonebridge", "faction": "Merchants Guild", "population": 160, "population_cap": 240,
			"prosperity": 0, "population_history": [],
			"inventory": {"grapes": 20, "must": 8, "wine": 4, "wood": 10}, "prices": {}, "position": Vector2(1380, 1080),
			"production_plan": {"grapes": 7, "must": 2, "wine": 1, "wood": 3},
			"consumption_rules": {"wheat": 0.03, "bread": 0.02, "iron_bar": 0.015},
			"production_upgrades": {}, "stock_cap_upgrades": {}, "report": {},
		},
	}
	market.recalculate_all_prices()


# ==========================================
# FACADE API (Delegation to Sub-systems)
# ==========================================

func get_town(town_name: String) -> Dictionary:
	return towns.get(town_name, {})

func get_town_report(town_name: String) -> Dictionary:
	return towns.get(town_name, {}).get("report", {})

func get_goods_category(item: String) -> String:
	return (items_data[item].category if items_data.has(item) else "unknown")

func get_population_trend(town_name: String) -> String:
	var town = towns.get(town_name, {})
	var history: Array = town.get("population_history", [])
	if history.size() < 2: return "stable"
	var first: int = int(history[0])
	var last: int = int(history[history.size() - 1])
	if last > first: return "up"
	elif last < first: return "down"
	return "stable"

# --- Simulation API ---

func advance_day() -> void:
	simulation.advance_day()

func get_upgrade_cost(item: String, level: int, stock_upgrade := false) -> int:
	return simulation.get_upgrade_cost(item, level, stock_upgrade)

# --- Market API ---

func get_price(town_name: String, item: String) -> float:
	return market.get_price(town_name, item)

func get_town_free_stock(town_name: String, item: String) -> int:
	return market.get_town_free_stock(town_name, item)

func add_town_stock(town_name: String, item: String, qty: int, respect_cap := true) -> bool:
	return market.add_town_stock(town_name, item, qty, respect_cap)

func player_buy(town_name: String, item: String, qty: int) -> bool:
	return market.player_buy(town_name, item, qty)

func player_sell(town_name: String, item: String, qty: int) -> bool:
	return market.player_sell(town_name, item, qty)

# --- Investment API ---

func get_prosperity(town_name: String) -> int:
	return investment.get_prosperity(town_name)

func get_prosperity_level(town_name: String) -> int:
	return investment.get_prosperity_level(town_name)

func get_prosperity_label(town_name: String) -> String:
	return investment.get_prosperity_label(town_name)

func get_prosperity_multiplier(town_name: String) -> float:
	return investment.get_prosperity_multiplier(town_name)

func invest_gold(town_name: String, gold_amount: float) -> Variant:
	return investment.invest_gold(town_name, gold_amount)
