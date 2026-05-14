extends RefCounted
class_name MarketSystem

const BASE_BUY_SPREAD := 0.08
const BASE_SELL_SPREAD := 0.08
const REPUTATION_TRADE_MODIFIER := 0.001
const MIN_ROUND_TRIP_MARGIN := 0.03
const CONSUMPTION_REFERENCE_DAYS := 14.0

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
	return _calculate_price_for_stock(town, item, float(town["inventory"].get(item, 0)))

func _calculate_price_for_stock(town: Dictionary, item: String, stock: float) -> float:
	var base := float((eco.BASE_PRICES[item] if eco.BASE_PRICES.has(item) else 0.0))
	if base <= 0.0:
		return 0.0
	var demand := float(eco.simulation.estimate_daily_consumption(town, item))
	var event_mult: float = 1.0
	if eco._events != null:
		event_mult = float(eco._events.get_price_multiplier(town.get("name", ""), item))
	if demand <= 0.0:
		return _calculate_capacity_based_price(town, item, stock, base, event_mult)
	var reference_stock := demand * CONSUMPTION_REFERENCE_DAYS
	var stock_ratio := stock / maxf(reference_stock, 1.0)
	var price_multiplier: float = _get_consumption_price_multiplier(stock_ratio)
	return maxf(base * price_multiplier * event_mult, base * 0.25)

func _calculate_capacity_based_price(town: Dictionary, item: String, stock: float, base: float, event_mult: float) -> float:
	var supply := float(eco.simulation.estimate_effective_daily_supply(town, item))
	var max_stock: float = maxf(float(eco.simulation.get_stock_cap(town, item)), 1.0)
	var pressure := -supply / max_stock
	var scarcity := stock / max_stock
	return maxf(base * (1.0 + clamp(pressure - scarcity, -0.7, 3.0) * 1.4) * event_mult, base * 0.25)

func _get_consumption_price_multiplier(stock_ratio: float) -> float:
	if stock_ratio <= 0.0:
		return 3.0
	if stock_ratio <= 0.5:
		return lerpf(3.0, 1.8, stock_ratio / 0.5)
	if stock_ratio <= 1.0:
		return lerpf(1.8, 1.0, (stock_ratio - 0.5) / 0.5)
	if stock_ratio <= 2.0:
		return lerpf(1.0, 0.6, stock_ratio - 1.0)
	if stock_ratio <= 3.0:
		return lerpf(0.6, 0.35, stock_ratio - 2.0)
	return 0.35

func get_price(town_name: String, item: String) -> float:
	return eco.towns.get(town_name, {}).get("prices", {}).get(item, (eco.BASE_PRICES[item] if eco.BASE_PRICES.has(item) else 0.0))

func get_buy_quote_total(town_name: String, item: String, qty: int) -> float:
	if qty <= 0:
		return 0.0
	var town = eco.towns.get(town_name, {})
	if town.is_empty():
		return 0.0
	var current_stock := int(town["inventory"].get(item, 0))
	if current_stock < qty:
		return 0.0
	return _get_marginal_total(town, item, current_stock, qty, -1, true)

func get_sell_quote_total(town_name: String, item: String, qty: int) -> float:
	if qty <= 0:
		return 0.0
	var town = eco.towns.get(town_name, {})
	if town.is_empty():
		return 0.0
	var current_stock := int(town["inventory"].get(item, 0))
	var cap: int = int(eco.simulation.get_stock_cap(town, item))
	if current_stock + qty > cap:
		return 0.0
	return _get_marginal_total(town, item, current_stock, qty, 1, false)

func get_buy_quote_average(town_name: String, item: String, qty: int) -> float:
	if qty <= 0:
		return 0.0
	return get_buy_quote_total(town_name, item, qty) / float(qty)

func get_sell_quote_average(town_name: String, item: String, qty: int) -> float:
	if qty <= 0:
		return 0.0
	return get_sell_quote_total(town_name, item, qty) / float(qty)

func _get_marginal_total(town: Dictionary, item: String, current_stock: int, qty: int, stock_delta: int, is_buy: bool) -> float:
	var total := 0.0
	for i in range(qty):
		var stock_after_unit := current_stock + (i * stock_delta)
		if is_buy:
			stock_after_unit -= 1
		stock_after_unit = maxi(stock_after_unit, 0)
		var mid_price: float = _calculate_price_for_stock(town, item, float(stock_after_unit))
		if is_buy:
			total += mid_price * _get_buy_multiplier(town)
		else:
			total += mid_price * _get_sell_multiplier(town)
	return total

func _get_buy_multiplier(town: Dictionary) -> float:
	var faction := str(town.get("faction", ""))
	var discount: float = float(eco._player.get_faction_rep(faction)) * REPUTATION_TRADE_MODIFIER
	return maxf(1.0 + BASE_BUY_SPREAD - discount, 0.75)

func _get_sell_multiplier(town: Dictionary) -> float:
	var faction := str(town.get("faction", ""))
	var rep_bonus: float = float(eco._player.get_faction_rep(faction)) * REPUTATION_TRADE_MODIFIER
	var prosperity_bonus: float = (float(eco.investment.get_prosperity_multiplier(str(town.get("name", "")))) - 1.0) * 0.30
	var raw_multiplier := 1.0 - BASE_SELL_SPREAD + rep_bonus + prosperity_bonus
	var max_no_arbitrage_multiplier: float = _get_buy_multiplier(town) - MIN_ROUND_TRIP_MARGIN
	return maxf(minf(raw_multiplier, max_no_arbitrage_multiplier), 0.50)

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
	
	var total_cost: float = get_buy_quote_total(town_name, item, qty)
	var effective_unit_cost := total_cost / float(qty)
	
	if not eco._player.remove_gold(total_cost):
		return false
	
	# Weighted average calculation
	var current_qty: int = int(eco._player.get_item_count(item))
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
	
	var total_earnings: float = get_sell_quote_total(town_name, item, qty)
	
	eco._player.add_gold(total_earnings)
	town["inventory"][item] = current_stock + qty
	recalculate_all_prices()
	return true
