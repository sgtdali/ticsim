extends Node

const TRAVEL_TIMES: Dictionary = {
	"Ashford|Ironmere":     2,
	"Ashford|Millhaven":    2,
	"Ashford|Grapevale":    3,
	"Ashford|Stonebridge":  4,
	"Ironmere|Millhaven":   2,
	"Ironmere|Stonebridge": 2,
	"Ironmere|Grapevale":   4,
	"Millhaven|Grapevale":  2,
	"Millhaven|Stonebridge":3,
	"Grapevale|Stonebridge":3,
}

var is_traveling: bool = false
var travel_destination: String = ""
var travel_days_remaining: int = 0
var travel_total_days: int = 0

signal travel_started(destination: String, days: int)
signal travel_day_passed(days_remaining: int)
signal travel_arrived(town: String)

var _player: Node
var _economy: Node
var _faction: Node

# -----------------------------------------------

func _ready() -> void:
	_player  = get_node("/root/PlayerData")
	_economy = get_node("/root/EconomyManager")
	_faction = get_node("/root/FactionManager")

func get_travel_time(from_town: String, to_town: String) -> int:
	var key1 = from_town + "|" + to_town
	var key2 = to_town + "|" + from_town
	if TRAVEL_TIMES.has(key1):
		return TRAVEL_TIMES[key1]
	if TRAVEL_TIMES.has(key2):
		return TRAVEL_TIMES[key2]
	return 99

func can_travel(to_town: String) -> bool:
	if is_traveling:
		return false
	var time = get_travel_time(_player.current_town, to_town)
	return time < 99

func start_travel(to_town: String) -> bool:
	if not can_travel(to_town):
		return false
	var days = get_travel_time(_player.current_town, to_town)
	var destination_town = _economy.get_town(to_town)
	if not destination_town.is_empty():
		var faction = destination_town.get("faction", "")
		var tax_rate = _faction.get_tax_rate(faction)
		if tax_rate > 0:
			var cargo_value = _estimate_cargo_value()
			var tax = cargo_value * tax_rate
			if tax > 0:
				_player.remove_gold(tax)
	is_traveling = true
	travel_destination = to_town
	travel_days_remaining = days
	travel_total_days = days
	emit_signal("travel_started", to_town, days)
	return true

func advance_day() -> void:
	if not is_traveling:
		return
	travel_days_remaining -= 1
	_economy.advance_day()
	_player.advance_day()
	_process_shops()
	if travel_days_remaining <= 0:
		_arrive()
	else:
		emit_signal("travel_day_passed", travel_days_remaining)

func advance_day_in_town() -> void:
	_economy.advance_day()
	_player.advance_day()
	_process_shops()

func _arrive() -> void:
	is_traveling = false
	_player.current_town = travel_destination
	emit_signal("travel_arrived", travel_destination)

func _estimate_cargo_value() -> float:
	var total = 0.0
	for item in _player.inventory:
		var qty = _player.inventory[item]
		total += _economy.BASE_PRICES.get(item, 0) * qty
	return total

func _process_shops() -> void:
	for shop in _player.owned_shops:
		var town_name = shop.get("town", "")
		var town = _economy.get_town(town_name)
		if town.is_empty():
			continue
		var level = shop.get("level", 1)
		var workers = shop.get("workers", [])
		var efficiency = clamp(0.5 + (workers.size() * 0.25), 0.0, 1.5)
		var daily_income = level * 5.0 * efficiency
		_player.add_gold(daily_income)
