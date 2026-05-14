extends RefCounted
class_name InvestmentSystem

var eco: Node
var daily_prosperity_earned: Dictionary = {}

func _init(_eco: Node) -> void:
	eco = _eco

func get_prosperity(town_name: String) -> int:
	return int(eco.towns.get(town_name, {}).get("prosperity", 0))

func get_prosperity_level(town_name: String) -> int:
	var p := get_prosperity(town_name)
	if p >= eco.PROSPERITY_LEVEL_3_THRESHOLD:
		return 3
	elif p >= eco.PROSPERITY_LEVEL_2_THRESHOLD:
		return 2
	return 1

func get_prosperity_label(town_name: String) -> String:
	match get_prosperity_level(town_name):
		3: return "Prosperous"
		2: return "Growing"
		_: return "Struggling"

func add_prosperity(town_name: String, amount: int) -> void:
	var town = eco.towns.get(town_name, {})
	if town.is_empty():
		return
	var current := int(town.get("prosperity", 0))
	town["prosperity"] = clamp(current + amount, 0, eco.PROSPERITY_MAX)

func get_prosperity_multiplier(town_name: String) -> float:
	match get_prosperity_level(town_name):
		3: return 1.50
		2: return 1.20
		_: return 1.0

func invest_gold(town_name: String, gold_amount: float) -> Variant:
	if gold_amount <= 0.0:
		return 0
	var town = eco.towns.get(town_name, {})
	if town.is_empty():
		return 0
	if eco._player.gold < gold_amount:
		return 0
	
	var daily_earned = daily_prosperity_earned.get(town_name, 0)
	if daily_earned >= eco.MAX_DAILY_PROSPERITY_GAIN:
		return "Daily investment limit reached"

	var prosperity_gain := int(floor(gold_amount / eco.GOLD_PER_PROSPERITY_POINT))
	if prosperity_gain <= 0:
		return 0
		
	if daily_earned + prosperity_gain > eco.MAX_DAILY_PROSPERITY_GAIN:
		prosperity_gain = eco.MAX_DAILY_PROSPERITY_GAIN - daily_earned
		gold_amount = float(prosperity_gain) * eco.GOLD_PER_PROSPERITY_POINT
		if prosperity_gain <= 0:
			return "Daily investment limit reached"

	if not eco._player.remove_gold(gold_amount):
		return 0

	add_prosperity(town_name, prosperity_gain)
	daily_prosperity_earned[town_name] = daily_earned + prosperity_gain
	eco.emit_signal("progression_updated")
	return prosperity_gain
