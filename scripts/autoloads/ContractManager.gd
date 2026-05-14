extends Node

signal contracts_changed
signal contract_completed(contract_id: String)
signal contract_failed(contract_id: String)

const STATUS_AVAILABLE := "available"
const STATUS_ACCEPTED := "accepted"
const STATUS_COMPLETED := "completed"
const STATUS_FAILED := "failed"

const TYPE_DELIVERY := "delivery"
const TYPE_PROCUREMENT := "procurement"

const CONTRACTS_PER_TOWN := 2
const FAILURE_REP_PENALTY := 1.0

const TIER_DATA := {
	"basic": {"minimum_deadline": 10, "travel_buffer": 5, "gold_multiplier": 1.0, "rep": 1.0},
	"standard": {"minimum_deadline": 8, "travel_buffer": 4, "gold_multiplier": 1.35, "rep": 1.5},
	"urgent": {"minimum_deadline": 6, "travel_buffer": 2, "gold_multiplier": 1.8, "rep": 2.0},
}

const TRAVEL_DISTANCE_PER_DAY := 200.0

var contracts: Dictionary = {}
var _next_id := 1

var _player: Node
var _economy: Node
var _faction: Node

func _ready() -> void:
	_player = get_node("/root/PlayerData")
	_economy = get_node("/root/EconomyManager")
	_faction = get_node("/root/FactionManager")

	if _economy.has_signal("economy_updated"):
		_economy.connect("economy_updated", _on_economy_updated)

	_generate_initial_contracts()

func get_available_contracts(town_name: String) -> Array:
	var result: Array = []
	for contract in contracts.values():
		if contract.get("status", "") == STATUS_AVAILABLE and contract.get("source_town", "") == town_name:
			result.append(contract)
	return result

func get_active_contracts() -> Array:
	var result: Array = []
	for contract in contracts.values():
		if contract.get("status", "") == STATUS_ACCEPTED:
			result.append(contract)
	return result

func get_player_contracts() -> Array:
	var result: Array = []
	for contract in contracts.values():
		if contract.get("status", "") != STATUS_AVAILABLE:
			result.append(contract)
	return result

func get_contract(contract_id: String) -> Dictionary:
	return contracts.get(contract_id, {})

func accept_contract(contract_id: String) -> bool:
	var contract := get_contract(contract_id)
	if contract.is_empty() or contract.get("status", "") != STATUS_AVAILABLE:
		return false

	contract["status"] = STATUS_ACCEPTED
	contract["accepted_day"] = _get_current_day()
	contract["deadline_day"] = _get_current_day() + int(contract.get("deadline_duration", 0))
	contracts[contract_id] = contract
	emit_signal("contracts_changed")
	return true

func can_complete_contract(contract_id: String) -> bool:
	var contract := get_contract(contract_id)
	if contract.is_empty() or contract.get("status", "") != STATUS_ACCEPTED:
		return false
	if _player.current_town != contract.get("target_town", ""):
		return false
	if _get_current_day() > int(contract.get("deadline_day", 0)):
		return false
	return _player.get_item_count(str(contract.get("required_item", ""))) >= int(contract.get("required_quantity", 0))

func complete_contract(contract_id: String) -> bool:
	if not can_complete_contract(contract_id):
		return false

	var contract := get_contract(contract_id)
	var item := String(contract.get("required_item", ""))
	var quantity := int(contract.get("required_quantity", 0))
	if not _player.remove_item(item, quantity):
		return false
	_economy.add_town_stock(str(contract.get("target_town", "")), item, quantity, false)

	_player.add_gold(float(contract.get("reward_gold", 0.0)))
	var faction := String(contract.get("issuing_faction", ""))
	if faction != "":
		var rep_bonus := float(contract.get("reward_faction_rep", 0.0))
		if get_node("/root/RankManager").current_rank_index >= 3: # Guild Master
			rep_bonus *= 1.5
		_player.change_faction_rep(faction, rep_bonus)
	var npc_id := String(contract.get("issuing_npc_id", ""))
	if npc_id != "":
		_player.change_npc_relation(npc_id, float(contract.get("reward_npc_relation", 0.0)))

	contract["status"] = STATUS_COMPLETED
	contract["completed_day"] = _get_current_day()
	contracts[contract_id] = contract
	_ensure_available_contracts(String(contract.get("source_town", "")))
	emit_signal("contract_completed", contract_id)
	emit_signal("contracts_changed")
	return true

func get_days_remaining(contract: Dictionary) -> int:
	if contract.get("status", "") == STATUS_AVAILABLE:
		return int(contract.get("deadline_duration", 0))
	return int(contract.get("deadline_day", 0)) - _get_current_day()

func _on_economy_updated() -> void:
	_expire_contracts()
	var town_names: Array = _economy.towns.keys()
	for town_name in town_names:
		_ensure_available_contracts(town_name)

func _expire_contracts() -> void:
	var changed := false
	for contract_id in contracts:
		var contract: Dictionary = contracts[contract_id]
		if contract.get("status", "") != STATUS_ACCEPTED:
			continue
		if _get_current_day() <= int(contract.get("deadline_day", 0)):
			continue

		contract["status"] = STATUS_FAILED
		contract["failed_day"] = _get_current_day()
		contracts[contract_id] = contract
		var faction := String(contract.get("issuing_faction", ""))
		if faction != "":
			_player.change_faction_rep(faction, -FAILURE_REP_PENALTY)
		emit_signal("contract_failed", contract_id)
		changed = true

	if changed:
		emit_signal("contracts_changed")

func _generate_initial_contracts() -> void:
	var town_names: Array = _economy.towns.keys()
	for town_name in town_names:
		_ensure_available_contracts(town_name)

func _ensure_available_contracts(town_name: String) -> void:
	var available_count := 0
	var generated := false
	for contract in contracts.values():
		if contract.get("status", "") == STATUS_AVAILABLE and contract.get("source_town", "") == town_name:
			available_count += 1

	while available_count < CONTRACTS_PER_TOWN:
		var contract := _make_contract(town_name)
		if contract.is_empty():
			return
		contracts[contract["id"]] = contract
		available_count += 1
		generated = true
	if generated:
		emit_signal("contracts_changed")

func _make_contract(source_town: String) -> Dictionary:
	var town_names: Array = _economy.towns.keys()
	if town_names.is_empty() or not _economy.towns.has(source_town):
		return {}

	var contract_type := TYPE_PROCUREMENT if (_next_id % 2 == 0) else TYPE_DELIVERY
	var target_town := source_town
	if contract_type == TYPE_DELIVERY and town_names.size() > 1:
		target_town = _pick_other_town(source_town, town_names)
	if contract_type == TYPE_DELIVERY and _get_delivery_item_candidates(source_town).is_empty():
		contract_type = TYPE_PROCUREMENT
		target_town = source_town

	var source_data: Dictionary = _economy.get_town(source_town)
	var item := _pick_contract_item(source_town, target_town, contract_type)
	var tier := _pick_tier()
	var quantity := _pick_quantity(item, tier)
	var created_day := _get_current_day()
	var travel_days: int = _estimate_contract_travel_days(source_town, target_town, item, contract_type)
	var deadline_duration: int = maxi(
		int(TIER_DATA[tier]["minimum_deadline"]),
		travel_days + int(TIER_DATA[tier]["travel_buffer"])
	)
	var source_faction: String = String(source_data.get("faction", ""))
	var npc_id: String = _pick_issuer_npc(source_town)
	var faction: String = _get_issuer_faction(npc_id, source_faction)
	var reward_gold: int = _calculate_reward_gold(source_town, target_town, item, quantity, tier)
	var reward_rep: float = float(TIER_DATA[tier]["rep"])

	var contract_id := "contract_%04d" % _next_id
	_next_id += 1

	var title := _make_title(contract_type, item, quantity, target_town, tier)
	return {
		"id": contract_id,
		"type": contract_type,
		"title": title,
		"description": _make_description(contract_type, item, quantity, source_town, target_town, deadline_duration),
		"source_town": source_town,
		"target_town": target_town,
		"issuing_npc_id": npc_id,
		"issuing_faction": faction,
		"required_item": item,
		"required_quantity": quantity,
		"created_day": created_day,
		"deadline_duration": deadline_duration,
		"deadline_day": 0,
		"reward_gold": reward_gold,
		"reward_faction_rep": reward_rep,
		"reward_npc_relation": reward_rep,
		"status": STATUS_AVAILABLE,
		"difficulty_tier": tier,
	}

func _pick_other_town(source_town: String, town_names: Array) -> String:
	var candidates: Array = []
	for town_name in town_names:
		if town_name != source_town:
			candidates.append(town_name)
	if candidates.is_empty():
		return source_town
	return candidates[_next_id % candidates.size()]

func _pick_contract_item(source_town: String, target_town: String, contract_type: String) -> String:
	if contract_type == TYPE_DELIVERY:
		return _pick_from_candidates(_get_delivery_item_candidates(source_town))
	return _pick_from_candidates(_get_procurement_item_candidates(target_town))

func _get_delivery_item_candidates(source_town: String) -> Array:
	var source_data: Dictionary = _economy.get_town(source_town)
	var candidates: Array = []

	for item in source_data.get("inventory", {}).keys():
		if _economy.BASE_PRICES.has(item) and int(source_data.get("inventory", {}).get(item, 0)) > 0:
			candidates.append(item)

	return candidates

func _get_procurement_item_candidates(target_town: String) -> Array:
	var target_data: Dictionary = _economy.get_town(target_town)
	var candidates: Array = []

	for item in target_data.get("consumption_rules", {}).keys():
		if _economy.BASE_PRICES.has(item) and _is_item_obtainable(item, target_town):
			candidates.append(item)
	for item in target_data.get("production_plan", {}).keys():
		if _economy.items_data.has(item) and not _economy.items_data[item].recipe_inputs.is_empty():
			for input_item in _economy.items_data[item].recipe_inputs.keys():
				if _economy.BASE_PRICES.has(input_item) and _is_item_obtainable(input_item, target_town):
					candidates.append(input_item)

	return candidates

func _pick_from_candidates(candidates: Array) -> String:
	if candidates.is_empty():
		candidates = _get_globally_obtainable_items()
	return candidates[_next_id % candidates.size()]

func _is_item_obtainable(item: String, excluded_town := "") -> bool:
	var town_names: Array = _economy.towns.keys()
	for town_name in town_names:
		if town_name == excluded_town:
			continue
		var town: Dictionary = _economy.get_town(town_name)
		if int(town.get("inventory", {}).get(item, 0)) > 0:
			return true
		if town.get("production_plan", {}).has(item):
			return true
	return false

func _get_globally_obtainable_items() -> Array:
	var candidates: Array = []
	var town_names: Array = _economy.towns.keys()
	for town_name in town_names:
		var town: Dictionary = _economy.get_town(town_name)
		for item in town.get("inventory", {}).keys():
			if _economy.BASE_PRICES.has(item) and int(town.get("inventory", {}).get(item, 0)) > 0 and not candidates.has(item):
				candidates.append(item)
		for item in town.get("production_plan", {}).keys():
			if _economy.BASE_PRICES.has(item) and not candidates.has(item):
				candidates.append(item)

	if candidates.is_empty():
		candidates = _economy.BASE_PRICES.keys()
	return candidates

func _pick_tier() -> String:
	match _next_id % 3:
		0:
			if get_node("/root/RankManager").can_get_urgent_contracts():
				return "urgent"
			return "standard"
		1:
			return "basic"
		_:
			return "standard"

func _pick_quantity(item: String, tier: String) -> int:
	var base_qty := 3
	var item_price := float(_economy.BASE_PRICES.get(item, 5.0))
	if item_price <= 5.0:
		base_qty = 6
	elif item_price <= 12.0:
		base_qty = 4
	else:
		base_qty = 2

	var tier_bonus := 0
	if tier == "standard":
		tier_bonus = 1
	elif tier == "urgent":
		tier_bonus = 2
	return mini(base_qty + tier_bonus, maxi(1, int(_player.caravan_capacity * 0.45)))

func _calculate_reward_gold(source_town: String, target_town: String, item: String, quantity: int, tier: String) -> int:
	var unit_price := float(_economy.BASE_PRICES.get(item, 5.0))
	var distance_bonus := 1.0
	if source_town != target_town:
		distance_bonus = 1.25
	var multiplier := float(TIER_DATA[tier]["gold_multiplier"])
	return int(round((unit_price * float(quantity) * 1.35 + 12.0) * distance_bonus * multiplier))

func _estimate_contract_travel_days(source_town: String, target_town: String, item: String, contract_type: String) -> int:
	if contract_type == TYPE_DELIVERY:
		return _get_travel_days_between_towns(source_town, target_town)

	var pickup_town: String = _get_nearest_obtainable_source_town(target_town, item)
	if pickup_town == "":
		return 0
	return _get_travel_days_between_towns(target_town, pickup_town) * 2

func _get_nearest_obtainable_source_town(target_town: String, item: String) -> String:
	var best_town: String = ""
	var best_days: int = 999999
	var town_names: Array = _economy.towns.keys()
	for town_name in town_names:
		if town_name == target_town:
			continue
		var town: Dictionary = _economy.get_town(town_name)
		if int(town.get("inventory", {}).get(item, 0)) <= 0 and not town.get("production_plan", {}).has(item):
			continue
		var days: int = _get_travel_days_between_towns(target_town, town_name)
		if days < best_days:
			best_days = days
			best_town = town_name
	return best_town

func _get_travel_days_between_towns(from_town: String, to_town: String) -> int:
	if from_town == to_town:
		return 0
	var from_data: Dictionary = _economy.get_town(from_town)
	var to_data: Dictionary = _economy.get_town(to_town)
	if from_data.is_empty() or to_data.is_empty():
		return 0
	var from_pos: Vector2 = from_data.get("position", Vector2.ZERO)
	var to_pos: Vector2 = to_data.get("position", Vector2.ZERO)
	return maxi(1, int(from_pos.distance_to(to_pos) / TRAVEL_DISTANCE_PER_DAY))

func _pick_issuer_npc(source_town: String) -> String:
	var town_npcs: Array = _faction.get_npcs_in_town(source_town)
	if town_npcs.is_empty():
		return ""
	return String(town_npcs[0].get("id", ""))

func _get_issuer_faction(npc_id: String, fallback_faction: String) -> String:
	if npc_id != "":
		var npc: Dictionary = _faction.get_npc(npc_id)
		if not npc.is_empty():
			return String(npc.get("faction", fallback_faction))
	return fallback_faction

func _make_title(contract_type: String, item: String, quantity: int, target_town: String, tier: String) -> String:
	var item_name := str(item).capitalize()
	if contract_type == TYPE_PROCUREMENT:
		return "%s request: %d %s" % [tier.capitalize(), quantity, item_name]
	return "%s delivery to %s" % [tier.capitalize(), target_town]

func _make_description(contract_type: String, item: String, quantity: int, source_town: String, target_town: String, deadline_duration: int) -> String:
	var item_name := str(item).capitalize()
	if contract_type == TYPE_PROCUREMENT:
		return "Bring %d %s to %s within %d days after accepting." % [quantity, item_name, target_town, deadline_duration]
	return "Deliver %d %s from %s to %s within %d days after accepting." % [quantity, item_name, source_town, target_town, deadline_duration]

func _get_current_day() -> int:
	return maxi(int(_player.current_day), int(_economy.current_day))
