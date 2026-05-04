extends Node

const RECIPES: Dictionary = {
	"flour":     { "inputs": {"wheat": 2},     "time": 1 },
	"bread":     { "inputs": {"flour": 2},     "time": 1 },
	"iron_bar":  { "inputs": {"iron_ore": 2},  "time": 2 },
	"sword":     { "inputs": {"iron_bar": 2},  "time": 2 },
	"tool":      { "inputs": {"iron_bar": 1},  "time": 1 },
	"plank":     { "inputs": {"wood": 2},      "time": 1 },
	"furniture": { "inputs": {"plank": 3},     "time": 2 },
	"must":      { "inputs": {"grapes": 3},    "time": 1 },
	"wine":      { "inputs": {"must": 2},      "time": 3 },
}

const BASE_PRICES: Dictionary = {
	"wheat":     3,
	"flour":     6,
	"bread":     10,
	"iron_ore":  5,
	"iron_bar":  12,
	"sword":     30,
	"tool":      18,
	"wood":      4,
	"plank":     8,
	"furniture": 25,
	"grapes":    4,
	"must":      9,
	"wine":      20,
}

var towns: Dictionary = {}

signal economy_updated

var _player: Node

# -----------------------------------------------

func _ready() -> void:
	_player = get_node("/root/PlayerData")
	_init_towns()

func _init_towns() -> void:
	towns = {
		"Ashford": {
			"name": "Ashford",
			"faction": "Northern Kingdom",
			"population": 120,
			"inventory": { "wheat": 80, "flour": 20, "wood": 40 },
			"produced": { "wheat": 12, "wood": 8 },
			"consumed": { "bread": 6, "tool": 1 },
			"prices": {},
			"position": Vector2(480, 360),
		},
		"Ironmere": {
			"name": "Ironmere",
			"faction": "Merchants Guild",
			"population": 200,
			"inventory": { "iron_ore": 60, "iron_bar": 15, "sword": 5 },
			"produced": { "iron_ore": 10, "iron_bar": 5 },
			"consumed": { "wheat": 8, "flour": 4, "wood": 5 },
			"prices": {},
			"position": Vector2(2200, 440),
		},
		"Stonebridge": {
			"name": "Stonebridge",
			"faction": "Merchants Guild",
			"population": 160,
			"inventory": { "grapes": 60, "must": 20, "wine": 10, "wood": 30 },
			"produced": { "grapes": 15, "wood": 6 },
			"consumed": { "wheat": 6, "bread": 4, "iron_bar": 2 },
			"prices": {},
			"position": Vector2(1380, 1080),
		},
	}
	_recalculate_all_prices()

func get_town(town_name: String) -> Dictionary:
	return towns.get(town_name, {})

func get_price(town_name: String, item: String) -> float:
	var town = towns.get(town_name, {})
	return town.get("prices", {}).get(item, BASE_PRICES.get(item, 0))

func _calculate_price(town: Dictionary, item: String) -> float:
	var base = BASE_PRICES.get(item, 0)
	if base == 0:
		return 0.0
	var stock = town["inventory"].get(item, 0)
	var max_stock = town["population"] * 0.5
	var demand = town["consumed"].get(item, 0)
	var supply = town["produced"].get(item, 0)
	var pressure = (demand - supply) / max(max_stock, 1.0)
	var price = base * (1.0 + clamp(pressure - (stock / max(max_stock, 1.0)), -0.6, 1.5))
	return max(price, base * 0.3)

func _recalculate_all_prices() -> void:
	for town_name in towns:
		var town = towns[town_name]
		town["prices"] = {}
		for item in BASE_PRICES:
			town["prices"][item] = _calculate_price(town, item)

func advance_day() -> void:
	for town_name in towns:
		var town = towns[town_name]
		for item in town["produced"]:
			var qty = town["produced"][item]
			town["inventory"][item] = town["inventory"].get(item, 0) + qty
		for item in town["consumed"]:
			var qty = town["consumed"][item]
			var current = town["inventory"].get(item, 0)
			town["inventory"][item] = max(current - qty, 0)
	_npc_trade_cycle()
	_recalculate_all_prices()
	emit_signal("economy_updated")

func _npc_trade_cycle() -> void:
	var town_list = towns.keys()
	for i in range(town_list.size()):
		for j in range(i + 1, town_list.size()):
			var a = towns[town_list[i]]
			var b = towns[town_list[j]]
			for item in BASE_PRICES:
				var stock_a = a["inventory"].get(item, 0)
				var stock_b = b["inventory"].get(item, 0)
				var surplus = stock_a - stock_b
				if surplus > 10:
					var transfer = int(surplus * 0.2)
					a["inventory"][item] -= transfer
					b["inventory"][item] = b["inventory"].get(item, 0) + transfer
				elif surplus < -10:
					var transfer = int(-surplus * 0.2)
					b["inventory"][item] -= transfer
					a["inventory"][item] = a["inventory"].get(item, 0) + transfer

func player_buy(town_name: String, item: String, qty: int) -> bool:
	var town = towns.get(town_name, {})
	if town.is_empty():
		return false
	var stock = town["inventory"].get(item, 0)
	if stock < qty:
		return false
	var price = get_price(town_name, item) * qty
	var rep = _player.get_faction_rep(town.get("faction", ""))
	var discount = rep * 0.001
	price = price * (1.0 - discount)
	if not _player.remove_gold(price):
		return false
	town["inventory"][item] -= qty
	if town["inventory"][item] == 0:
		town["inventory"].erase(item)
	_player.add_item(item, qty)
	_recalculate_all_prices()
	return true

func player_sell(town_name: String, item: String, qty: int) -> bool:
	var town = towns.get(town_name, {})
	if town.is_empty():
		return false
	if not _player.remove_item(item, qty):
		return false
	var price = get_price(town_name, item) * qty
	var rep = _player.get_faction_rep(town.get("faction", ""))
	var bonus = rep * 0.001
	price = price * (1.0 + bonus)
	_player.add_gold(price)
	town["inventory"][item] = town["inventory"].get(item, 0) + qty
	_recalculate_all_prices()
	return true
