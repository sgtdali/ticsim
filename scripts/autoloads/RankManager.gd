extends Node
 
signal rank_changed(old_rank: String, new_rank: String)
 
var RANKS: Array[String] = []
var ranks_data: Dictionary = {}
var current_rank_index: int = 0
 
var _economy: Node
var _player: Node
var _posts: Node
 
func _ready() -> void:
	_economy = get_node("/root/EconomyManager")
	_player = get_node("/root/PlayerData")
	_posts = get_node_or_null("/root/TradingPostManager")
	
	_load_ranks_data()
	
	if _economy.has_signal("progression_updated"):
		_economy.connect("progression_updated", _on_progression_updated)

func _load_ranks_data() -> void:
	RANKS.clear()
	ranks_data.clear()
	var rows = CSVLoader.load_csv("res://data/balance/ranks.csv")
	rows.sort_custom(func(a, b): return CSVLoader.parse_int(a["rank_index"]) < CSVLoader.parse_int(b["rank_index"]))
	
	for row in rows:
		var r_id = row["rank_id"]
		RANKS.append(r_id)
		ranks_data[r_id] = {
			"index": CSVLoader.parse_int(row["rank_index"]),
			"gold": CSVLoader.parse_float(row["gold_required"]),
			"growing_cities": CSVLoader.parse_int(row["growing_cities_required"]),
			"prosperous_cities": CSVLoader.parse_int(row["prosperous_cities_required"]),
			"trading_posts": CSVLoader.parse_int(row["posts_required"]),
			"daily_upkeep": CSVLoader.parse_float(row["daily_upkeep"])
		}

func get_current_rank() -> String:
	if current_rank_index < RANKS.size():
		return RANKS[current_rank_index]
	return "Peddler"
 
func get_next_rank() -> String:
	if current_rank_index + 1 < RANKS.size():
		return RANKS[current_rank_index + 1]
	return ""
 
func can_upgrade_caravan() -> bool:
	return current_rank_index >= 1
 
func can_open_trading_post() -> bool:
	return current_rank_index >= 2
 
func can_get_urgent_contracts() -> bool:
	return current_rank_index >= 3
 
func get_rank_requirements(rank_idx: int) -> Dictionary:
	var reqs = {
		"gold": 0,
		"trading_posts": 0,
		"growing_cities": 0,
		"prosperous_cities": 0,
		"debt_free": 1
	}
	if rank_idx < RANKS.size():
		var r_id = RANKS[rank_idx]
		var data = ranks_data.get(r_id, {})
		if not data.is_empty():
			reqs["gold"] = data["gold"]
			reqs["trading_posts"] = data["trading_posts"]
			reqs["growing_cities"] = data["growing_cities"]
			reqs["prosperous_cities"] = data["prosperous_cities"]
	return reqs
 
func get_progress_data() -> Dictionary:
	if current_rank_index + 1 >= RANKS.size():
		return {}
	
	var next_reqs = get_rank_requirements(current_rank_index + 1)
	
	var post_count = 0
	if _posts:
		for town_name in _economy.towns.keys():
			if _posts.has_post(town_name):
				post_count += 1
				
	var growing_count = 0
	var prosperous_count = 0
	for town_name in _economy.towns.keys():
		var p = _economy.get_prosperity(town_name)
		if p >= 30: growing_count += 1
		if p >= 65: prosperous_count += 1
		
	return {
		"gold": {"current": int(_player.gold), "req": next_reqs["gold"]},
		"trading_posts": {"current": post_count, "req": next_reqs["trading_posts"]},
		"growing_cities": {"current": growing_count, "req": next_reqs["growing_cities"]},
		"prosperous_cities": {"current": prosperous_count, "req": next_reqs["prosperous_cities"]},
		"debt_free": {"current": 0 if _player.has_debt() else 1, "req": next_reqs["debt_free"]}
	}

func get_current_upkeep() -> float:
	var rank = get_current_rank()
	if ranks_data.has(rank):
		return float(ranks_data[rank]["daily_upkeep"])
	return 0.0
 
func check_rank_up() -> bool:
	if current_rank_index + 1 >= RANKS.size():
		return false
	if _player.has_debt():
		return false
		
	var prog = get_progress_data()
	for key in prog.keys():
		if prog[key]["req"] > 0 and prog[key]["current"] < prog[key]["req"]:
			return false
			
	var old_rank = get_current_rank()
	current_rank_index += 1
	var new_rank = get_current_rank()
	emit_signal("rank_changed", old_rank, new_rank)
	
	check_rank_up()
	return true
 
func _on_progression_updated() -> void:
	check_rank_up()
