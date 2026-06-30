extends Node

# Single-slot JSON save/load for the whole game state.
# WorldMap travel/speed state is passed in/out via world_state dicts
# rather than read directly, since SaveManager has no scene reference.

signal game_saved
signal game_loaded

const SAVE_VERSION := 1
const SAVE_DIR := "user://saves"
const SAVE_PATH := "user://saves/savegame.json"

# Set by MainMenu before changing to WorldMap.tscn; consumed in WorldMap._ready().
var pending_load := false

var _pending_world_state: Dictionary = {}

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)

func save_game(world_state: Dictionary) -> bool:
	var dir := DirAccess.open("user://")
	if dir == null:
		return false
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(_gather_state(world_state), "\t"))
	file.close()
	emit_signal("game_saved")
	return true

func load_game() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var text := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false

	_apply_state(parsed)
	emit_signal("game_loaded")
	return true

# Called by WorldMap after applying town/player/etc state, to pick up
# travel/speed/victory state. Clears it so a second call returns nothing.
func consume_world_state() -> Dictionary:
	var state := _pending_world_state
	_pending_world_state = {}
	return state

# ==========================================
# Gather (save)
# ==========================================

func _gather_state(world_state: Dictionary) -> Dictionary:
	var player: Node = get_node("/root/PlayerData")
	var economy: Node = get_node("/root/EconomyManager")
	var rank: Node = get_node("/root/RankManager")
	var contracts: Node = get_node("/root/ContractManager")
	var posts: Node = get_node_or_null("/root/TradingPostManager")
	var masters: Node = get_node_or_null("/root/CaravanMasterManager")
	var traders: Node = get_node_or_null("/root/TraderManager")

	return {
		"version": SAVE_VERSION,
		"player": {
			"gold": player.gold,
			"debt": player.debt,
			"debt_days": player.debt_days,
			"finance_today": player.finance_today,
			"finance_yesterday": player.finance_yesterday,
			"inventory": player.inventory,
			"purchase_prices": player.purchase_prices,
			"caravan_capacity": player.caravan_capacity,
			"caravan_upgrade_level": player.caravan_upgrade_level,
			"current_town": player.current_town,
			"faction_reputation": player.faction_reputation,
			"owned_shops": player.owned_shops,
			"current_day": player.current_day,
		},
		"economy": {
			"current_day": economy.current_day,
			"towns": _serialize_towns(economy.towns),
		},
		"rank": {
			"current_rank_index": rank.current_rank_index,
		},
		"contracts": {
			"contracts": contracts.contracts,
			"next_id": contracts._next_id,
		},
		"trading_posts": {
			"posts": (posts.posts if posts != null else {}),
		},
		"caravan_masters": {
			"masters": (_serialize_masters(masters.masters) if masters != null else {}),
			"routes": (masters.routes if masters != null else {}),
		},
		"traders": {
			"traders": (traders.traders if traders != null else {}),
		},
		"world": world_state,
	}

func _serialize_towns(towns: Dictionary) -> Dictionary:
	var result := {}
	for town_name in towns:
		var town: Dictionary = (towns[town_name] as Dictionary).duplicate(true)
		town.erase("position")  # re-derived from scene anchors on load
		result[town_name] = town
	return result

func _serialize_masters(masters: Dictionary) -> Dictionary:
	var result := {}
	for master_id in masters:
		result[master_id] = _master_to_dict(masters[master_id])
	return result

func _master_to_dict(master: CaravanMaster) -> Dictionary:
	return {
		"id": master.id,
		"display_name": master.display_name,
		"speed": master.speed,
		"capacity": master.capacity,
		"bargaining": master.bargaining,
		"courage": master.courage,
		"xp": master.xp,
		"level": master.level,
		"hire_cost": master.hire_cost,
		"daily_wage": master.daily_wage,
	}

# ==========================================
# Apply (load)
# ==========================================

func _apply_state(data: Dictionary) -> void:
	var player: Node = get_node("/root/PlayerData")
	var economy: Node = get_node("/root/EconomyManager")
	var rank: Node = get_node("/root/RankManager")
	var contracts: Node = get_node("/root/ContractManager")
	var posts: Node = get_node_or_null("/root/TradingPostManager")
	var masters: Node = get_node_or_null("/root/CaravanMasterManager")
	var traders: Node = get_node_or_null("/root/TraderManager")

	var p: Dictionary = data.get("player", {})
	player.gold = float(p.get("gold", player.gold))
	player.debt = float(p.get("debt", 0.0))
	player.debt_days = int(p.get("debt_days", 0))
	player.finance_today = p.get("finance_today", player.finance_today)
	player.finance_yesterday = p.get("finance_yesterday", player.finance_yesterday)
	player.inventory = p.get("inventory", {})
	player.purchase_prices = p.get("purchase_prices", {})
	player.caravan_capacity = int(p.get("caravan_capacity", player.caravan_capacity))
	player.caravan_upgrade_level = int(p.get("caravan_upgrade_level", 0))
	player.current_town = str(p.get("current_town", player.current_town))
	player.faction_reputation = p.get("faction_reputation", {})
	player.owned_shops = p.get("owned_shops", [])
	player.current_day = int(p.get("current_day", 1))

	var eco: Dictionary = data.get("economy", {})
	economy.current_day = int(eco.get("current_day", economy.current_day))
	_restore_towns(economy.towns, eco.get("towns", {}))

	var rk: Dictionary = data.get("rank", {})
	rank.current_rank_index = int(rk.get("current_rank_index", 0))

	var c: Dictionary = data.get("contracts", {})
	contracts.contracts = c.get("contracts", {})
	contracts._next_id = int(c.get("next_id", 1))

	if posts != null:
		var tp: Dictionary = data.get("trading_posts", {})
		posts.posts = tp.get("posts", {})

	if masters != null:
		var cm: Dictionary = data.get("caravan_masters", {})
		_restore_masters(masters, cm.get("masters", {}))
		masters.routes = cm.get("routes", {})

	if traders != null:
		var tr: Dictionary = data.get("traders", {})
		traders.traders = tr.get("traders", {})

	_pending_world_state = data.get("world", {})

func _restore_towns(towns: Dictionary, saved: Dictionary) -> void:
	for town_name in saved:
		if not towns.has(town_name):
			continue
		var position: Vector2 = (towns[town_name] as Dictionary).get("position", Vector2.ZERO)
		var restored: Dictionary = (saved[town_name] as Dictionary).duplicate(true)
		restored["position"] = position
		towns[town_name] = restored

func _restore_masters(manager: Node, saved: Dictionary) -> void:
	var result := {}
	for master_id in saved:
		result[master_id] = _dict_to_master(saved[master_id])
	manager.masters = result

func _dict_to_master(d: Dictionary) -> CaravanMaster:
	var master := CaravanMaster.new()
	master.id = str(d.get("id", ""))
	master.display_name = str(d.get("display_name", ""))
	master.speed = int(d.get("speed", 1))
	master.capacity = int(d.get("capacity", 1))
	master.bargaining = int(d.get("bargaining", 1))
	master.courage = int(d.get("courage", 1))
	master.xp = int(d.get("xp", 0))
	master.level = int(d.get("level", 1))
	master.hire_cost = int(d.get("hire_cost", 0))
	master.daily_wage = float(d.get("daily_wage", 0.0))
	return master
