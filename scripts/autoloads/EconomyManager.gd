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

var SEASON_MULTIPLIERS: Dictionary = {}
var price_curves: Dictionary = {}
var routes_data: Dictionary = {}

var items_data: Dictionary = {}
var BASE_PRICES: Dictionary = {}
var towns: Dictionary = {}
var current_day := 1

signal progression_updated

var _player: Node
var _events: Node
var _contracts: Node
var _traders: Node
var _posts: Node
var _rank: Node
var _masters: Node

# Sub-systems
var market: MarketSystem
var simulation: TownSimulation
var investment: InvestmentSystem

func _ready() -> void:
	_player = get_node("/root/PlayerData")
	_events = get_node_or_null("/root/EventManager")
	_contracts = get_node_or_null("/root/ContractManager")
	_traders = get_node_or_null("/root/TraderManager")
	_posts = get_node_or_null("/root/TradingPostManager")
	_rank = get_node_or_null("/root/RankManager")
	_masters = get_node_or_null("/root/CaravanMasterManager")
	
	market = MarketSystem.new(self)
	simulation = TownSimulation.new(self)
	investment = InvestmentSystem.new(self)
	
	_load_season_modifiers()
	_load_price_curves()
	_load_items_data()
	_load_routes_data()
	_init_towns()

func _load_season_modifiers() -> void:
	SEASON_MULTIPLIERS.clear()
	var rows = CSVLoader.load_csv("res://data/balance/season_modifiers.csv")
	for row in rows:
		var season = row["season"]
		var item_id = row["item_id"]
		var prod_mult = CSVLoader.parse_float(row["production_multiplier"], 1.0)
		if not SEASON_MULTIPLIERS.has(season):
			SEASON_MULTIPLIERS[season] = {}
		SEASON_MULTIPLIERS[season][item_id] = prod_mult

func _load_price_curves() -> void:
	price_curves.clear()
	var rows = CSVLoader.load_csv("res://data/balance/price_curves.csv")
	for row in rows:
		var cat = row["category"]
		price_curves[cat] = {
			"zero_stock_multiplier": CSVLoader.parse_float(row["zero_stock_multiplier"]),
			"base_stock_multiplier": CSVLoader.parse_float(row["base_stock_multiplier"]),
			"max_stock_multiplier": CSVLoader.parse_float(row["max_stock_multiplier"])
		}

func _load_routes_data() -> void:
	routes_data.clear()
	var rows = CSVLoader.load_csv("res://data/balance/routes.csv")
	for row in rows:
		var from_t = row["from_town"]
		var to_t = row["to_town"]
		if not routes_data.has(from_t):
			routes_data[from_t] = {}
		routes_data[from_t][to_t] = {
			"travel_days": CSVLoader.parse_int(row["travel_days"]),
			"risk_level": row["risk_level"],
			"attack_risk": CSVLoader.parse_float(row["attack_risk"])
		}

func get_route_travel_days(from_town: String, to_town: String) -> int:
	if routes_data.has(from_town) and routes_data[from_town].has(to_town):
		return int(routes_data[from_town][to_town]["travel_days"])
	var t1 = towns.get(from_town, {})
	var t2 = towns.get(to_town, {})
	if not t1.is_empty() and not t2.is_empty():
		var distance = t1["position"].distance_to(t2["position"])
		return int(maxf(round(distance / 200.0), 1.0))
	return 1

func get_route_attack_risk(from_town: String, to_town: String) -> float:
	if routes_data.has(from_town) and routes_data[from_town].has(to_town):
		return float(routes_data[from_town][to_town]["attack_risk"])
	return 0.05

func _load_items_data() -> void:
	items_data.clear()
	BASE_PRICES.clear()
	
	var items_rows = CSVLoader.load_csv("res://data/balance/items.csv")
	for row in items_rows:
		var item = ItemData.new()
		item.id = row["item_id"]
		item.display_name = row["display_name"]
		item.category = row["category"]
		item.base_price = CSVLoader.parse_float(row["base_price"])
		item.stock_cap = CSVLoader.parse_int(row["stock_cap_base"])
		item.base_daily_demand_per_1000_pop = CSVLoader.parse_float(row["base_daily_demand_per_1000_pop"])
		
		if item.id == "wheat" or item.id == "grapes":
			item.is_natural_resource = true
			item.slot_type = "farm"
		elif item.id == "iron_ore":
			item.is_natural_resource = true
			item.slot_type = "mine"
		else:
			item.is_natural_resource = false
			item.slot_type = "none"
			
		items_data[item.id] = item
		BASE_PRICES[item.id] = item.base_price
		
	var recipe_rows = CSVLoader.load_csv("res://data/balance/recipes.csv")
	for row in recipe_rows:
		var output_item_id = row["output_item_id"]
		var input_item_id = row["input_item_id"]
		var input_qty = CSVLoader.parse_int(row["input_qty"])
		if items_data.has(output_item_id):
			items_data[output_item_id].recipe_inputs[input_item_id] = input_qty

func _init_towns() -> void:
	var town_rows = CSVLoader.load_csv("res://data/balance/towns.csv")
	var stock_rows = CSVLoader.load_csv("res://data/balance/town_stocks.csv")
	var production_rows = CSVLoader.load_csv("res://data/balance/production.csv")
	
	towns = {}
	
	for row in town_rows:
		var town_id = row["town_id"]
		var pop = CSVLoader.parse_int(row["start_population"])
		var pos = Vector2(CSVLoader.parse_float(row["position_x"]), CSVLoader.parse_float(row["position_y"]))
		
		towns[town_id] = {
			"name": row["display_name"],
			"faction": row["faction"],
			"population": pop,
			"population_cap": int(pop * 1.5),
			"prosperity": CSVLoader.parse_int(row["start_prosperity"]),
			"population_history": [],
			"inventory": {},
			"prices": {},
			"position": pos,
			"production_plan": {},
			"consumption_rules": {},
			"slots": {
				"farm": {
					"max": CSVLoader.parse_int(row["farm_max"]),
					"allocated": {}
				},
				"mine": {
					"max": CSVLoader.parse_int(row["mine_max"]),
					"allocated": {}
				}
			},
			"production_upgrades": {},
			"stock_cap_upgrades": {},
			"report": {}
		}
		
		var farm_wheat = CSVLoader.parse_int(row["farm_allocated_wheat"])
		if farm_wheat > 0:
			towns[town_id]["slots"]["farm"]["allocated"]["wheat"] = farm_wheat
		var farm_grapes = CSVLoader.parse_int(row["farm_allocated_grapes"])
		if farm_grapes > 0:
			towns[town_id]["slots"]["farm"]["allocated"]["grapes"] = farm_grapes
		var mine_iron_ore = CSVLoader.parse_int(row["mine_allocated_iron_ore"])
		if mine_iron_ore > 0:
			towns[town_id]["slots"]["mine"]["allocated"]["iron_ore"] = mine_iron_ore
			
	for row in stock_rows:
		var town_id = row["town_id"]
		var item_id = row["item_id"]
		var start_stock = CSVLoader.parse_int(row["start_stock"])
		if towns.has(town_id):
			towns[town_id]["inventory"][item_id] = start_stock
			
	for row in production_rows:
		var town_id = row["town_id"]
		var item_id = row["item_id"]
		var base_prod = CSVLoader.parse_float(row["base_daily_production"])
		if towns.has(town_id):
			if not items_data.has(item_id) or not items_data[item_id].is_natural_resource:
				towns[town_id]["production_plan"][item_id] = base_prod
				
	for town_id in towns:
		for item_id in items_data:
			var item = items_data[item_id]
			if item.base_daily_demand_per_1000_pop > 0:
				towns[town_id]["consumption_rules"][item_id] = item.base_daily_demand_per_1000_pop / 1000.0

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
	current_day += 1
	_player.advance_day()
	_process_trading_posts()
	simulation.process_town_production_phase()
	simulation.process_town_consumption_phase()
	simulation.process_population_phase()
	market.recalculate_all_prices()
	investment.daily_prosperity_earned.clear()
	_process_traders()
	_process_masters()
	_process_contracts()
	_process_events()
	_check_rank()

func _process_trading_posts() -> void:
	if _posts == null:
		_posts = get_node_or_null("/root/TradingPostManager")
	if _posts != null and _posts.has_method("process_day"):
		_posts.call("process_day")

func _process_traders() -> void:
	if _traders == null:
		_traders = get_node_or_null("/root/TraderManager")
	if _traders != null and _traders.has_method("process_day"):
		_traders.call("process_day")

func _process_masters() -> void:
	if _masters == null:
		_masters = get_node_or_null("/root/CaravanMasterManager")
	if _masters != null and _masters.has_method("process_day"):
		_masters.call("process_day")

func _process_contracts() -> void:
	if _contracts == null:
		_contracts = get_node_or_null("/root/ContractManager")
	if _contracts != null and _contracts.has_method("process_day"):
		_contracts.call("process_day")

func _process_events() -> void:
	if _events == null:
		_events = get_node_or_null("/root/EventManager")
	if _events != null and _events.has_method("process_day"):
		_events.call("process_day")

func _check_rank() -> void:
	if _rank == null:
		_rank = get_node_or_null("/root/RankManager")
	if _rank != null and _rank.has_method("check_rank_up"):
		_rank.call("check_rank_up")

func get_upgrade_cost(item: String, level: int, stock_upgrade := false) -> int:
	return simulation.get_upgrade_cost(item, level, stock_upgrade)

# --- Market API ---

func get_price(town_name: String, item: String) -> float:
	return market.get_price(town_name, item)

func get_buy_quote_total(town_name: String, item: String, qty: int) -> float:
	return market.get_buy_quote_total(town_name, item, qty)

func get_sell_quote_total(town_name: String, item: String, qty: int) -> float:
	return market.get_sell_quote_total(town_name, item, qty)

func get_buy_quote_average(town_name: String, item: String, qty: int) -> float:
	return market.get_buy_quote_average(town_name, item, qty)

func get_sell_quote_average(town_name: String, item: String, qty: int) -> float:
	return market.get_sell_quote_average(town_name, item, qty)

func get_town_free_stock(town_name: String, item: String) -> int:
	return market.get_town_free_stock(town_name, item)

func add_town_stock(town_name: String, item: String, qty: int, respect_cap := true) -> bool:
	return market.add_town_stock(town_name, item, qty, respect_cap)

func player_buy(town_name: String, item: String, qty: int) -> bool:
	return market.player_buy(town_name, item, qty)

func player_sell(town_name: String, item: String, qty: int) -> bool:
	return market.player_sell(town_name, item, qty)

func town_buy(buyer_inventory: Dictionary, buyer_gold_ref: Array, town_name: String, item: String, qty: int) -> bool:
	return market.town_buy(buyer_inventory, buyer_gold_ref, town_name, item, qty)

func town_sell(seller_inventory: Dictionary, seller_gold_ref: Array, town_name: String, item: String, qty: int) -> bool:
	return market.town_sell(seller_inventory, seller_gold_ref, town_name, item, qty)

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

# --- Slot API ---

func get_slot_cost(town_name: String, slot_type: String) -> int:
	return simulation.get_slot_cost(town_name, slot_type)

func add_slot(town_name: String, slot_type: String, item: String) -> bool:
	return simulation.add_slot(town_name, slot_type, item)

func get_allocated_slots(town_name: String, slot_type: String) -> int:
	var town = towns.get(town_name, {})
	if town.is_empty(): return 0
	var allocated = town.get("slots", {}).get(slot_type, {}).get("allocated", {})
	var total := 0
	for count in allocated.values():
		total += int(count)
	return total

func get_max_slots(town_name: String, slot_type: String) -> int:
	var town = towns.get(town_name, {})
	return int(town.get("slots", {}).get(slot_type, {}).get("max", 0))
