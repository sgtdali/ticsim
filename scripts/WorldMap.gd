extends Node2D

var _player_data: Node
var _economy: Node
var _contracts: Node
var _risk: Node
var _events: Node

var is_traveling: bool = false
var travel_destination: String = ""
var travel_days_remaining: int = 0
var travel_total_days: int = 0
var travel_start_pos: Vector2   # screen space
var travel_end_pos: Vector2     # screen space

var town_buttons: Dictionary = {}
var top_bar: Control
var _contracts_panel_open := true

var game_speed: int = 1
const DAY_INTERVAL: float = 3.0

const MAP_W: float = 1672.0
const MAP_H: float = 941.0
const TOWN_COORD_W: float = 2816.0
const TOWN_COORD_H: float = 1536.0
const DEFAULT_TOP_BAR_HEIGHT: float = 88.0

# City interaction radius in screen pixels
const CITY_R: float = 14.0

# Calculated once in _setup_view
var _map_scale: float  = 1.0
var _map_offset: Vector2 = Vector2.ZERO

var _day_timer: Timer

signal town_selected(town_name: String)

# -----------------------------------------------

func _ready() -> void:
	_player_data = get_node("/root/PlayerData")
	_economy     = get_node("/root/EconomyManager")
	_contracts   = get_node("/root/ContractManager")
	_risk        = get_node("/root/TravelRiskManager")
	_events = get_node_or_null("/root/EventManager")
	if _events:
		_events.connect("event_started", _on_event_changed)
		_events.connect("event_ended", _on_event_changed)
	_player_data.current_town = "Ashford"

	_setup_view()
	_bind_top_bar()
	_bind_contract_tracker()
	_place_player()
	_build_town_buttons()
	_setup_day_timer()
	_update_ui()

# Scale & position the map sprite to fill the viewport while keeping aspect ratio.
# WorldMap node itself stays at identity (position=0, scale=1).
# All other calculations use _map_to_screen() for explicit conversion.
func _setup_view() -> void:
	var vp: Vector2 = get_viewport_rect().size
	var top_bar_height := _get_top_bar_height()
	var map_area := Vector2(vp.x, max(1.0, vp.y - top_bar_height))
	_map_scale  = max(map_area.x / MAP_W, map_area.y / MAP_H)
	_map_offset = Vector2(0.0, top_bar_height) + (map_area - Vector2(MAP_W, MAP_H) * _map_scale) * 0.5

	var map_sprite = get_node_or_null("MapSprite")
	if map_sprite:
		map_sprite.scale    = Vector2(_map_scale, _map_scale)
		map_sprite.position = _map_offset
	var player = get_node_or_null("Player")
	if player:
		player.z_index = 3

func _get_top_bar_height() -> float:
	var bar := get_node_or_null("UI/TopBar") as Control
	if bar == null or not bar.visible:
		return DEFAULT_TOP_BAR_HEIGHT

	return maxf(
		maxf(bar.size.y, bar.custom_minimum_size.y),
		maxf(bar.get_combined_minimum_size().y, DEFAULT_TOP_BAR_HEIGHT)
	)

# Map (world) coordinate → screen coordinate
func _map_to_screen(map_pos: Vector2) -> Vector2:
	var texture_pos = Vector2(
		map_pos.x / TOWN_COORD_W * MAP_W,
		map_pos.y / TOWN_COORD_H * MAP_H
	)
	return _map_offset + texture_pos * _map_scale

func _setup_day_timer() -> void:
	_day_timer = Timer.new()
	_day_timer.wait_time = DAY_INTERVAL
	_day_timer.autostart = true
	_day_timer.timeout.connect(_on_day_tick)
	add_child(_day_timer)

func _bind_top_bar() -> void:
	var old_panel := get_node_or_null("UI/InfoPanel") as Control
	if old_panel:
		old_panel.visible = false

	var ui := get_node("UI")
	ui.layer = 10
	top_bar = get_node_or_null("UI/TopBar") as Control
	if top_bar and top_bar.has_signal("speed_changed"):
		top_bar.connect("speed_changed", _set_speed)

func _bind_contract_tracker() -> void:
	var toggle := get_node_or_null("UI/ContractsToggle") as Button
	if toggle:
		toggle.pressed.connect(_toggle_contract_tracker)
	if _contracts and _contracts.has_signal("contracts_changed"):
		_contracts.connect("contracts_changed", _update_contract_tracker)
	_update_contract_tracker()

func _set_speed(speed: int) -> void:
	game_speed = speed
	if speed == 0:
		_day_timer.paused = true
	else:
		_day_timer.paused = false
		_day_timer.wait_time = DAY_INTERVAL / float(speed)
	if top_bar and top_bar.has_method("set_speed"):
		top_bar.call("set_speed", game_speed)

# -----------------------------------------------

func _process(delta: float) -> void:
	queue_redraw()
	if not is_traveling or game_speed == 0:
		return
	var player = get_node("Player")
	var total_dist = travel_start_pos.distance_to(travel_end_pos)
	if total_dist < 1.0:
		return
	var speed_px = total_dist * float(game_speed) / (float(travel_total_days) * DAY_INTERVAL)
	player.position = player.position.move_toward(travel_end_pos, speed_px * delta)

func _on_day_tick() -> void:
	_economy.advance_day()
	_player_data.advance_day()
	if is_traveling:
		travel_days_remaining -= 1
		if travel_days_remaining <= 0:
			get_node("Player").position = travel_end_pos
			_arrive()
			return
	_update_ui()
	_refresh_buttons()

# -----------------------------------------------

func _build_town_buttons() -> void:
	for town_name in _economy.towns:
		var btn := get_node_or_null("TownButtons/%sBtn" % town_name) as Button
		if btn == null:
			continue
		btn.pressed.connect(_on_town_pressed.bind(town_name))
		town_buttons[town_name] = btn
	_refresh_buttons()

func _place_player() -> void:
	var map_pos: Vector2 = _economy.towns.get(_player_data.current_town, {}).get("position", Vector2.ZERO)
	get_node("Player").position = _map_to_screen(map_pos)

func _on_town_pressed(town_name: String) -> void:
	if is_traveling:
		return
	if town_name == _player_data.current_town:
		_open_town(town_name)
		return

	is_traveling = true
	travel_destination    = town_name
	travel_start_pos      = get_node("Player").position
	travel_end_pos        = _map_to_screen(_economy.towns[town_name].get("position", Vector2.ZERO))
	travel_total_days     = _calc_travel_days(town_name)
	travel_days_remaining = travel_total_days

	_refresh_buttons()
	_update_ui()

func _calc_travel_days(town_name: String) -> int:
	var from: Vector2 = _economy.towns[_player_data.current_town].get("position", Vector2.ZERO)
	var to: Vector2   = _economy.towns[town_name].get("position", Vector2.ZERO)
	return max(1, int(from.distance_to(to) / 200.0))

func _arrive() -> void:
	is_traveling = false
	var arrived_town: String = travel_destination
	_player_data.current_town = arrived_town
	travel_destination = ""
	travel_days_remaining = 0
	travel_total_days = 0
	_refresh_buttons()

	# Saldırı kontrolü - şehre vardığında değil, varış anında roll
	if _risk.roll_attack(arrived_town) and _player_data.get_total_cargo() > 0:
		var lost: Dictionary = _resolve_attack()
		_show_attack_popup(lost, arrived_town)
		return

	_update_ui()
	_open_town(arrived_town)

func _open_town(town_name: String) -> void:
	_day_timer.paused = true
	var town_ui = preload("res://scenes/TownUI.tscn").instantiate()
	town_ui.town_name = town_name
	get_node("UI").add_child(town_ui)
	town_ui.closed.connect(_on_town_ui_closed)

func _on_town_ui_closed() -> void:
	if game_speed > 0:
		_day_timer.paused = false
	_update_ui()
	_refresh_buttons()

func _refresh_buttons() -> void:
	for town_name in town_buttons:
		var btn: Button = town_buttons[town_name]
		if is_traveling:
			btn.modulate = Color(0.55, 0.55, 0.55)
			btn.text = town_name
			continue
		if town_name == _player_data.current_town:
			btn.modulate = Color(0.3, 1.0, 0.3)
			btn.text = town_name
			continue

		# Olay rozeti
		if _events != null and _events.has_event(town_name):
			var event: Dictionary = _events.get_event(town_name)
			var icon: String = str(event.get("icon", "?"))
			var event_color: Color = event.get("color", Color.WHITE)
			btn.text = "%s %s" % [icon, town_name]
			btn.modulate = event_color
			continue

		# Risk rengi (olay yoksa)
		var chance: float = 0.0
		if _risk != null:
			chance = _risk.calculate_attack_chance(town_name)
		if chance >= 0.30:
			btn.modulate = Color(1.0, 0.65, 0.55)
		elif chance >= 0.20:
			btn.modulate = Color(1.0, 0.85, 0.7)
		else:
			btn.modulate = Color(1.0, 1.0, 1.0)
		btn.text = town_name
	_update_risk_indicators()

func _update_ui() -> void:
	var day_lbl    = get_node_or_null("UI/InfoPanel/VBox/DayLabel")
	var gold_lbl   = get_node_or_null("UI/InfoPanel/VBox/GoldLabel")
	var loc_lbl    = get_node_or_null("UI/InfoPanel/VBox/LocationLabel")
	var travel_lbl = get_node_or_null("UI/InfoPanel/VBox/TravelLabel")

	if day_lbl:  day_lbl.text  = "Day: %d"      % _player_data.current_day
	if gold_lbl: gold_lbl.text = "Gold: %.1f"   % _player_data.gold
	if loc_lbl:  loc_lbl.text  = "Location: %s" % _player_data.current_town
	if travel_lbl:
		if is_traveling:
			travel_lbl.text = "→ %s (%d day(s))" % [travel_destination, travel_days_remaining]
		else:
			travel_lbl.text = ""
	if top_bar and top_bar.has_method("set_values"):
		var location: String = travel_destination if is_traveling else _player_data.current_town
		var travel_days: int = travel_days_remaining if is_traveling else 0
		top_bar.call(
			"set_values",
			_player_data.current_day,
			_player_data.gold,
			_player_data.get_total_cargo(),
			_player_data.caravan_capacity,
			location,
			travel_days
		)
	_update_contract_tracker()

func _toggle_contract_tracker() -> void:
	_contracts_panel_open = not _contracts_panel_open
	_update_contract_tracker()

func _update_contract_tracker() -> void:
	if _contracts == null:
		return

	var toggle := get_node_or_null("UI/ContractsToggle") as Button
	var panel := get_node_or_null("UI/ContractsPanel") as Control
	var list := get_node_or_null("UI/ContractsPanel/VBox/ScrollContainer/ContractList") as VBoxContainer
	if toggle == null or panel == null or list == null:
		return

	var active_contracts: Array = _contracts.get_active_contracts()
	var player_contracts: Array = _contracts.get_player_contracts()
	toggle.text = "Contracts (%d)" % active_contracts.size()
	panel.visible = _contracts_panel_open and not player_contracts.is_empty()

	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()

	if player_contracts.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No accepted contracts yet."
		list.add_child(empty_label)
		return

	for contract in player_contracts:
		_add_contract_tracker_row(list, contract)

func _add_contract_tracker_row(list: VBoxContainer, contract: Dictionary) -> void:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)

	var title := Label.new()
	title.text = "%s [%s]" % [contract.get("title", "Contract"), str(contract.get("status", "")).capitalize()]
	title.add_theme_color_override("font_color", _get_contract_status_color(str(contract.get("status", ""))))
	row.add_child(title)

	var detail := Label.new()
	detail.text = _format_contract_tracker_detail(contract)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(detail)

	list.add_child(row)
	list.add_child(HSeparator.new())

func _format_contract_tracker_detail(contract: Dictionary) -> String:
	var status: String = str(contract.get("status", ""))
	var item: String = str(contract.get("required_item", ""))
	var required: int = int(contract.get("required_quantity", 0))
	var held: int = int(_player_data.get_item_count(item))
	var target: String = str(contract.get("target_town", ""))
	var days_left: int = int(_contracts.get_days_remaining(contract))

	if status == "completed":
		return "Completed on day %d. Reward: %dg" % [
			int(contract.get("completed_day", 0)),
			int(contract.get("reward_gold", 0)),
		]
	if status == "failed":
		return "Failed on day %d. Target was %s." % [int(contract.get("failed_day", 0)), target]

	var progress := "Ready"
	if _player_data.current_town != target:
		progress = "Travel to %s" % target
	elif held < required:
		progress = "Need %d more %s" % [required - held, item.capitalize()]

	return "%d/%d %s | %s | %d day(s) left | %dg" % [
		held,
		required,
		item.capitalize(),
		progress,
		days_left,
		int(contract.get("reward_gold", 0)),
	]

func _get_contract_status_color(status: String) -> Color:
	if status == "completed":
		return Color(0.45, 1.0, 0.35)
	if status == "failed":
		return Color(1.0, 0.35, 0.25)
	if status == "accepted":
		return Color(1.0, 0.82, 0.36)
	return Color(0.82, 0.65, 0.36)

# Her şehir butonu için risk göstergesini günceller (tooltip + renk).
func _update_risk_indicators() -> void:
	if _risk == null or _player_data == null:
		return

	for town_name in town_buttons:
		var btn: Button = town_buttons[town_name]
		if btn == null:
			continue

		# Aynı şehir veya seyahat halinde - risk uyarısı göstermeye gerek yok
		if town_name == _player_data.current_town or is_traveling:
			btn.tooltip_text = town_name
			continue

		var chance: float = _risk.calculate_attack_chance(town_name)
		var label: String = _risk.get_risk_label(chance)
		var percent: int = int(round(chance * 100.0))
		btn.tooltip_text = "%s\nRisk: %s (%d%%)" % [town_name, label, percent]

# Saldırı olduğunda cargonun yarısını rastgele kaybeder.
# Geriye kayıp özetini döndürür.
func _resolve_attack() -> Dictionary:
	var lost_items: Dictionary = {}
	var inventory_copy: Dictionary = _player_data.inventory.duplicate()

	for item in inventory_copy:
		var qty: int = int(inventory_copy[item])
		if qty <= 0:
			continue
		# Her itemin üçte biri kaybediliyor (yukarı yuvarla, en az 1)
		var lost: int = maxi(1, int(ceil(qty / 3.0)))
		lost = mini(lost, qty)
		_player_data.remove_item(item, lost)
		lost_items[item] = lost

	return lost_items

func _show_attack_popup(lost_items: Dictionary, arrived_town: String) -> void:
	_day_timer.paused = true
	var popup: Control = preload("res://scenes/ui/AttackPopup.tscn").instantiate()
	get_node("UI").add_child(popup)
	popup.call("show_attack", lost_items)
	popup.connect("closed", _on_attack_popup_closed.bind(arrived_town))

func _on_attack_popup_closed(arrived_town: String) -> void:
	_update_ui()
	_open_town(arrived_town)

func _on_event_changed(town_name: String, event: Dictionary) -> void:
	_refresh_buttons()
	if event.is_empty():
		return
	if top_bar and top_bar.has_method("show_notification"):
		var event_color: Color = event.get("color", Color.WHITE)
		var msg: String = "%s: %s begins!" % [town_name, str(event.get("name", ""))]
		top_bar.call("show_notification", msg, event_color)
