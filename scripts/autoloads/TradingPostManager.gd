extends Node

signal post_updated(town_name: String)

const POST_COST := 300.0
const DEPOT_CAPACITY := 50

# Format:
# posts = {
# 	"Ashford": {
# 		"established": true,
# 		"depot": { "wheat": 10, "iron_bar": 5 },
# 		"rules": [
# 			{
# 				"item": "wheat",
# 				"type": "buy", # "buy" or "sell"
# 				"price_limit": 4.0,
# 				"daily_max": 20,
# 				"depot_limit": 10,
# 				"enabled": true
# 			}
# 		]
# 	}
# }
var posts: Dictionary = {}

var _economy: Node
var _player: Node

func _ready() -> void:
	_economy = get_node("/root/EconomyManager")
	_player = get_node("/root/PlayerData")
	
	if _economy.has_signal("new_day"):
		_economy.connect("new_day", _on_new_day)

func has_post(town_name: String) -> bool:
	return posts.has(town_name) and posts[town_name].get("established", false)

func establish_post(town_name: String) -> bool:
	if not get_node("/root/RankManager").can_open_trading_post():
		return false
	if has_post(town_name):
		return false
	if _player.gold < POST_COST:
		return false
	
	_player.remove_gold(POST_COST)
	
	if not posts.has(town_name):
		posts[town_name] = { "established": true, "depot": {}, "rules": [] }
	else:
		posts[town_name]["established"] = true
	
	emit_signal("post_updated", town_name)
	return true

func get_depot(town_name: String) -> Dictionary:
	if not has_post(town_name):
		return {}
	return posts[town_name].get("depot", {})

func get_depot_total(town_name: String) -> int:
	var total := 0
	var depot = get_depot(town_name)
	for qty in depot.values():
		total += int(qty)
	return total

func get_depot_item_count(town_name: String, item: String) -> int:
	return int(get_depot(town_name).get(item, 0))

func add_to_depot(town_name: String, item: String, qty: int) -> bool:
	if qty <= 0 or not has_post(town_name):
		return false
	var total = get_depot_total(town_name)
	if total + qty > DEPOT_CAPACITY:
		return false
	var current = get_depot_item_count(town_name, item)
	posts[town_name]["depot"][item] = current + qty
	emit_signal("post_updated", town_name)
	return true

func remove_from_depot(town_name: String, item: String, qty: int) -> bool:
	if qty <= 0 or not has_post(town_name):
		return false
	var current = get_depot_item_count(town_name, item)
	if current < qty:
		return false
	posts[town_name]["depot"][item] = current - qty
	if posts[town_name]["depot"][item] <= 0:
		posts[town_name]["depot"].erase(item)
	emit_signal("post_updated", town_name)
	return true

func get_rules(town_name: String) -> Array:
	if not has_post(town_name):
		return []
	return posts[town_name].get("rules", [])

func add_rule(town_name: String, rule_data: Dictionary) -> void:
	if not has_post(town_name):
		return
	posts[town_name]["rules"].append(rule_data)
	emit_signal("post_updated", town_name)

func remove_rule(town_name: String, idx: int) -> void:
	if not has_post(town_name):
		return
	var rules: Array = posts[town_name]["rules"]
	if idx >= 0 and idx < rules.size():
		rules.remove_at(idx)
		emit_signal("post_updated", town_name)

func toggle_rule(town_name: String, idx: int, enabled: bool) -> void:
	if not has_post(town_name):
		return
	var rules: Array = posts[town_name]["rules"]
	if idx >= 0 and idx < rules.size():
		rules[idx]["enabled"] = enabled
		emit_signal("post_updated", town_name)

func _on_new_day() -> void:
	var trades_happened := false
	for town_name in posts.keys():
		if not has_post(town_name):
			continue
		
		var rules: Array = posts[town_name]["rules"]
		for rule in rules:
			if not rule.get("enabled", true):
				continue
				
			var item: String = str(rule.get("item", ""))
			var type: String = str(rule.get("type", "buy"))
			var limit_price: float = float(rule.get("price_limit", 0.0))
			var daily_max: int = int(rule.get("daily_max", 0))
			var depot_limit: int = int(rule.get("depot_limit", 0))
			
			if daily_max <= 0:
				continue
				
			var current_price := float(_economy.get_price(town_name, item))
			var current_depot := get_depot_item_count(town_name, item)
			
			if type == "buy":
				if current_price < limit_price and current_depot < depot_limit:
					var market_stock := int(_economy.get_town(town_name).get("inventory", {}).get(item, 0))
					var space_to_limit := depot_limit - current_depot
					var global_space := DEPOT_CAPACITY - get_depot_total(town_name)
					var space := mini(space_to_limit, global_space)
					
					var qty := mini(daily_max, mini(market_stock, space))
					if qty > 0:
						var cost := qty * current_price
						if _player.gold >= cost:
							_player.remove_gold(cost)
							# take from market
							var town_data: Dictionary = _economy.get_town(town_name)
							town_data["inventory"][item] -= qty
							if town_data["inventory"][item] <= 0:
								town_data["inventory"].erase(item)
							
							# add to depot silently without emitting signal repeatedly
							posts[town_name]["depot"][item] = current_depot + qty
							print("[Post] %s: bought %dx %s at %.1fg" % [town_name, qty, item, current_price])
							trades_happened = true
			
			elif type == "sell":
				if current_price > limit_price and current_depot > depot_limit:
					var stock_to_sell := current_depot - depot_limit
					var qty := mini(daily_max, stock_to_sell)
					
					var market_free: int = int(_economy.get_town_free_stock(town_name, item))
					qty = mini(qty, market_free)
					
					if qty > 0:
						var earnings := qty * current_price
						_player.add_gold(earnings)
						
						# add to market
						var town_data: Dictionary = _economy.get_town(town_name)
						town_data["inventory"][item] = int(town_data["inventory"].get(item, 0)) + qty
						
						# remove from depot
						posts[town_name]["depot"][item] = current_depot - qty
						if posts[town_name]["depot"][item] <= 0:
							posts[town_name]["depot"].erase(item)
						print("[Post] %s: sold %dx %s at %.1fg" % [town_name, qty, item, current_price])
						trades_happened = true
	
	if trades_happened:
		_economy.market.recalculate_all_prices()
		for town_name in posts.keys():
			emit_signal("post_updated", town_name)
