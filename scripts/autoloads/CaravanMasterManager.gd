extends Node

signal master_updated(master_id: String)
signal master_leveled_up(master_id: String)

const RANK_MASTER_CAPS := {
	"Peddler": 0,
	"Trader": 1,
	"Merchant": 2,
	"Guild Master": 4,
	"Patrician": 6,
}

const XP_PER_DELIVERY := 25

# { master_id: CaravanMaster }
var masters: Dictionary = {}

# { master_id: route_data }
# route_data = {
#   "stops": [
#     {
#       "town_name": String,
#       "rules": [
#         { "type": "buy"/"sell", "item": String, "price_limit": float, "max_qty": int }
#       ]
#     }
#   ],
#   "current_stop_index": int,
#   "inventory": { item: qty },
#   "days_traveling": int,
#   "travel_total_days": int,
#   "destination_town": String,
#   "active": bool
# }
var routes: Dictionary = {}

var _economy: Node
var _player: Node
var _risk: Node
var _rank: Node

var master_templates: Dictionary = {}

func _ready() -> void:
	_economy = get_node("/root/EconomyManager")
	_player = get_node("/root/PlayerData")
	_risk = get_node("/root/TravelRiskManager")
	_rank = get_node("/root/RankManager")
	
	_load_automation_templates()

func _load_automation_templates() -> void:
	master_templates.clear()
	var rows = CSVLoader.load_csv("res://data/balance/automation.csv")
	for row in rows:
		var type = row["automation_type"]
		if type == "trading_post":
			continue
		master_templates[type] = {
			"type": type,
			"unlock_rank": row["unlock_rank"],
			"hire_cost": CSVLoader.parse_float(row["hire_or_build_cost"]),
			"daily_wage": CSVLoader.parse_float(row["daily_upkeep"]),
			"capacity": CSVLoader.parse_int(row["capacity"]),
			"speed": CSVLoader.parse_int(row["speed_level"]),
			"bargaining": CSVLoader.parse_int(row["bargaining_level"]),
			"courage": CSVLoader.parse_int(row["courage_level"])
		}

func get_unlocked_templates() -> Array:
	var list: Array = []
	if _rank == null:
		return list
	var rank_idx = _rank.current_rank_index
	for type in master_templates:
		var t = master_templates[type]
		var req_rank = t["unlock_rank"]
		var req_idx = _rank.RANKS.find(req_rank)
		if rank_idx >= req_idx:
			list.append(t)
	return list

func can_afford_any_unlocked_master(player_gold: float) -> bool:
	var unlocked = get_unlocked_templates()
	for t in unlocked:
		if player_gold >= t["hire_cost"]:
			return true
	return false

# --- Cap ---

func get_master_cap() -> int:
	var rank: String = str(_rank.get_current_rank())
	return int(RANK_MASTER_CAPS.get(rank, 0))

func get_active_master_count() -> int:
	return masters.size()

func can_hire_master() -> bool:
	return get_active_master_count() < get_master_cap() and not _player.has_debt()

# --- Hiring ---

func hire_master(master: CaravanMaster) -> bool:
	if not can_hire_master():
		return false
	if _player.gold < float(master.hire_cost):
		return false
	if not _player.remove_gold(float(master.hire_cost)):
		return false
	masters[master.id] = master
	routes[master.id] = {
		"stops": [],
		"current_stop_index": 0,
		"inventory": {},
		"days_traveling": 0,
		"travel_total_days": 0,
		"destination_town": "",
		"active": false,
	}
	emit_signal("master_updated", master.id)
	return true

func fire_master(master_id: String) -> bool:
	if not masters.has(master_id):
		return false
	masters.erase(master_id)
	routes.erase(master_id)
	emit_signal("master_updated", master_id)
	return true

# --- Route management ---

func set_route(master_id: String, stops: Array) -> bool:
	if not masters.has(master_id):
		return false
	# Each stop must have a Trading Post
	var posts = get_node("/root/TradingPostManager")
	for stop in stops:
		if not posts.has_post(str(stop.get("town_name", ""))):
			return false
	routes[master_id]["stops"] = stops
	routes[master_id]["current_stop_index"] = 0
	emit_signal("master_updated", master_id)
	return true

func start_route(master_id: String) -> bool:
	if not masters.has(master_id):
		return false
	var route = routes[master_id]
	if route["stops"].size() < 2:
		return false
	route["active"] = true
	route["current_stop_index"] = 0
	_depart_to_next_stop(master_id)
	emit_signal("master_updated", master_id)
	return true

func stop_route(master_id: String) -> void:
	if not routes.has(master_id):
		return
	routes[master_id]["active"] = false
	routes[master_id]["destination_town"] = ""
	emit_signal("master_updated", master_id)

# --- Daily tick ---

func process_day() -> void:
	for master_id in masters.keys():
		_tick_master(master_id)

func _tick_master(master_id: String) -> void:
	var route = routes[master_id]
	if not route.get("active", false):
		return

	# Traveling
	if str(route.get("destination_town", "")) != "":
		route["days_traveling"] = int(route["days_traveling"]) + 1
		_check_travel_risk(master_id)
		if int(route["days_traveling"]) >= int(route["travel_total_days"]):
			_arrive_at_stop(master_id)
		return

func _arrive_at_stop(master_id: String) -> void:
	var master: CaravanMaster = masters[master_id]
	var route = routes[master_id]
	var stop_index: int = int(route["current_stop_index"])
	var stops: Array = route["stops"]
	if stops.is_empty():
		return

	var stop = stops[stop_index]
	var town_name: String = str(stop.get("town_name", ""))

	# Process stop rules
	_process_stop(master_id, town_name, stop)

	# Award XP
	var leveled_up: bool = master.add_xp(XP_PER_DELIVERY)
	if leveled_up:
		emit_signal("master_leveled_up", master_id)

	# Advance to next stop
	route["current_stop_index"] = (stop_index + 1) % stops.size()
	route["destination_town"] = ""
	route["days_traveling"] = 0
	route["travel_total_days"] = 0
	_depart_to_next_stop(master_id)
	emit_signal("master_updated", master_id)

func _process_stop(master_id: String, town_name: String, stop: Dictionary) -> void:
	var master: CaravanMaster = masters[master_id]
	var route = routes[master_id]
	var posts = get_node("/root/TradingPostManager")

	for rule in stop.get("rules", []):
		var item: String = str(rule.get("item", ""))
		var type: String = str(rule.get("type", "sell"))
		var price_limit: float = float(rule.get("price_limit", 0.0))
		var max_qty: int = int(rule.get("max_qty", 0))
		if max_qty <= 0 or item == "":
			continue

		if type == "sell":
			# Sell from master inventory to Trading Post depot
			var carry_qty: int = int(route["inventory"].get(item, 0))
			if carry_qty <= 0:
				continue
			var current_price: float = _economy.get_price(town_name, item)
			var effective_price: float = current_price * (1.0 + master.get_bargaining_discount())
			if effective_price < price_limit:
				continue
			var qty: int = mini(carry_qty, max_qty)
			var depot_space: int = posts.DEPOT_CAPACITY - posts.get_depot_total(town_name)
			qty = mini(qty, depot_space)
			if qty <= 0:
				continue
			route["inventory"][item] = carry_qty - qty
			if int(route["inventory"][item]) <= 0:
				route["inventory"].erase(item)
			posts.add_to_depot(town_name, item, qty)

		elif type == "buy":
			# Buy from Trading Post depot into master inventory
			var free_capacity: int = master.get_capacity() - _get_total_cargo(master_id)
			if free_capacity <= 0:
				continue
			var depot_qty: int = posts.get_depot_item_count(town_name, item)
			if depot_qty <= 0:
				continue
			var current_price: float = _economy.get_price(town_name, item)
			var effective_price: float = current_price * (1.0 - master.get_bargaining_discount())
			if effective_price > price_limit:
				continue
			var qty: int = mini(mini(depot_qty, free_capacity), max_qty)
			if qty <= 0:
				continue
			posts.remove_from_depot(town_name, item, qty)
			route["inventory"][item] = int(route["inventory"].get(item, 0)) + qty

func _depart_to_next_stop(master_id: String) -> void:
	var route = routes[master_id]
	var stops: Array = route["stops"]
	if stops.is_empty():
		return
	var next_index: int = int(route["current_stop_index"])
	var next_town: String = str(stops[next_index].get("town_name", ""))
	var current_town: String = str(route.get("destination_town", ""))
	if current_town == "":
		# Find previous stop town
		var prev_index: int = (next_index - 1 + stops.size()) % stops.size()
		current_town = str(stops[prev_index].get("town_name", ""))
	var master: CaravanMaster = masters[master_id]
	var base_days: int = _calc_travel_days(current_town, next_town)
	var actual_days: int = maxi(1, int(round(float(base_days) * master.get_travel_multiplier())))
	route["destination_town"] = next_town
	route["days_traveling"] = 0
	route["travel_total_days"] = actual_days

func _check_travel_risk(master_id: String) -> void:
	var master: CaravanMaster = masters[master_id]
	var route = routes[master_id]
	var destination: String = str(route.get("destination_town", ""))
	var base_risk: float = float(_risk.calculate_attack_chance(destination))
	var effective_risk: float = maxf(base_risk - master.get_courage_risk_reduction(), 0.0)
	if randf() < effective_risk:
		# Lose roughly 1/3 of each item
		for item in route["inventory"].keys():
			var qty: int = int(route["inventory"][item])
			var lost: int = int(ceil(float(qty) / 3.0))
			route["inventory"][item] = qty - lost
			if int(route["inventory"][item]) <= 0:
				route["inventory"].erase(item)

func _get_total_cargo(master_id: String) -> int:
	var total := 0
	for qty in routes[master_id]["inventory"].values():
		total += int(qty)
	return total

func _calc_travel_days(from_town: String, to_town: String) -> int:
	var from_pos: Vector2 = _economy.get_town(from_town).get("position", Vector2.ZERO)
	var to_pos: Vector2 = _economy.get_town(to_town).get("position", Vector2.ZERO)
	return maxi(1, int(from_pos.distance_to(to_pos) / 200.0))

# --- Upkeep ---

func get_total_daily_wage() -> float:
	var total := 0.0
	for master in masters.values():
		total += float(master.daily_wage)
	return total

# --- Helpers ---

func get_master(master_id: String) -> CaravanMaster:
	return masters.get(master_id, null)

func get_route(master_id: String) -> Dictionary:
	return routes.get(master_id, {})

func is_traveling(master_id: String) -> bool:
	return str(routes.get(master_id, {}).get("destination_town", "")) != ""

func get_master_location(master_id: String) -> String:
	var route = routes.get(master_id, {})
	var dest: String = str(route.get("destination_town", ""))
	if dest != "":
		return "→ %s" % dest
	var stops: Array = route.get("stops", [])
	var idx: int = int(route.get("current_stop_index", 0))
	if stops.is_empty():
		return "idle"
	var prev_idx: int = (idx - 1 + stops.size()) % stops.size()
	return str(stops[prev_idx].get("town_name", "unknown"))
