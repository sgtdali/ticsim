extends Node

# Olay tipleri sabit listesi.
const EVENT_FESTIVAL := "festival"
const EVENT_FAMINE := "famine"
const EVENT_DEMAND_SURGE := "demand_surge"
const EVENT_BUMPER_CROP := "bumper_crop"
const EVENT_PLAGUE := "plague"

# Her olayın metadata'sı: gösterim adı, ikon harfi, açıklama, varsayılan süre.
const EVENT_DATA: Dictionary = {
	EVENT_FESTIVAL: {
		"name": "Festival",
		"icon": "*",
		"description": "Citizens celebrate. Comfort goods are in high demand.",
		"duration": 12,
		"color": Color(1.0, 0.85, 0.4),
	},
	EVENT_FAMINE: {
		"name": "Famine",
		"icon": "!",
		"description": "Food is scarce. Survival goods cost a fortune.",
		"duration": 16,
		"color": Color(1.0, 0.4, 0.3),
	},
	EVENT_DEMAND_SURGE: {
		"name": "Demand Surge",
		"icon": "+",
		"description": "Sudden demand for a specific good drives prices up.",
		"duration": 12,
		"color": Color(0.4, 0.9, 1.0),
	},
	EVENT_BUMPER_CROP: {
		"name": "Bumper Crop",
		"icon": "v",
		"description": "Local production is unusually high. Prices are low.",
		"duration": 14,
		"color": Color(0.5, 1.0, 0.5),
	},
	EVENT_PLAGUE: {
		"name": "Plague",
		"icon": "x",
		"description": "Disease has struck. Production and demand crash.",
		"duration": 18,
		"color": Color(0.7, 0.4, 0.9),
	},
}

# Her olay tipi için ekonomi çarpanları.
# price_multiplier: o şehirdeki fiyatları çarpar (satın alma + satış)
# production_multiplier: üretim miktarını çarpar
# consumption_multiplier: tüketim miktarını çarpar
# affected_category: hangi mal kategorisini etkiler (boşsa hepsini)
# demand_surge_multiplier: sadece demand_surge için o malın özel çarpanı
const EVENT_MODIFIERS: Dictionary = {
	EVENT_FESTIVAL: {
		"price_multiplier": 1.6,
		"production_multiplier": 1.0,
		"consumption_multiplier": 2.0,
		"affected_category": "comfort",   # wine, sword, grapes
	},
	EVENT_FAMINE: {
		"price_multiplier": 3.0,
		"production_multiplier": 0.3,
		"consumption_multiplier": 1.5,
		"affected_category": "survival",  # wheat, bread
	},
	EVENT_DEMAND_SURGE: {
		"price_multiplier": 2.5,
		"production_multiplier": 1.0,
		"consumption_multiplier": 3.0,
		"affected_category": "",          # payload["item"] ile belirlenir
	},
	EVENT_BUMPER_CROP: {
		"price_multiplier": 0.5,
		"production_multiplier": 2.5,
		"consumption_multiplier": 1.0,
		"affected_category": "",          # payload["item"] ile belirlenir
	},
	EVENT_PLAGUE: {
		"price_multiplier": 1.2,
		"production_multiplier": 0.4,
		"consumption_multiplier": 0.4,
		"affected_category": "",          # hepsini etkiler
	},
}

# Bir şehirde olay çıkma şansı (gün başına).
const EVENT_CHANCE_PER_DAY := 0.04
const MIN_DAYS_BETWEEN_EVENTS := 8

# Aktif olaylar: { town_name: {type, started_day, ends_day, payload} }
# payload bazı olaylar için ekstra veri tutar (ör. demand_surge → hangi mal).
var active_events: Dictionary = {}

# Şehir başına son olay bittiği gün — cooldown takibi için.
var _last_event_end_day: Dictionary = {}

signal event_started(town_name: String, event: Dictionary)
signal event_ended(town_name: String, event: Dictionary)

var _economy: Node
var _player: Node

# -----------------------------------------------

func _ready() -> void:
	randomize()
	_economy = get_node("/root/EconomyManager")
	_player = get_node("/root/PlayerData")

	if _economy.has_signal("economy_updated"):
		_economy.connect("economy_updated", _on_economy_updated)

# Şehirde aktif olay var mı?
func has_event(town_name: String) -> bool:
	return active_events.has(town_name)

# Şehirdeki aktif olayı döndürür (yoksa boş).
func get_event(town_name: String) -> Dictionary:
	return active_events.get(town_name, {})

# Olay metadata'sını döndürür (icon, color, description).
func get_event_data(event_type: String) -> Dictionary:
	return EVENT_DATA.get(event_type, {})

# Her gün economy_updated tetiklenince çalışır:
# - Aktif olayları bitir (süresi dolmuşsa)
# - Yeni olay tetikle (rastgele şehirde, şartları sağlıyorsa)
func _on_economy_updated() -> void:
	var current_day: int = int(_economy.current_day)
	_expire_events(current_day)
	_try_trigger_new_events(current_day)

func _expire_events(current_day: int) -> void:
	var to_remove: Array = []
	for town_name in active_events:
		var event: Dictionary = active_events[town_name]
		if current_day >= int(event.get("ends_day", 0)):
			to_remove.append(town_name)

	for town_name in to_remove:
		var ended_event: Dictionary = active_events[town_name]
		active_events.erase(town_name)
		_last_event_end_day[town_name] = current_day
		emit_signal("event_ended", town_name, ended_event)

func _try_trigger_new_events(current_day: int) -> void:
	for town_name in _economy.towns.keys():
		# Zaten olay varsa atla
		if active_events.has(town_name):
			continue
		# Cooldown'da mı?
		var last_end: int = int(_last_event_end_day.get(town_name, -999))
		if current_day - last_end < MIN_DAYS_BETWEEN_EVENTS:
			continue
		# Şans kontrol
		if randf() >= EVENT_CHANCE_PER_DAY:
			continue

		_start_random_event(town_name, current_day)

func _start_random_event(town_name: String, current_day: int) -> void:
	var event_type: String = _pick_event_type(town_name)
	var event_meta: Dictionary = EVENT_DATA[event_type]
	var payload: Dictionary = _build_event_payload(event_type, town_name)

	var event: Dictionary = {
		"type": event_type,
		"name": event_meta["name"],
		"description": event_meta["description"],
		"icon": event_meta["icon"],
		"color": event_meta["color"],
		"started_day": current_day,
		"ends_day": current_day + int(event_meta["duration"]),
		"payload": payload,
	}
	active_events[town_name] = event
	emit_signal("event_started", town_name, event)
	print("[Event] %s in %s (until day %d)" % [event["name"], town_name, event["ends_day"]])

# Olay tipini rastgele seç. Bazı olaylar belirli şehir tiplerinde daha mantıklı
# ama şu anlık tamamen random.
func _pick_event_type(_town_name: String) -> String:
	var types: Array = EVENT_DATA.keys()
	return String(types[randi() % types.size()])

# Bazı olaylar ekstra veri ister (demand_surge: hangi mal? bumper_crop: hangi mal?).
func _build_event_payload(event_type: String, town_name: String) -> Dictionary:
	var payload: Dictionary = {}
	var town: Dictionary = _economy.get_town(town_name)

	match event_type:
		EVENT_DEMAND_SURGE:
			# Şehrin tükettiği bir mal seç
			var consumes: Array = town.get("consumption_rules", {}).keys()
			if consumes.is_empty():
				consumes = _economy.BASE_PRICES.keys()
			payload["item"] = String(consumes[randi() % consumes.size()])
		EVENT_BUMPER_CROP:
			# Şehrin ürettiği bir mal seç
			var produces: Array = town.get("production_plan", {}).keys()
			if produces.is_empty():
				produces = ["wheat"]
			payload["item"] = String(produces[randi() % produces.size()])

	return payload

# Belirli bir şehir + mal için fiyat çarpanını döndürür.
func get_price_multiplier(town_name: String, item: String) -> float:
	var event: Dictionary = get_event(town_name)
	if event.is_empty():
		return 1.0
	return _get_multiplier(event, item, "price_multiplier")

# Belirli bir şehir + mal için üretim çarpanını döndürür.
func get_production_multiplier(town_name: String, item: String) -> float:
	var event: Dictionary = get_event(town_name)
	if event.is_empty():
		return 1.0
	return _get_multiplier(event, item, "production_multiplier")

# Belirli bir şehir + mal için tüketim çarpanını döndürür.
func get_consumption_multiplier(town_name: String, item: String) -> float:
	var event: Dictionary = get_event(town_name)
	if event.is_empty():
		return 1.0
	return _get_multiplier(event, item, "consumption_multiplier")

# İç yardımcı: olay + mal + çarpan tipi → float
func _get_multiplier(event: Dictionary, item: String, multiplier_key: String) -> float:
	var event_type: String = str(event.get("type", ""))
	var modifiers: Dictionary = EVENT_MODIFIERS.get(event_type, {})
	if modifiers.is_empty():
		return 1.0

	var affected_category: String = str(modifiers.get("affected_category", ""))
	var payload: Dictionary = event.get("payload", {})
	var payload_item: String = str(payload.get("item", ""))

	# Hangi mallar etkileniyor?
	var item_affected: bool = false
	if affected_category == "":
		# Payload'da item varsa (demand_surge, bumper_crop) sadece o mal
		if payload_item != "":
			item_affected = (item == payload_item)
		else:
			# Plague gibi: hepsini etkiler
			item_affected = true
	else:
		# Belirli kategori (comfort, survival)
		var item_category: String = _economy.get_goods_category(item)
		item_affected = (item_category == affected_category)

	if not item_affected:
		return 1.0

	return float(modifiers.get(multiplier_key, 1.0))
