extends Node

const MAX_UPGRADE_LEVEL := 3
const BASE_UPGRADE_MULTIPLIER := 0.10
const INPUT_CRITICAL_THRESHOLD := 0.25
const POPULATION_TICK_DAYS := 30

# --- Prosperity ---
const PROSPERITY_MAX := 100
const PROSPERITY_LEVEL_2_THRESHOLD := 30   # Level 2 = "Growing"
const PROSPERITY_LEVEL_3_THRESHOLD := 65   # Level 3 = "Prosperous"
const PROSPERITY_DECAY_PER_TICK := 1       # Yatırım yapılmazsa yavaşça düşer

const GOODS: Dictionary = {
	"wheat": {
		"category": "survival",
		"stock_cap": 220,
		"stock_cap_base_cost": 40,
		"production_base_cost": 35,
		"production_interval_days": 1,
	},
	"wood": {
		"category": "production_input",
		"stock_cap": 180,
		"stock_cap_base_cost": 50,
		"production_base_cost": 45,
		"production_interval_days": 1,
	},
	"flour": {
		"category": "production_input",
		"stock_cap": 160,
		"stock_cap_base_cost": 55,
		"production_base_cost": 70,
		"production_interval_days": 1,
	},
	"bread": {
		"category": "survival",
		"stock_cap": 160,
		"stock_cap_base_cost": 60,
		"production_base_cost": 80,
		"production_interval_days": 1,
	},
	"iron_ore": {
		"category": "production_input",
		"stock_cap": 200,
		"stock_cap_base_cost": 65,
		"production_base_cost": 60,
		"production_interval_days": 1,
	},
	"iron_bar": {
		"category": "production_input",
		"stock_cap": 180,
		"stock_cap_base_cost": 90,
		"production_base_cost": 120,
		"production_interval_days": 2,
	},
	"sword": {
		"category": "comfort",
		"stock_cap": 80,
		"stock_cap_base_cost": 120,
		"production_base_cost": 220,
		"production_interval_days": 2,
	},
	"tool": {
		"category": "production_input",
		"stock_cap": 120,
		"stock_cap_base_cost": 95,
		"production_base_cost": 140,
		"production_interval_days": 1,
	},
	"grapes": {
		"category": "comfort",
		"stock_cap": 180,
		"stock_cap_base_cost": 45,
		"production_base_cost": 40,
		"production_interval_days": 1,
	},
	"must": {
		"category": "production_input",
		"stock_cap": 140,
		"stock_cap_base_cost": 85,
		"production_base_cost": 100,
		"production_interval_days": 1,
	},
	"wine": {
		"category": "comfort",
		"stock_cap": 90,
		"stock_cap_base_cost": 140,
		"production_base_cost": 240,
		"production_interval_days": 3,
	},
}

const RECIPES: Dictionary = {
	"flour": {"inputs": {"wheat": 2}},
	"bread": {"inputs": {"flour": 2}},
	"iron_bar": {"inputs": {"iron_ore": 2}},
	"sword": {"inputs": {"iron_bar": 2}},
	"tool": {"inputs": {"iron_bar": 1}},
	"must": {"inputs": {"grapes": 3}},
	"wine": {"inputs": {"must": 2}},
}

const BASE_PRICES: Dictionary = {
	"wheat": 3, "flour": 6, "bread": 10, "iron_ore": 5, "iron_bar": 12,
	"sword": 30, "tool": 18, "wood": 4, "grapes": 4, "must": 9, "wine": 20,
}

const SEASON_MULTIPLIERS := {
	"spring": {"wheat": 1.15, "grapes": 1.10, "wood": 1.00},
	"summer": {"wheat": 1.10, "grapes": 1.20, "wood": 0.95},
	"autumn": {"wheat": 1.00, "grapes": 0.95, "wood": 1.05},
	"winter": {"wheat": 0.70, "grapes": 0.60, "wood": 1.10},
}

var towns: Dictionary = {}
var current_day := 1

signal economy_updated

var _player: Node

func _ready() -> void:
	_player = get_node("/root/PlayerData")
	_init_towns()

func _init_towns() -> void:
	towns = {
		"Ashford": {
			"name": "Ashford", "faction": "Northern Kingdom", "population": 120, "population_cap": 180,
			"prosperity": 0,
			"inventory": {"wheat": 80, "flour": 20, "wood": 40}, "prices": {}, "position": Vector2(480, 360),
			"production_plan": {"wheat": 12, "wood": 8, "flour": 4},
			"consumption_rules": {"bread": 0.05, "tool": 0.006},
			"production_upgrades": {}, "stock_cap_upgrades": {}, "report": {},
		},
		"Ironmere": {
			"name": "Ironmere", "faction": "Merchants Guild", "population": 200, "population_cap": 280,
			"prosperity": 0,
			"inventory": {"iron_ore": 60, "iron_bar": 15, "sword": 5}, "prices": {}, "position": Vector2(2200, 440),
			"production_plan": {"iron_ore": 10, "iron_bar": 5, "tool": 3, "sword": 2},
			"consumption_rules": {"wheat": 0.04, "flour": 0.03, "wood": 0.025},
			"production_upgrades": {}, "stock_cap_upgrades": {}, "report": {},
		},
		"Stonebridge": {
			"name": "Stonebridge", "faction": "Merchants Guild", "population": 160, "population_cap": 240,
			"prosperity": 0,
			"inventory": {"grapes": 60, "must": 20, "wine": 10, "wood": 30}, "prices": {}, "position": Vector2(1380, 1080),
			"production_plan": {"grapes": 15, "must": 4, "wine": 2, "wood": 6},
			"consumption_rules": {"wheat": 0.03, "bread": 0.02, "iron_bar": 0.015},
			"production_upgrades": {}, "stock_cap_upgrades": {}, "report": {},
		},
	}
	_recalculate_all_prices()

func get_town(town_name: String) -> Dictionary:
	return towns.get(town_name, {})

func get_town_report(town_name: String) -> Dictionary:
	return towns.get(town_name, {}).get("report", {})

func get_goods_category(item: String) -> String:
	return GOODS.get(item, {}).get("category", "unknown")

func get_price(town_name: String, item: String) -> float:
	return towns.get(town_name, {}).get("prices", {}).get(item, BASE_PRICES.get(item, 0.0))

func get_town_free_stock(town_name: String, item: String) -> int:
	var town = towns.get(town_name, {})
	if town.is_empty():
		return 0
	return maxi(_get_stock_cap(town, item) - int(town["inventory"].get(item, 0)), 0)

func add_town_stock(town_name: String, item: String, qty: int, respect_cap := true) -> bool:
	if qty <= 0:
		return false
	var town = towns.get(town_name, {})
	if town.is_empty():
		return false
	var current_stock = int(town["inventory"].get(item, 0))
	if respect_cap:
		var cap = _get_stock_cap(town, item)
		town["inventory"][item] = mini(current_stock + qty, cap)
	else:
		town["inventory"][item] = current_stock + qty
	_recalculate_all_prices()
	return true

func _get_season() -> String:
	var idx = int(((current_day - 1) / 30) % 4)
	return ["spring", "summer", "autumn", "winter"][idx]

func _get_season_multiplier(item: String) -> float:
	return SEASON_MULTIPLIERS.get(_get_season(), {}).get(item, 1.0)

func _get_upgrade_level(upgrades: Dictionary, item: String) -> int:
	return int(clamp(upgrades.get(item, 0), 0, MAX_UPGRADE_LEVEL))

func get_upgrade_cost(item: String, level: int, stock_upgrade := false) -> int:
	var goods_data = GOODS.get(item, {})
	var base_key = "stock_cap_base_cost" if stock_upgrade else "production_base_cost"
	var base_cost = int(goods_data.get(base_key, 0))
	return int(base_cost * pow(2, level))

func _calculate_effective_output(base_output: float, season_multiplier: float, efficiency: float, upgrade_level: int) -> float:
	var upgrade_multiplier = 1.0 + (BASE_UPGRADE_MULTIPLIER * upgrade_level)
	return base_output * season_multiplier * efficiency * upgrade_multiplier

func _calculate_input_efficiency(town: Dictionary, item: String, planned_batches: float) -> Dictionary:
	if not RECIPES.has(item):
		return {"efficiency": 1.0, "critical": false, "consume_ratio": 1.0}
	var recipe_inputs: Dictionary = RECIPES[item].get("inputs", {})
	var ratio := 1.0
	for input_item in recipe_inputs:
		var required_total = float(recipe_inputs[input_item]) * planned_batches
		if required_total <= 0.0:
			continue
		var in_stock = float(town["inventory"].get(input_item, 0))
		ratio = min(ratio, in_stock / required_total)
	ratio = clamp(ratio, 0.0, 1.0)
	return {"efficiency": ratio, "critical": ratio <= INPUT_CRITICAL_THRESHOLD, "consume_ratio": ratio}

func _get_stock_cap(town: Dictionary, item: String) -> int:
	var base_cap = int(GOODS.get(item, {}).get("stock_cap", 100))
	var upgrade_level = _get_upgrade_level(town.get("stock_cap_upgrades", {}), item)
	return int(round(base_cap * (1.0 + (BASE_UPGRADE_MULTIPLIER * upgrade_level))))

func _recalculate_all_prices() -> void:
	for town_name in towns:
		var town = towns[town_name]
		town["prices"] = {}
		for item in BASE_PRICES:
			town["prices"][item] = _calculate_price(town, item)

func _calculate_price(town: Dictionary, item: String) -> float:
	var base := float(BASE_PRICES.get(item, 0.0))
	if base <= 0.0:
		return 0.0
	var stock := float(town["inventory"].get(item, 0))
	var demand := float(_estimate_daily_consumption(town, item))
	var supply := _estimate_effective_daily_supply(town, item)
	var max_stock := maxf(float(_get_stock_cap(town, item)), 1.0)
	var pressure := (demand - supply) / max_stock
	var scarcity := stock / max_stock
	return maxf(base * (1.0 + clamp(pressure - scarcity, -0.7, 3.0) * 1.4), base * 0.25)

func _estimate_effective_daily_supply(town: Dictionary, item: String) -> float:
	var planned_output := float(town.get("production_plan", {}).get(item, 0))
	if planned_output <= 0.0:
		return 0.0

	var interval := maxi(int(GOODS.get(item, {}).get("production_interval_days", 1)), 1)
	var input_state := _calculate_input_efficiency(town, item, planned_output)
	var upgrade_level := _get_upgrade_level(town.get("production_upgrades", {}), item)
	var effective_output := _calculate_effective_output(
		planned_output,
		_get_season_multiplier(item),
		input_state["efficiency"],
		upgrade_level
	)
	return effective_output / float(interval)

func _estimate_daily_consumption(town: Dictionary, item: String) -> int:
	var per_capita = float(town.get("consumption_rules", {}).get(item, 0.0))
	return int(round(town.get("population", 0) * per_capita))

func advance_day() -> void:
	current_day += 1
	for town_name in towns:
		_process_town_production(towns[town_name])
		_process_town_consumption(towns[town_name])
	if current_day % POPULATION_TICK_DAYS == 0:
		for town_name in towns:
			_process_population_change(towns[town_name])
	_recalculate_all_prices()
	emit_signal("economy_updated")

func _process_town_production(town: Dictionary) -> void:
	var report = {
		"season": _get_season(),
		"base_production": {},
		"final_production": {},
		"missing_input_efficiency": {},
		"stock_blocked": {},
		"critical_consumption_issues": [],
	}
	for item in town.get("production_plan", {}):
		var interval = int(GOODS.get(item, {}).get("production_interval_days", 1))
		if interval <= 0 or current_day % interval != 0:
			continue
		var base_output = float(town["production_plan"][item])
		report["base_production"][item] = base_output
		var input_state = _calculate_input_efficiency(town, item, base_output)
		var upgrade_level = _get_upgrade_level(town.get("production_upgrades", {}), item)
		var final_output = _calculate_effective_output(base_output, _get_season_multiplier(item), input_state["efficiency"], upgrade_level)
		var stock_cap = _get_stock_cap(town, item)
		var in_stock = int(town["inventory"].get(item, 0))
		var free_space = max(stock_cap - in_stock, 0)
		var actual = int(min(round(final_output), free_space))
		var blocked = max(int(round(final_output)) - actual, 0)
		town["inventory"][item] = in_stock + actual
		report["final_production"][item] = actual
		report["missing_input_efficiency"][item] = input_state["efficiency"]
		report["stock_blocked"][item] = blocked

		if RECIPES.has(item):
			for input_item in RECIPES[item]["inputs"]:
				var needed = RECIPES[item]["inputs"][input_item] * actual
				var current_stock = int(town["inventory"].get(input_item, 0))
				town["inventory"][input_item] = max(current_stock - needed, 0)
	town["report"] = report

func _process_town_consumption(town: Dictionary) -> void:
	for item in town.get("consumption_rules", {}):
		var consume_amount = _estimate_daily_consumption(town, item)
		if consume_amount <= 0:
			continue
		var current_stock = int(town["inventory"].get(item, 0))
		if current_stock < consume_amount:
			town["report"]["critical_consumption_issues"].append(item)
		town["inventory"][item] = max(current_stock - consume_amount, 0)

func _process_population_change(town: Dictionary) -> void:
	var change := 0
	if town["report"].get("critical_consumption_issues", []).has("bread"):
		change -= int(ceil(town["population"] * 0.03))
	if town["inventory"].get("bread", 0) > 20:
		change += int(ceil(town["population"] * 0.01))
	town["population"] = clamp(town["population"] + change, 10, town.get("population_cap", 200))

func player_buy(town_name: String, item: String, qty: int) -> bool:
	if qty <= 0:
		return false
	var town = towns.get(town_name, {})
	if town.is_empty() or town["inventory"].get(item, 0) < qty:
		return false
	if _player.get_free_capacity() < qty:
		return false
	var price = get_price(town_name, item) * qty
	var discount = _player.get_faction_rep(town.get("faction", "")) * 0.001
	if not _player.remove_gold(price * (1.0 - discount)):
		return false
	town["inventory"][item] -= qty
	if town["inventory"][item] == 0:
		town["inventory"].erase(item)
	_player.add_item(item, qty)
	_recalculate_all_prices()
	return true

func player_sell(town_name: String, item: String, qty: int) -> bool:
	if qty <= 0:
		return false
	var town = towns.get(town_name, {})
	if town.is_empty():
		return false
	var cap = _get_stock_cap(town, item)
	var current_stock = int(town["inventory"].get(item, 0))
	if current_stock + qty > cap:
		return false
	if not _player.remove_item(item, qty):
		return false
	var price = get_price(town_name, item) * qty
	var bonus = _player.get_faction_rep(town.get("faction", "")) * 0.001
	_player.add_gold(price * (1.0 + bonus))
	town["inventory"][item] = current_stock + qty
	_recalculate_all_prices()
	return true


# --- Prosperity API ---

func get_prosperity(town_name: String) -> int:
	return int(towns.get(town_name, {}).get("prosperity", 0))

func get_prosperity_level(town_name: String) -> int:
	var p := get_prosperity(town_name)
	if p >= PROSPERITY_LEVEL_3_THRESHOLD:
		return 3
	elif p >= PROSPERITY_LEVEL_2_THRESHOLD:
		return 2
	return 1

func get_prosperity_label(town_name: String) -> String:
	match get_prosperity_level(town_name):
		3: return "Prosperous"
		2: return "Growing"
		_: return "Struggling"

func add_prosperity(town_name: String, amount: int) -> void:
	var town = towns.get(town_name, {})
	if town.is_empty():
		return
	var current := int(town.get("prosperity", 0))
	town["prosperity"] = clamp(current + amount, 0, PROSPERITY_MAX)
