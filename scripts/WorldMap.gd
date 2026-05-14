extends Node2D

var _player_data: Node
var _economy: Node
var _contracts: Node
var _risk: Node
var _events: Node
var _traders: Node
var _posts: Node

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
const DAY_INTERVAL: float = 8.0

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
	_traders = get_node_or_null("/root/TraderManager")
	if _traders:
		_traders.connect("trader_moved", _on_trader_moved)
		_traders.connect("trader_traded", _on_trader_traded)
	_posts = get_node_or_null("/root/TradingPostManager")
	_player_data.current_town = "Ashford"

	_setup_view()
	_bind_top_bar()
	_bind_contract_tracker()
	_place_player()
	_build_town_buttons()
	_setup_day_timer()
	_update_ui()
	_build_rank_panel()
	_build_goal_panel()
	_build_cargo_panel()
	_build_trader_labels()

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
	_update_rank_panel()
	_update_goal_panel()
	_update_cargo_panel()
	_update_trader_labels()
	_check_win_condition()

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
	_update_cargo_panel()

func _refresh_buttons() -> void:
	for town_name in town_buttons:
		var btn: Button = town_buttons[town_name]
		if is_traveling:
			btn.modulate = Color(0.55, 0.55, 0.55)
			btn.text = _get_town_label(town_name)
			continue
		if town_name == _player_data.current_town:
			btn.modulate = Color(0.3, 1.0, 0.3)
			btn.text = _get_town_label(town_name)
			continue

		var level: int = _economy.get_prosperity_level(town_name)
		var btn_text: String = _get_town_label(town_name)
		if level == 2:
			btn_text = btn_text.replace(town_name, town_name + " ●")
		elif level == 3:
			btn_text = btn_text.replace(town_name, town_name + " ●●")

		# Olay rozeti
		if _events != null and _events.has_event(town_name):
			var event: Dictionary = _events.get_event(town_name)
			var icon: String = str(event.get("icon", "?"))
			var event_color: Color = event.get("color", Color.WHITE)
			btn.text = "%s %s" % [icon, btn_text]
			btn.modulate = event_color
			continue

		btn.text = btn_text

		# Risk rengi (olay yoksa)
		var chance: float = 0.0
		if _risk != null:
			chance = _risk.calculate_attack_chance(town_name)

		# Trend rengi öncelikli
		var trend: String = _economy.get_population_trend(town_name)
		if trend == "down":
			btn.modulate = Color(1.0, 0.5, 0.5)    # kırmızı — batıyor
		elif trend == "up":
			btn.modulate = Color(0.6, 1.0, 0.6)    # yeşil — büyüyor
		elif chance >= 0.30:
			btn.modulate = Color(1.0, 0.65, 0.55)  # turuncu — tehlikeli
		elif chance >= 0.20:
			btn.modulate = Color(1.0, 0.85, 0.7)
		else:
			if level == 3:
				btn.modulate = Color(0.4, 1.0, 0.4) # parlak yeşil
			elif level == 2:
				btn.modulate = Color(1.0, 0.9, 0.4) # hafif altın rengi
			else:
				btn.modulate = Color(1.0, 1.0, 1.0)
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

func _update_risk_indicators() -> void:
	if _risk == null or _player_data == null:
		return

	for town_name in town_buttons:
		var btn: Button = town_buttons[town_name]
		if btn == null:
			continue

		if town_name == _player_data.current_town or is_traveling:
			btn.tooltip_text = town_name
			continue

		var lines: Array[String] = []
		lines.append(town_name)
		lines.append("─────────────────")

		# --- Fiyat analizi ---
		var town: Dictionary = _economy.get_town(town_name)
		var inventory: Dictionary = town.get("inventory", {})

		var expensive: Array = []  # sat fırsatı
		var cheap: Array = []      # al fırsatı

		for item in _economy.BASE_PRICES:
			var base: float = float(_economy.BASE_PRICES[item])
			if base <= 0.0:
				continue
			var current: float = float(_economy.get_price(town_name, item))
			var ratio: float = (current - base) / base  # +0.3 = %30 pahalı

			if ratio >= 0.20:
				expensive.append({"item": item, "price": current, "ratio": ratio})
			elif ratio <= -0.15:
				cheap.append({"item": item, "price": current, "ratio": ratio})

		# Sırala — en karlı önce
		expensive.sort_custom(func(a, b): return float(a["ratio"]) > float(b["ratio"]))
		cheap.sort_custom(func(a, b): return float(a["ratio"]) < float(b["ratio"]))

		# En fazla 3 tane göster
		if not expensive.is_empty():
			lines.append("↑ Sat fırsatı:")
			for i in range(mini(3, expensive.size())):
				var e = expensive[i]
				var pct: int = int(round(float(e["ratio"]) * 100.0))
				lines.append("  %s: %.1fg (+%d%%)" % [str(e["item"]).capitalize(), float(e["price"]), pct])

		if not cheap.is_empty():
			lines.append("↓ Al fırsatı:")
			for i in range(mini(3, cheap.size())):
				var c = cheap[i]
				var pct: int = int(round(float(c["ratio"]) * 100.0))
				lines.append("  %s: %.1fg (%d%%)" % [str(c["item"]).capitalize(), float(c["price"]), pct])

		if expensive.is_empty() and cheap.is_empty():
			lines.append("Fiyatlar normal.")

		# --- Risk ---
		var chance: float = float(_risk.calculate_attack_chance(town_name))
		var risk_label: String = _risk.get_risk_label(chance)
		var risk_pct: int = int(round(chance * 100.0))
		lines.append("─────────────────")
		lines.append("Bandit riski: %s (%d%%)" % [risk_label, risk_pct])

		# --- Aktif olay ---
		if _events != null and _events.has_event(town_name):
			var event: Dictionary = _events.get_event(town_name)
			var days_left: int = int(event.get("ends_day", 0)) - int(_economy.current_day)
			lines.append("%s %s — %d gün kaldı" % [
				str(event.get("icon", "")),
				str(event.get("name", "")),
				maxi(days_left, 0)
			])

		btn.tooltip_text = "\n".join(lines)

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

func _on_rank_changed(old_rank: String, new_rank: String) -> void:
	if top_bar and top_bar.has_method("show_notification"):
		top_bar.call("show_notification", "You are now a %s!" % new_rank, Color(1.0, 0.85, 0.3))

# --- Rank Panel ---

func _build_rank_panel() -> void:
	var ui := get_node("UI")

	var panel := PanelContainer.new()
	panel.name = "RankPanel"
	panel.anchors_preset = 3  # bottom-left
	panel.anchor_left = 0.0
	panel.anchor_top = 1.0
	panel.anchor_right = 0.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 10.0
	panel.offset_top = -340.0
	panel.offset_right = 280.0
	panel.offset_bottom = -190.0
	ui.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.name = "RankVBox"
	panel.add_child(vbox)
	
	var rm = get_node("/root/RankManager")
	rm.connect("rank_changed", _on_rank_changed)
	
	_update_rank_panel()

func _update_rank_panel() -> void:
	var vbox := get_node_or_null("UI/RankPanel/RankVBox")
	if vbox == null:
		return
		
	for child in vbox.get_children():
		child.queue_free()
		
	var rm = get_node("/root/RankManager")
	var curr = rm.get_current_rank()
	var next = rm.get_next_rank()
	
	var title = Label.new()
	title.text = "RANK: %s" % curr
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	vbox.add_child(title)
	
	vbox.add_child(HSeparator.new())
	
	if next == "":
		var lbl = Label.new()
		lbl.text = "Maximum rank achieved!"
		lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		vbox.add_child(lbl)
		return
		
	var next_lbl = Label.new()
	next_lbl.text = "Next: %s" % next
	vbox.add_child(next_lbl)
	
	var prog = rm.get_progress_data()
	for key in prog.keys():
		var req = int(prog[key]["req"])
		if req > 0:
			var cur = int(prog[key]["current"])
			var row = Label.new()
			var key_name = key.replace("_", " ").capitalize()
			row.text = "- %s: %d / %d" % [key_name, cur, req]
			if cur >= req:
				row.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
			else:
				row.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
			vbox.add_child(row)

# --- Goal Panel ---

func _build_goal_panel() -> void:
	var ui := get_node("UI")

	var panel := PanelContainer.new()
	panel.name = "GoalPanel"
	panel.anchors_preset = 3  # bottom-left
	panel.anchor_left = 0.0
	panel.anchor_top = 1.0
	panel.anchor_right = 0.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 10.0
	panel.offset_top = -180.0
	panel.offset_right = 280.0
	panel.offset_bottom = -10.0
	ui.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.name = "GoalVBox"
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "GOAL: Develop all cities"
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	for town_name in _economy.towns.keys():
		var row := HBoxContainer.new()
		row.name = "GoalRow_%s" % town_name
		row.add_theme_constant_override("separation", 6)

		var name_lbl := Label.new()
		name_lbl.name = "NameLbl"
		name_lbl.text = town_name
		name_lbl.custom_minimum_size.x = 90
		name_lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(name_lbl)

		var bar_lbl := Label.new()
		bar_lbl.name = "BarLbl"
		bar_lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(bar_lbl)

		var status_lbl := Label.new()
		status_lbl.name = "StatusLbl"
		status_lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(status_lbl)

		vbox.add_child(row)

	_update_goal_panel()

func _update_goal_panel() -> void:
	var vbox := get_node_or_null("UI/GoalPanel/GoalVBox")
	if vbox == null:
		return

	var threshold: int = int(_economy.PROSPERITY_LEVEL_3_THRESHOLD)

	for town_name in _economy.towns.keys():
		var row := vbox.get_node_or_null("GoalRow_%s" % town_name)
		if row == null:
			continue

		var prosperity: int = int(_economy.get_prosperity(town_name))
		var label: String = _economy.get_prosperity_label(town_name)

		# Progress bar (10 karakter)
		var filled: int = int(round(float(prosperity) / float(threshold) * 10.0))
		filled = clampi(filled, 0, 10)
		var bar: String = "█".repeat(filled) + "░".repeat(10 - filled)

		var bar_lbl := row.get_node_or_null("BarLbl") as Label
		var status_lbl := row.get_node_or_null("StatusLbl") as Label

		if bar_lbl:
			bar_lbl.text = "%s %d/%d" % [bar, prosperity, threshold]
		if status_lbl:
			status_lbl.text = label
			match label:
				"Prosperous": status_lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
				"Growing":    status_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
				_:            status_lbl.add_theme_color_override("font_color", Color(0.7, 0.6, 0.5))

func _check_win_condition() -> void:
	if get_node("/root/RankManager").get_current_rank() == "Patrician":
		_show_win_screen()

func _show_win_screen() -> void:
	_day_timer.paused = true
	var win := Label.new()
	win.text = "YOU WIN!\nYou have reached the Patrician rank.\nDay %d" % _player_data.current_day
	win.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	win.add_theme_font_size_override("font_size", 36)
	win.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	win.anchors_preset = 15
	win.anchor_right = 1.0
	win.anchor_bottom = 1.0
	get_node("UI").add_child(win)

# --- Cargo Panel ---

func _build_cargo_panel() -> void:
	var ui := get_node("UI")

	var panel := PanelContainer.new()
	panel.name = "CargoPanel"
	panel.anchor_left = 1.0
	panel.anchor_top = 1.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = -180.0
	panel.offset_top = -220.0
	panel.offset_right = -10.0
	panel.offset_bottom = -10.0
	ui.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.name = "CargoVBox"
	panel.add_child(vbox)

	var title := Label.new()
	title.name = "CargoTitle"
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var list := VBoxContainer.new()
	list.name = "CargoList"
	vbox.add_child(list)

	_update_cargo_panel()

func _update_cargo_panel() -> void:
	var title := get_node_or_null("UI/CargoPanel/CargoVBox/CargoTitle") as Label
	var list := get_node_or_null("UI/CargoPanel/CargoVBox/CargoList") as VBoxContainer
	if title == null or list == null:
		return

	var total: int = int(_player_data.get_total_cargo())
	var capacity: int = int(_player_data.caravan_capacity)
	title.text = "CARGO  (%d/%d)" % [total, capacity]

	for child in list.get_children():
		child.queue_free()

	if _player_data.inventory.is_empty():
		var empty := Label.new()
		empty.text = "Cargo empty."
		empty.add_theme_color_override("font_color", Color(0.6, 0.55, 0.45))
		empty.add_theme_font_size_override("font_size", 12)
		list.add_child(empty)
		return

	for item in _player_data.inventory:
		var qty: int = int(_player_data.inventory[item])
		if qty <= 0:
			continue

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var name_lbl := Label.new()
		name_lbl.text = str(item).capitalize()
		name_lbl.custom_minimum_size.x = 100
		name_lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(name_lbl)

		var qty_lbl := Label.new()
		qty_lbl.text = "x%d" % qty
		qty_lbl.add_theme_font_size_override("font_size", 12)
		qty_lbl.add_theme_color_override("font_color", Color(0.94, 0.78, 0.45))
		row.add_child(qty_lbl)

		list.add_child(row)

func _get_town_label(town_name: String) -> String:
	var pop: int = int(_economy.get_town(town_name).get("population", 0))
	var trend: String = _economy.get_population_trend(town_name)
	var arrow: String = ""
	match trend:
		"up":   arrow = " ↑"
		"down": arrow = " ↓"
		_:      arrow = " →"
	var p = " [P]" if _posts and _posts.has_post(town_name) else ""
	return "%s%s\n👥 %d%s" % [town_name, p, pop, arrow]

func _on_trader_moved(trader_id: String, from_town: String, to_town: String) -> void:
	_update_trader_labels()
	print("[Trader] %s: %s → %s" % [trader_id, from_town, to_town])

func _on_trader_traded(trader_id: String, town_name: String, action: String, item: String, qty: int) -> void:
	print("[Trader] %s %s %dx %s in %s" % [trader_id, action, qty, item, town_name])

# --- Trader Labels ---

func _build_trader_labels() -> void:
	if _traders == null:
		return
	var ui := get_node("UI")
	for trader_id in _traders.traders:
		var trader: Dictionary = _traders.get_trader(trader_id)
		var lbl := Label.new()
		lbl.name = "TraderLabel_%s" % trader_id
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", Color(0.9, 0.75, 0.3))
		ui.add_child(lbl)
	_update_trader_labels()

func _update_trader_labels() -> void:
	if _traders == null:
		return
	for trader_id in _traders.traders:
		var lbl := get_node_or_null("UI/TraderLabel_%s" % trader_id) as Label
		if lbl == null:
			continue
		var trader: Dictionary = _traders.get_trader(trader_id)
		var is_traveling: bool = _traders.is_traveling(trader_id)

		if is_traveling:
			# Seyahatteyse — from ve to arasında göster
			var from_town: String = str(trader.get("current_town", ""))
			var dest_town: String = str(trader.get("destination", ""))
			var from_pos: Vector2 = _map_to_screen(_economy.towns.get(from_town, {}).get("position", Vector2.ZERO))
			var dest_pos: Vector2 = _map_to_screen(_economy.towns.get(dest_town, {}).get("position", Vector2.ZERO))
			var days_done: float = float(trader.get("days_traveling", 0))
			var days_total: float = maxf(float(trader.get("travel_total_days", 1)), 1.0)
			var t: float = clamp(days_done / days_total, 0.0, 1.0)
			lbl.position = from_pos.lerp(dest_pos, t) + Vector2(8, -16)
			lbl.text = "» %s" % str(trader.get("name", ""))
			lbl.modulate = Color(1.0, 0.85, 0.4)
		else:
			# Şehirdeyse — şehir butonunun yanında
			var town_name: String = str(trader.get("current_town", ""))
			var town_pos: Vector2 = _map_to_screen(_economy.towns.get(town_name, {}).get("position", Vector2.ZERO))
			var offset := Vector2(60, -8) * (["aldric", "mira", "torben"].find(trader_id) + 1) * 0.6
			lbl.position = town_pos + offset + Vector2(0, 20)
			lbl.text = "• %s" % str(trader.get("name", ""))
			lbl.modulate = Color(0.8, 0.65, 0.3)

		# Tooltip
		var tooltip_lines: Array[String] = []
		tooltip_lines.append(str(trader.get("name", "")))
		tooltip_lines.append("─────────────────")

		var trader_type: String = str(trader.get("type", ""))
		match trader_type:
			"aggressive": tooltip_lines.append("Aggressive trader")
			"careful":    tooltip_lines.append("Careful trader")
			"specialist": tooltip_lines.append("Specialist (production goods)")

		var cargo_total: int = _traders.get_total_cargo(trader_id)
		var capacity: int = int(trader.get("cargo_capacity", 15))
		tooltip_lines.append("Cargo: %d/%d" % [cargo_total, capacity])

		var inventory: Dictionary = trader.get("inventory", {})
		if inventory.is_empty():
			tooltip_lines.append("(empty cargo)")
		else:
			for item in inventory:
				var qty: int = int(inventory[item])
				if qty > 0:
					tooltip_lines.append("  %s x%d" % [str(item).capitalize(), qty])

		tooltip_lines.append("─────────────────")
		if is_traveling:
			var dest: String = str(trader.get("destination", ""))
			var days_left: int = int(trader.get("travel_total_days", 0)) - int(trader.get("days_traveling", 0))
			tooltip_lines.append("Heading to %s (%d day(s))" % [dest, maxi(days_left, 0)])
		else:
			tooltip_lines.append("In %s" % str(trader.get("current_town", "")))

		var gold: float = float(trader.get("gold", 0.0))
		tooltip_lines.append("Gold: %.0f" % gold)

		lbl.tooltip_text = "\n".join(tooltip_lines)
		lbl.visible = true
