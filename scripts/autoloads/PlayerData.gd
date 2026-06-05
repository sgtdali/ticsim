extends Node

# --- Money ---
var gold: float = 400.0
var debt: float = 0.0
var debt_days: int = 0
var finance_today: Dictionary = {
	"income": 0.0,
	"expenses": 0.0,
	"debt_paid": 0.0,
	"upkeep_paid": 0.0,
	"upkeep_unpaid": 0.0,
}
var finance_yesterday: Dictionary = {
	"income": 0.0,
	"expenses": 0.0,
	"debt_paid": 0.0,
	"upkeep_paid": 0.0,
	"upkeep_unpaid": 0.0,
}

const DEBT_REP_PENALTY_DAYS := 14
const DEBT_REP_GAIN_MULTIPLIER := 0.75

var CARAVAN_UPKEEP: Array[float] = []
var UPGRADE_NAMES: Array[String] = []
var UPGRADE_CAPACITIES: Array[int] = []
var UPGRADE_COSTS: Array[float] = []

const TRADING_POST_UPKEEP := 8.0

# --- Inventory ---
# { "item_name": quantity }
var inventory: Dictionary = {}

# { "item_name": average_purchase_price }
var purchase_prices: Dictionary = {}

# --- Caravan ---
var caravan_capacity: int = 20
var caravan_upgrade_level: int = 0  # 0=donkey, 1=cart, 2=large_caravan

# --- Current location ---
var current_town: String = ""

# --- Faction reputation ---
# { "faction_name": value (-100 to +100) }
var faction_reputation: Dictionary = {}

# --- NPC relations ---
# { "npc_id": value (-100 to +100) }
var npc_relations: Dictionary = {}

# --- Owned shops ---
# [ { "town": "...", "type": "...", "level": 1, "workers": [] } ]
var owned_shops: Array = []

# --- Time ---
var current_day: int = 1

func _ready() -> void:
	_load_caravan_upgrades()

func _load_caravan_upgrades() -> void:
	UPGRADE_NAMES.clear()
	UPGRADE_CAPACITIES.clear()
	UPGRADE_COSTS.clear()
	CARAVAN_UPKEEP.clear()
	
	var rows = CSVLoader.load_csv("res://data/balance/caravan_upgrades.csv")
	rows.sort_custom(func(a, b): return CSVLoader.parse_int(a["level"]) < CSVLoader.parse_int(b["level"]))
	
	for row in rows:
		UPGRADE_NAMES.append(row["name"])
		UPGRADE_CAPACITIES.append(CSVLoader.parse_int(row["capacity"]))
		UPGRADE_COSTS.append(CSVLoader.parse_float(row["cost"]))
		CARAVAN_UPKEEP.append(CSVLoader.parse_float(row["daily_upkeep"]))

# -----------------------------------------------

func add_gold(amount: float) -> void:
	if amount <= 0.0:
		return
	var gross_amount := amount
	if debt > 0.0:
		var debt_payment: float = minf(amount, debt)
		debt -= debt_payment
		amount -= debt_payment
		finance_today["debt_paid"] = float(finance_today["debt_paid"]) + debt_payment
		if debt <= 0.0:
			debt = 0.0
			debt_days = 0
	gold += amount
	finance_today["income"] = float(finance_today["income"]) + gross_amount

func remove_gold(amount: float) -> bool:
	if gold >= amount:
		gold -= amount
		finance_today["expenses"] = float(finance_today["expenses"]) + amount
		return true
	return false

func add_item(item: String, qty: int) -> void:
	if inventory.has(item):
		inventory[item] += qty
	else:
		inventory[item] = qty

func remove_item(item: String, qty: int) -> bool:
	if inventory.get(item, 0) >= qty:
		inventory[item] -= qty
		if inventory[item] == 0:
			inventory.erase(item)
		return true
	return false

func get_item_count(item: String) -> int:
	return inventory.get(item, 0)

func get_total_cargo() -> int:
	var total = 0
	for qty in inventory.values():
		total += qty
	return total

func get_free_capacity() -> int:
	return caravan_capacity - get_total_cargo()

func change_faction_rep(faction: String, amount: float) -> void:
	if amount > 0.0 and debt_days >= DEBT_REP_PENALTY_DAYS:
		amount *= DEBT_REP_GAIN_MULTIPLIER
	var current = faction_reputation.get(faction, 0.0)
	faction_reputation[faction] = clamp(current + amount, -100.0, 100.0)

func get_faction_rep(faction: String) -> float:
	return faction_reputation.get(faction, 0.0)

func change_npc_relation(npc_id: String, amount: float) -> void:
	var current = npc_relations.get(npc_id, 0.0)
	npc_relations[npc_id] = clamp(current + amount, -100.0, 100.0)

func get_npc_relation(npc_id: String) -> float:
	return npc_relations.get(npc_id, 0.0)

func advance_day() -> void:
	finance_yesterday = finance_today.duplicate()
	finance_today = _make_empty_finance_bucket()
	current_day += 1
	_pay_daily_upkeep()

func has_debt() -> bool:
	return debt > 0.0

func get_daily_upkeep() -> float:
	var upkeep: float = _get_caravan_upkeep() + _get_rank_upkeep() + _get_trading_post_upkeep()
	var master_manager: Node = get_node_or_null("/root/CaravanMasterManager")
	var master_wages: float = 0.0
	if master_manager != null:
		master_wages = float(master_manager.get_total_daily_wage())
	return upkeep + master_wages

func get_finance_summary() -> Dictionary:
	var rank_name := "Peddler"
	var rank_manager: Node = get_node_or_null("/root/RankManager")
	if rank_manager != null and rank_manager.has_method("get_current_rank"):
		rank_name = str(rank_manager.call("get_current_rank"))
	var master_manager: Node = get_node_or_null("/root/CaravanMasterManager")
	var master_wages: float = 0.0
	if master_manager != null:
		master_wages = float(master_manager.get_total_daily_wage())
	return {
		"gold": gold,
		"debt": debt,
		"debt_days": debt_days,
		"today": finance_today.duplicate(),
		"yesterday": finance_yesterday.duplicate(),
		"daily_upkeep": get_daily_upkeep(),
		"caravan_upkeep": _get_caravan_upkeep(),
		"rank_upkeep": _get_rank_upkeep(),
		"rank": rank_name,
		"trading_post_upkeep": _get_trading_post_upkeep(),
		"active_posts": _get_active_post_count(),
		"master_wages": master_wages,
	}

func should_stop_trading_post_auto_trade() -> bool:
	return false

func _pay_daily_upkeep() -> void:
	var upkeep: float = get_daily_upkeep()
	if upkeep <= 0.0:
		if debt <= 0.0:
			debt_days = 0
		return

	if gold >= upkeep:
		gold -= upkeep
		finance_today["upkeep_paid"] = float(finance_today["upkeep_paid"]) + upkeep
		finance_today["expenses"] = float(finance_today["expenses"]) + upkeep
	else:
		var unpaid: float = upkeep - gold
		if gold > 0.0:
			finance_today["upkeep_paid"] = float(finance_today["upkeep_paid"]) + gold
			finance_today["expenses"] = float(finance_today["expenses"]) + gold
		gold = 0.0
		debt += unpaid
		finance_today["upkeep_unpaid"] = float(finance_today["upkeep_unpaid"]) + unpaid

	if debt > 0.0:
		debt_days += 1
		_apply_debt_duration_penalties()
	else:
		debt_days = 0

func _apply_debt_duration_penalties() -> void:
	if debt_days >= 60:
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func _get_caravan_upkeep() -> float:
	var idx := clampi(caravan_upgrade_level, 0, CARAVAN_UPKEEP.size() - 1)
	return float(CARAVAN_UPKEEP[idx])

func _get_rank_upkeep() -> float:
	var rank_manager: Node = get_node_or_null("/root/RankManager")
	if rank_manager != null and rank_manager.has_method("get_current_upkeep"):
		return float(rank_manager.get_current_upkeep())
	return 0.0

func _get_trading_post_upkeep() -> float:
	return float(_get_active_post_count()) * TRADING_POST_UPKEEP

func _get_active_post_count() -> int:
	var posts: Node = get_node_or_null("/root/TradingPostManager")
	if posts != null and posts.has_method("get_active_post_count"):
		return int(posts.call("get_active_post_count"))
	return 0

func _make_empty_finance_bucket() -> Dictionary:
	return {
		"income": 0.0,
		"expenses": 0.0,
		"debt_paid": 0.0,
		"upkeep_paid": 0.0,
		"upkeep_unpaid": 0.0,
	}

# --- Caravan Upgrade ---

func get_upgrade_name() -> String:
	if UPGRADE_NAMES.size() == 0:
		return "Donkey Cart"
	return UPGRADE_NAMES[clamp(caravan_upgrade_level, 0, UPGRADE_NAMES.size() - 1)]

func get_next_upgrade_name() -> String:
	var next := caravan_upgrade_level + 1
	if next >= UPGRADE_NAMES.size():
		return ""
	return UPGRADE_NAMES[next]

func get_next_upgrade_cost() -> int:
	var next := caravan_upgrade_level + 1
	if next >= UPGRADE_COSTS.size():
		return -1  # max level
	return int(UPGRADE_COSTS[next])

func can_upgrade_caravan() -> bool:
	if has_debt():
		return false
	if not get_node("/root/RankManager").can_upgrade_caravan():
		return false
	var cost: int = get_next_upgrade_cost()
	if cost < 0:
		return false
	return gold >= float(cost)

func upgrade_caravan() -> bool:
	if not can_upgrade_caravan():
		return false
	var cost: int = get_next_upgrade_cost()
	if not remove_gold(float(cost)):
		return false
	caravan_upgrade_level += 1
	caravan_capacity = UPGRADE_CAPACITIES[clamp(caravan_upgrade_level, 0, UPGRADE_CAPACITIES.size() - 1)]
	return true
