extends Node

signal rank_changed(old_rank: String, new_rank: String)

const RANKS = ["Peddler", "Trader", "Merchant", "Guild Master", "Patrician"]

var current_rank_index: int = 0

var _economy: Node
var _player: Node
var _faction: Node
var _posts: Node

func _ready() -> void:
	_economy = get_node("/root/EconomyManager")
	_player = get_node("/root/PlayerData")
	_faction = get_node("/root/FactionManager")
	_posts = get_node_or_null("/root/TradingPostManager")
	
	if _economy.has_signal("economy_updated"):
		_economy.connect("economy_updated", _on_economy_updated)

func get_current_rank() -> String:
	return RANKS[current_rank_index]

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
		"friendly_factions": 0,
		"trading_posts": 0,
		"growing_cities": 0,
		"allied_factions": 0,
		"prosperous_cities": 0,
		"debt_free": 1
	}
	match rank_idx:
		1: # Trader
			reqs["gold"] = 500
			reqs["friendly_factions"] = 1
		2: # Merchant
			reqs["gold"] = 1500
			reqs["friendly_factions"] = 2
		3: # Guild Master
			reqs["gold"] = 4000
			reqs["friendly_factions"] = 3
			reqs["trading_posts"] = 2
			reqs["growing_cities"] = 1
		4: # Patrician
			reqs["gold"] = 10000
			reqs["allied_factions"] = 3
			reqs["prosperous_cities"] = 3
	return reqs

func get_progress_data() -> Dictionary:
	if current_rank_index + 1 >= RANKS.size():
		return {}
	
	var next_reqs = get_rank_requirements(current_rank_index + 1)
	
	var friendly_count = 0
	var allied_count = 0
	for f in _faction.FACTIONS.keys():
		var rep = _player.get_faction_rep(f)
		if rep >= 30: friendly_count += 1
		if rep >= 60: allied_count += 1
		
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
		"friendly_factions": {"current": friendly_count, "req": next_reqs["friendly_factions"]},
		"trading_posts": {"current": post_count, "req": next_reqs["trading_posts"]},
		"growing_cities": {"current": growing_count, "req": next_reqs["growing_cities"]},
		"allied_factions": {"current": allied_count, "req": next_reqs["allied_factions"]},
		"prosperous_cities": {"current": prosperous_count, "req": next_reqs["prosperous_cities"]},
		"debt_free": {"current": 0 if _player.has_debt() else 1, "req": next_reqs["debt_free"]}
	}

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
	
	# Recursively check if we somehow skipped a rank
	check_rank_up()
	return true

func _on_economy_updated() -> void:
	check_rank_up()
