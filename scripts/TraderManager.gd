extends Node

# --- Tüccar tipleri ---
const TYPE_AGGRESSIVE := "aggressive"   # En yüksek fiyat farkı, riski umursamaz
const TYPE_CAREFUL    := "careful"      # Güvenli rotalar, yavaş ama istikrarlı
const TYPE_SPECIALIST := "specialist"   # Sadece production_input kategorisi

# --- Sabitler ---
const TRADER_CARGO_CAPACITY  := 15      # Her tüccarın cargo kapasitesi
const TRAVEL_SPEED_DAYS      := 1       # Şehirler arası seyahat (gün olarak, _calc ile hesaplanır)
const TRADE_PROFIT_THRESHOLD := 0.15   # En az %15 fiyat farkı olmadan almaz
const CAREFUL_MAX_RISK       := 0.15   # Temkinli tüccar max risk toleransı

# Tüccarlar: { id: { ...data } }
var traders: Dictionary = {}

signal trader_moved(trader_id: String, from_town: String, to_town: String)
signal trader_traded(trader_id: String, town_name: String, action: String, item: String, qty: int)

var _economy: Node
var _risk: Node
var _player: Node

# -----------------------------------------------

func _ready() -> void:
	randomize()
	_economy = get_node("/root/EconomyManager")
	_risk    = get_node("/root/TravelRiskManager")
	_player  = get_node("/root/PlayerData")

	if _economy.has_signal("economy_updated"):
		_economy.connect("economy_updated", _on_economy_updated)

	_init_traders()

func _init_traders() -> void:
	traders = {
		"aldric": {
			"id": "aldric",
			"name": "Aldric",
			"type": TYPE_AGGRESSIVE,
			"current_town": "Ashford",
			"destination": "",
			"days_traveling": 0,
			"travel_total_days": 0,
			"inventory": {},
			"gold": 150.0,
			"cargo_capacity": TRADER_CARGO_CAPACITY,
		},
		"mira": {
			"id": "mira",
			"name": "Mira",
			"type": TYPE_CAREFUL,
			"current_town": "Ironmere",
			"destination": "",
			"days_traveling": 0,
			"travel_total_days": 0,
			"inventory": {},
			"gold": 120.0,
			"cargo_capacity": TRADER_CARGO_CAPACITY,
		},
		"torben": {
			"id": "torben",
			"name": "Torben",
			"type": TYPE_SPECIALIST,
			"current_town": "Stonebridge",
			"destination": "",
			"days_traveling": 0,
			"travel_total_days": 0,
			"inventory": {},
			"gold": 100.0,
			"cargo_capacity": TRADER_CARGO_CAPACITY,
		},
	}

# --- Public API ---

func get_trader(trader_id: String) -> Dictionary:
	return traders.get(trader_id, {})

func is_traveling(trader_id: String) -> bool:
	var t := get_trader(trader_id)
	return str(t.get("destination", "")) != ""

func get_trader_location(trader_id: String) -> String:
	var t := get_trader(trader_id)
	if is_traveling(trader_id):
		return "→ %s" % str(t.get("destination", ""))
	return str(t.get("current_town", ""))

func get_total_cargo(trader_id: String) -> int:
	var t := get_trader(trader_id)
	var total := 0
	for qty in t.get("inventory", {}).values():
		total += int(qty)
	return total

# --- Economy tick ---

func _on_economy_updated() -> void:
	for trader_id in traders:
		_tick_trader(trader_id)

func _tick_trader(trader_id: String) -> void:
	var t: Dictionary = traders[trader_id]

	# Seyahatteyse ilerle
	if str(t.get("destination", "")) != "":
		t["days_traveling"] = int(t["days_traveling"]) + 1
		if int(t["days_traveling"]) >= int(t["travel_total_days"]):
			_arrive_trader(trader_id)
		return

	# Şehirdeyse: önce sat, sonra al, sonra karar ver
	_trader_sell(trader_id)
	_trader_buy(trader_id)
	_trader_decide_destination(trader_id)

func _arrive_trader(trader_id: String) -> void:
	var t: Dictionary = traders[trader_id]
	var destination: String = str(t.get("destination", ""))
	var from_town: String = str(t.get("current_town", ""))
	t["current_town"] = destination
	t["destination"] = ""
	t["days_traveling"] = 0
	t["travel_total_days"] = 0
	emit_signal("trader_moved", trader_id, from_town, destination)

# --- Ticaret ---

func _trader_sell(trader_id: String) -> void:
	var t: Dictionary = traders[trader_id]
	var town_name: String = str(t.get("current_town", ""))
	var inventory_copy: Dictionary = t.get("inventory", {}).duplicate()

	for item in inventory_copy:
		var qty: int = int(inventory_copy[item])
		if qty <= 0:
			continue
		var base: float = float(_economy.BASE_PRICES.get(item, 0.0))
		var current: float = float(_economy.get_price(town_name, item))
		if base <= 0.0:
			continue
		# Sadece kârlıysa sat
		if current >= base * (1.0 + TRADE_PROFIT_THRESHOLD):
			var free_space: int = int(_economy.get_town_free_stock(town_name, item))
			var sell_qty: int = mini(qty, free_space)
			if sell_qty <= 0:
				continue
			t["inventory"][item] = qty - sell_qty
			if int(t["inventory"][item]) <= 0:
				t["inventory"].erase(item)
			var earned: float = current * float(sell_qty)
			t["gold"] = float(t.get("gold", 0.0)) + earned
			_economy.add_town_stock(town_name, item, sell_qty, true)
			emit_signal("trader_traded", trader_id, town_name, "sell", item, sell_qty)

func _trader_buy(trader_id: String) -> void:
	var t: Dictionary = traders[trader_id]
	var town_name: String = str(t.get("current_town", ""))
	var free_capacity: int = int(t.get("cargo_capacity", TRADER_CARGO_CAPACITY)) - get_total_cargo(str(t.get("id", "")))
	if free_capacity <= 0:
		return

	# Tüccar tipine göre hangi malları alacağını belirle
	var candidates: Array = _get_buy_candidates(trader_id, town_name)
	if candidates.is_empty():
		return

	# En karlı malı al
	candidates.sort_custom(func(a, b): return float(a["ratio"]) < float(b["ratio"]))

	for candidate in candidates:
		if free_capacity <= 0:
			break
		var item: String = str(candidate["item"])
		var town_stock: int = int(_economy.get_town(town_name).get("inventory", {}).get(item, 0))
		var buy_qty: int = mini(mini(town_stock, free_capacity), 8)
		if buy_qty <= 0:
			continue
		var price: float = float(_economy.get_price(town_name, item)) * float(buy_qty)
		if float(t.get("gold", 0.0)) < price:
			continue
		# Stoktan düş
		var town = _economy.get_town(town_name)
		town["inventory"][item] = town_stock - buy_qty
		t["gold"] = float(t.get("gold", 0.0)) - price
		t["inventory"][item] = int(t.get("inventory", {}).get(item, 0)) + buy_qty
		free_capacity -= buy_qty
		emit_signal("trader_traded", trader_id, town_name, "buy", item, buy_qty)

func _get_buy_candidates(trader_id: String, town_name: String) -> Array:
	var t: Dictionary = traders[trader_id]
	var trader_type: String = str(t.get("type", ""))
	var candidates: Array = []

	for item in _economy.BASE_PRICES:
		var base: float = float(_economy.BASE_PRICES.get(item, 0.0))
		if base <= 0.0:
			continue
		# Specialist sadece production_input alır
		if trader_type == TYPE_SPECIALIST:
			if _economy.get_goods_category(item) != "production_input":
				continue
		var current: float = float(_economy.get_price(town_name, item))
		var ratio: float = (current - base) / base
		# Ucuz olan malı al (negatif ratio = ucuz)
		if ratio < -0.10:
			var stock: int = int(_economy.get_town(town_name).get("inventory", {}).get(item, 0))
			if stock > 0:
				candidates.append({"item": item, "ratio": ratio})

	return candidates

# --- Destinasyon kararı ---

func _trader_decide_destination(trader_id: String) -> void:
	var t: Dictionary = traders[trader_id]
	var current_town: String = str(t.get("current_town", ""))
	var trader_type: String = str(t.get("type", ""))
	var best_town: String = ""
	var best_score: float = -999.0

	for town_name in _economy.towns.keys():
		if town_name == current_town:
			continue

		# Temkinli tüccar risk kontrolü
		if trader_type == TYPE_CAREFUL:
			var risk: float = float(_risk.calculate_attack_chance(town_name))
			if risk > CAREFUL_MAX_RISK:
				continue

		var score: float = _score_destination(trader_id, town_name)
		if score > best_score:
			best_score = score
			best_town = town_name

	if best_town == "" or best_score <= 0.0:
		return

	# Yola çık
	t["destination"] = best_town
	t["days_traveling"] = 0
	t["travel_total_days"] = _calc_travel_days(current_town, best_town)

func _score_destination(trader_id: String, town_name: String) -> float:
	var t: Dictionary = traders[trader_id]
	var trader_type: String = str(t.get("type", ""))
	var score: float = 0.0

	# Taşıdığı malların bu şehirde kaç para edeceğine bak
	for item in t.get("inventory", {}):
		var qty: int = int(t["inventory"][item])
		if qty <= 0:
			continue
		if trader_type == TYPE_SPECIALIST:
			if _economy.get_goods_category(item) != "production_input":
				continue
		var base: float = float(_economy.BASE_PRICES.get(item, 0.0))
		var current: float = float(_economy.get_price(town_name, item))
		if base > 0.0:
			score += (current - base) / base * float(qty)

	return score

func _calc_travel_days(from_town: String, to_town: String) -> int:
	var from_pos: Vector2 = _economy.get_town(from_town).get("position", Vector2.ZERO)
	var to_pos: Vector2   = _economy.get_town(to_town).get("position", Vector2.ZERO)
	return maxi(1, int(from_pos.distance_to(to_pos) / 200.0))
