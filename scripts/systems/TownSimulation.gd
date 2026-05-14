extends RefCounted
class_name TownSimulation

var eco: Node

func _init(_eco: Node) -> void:
	eco = _eco

func advance_day() -> void:
	eco.current_day += 1
	process_town_production_phase()
	process_town_consumption_phase()
	process_population_phase()
	eco.market.recalculate_all_prices()
	eco.investment.daily_prosperity_earned.clear()

func process_town_production_phase() -> void:
	for town_name in eco.towns:
		process_town_production(eco.towns[town_name])

func process_town_consumption_phase() -> void:
	for town_name in eco.towns:
		process_town_consumption(eco.towns[town_name])

func process_population_phase() -> void:
	for town_name in eco.towns:
		process_population_change(eco.towns[town_name])

func get_season() -> String:
	var idx = int(((eco.current_day - 1) / 30) % 4)
	return ["spring", "summer", "autumn", "winter"][idx]

func get_season_multiplier(item: String) -> float:
	return eco.SEASON_MULTIPLIERS.get(get_season(), {}).get(item, 1.0)

func get_upgrade_level(upgrades: Dictionary, item: String) -> int:
	return int(clamp(upgrades.get(item, 0), 0, eco.MAX_UPGRADE_LEVEL))

func get_upgrade_cost(item: String, level: int, stock_upgrade := false) -> int:
	var base_key = "stock_cap_base_cost" if stock_upgrade else "production_base_cost"
	var base_cost = 0
	if eco.items_data.has(item):
		base_cost = int(eco.items_data[item].get(base_key))
	return int(base_cost * pow(2, level))

func calculate_effective_output(base_output: float, season_multiplier: float, efficiency: float, upgrade_level: int) -> float:
	var upgrade_multiplier = 1.0 + (eco.BASE_UPGRADE_MULTIPLIER * upgrade_level)
	return base_output * season_multiplier * efficiency * upgrade_multiplier

func calculate_input_efficiency(town: Dictionary, item: String, planned_batches: float) -> Dictionary:
	if not eco.items_data.has(item) or eco.items_data[item].recipe_inputs.is_empty():
		return {"efficiency": 1.0, "critical": false, "consume_ratio": 1.0}
	var recipe_inputs: Dictionary = eco.items_data[item].recipe_inputs
	var ratio := 1.0
	for input_item in recipe_inputs:
		var required_total = float(recipe_inputs[input_item]) * planned_batches
		if required_total <= 0.0:
			continue
		var in_stock = float(town["inventory"].get(input_item, 0))
		ratio = min(ratio, in_stock / required_total)
	ratio = clamp(ratio, 0.0, 1.0)
	return {"efficiency": ratio, "critical": ratio <= eco.INPUT_CRITICAL_THRESHOLD, "consume_ratio": ratio}

func get_stock_cap(town: Dictionary, item: String) -> int:
	var base_cap = (eco.items_data[item].stock_cap if eco.items_data.has(item) else 100)
	var upgrade_level = get_upgrade_level(town.get("stock_cap_upgrades", {}), item)
	return int(round(base_cap * (1.0 + (eco.BASE_UPGRADE_MULTIPLIER * upgrade_level))))

func estimate_effective_daily_supply(town: Dictionary, item: String) -> float:
	var planned_output := float(town.get("production_plan", {}).get(item, 0))
	if planned_output <= 0.0:
		return 0.0

	var interval := maxi(eco.items_data[item].production_interval_days if eco.items_data.has(item) else 1, 1)
	var input_state := calculate_input_efficiency(town, item, planned_output)
	var upgrade_level := get_upgrade_level(town.get("production_upgrades", {}), item)
	var effective_output := calculate_effective_output(
		planned_output,
		get_season_multiplier(item),
		input_state["efficiency"],
		upgrade_level
	)
	return effective_output / float(interval)

func estimate_daily_consumption(town: Dictionary, item: String) -> int:
	var per_capita = float(town.get("consumption_rules", {}).get(item, 0.0))
	var multiplier = eco.investment.get_prosperity_multiplier(town.get("name", ""))
	var event_mult: float = 1.0
	if eco._events != null:
		event_mult = float(eco._events.get_consumption_multiplier(town.get("name", ""), item))
	return int(round(town.get("population", 0) * per_capita * multiplier * event_mult))

func process_town_production(town: Dictionary) -> void:
	var report = {
		"season": get_season(),
		"base_production": {},
		"final_production": {},
		"missing_input_efficiency": {},
		"stock_blocked": {},
		"critical_consumption_issues": [],
	}
	for item in town.get("production_plan", {}):
		var interval = (eco.items_data[item].production_interval_days if eco.items_data.has(item) else 1)
		if interval <= 0 or eco.current_day % interval != 0:
			continue
		var base_output = float(town["production_plan"][item])
		report["base_production"][item] = base_output
		var input_state = calculate_input_efficiency(town, item, base_output)
		var upgrade_level = get_upgrade_level(town.get("production_upgrades", {}), item)
		var final_output = calculate_effective_output(base_output, get_season_multiplier(item), input_state["efficiency"], upgrade_level)
		final_output *= eco.investment.get_prosperity_multiplier(town["name"])
		if eco._events != null:
			final_output *= float(eco._events.get_production_multiplier(town["name"], item))
		var stock_cap = get_stock_cap(town, item)
		var in_stock = int(town["inventory"].get(item, 0))
		var free_space = max(stock_cap - in_stock, 0)
		var actual = int(min(round(final_output), free_space))
		var blocked = max(int(round(final_output)) - actual, 0)
		town["inventory"][item] = in_stock + actual
		report["final_production"][item] = actual
		report["missing_input_efficiency"][item] = input_state["efficiency"]
		report["stock_blocked"][item] = blocked

		if eco.items_data.has(item) and not eco.items_data[item].recipe_inputs.is_empty():
			for input_item in eco.items_data[item].recipe_inputs:
				var needed = eco.items_data[item].recipe_inputs[input_item] * actual
				var current_stock = int(town["inventory"].get(input_item, 0))
				town["inventory"][input_item] = max(current_stock - needed, 0)
	town["report"] = report

func process_town_consumption(town: Dictionary) -> void:
	for item in town.get("consumption_rules", {}):
		var consume_amount = estimate_daily_consumption(town, item)
		if consume_amount <= 0:
			continue
		var current_stock = int(town["inventory"].get(item, 0))
		if current_stock < consume_amount:
			town["report"]["critical_consumption_issues"].append(item)
		town["inventory"][item] = max(current_stock - consume_amount, 0)

func process_population_change(town: Dictionary) -> void:
	var change := 0
	var has_critical_survival := false
	for item in town["report"].get("critical_consumption_issues", []):
		if eco.get_goods_category(item) == "survival":
			has_critical_survival = true
			break
			
	if has_critical_survival:
		change -= int(ceil(town["population"] * 0.03))
	elif town["inventory"].get("bread", 0) > 10 or town["inventory"].get("wheat", 0) > 20:
		change += int(ceil(town["population"] * 0.01))
		
	town["population"] = clamp(town["population"] + change, 10, town.get("population_cap", 200))

	var history: Array = town.get("population_history", [])
	history.append(int(town["population"]))
	if history.size() > 3:
		history = history.slice(history.size() - 3)
	town["population_history"] = history
