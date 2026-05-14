extends Node

const FACTIONS: Dictionary = {
	"Northern Kingdom": {
		"color": Color(0.2, 0.4, 0.8),
		"description": "The ruling monarchy. Controls northern trade routes.",
		"relations": { "Merchants Guild": 20, "Thieves Brotherhood": -60 },
	},
	"Merchants Guild": {
		"color": Color(0.8, 0.6, 0.1),
		"description": "Powerful trade organization. Controls southern markets.",
		"relations": { "Northern Kingdom": 20, "Thieves Brotherhood": -30 },
	},
	"Thieves Brotherhood": {
		"color": Color(0.5, 0.1, 0.5),
		"description": "Underground network. Offers black market access.",
		"relations": { "Northern Kingdom": -60, "Merchants Guild": -30 },
	},
}

var npcs: Dictionary = {}

signal reputation_changed(faction: String, new_value: float)

var _player: Node

# -----------------------------------------------

func _ready() -> void:
	_player = get_node("/root/PlayerData")
	_init_npcs()

func _init_npcs() -> void:
	npcs = {
		"aldric": {
			"name": "Aldric",
			"faction": "Northern Kingdom",
			"town": "Ashford",
			"role": "Town Mayor",
			"description": "The mayor of Ashford. Grants trade licenses.",
		},
		"mira": {
			"name": "Mira",
			"faction": "Merchants Guild",
			"town": "Ironmere",
			"role": "Guild Representative",
			"description": "Guild rep in Ironmere. Offers bulk contracts.",
		},
		"torben": {
			"name": "Torben",
			"faction": "Merchants Guild",
			"town": "Stonebridge",
			"role": "Master Craftsman",
			"description": "Controls the craftsman association. Sells rare tools.",
		},
	}

func get_npc(npc_id: String) -> Dictionary:
	return npcs.get(npc_id, {})

func get_npcs_in_town(town_name: String) -> Array:
	var result = []
	for id in npcs:
		if npcs[id]["town"] == town_name:
			result.append({ "id": id, "data": npcs[id] })
	return result

func get_faction_data(faction_name: String) -> Dictionary:
	return FACTIONS.get(faction_name, {})

func get_tax_rate(faction_name: String) -> float:
	var rep = _player.get_faction_rep(faction_name)
	return clamp(0.05 - (rep * 0.0005), 0.0, 0.20)

func apply_trade_reputation(faction_name: String, trade_value: float) -> void:
	var gain = trade_value * 0.002
	_player.change_faction_rep(faction_name, gain)
	var faction_data = FACTIONS.get(faction_name, {})
	for rival in faction_data.get("relations", {}):
		if faction_data["relations"][rival] < 0:
			_player.change_faction_rep(rival, -gain * 0.3)
	emit_signal("reputation_changed", faction_name, _player.get_faction_rep(faction_name))

func get_relation_description(value: float) -> String:
	if value >= 60:
		return "Allied"
	elif value >= 30:
		return "Friendly"
	elif value >= -10:
		return "Neutral"
	elif value >= -40:
		return "Unfriendly"
	else:
		return "Hostile"
