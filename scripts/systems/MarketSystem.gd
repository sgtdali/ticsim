extends RefCounted
class_name MarketSystem

var eco: Node

func _init(_eco: Node) -> void:
	eco = _eco

func recalculate_all_prices() -> void:
	for town_name in eco.towns:
		var town = eco.towns[town_name]
		town["prices"] = {}
		for item in eco.BASE_PRICES:
			town["prices"][item] = calculate_price(town, item)

func calculate_price(town: Dictionary, item: String) -> float:
	var base := float((eco.BASE_PRICES[item] if eco.BASE_PRICES.has(item) else 0.0))
	if base <= 0.0:
		return 0.0
	var stock := float(town["inventory"].get(item, 0))
	var demand := float(eco.simulation.estimate_daily_consumption(town, item))
	var supply := float(eco.simulation.estimate_effective_daily_supply(town, item))
	var max_stock := maxf(float(eco.simulation.get_stock_cap(town, item)), 1.0)
	var pressure := (demand - supply) / max_stock
	var scarcity := stock / max_stock
	var event_mult: float = 1.0
	if eco._events != null:
		event_mult = float(eco._events.get_price_multiplier(town.get("name", ""), item))
	return maxf(base * (1.0 + clamp(pressure - scarcity, -0.7, 3.0) * 1.4) * event_mult, base * 0.25)

func get_price(town_name: String, item: String) -> float:
	return eco.towns.get(town_name, {}).get("prices", {}).get(item, (eco.BASE_PRICES[item] if eco.BASE_PRICES.has(item) else 0.0))

func get_town_free_stock(town_name: String, item: String) -> int:
	var town = eco.towns.get(town_name, {})
	if town.is_empty():
		return 0
	return maxi(int(eco.simulation.get_stock_cap(town, item)) - int(town["inventory"].get(item, 0)), 0)

func add_town_stock(town_name: String, item: String, qty: int, respect_cap := true) -> bool:
	if qty <= 0:
		return false
	var town = eco.towns.get(town_name, {})
	if town.is_empty():
		return false
	var current_stock = int(town["inventory"].get(item, 0))
	if respect_cap:
		var cap: int = int(eco.simulation.get_stock_cap(town, item))
		town["inventory"][item] = mini(current_stock + qty, cap)
	else:
		town["inventory"][item] = current_stock + qty
	recalculate_all_prices()
	return true

func player_buy(town_name: String, item: String, qty: int) -> bool:
	if qty <= 0:
		return false
	var town = eco.towns.get(town_name, {})
	if town.is_empty() or town["inventory"].get(item, 0) < qty:
		return false
	if eco._player.get_free_capacity() < qty:
		return false
	
	var unit_price := get_price(town_name, item)
	var discount := float(eco._player.get_faction_rep(town.get("faction", ""))) * 0.001
	var effective_unit_cost := unit_price * (1.0 - discount)
	var total_cost := effective_unit_cost * qty
	
	if not eco._player.remove_gold(total_cost):
		return false
	
	# Weighted average calculation
	var current_qty := int(eco._player.get_item_count(item))
	var old_avg := float(eco._player.purchase_prices.get(item, 0.0))
	var new_qty := current_qty + qty
	var new_avg := (current_qty * old_avg + qty * effective_unit_cost) / float(new_qty)
	eco._player.purchase_prices[item] = new_avg
	
	town["inventory"][item] -= qty
	if town["inventory"][item] == 0:
		town["inventory"].erase(item)
	
	eco._player.add_item(item, qty)
	recalculate_all_prices()
	return true

func player_sell(town_name: String, item: String, qty: int) -> bool:
	if qty <= 0:
		return false
	var town = eco.towns.get(town_name, {})
	if town.is_empty():
		return false
	var cap: int = int(eco.simulation.get_stock_cap(town, item))
	var current_stock = int(town["inventory"].get(item, 0))
	if current_stock + qty > cap:
		return false
	if not eco._player.remove_item(item, qty):
		return false
		
	if eco._player.get_item_count(item) == 0:
		eco._player.purchase_prices.erase(item)
	
	var unit_price := get_price(town_name, item)
	var bonus := float(eco._player.get_faction_rep(town.get("faction", ""))) * 0.001
	var prosperity_bonus: float = (float(eco.investment.get_prosperity_multiplier(town_name)) - 1.0) * 0.30
	var effective_sell_price: float = unit_price * (1.0 + bonus + prosperity_bonus)
	
	eco._player.add_gold(effective_sell_price * qty)
	town["inventory"][item] = current_stock + qty
	recalculate_all_prices()
	return true
