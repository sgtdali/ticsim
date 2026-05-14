extends Node

# --- Money ---
var gold: float = 400.0

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

# -----------------------------------------------

func add_gold(amount: float) -> void:
	gold += amount

func remove_gold(amount: float) -> bool:
	if gold >= amount:
		gold -= amount
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
	current_day += 1

# --- Caravan Upgrade ---

const UPGRADE_NAMES := ["Donkey Cart", "Horse Cart", "Small Caravan"]
const UPGRADE_CAPACITIES := [20, 35, 50]
const UPGRADE_COSTS := [0, 300, 800]  # index 0 = başlangıç, ücretsiz

func get_upgrade_name() -> String:
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
	return UPGRADE_COSTS[next]

func can_upgrade_caravan() -> bool:
	if not get_node("/root/RankManager").can_upgrade_caravan():
		return false
	var cost := get_next_upgrade_cost()
	if cost < 0:
		return false
	return gold >= float(cost)

func upgrade_caravan() -> bool:
	if not can_upgrade_caravan():
		return false
	var cost := get_next_upgrade_cost()
	if not remove_gold(float(cost)):
		return false
	caravan_upgrade_level += 1
	caravan_capacity = UPGRADE_CAPACITIES[clamp(caravan_upgrade_level, 0, UPGRADE_CAPACITIES.size() - 1)]
	return true
