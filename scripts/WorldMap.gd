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
var travel_start_map_pos: Vector2
var travel_end_map_pos: Vector2
var travel_elapsed_seconds: float = 0.0

var town_buttons: Dictionary = {}
var top_bar: Control
var _contracts_panel_open := true
var _finance_panel: PanelContainer
var _speed_before_finance := 1
var _town_view_host: Control
var _active_town_scene: Control

var game_speed: int = 1
const DAY_INTERVAL: float = 8.0

const MAP_W: float = 2688.0
const MAP_H: float = 1536.0
const TOWN_COORD_W: float = 2688.0
const TOWN_COORD_H: float = 1536.0
const DEFAULT_TOP_BAR_HEIGHT: float = 88.0
const SIDE_PANEL_WIDTH: float = 360.0
const SIDE_PANEL_MIN_WIDTH: float = 300.0
const SIDE_PANEL_RATIO: float = 0.22
const BOTTOM_BAR_HEIGHT: float = 96.0
const UI_GAP: float = 10.0
const MAP_VIEW_SCALE: float = 0.85
const MAP_MIN_VIEW_SCALE: float = 0.55
const MAP_ZOOM_STEP: float = 0.08

# City interaction radius in screen pixels
const CITY_R: float = 14.0

# Calculated once in _setup_view
var _map_scale: float  = 1.0
var _map_offset: Vector2 = Vector2.ZERO
var _map_view_rect: Rect2 = Rect2()
var _map_pan: Vector2 = Vector2.ZERO
var _is_panning_map: bool = false
var _last_pan_mouse_pos: Vector2 = Vector2.ZERO

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
	get_viewport().size_changed.connect(_on_viewport_resized)
	_bind_top_bar()
	_bind_contract_tracker()
	_sync_town_positions_from_anchors()
	_smooth_road_lines()
	_place_player()
	_build_town_buttons()
	_setup_day_timer()
	_update_ui()
	_build_rank_panel()
	_build_goal_panel()
	_build_cargo_panel()
	_build_trader_labels()
	_layout_ui()

# Scale & position the map sprite to fill the viewport while keeping aspect ratio.
# WorldMap node itself stays at identity (position=0, scale=1).
# All other calculations use _map_to_screen() for explicit conversion.
func _setup_view() -> void:
	var vp: Vector2 = get_viewport_rect().size
	var top_bar_height := _get_top_bar_height()
	var side_width := _get_side_panel_width()
	_map_view_rect = Rect2(
		Vector2.ZERO + Vector2(0.0, top_bar_height),
		Vector2(
			maxf(1.0, vp.x - side_width - UI_GAP),
			maxf(1.0, vp.y - top_bar_height - BOTTOM_BAR_HEIGHT - UI_GAP)
		)
	)
	_map_scale = MAP_VIEW_SCALE
	_clamp_map_pan()
	_apply_map_transform()
	_layout_ui()

func _on_viewport_resized() -> void:
	_setup_view()
	_update_map_positions()

func _get_side_panel_width() -> float:
	var vp_width := get_viewport_rect().size.x
	return clampf(vp_width * SIDE_PANEL_RATIO, SIDE_PANEL_MIN_WIDTH, SIDE_PANEL_WIDTH)

func _apply_map_transform() -> void:
	_map_offset = _map_view_rect.position + _map_pan * _map_scale

	var map_content = get_node_or_null("MapContent")
	if map_content:
		map_content.scale = Vector2(_map_scale, _map_scale)
		map_content.position = _map_offset
	var player = get_node_or_null("Player")
	if player:
		player.z_index = 3

func _clamp_map_pan() -> void:
	var display_size := Vector2(MAP_W, MAP_H) * _map_scale
	for axis in range(2):
		var view_size: float = _map_view_rect.size[axis]
		var map_size: float = display_size[axis]
		if map_size <= view_size:
			_map_pan[axis] = ((view_size - map_size) * 0.5) / _map_scale
		else:
			var min_pan := (view_size - map_size) / _map_scale
			_map_pan[axis] = clampf(_map_pan[axis], min_pan, 0.0)

func _layout_ui() -> void:
	var vp := get_viewport_rect().size
	var top_bar_height := _get_top_bar_height()
	var side_width := _get_side_panel_width()
	var side_left := vp.x - side_width
	_layout_backdrops(vp, top_bar_height, side_left)

	var contracts_toggle := get_node_or_null("UI/ContractsToggle") as Control
	if contracts_toggle:
		contracts_toggle.anchor_left = 0.0
		contracts_toggle.anchor_right = 0.0
		contracts_toggle.offset_left = side_left + UI_GAP
		contracts_toggle.offset_top = top_bar_height + UI_GAP
		contracts_toggle.offset_right = vp.x - UI_GAP
		contracts_toggle.offset_bottom = top_bar_height + 46.0

	var contracts_panel := get_node_or_null("UI/ContractsPanel") as Control
	if contracts_panel:
		contracts_panel.anchor_left = 0.0
		contracts_panel.anchor_right = 0.0
		contracts_panel.offset_left = side_left + UI_GAP
		contracts_panel.offset_top = top_bar_height + 54.0
		contracts_panel.offset_right = vp.x - UI_GAP
		contracts_panel.offset_bottom = top_bar_height + 346.0

	if _finance_panel != null and is_instance_valid(_finance_panel):
		_finance_panel.offset_left = side_left + UI_GAP
		_finance_panel.offset_top = top_bar_height + UI_GAP
		_finance_panel.offset_right = vp.x - UI_GAP

	var rank_panel := get_node_or_null("UI/RankPanel") as Control
	if rank_panel:
		rank_panel.anchor_left = 0.0
		rank_panel.anchor_top = 0.0
		rank_panel.anchor_right = 0.0
		rank_panel.anchor_bottom = 0.0
		rank_panel.offset_left = UI_GAP
		rank_panel.offset_top = vp.y - BOTTOM_BAR_HEIGHT + UI_GAP
		rank_panel.offset_right = 290.0
		rank_panel.offset_bottom = vp.y - UI_GAP

	var goal_panel := get_node_or_null("UI/GoalPanel") as Control
	if goal_panel:
		goal_panel.anchor_left = 0.0
		goal_panel.anchor_top = 0.0
		goal_panel.anchor_right = 0.0
		goal_panel.anchor_bottom = 0.0
		goal_panel.offset_left = 300.0
		goal_panel.offset_top = vp.y - BOTTOM_BAR_HEIGHT + UI_GAP
		goal_panel.offset_right = minf(_map_view_rect.end.x - UI_GAP, 720.0)
		goal_panel.offset_bottom = vp.y - UI_GAP

	var cargo_panel := get_node_or_null("UI/CargoPanel") as Control
	if cargo_panel:
		cargo_panel.anchor_left = 0.0
		cargo_panel.anchor_top = 0.0
		cargo_panel.anchor_right = 0.0
		cargo_panel.anchor_bottom = 0.0
		cargo_panel.offset_left = side_left + UI_GAP
		cargo_panel.offset_top = maxf(top_bar_height + 360.0, vp.y - 230.0)
		cargo_panel.offset_right = vp.x - UI_GAP
		cargo_panel.offset_bottom = vp.y - UI_GAP

	_layout_town_view_host()

func _layout_town_view_host() -> void:
	if _town_view_host == null or not is_instance_valid(_town_view_host):
		return
	_town_view_host.anchor_left = 0.0
	_town_view_host.anchor_top = 0.0
	_town_view_host.anchor_right = 0.0
	_town_view_host.anchor_bottom = 0.0
	_town_view_host.offset_left = _map_view_rect.position.x
	_town_view_host.offset_top = _map_view_rect.position.y
	_town_view_host.offset_right = _map_view_rect.end.x
	_town_view_host.offset_bottom = _map_view_rect.end.y

func _layout_backdrops(vp: Vector2, top_bar_height: float, side_left: float) -> void:
	var ui := get_node_or_null("UI")
	if ui == null:
		return

	var right_dock := ui.get_node_or_null("RightDockBackdrop") as ColorRect
	if right_dock == null:
		right_dock = ColorRect.new()
		right_dock.name = "RightDockBackdrop"
		right_dock.color = Color(0.055, 0.045, 0.035, 0.96)
		right_dock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.add_child(right_dock)
		ui.move_child(right_dock, 0)
	right_dock.anchor_left = 0.0
	right_dock.anchor_top = 0.0
	right_dock.anchor_right = 0.0
	right_dock.anchor_bottom = 0.0
	right_dock.offset_left = side_left
	right_dock.offset_top = top_bar_height
	right_dock.offset_right = vp.x
	right_dock.offset_bottom = vp.y

	var bottom_bar := ui.get_node_or_null("BottomDockBackdrop") as ColorRect
	if bottom_bar == null:
		bottom_bar = ColorRect.new()
		bottom_bar.name = "BottomDockBackdrop"
		bottom_bar.color = Color(0.055, 0.045, 0.035, 0.96)
		bottom_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.add_child(bottom_bar)
		ui.move_child(bottom_bar, 0)
	bottom_bar.anchor_left = 0.0
	bottom_bar.anchor_top = 0.0
	bottom_bar.anchor_right = 0.0
	bottom_bar.anchor_bottom = 0.0
	bottom_bar.offset_left = 0.0
	bottom_bar.offset_top = vp.y - BOTTOM_BAR_HEIGHT
	bottom_bar.offset_right = side_left
	bottom_bar.offset_bottom = vp.y

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
	var texture_pos := Vector2(
		map_pos.x / TOWN_COORD_W * MAP_W,
		map_pos.y / TOWN_COORD_H * MAP_H
	)
	return _map_offset + texture_pos * _map_scale

func _is_in_map_view(screen_pos: Vector2) -> bool:
	return _map_view_rect.has_point(screen_pos)

func _update_map_positions() -> void:
	_apply_map_transform()
	_position_town_buttons()
	_update_trader_labels()
	if is_traveling:
		_update_player_travel_position()
	else:
		_place_player()

func _sync_town_positions_from_anchors() -> void:
	var anchors := get_node_or_null("MapContent/TownAnchors")
	if anchors == null or _economy == null:
		return

	for child in anchors.get_children():
		if not child is Node2D:
			continue
		var town_name := child.name
		if not _economy.towns.has(town_name):
			continue
		var town: Dictionary = _economy.towns[town_name]
		town["position"] = (child as Node2D).position
		_economy.towns[town_name] = town

func _smooth_road_lines() -> void:
	var roads := get_node_or_null("MapContent/Roads")
	if roads == null:
		return

	for child in roads.get_children():
		var line := child as Line2D
		if line == null or line.points.size() < 3:
			continue
		line.points = _catmull_rom_points(line.points, 10)

func _catmull_rom_points(source: PackedVector2Array, steps_per_segment: int) -> PackedVector2Array:
	var smoothed := PackedVector2Array()
	for i in range(source.size() - 1):
		var p0 := source[maxi(i - 1, 0)]
		var p1 := source[i]
		var p2 := source[i + 1]
		var p3 := source[mini(i + 2, source.size() - 1)]

		for step in range(steps_per_segment):
			var t := float(step) / float(steps_per_segment)
			smoothed.append(_catmull_rom_point(p0, p1, p2, p3, t))

	smoothed.append(source[source.size() - 1])
	return smoothed

func _catmull_rom_point(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var t2 := t * t
	var t3 := t2 * t
	return 0.5 * (
		(2.0 * p1) +
		(-p0 + p2) * t +
		(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
		(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
	)

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
	if top_bar and top_bar.has_signal("finance_requested"):
		top_bar.connect("finance_requested", _toggle_finance_panel)

func _bind_contract_tracker() -> void:
	var toggle := get_node_or_null("UI/ContractsToggle") as Button
	if toggle:
		toggle.pressed.connect(_toggle_contract_tracker)
	if _contracts and _contracts.has_signal("contracts_changed"):
		_contracts.connect("contracts_changed", _update_contract_tracker)
	_update_contract_tracker()

func _toggle_finance_panel() -> void:
	if _finance_panel != null and is_instance_valid(_finance_panel):
		_close_finance_panel()
		return
	_open_finance_panel()

func _open_finance_panel() -> void:
	_speed_before_finance = game_speed
	_set_speed(0)
	_build_finance_panel()

func _close_finance_panel() -> void:
	if _finance_panel != null and is_instance_valid(_finance_panel):
		_finance_panel.queue_free()
	_finance_panel = null
	_set_speed(_speed_before_finance)

func _build_finance_panel() -> void:
	var ui := get_node("UI")
	var panel := PanelContainer.new()
	panel.name = "FinancePanel"
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 0.0
	panel.anchor_bottom = 0.0
	var vp := get_viewport_rect().size
	var side_left := vp.x - _get_side_panel_width()
	panel.offset_left = side_left + UI_GAP
	panel.offset_top = _get_top_bar_height() + UI_GAP
	panel.offset_right = vp.x - UI_GAP
	panel.offset_bottom = panel.offset_top + 340.0
	ui.add_child(panel)
	_finance_panel = panel

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var header := HBoxContainer.new()
	vbox.add_child(header)

	var title := Label.new()
	title.text = "Finance Summary"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36))
	header.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.custom_minimum_size = Vector2(34, 28)
	close_btn.pressed.connect(_toggle_finance_panel)
	header.add_child(close_btn)

	vbox.add_child(HSeparator.new())

	var summary: Dictionary = _player_data.get_finance_summary()
	_add_finance_row(vbox, "Gold", _format_gold(float(summary.get("gold", 0.0))))
	_add_finance_row(vbox, "Debt", "%s (%d day%s)" % [
		_format_gold(float(summary.get("debt", 0.0))),
		int(summary.get("debt_days", 0)),
		"" if int(summary.get("debt_days", 0)) == 1 else "s"
	])
	_add_finance_row(vbox, "Daily upkeep", _format_gold(float(summary.get("daily_upkeep", 0.0))))

	vbox.add_child(HSeparator.new())
	_add_finance_section_title(vbox, "Upkeep Breakdown")
	_add_finance_row(vbox, "Caravan", _format_gold(float(summary.get("caravan_upkeep", 0.0))))
	_add_finance_row(vbox, "Rank (%s)" % str(summary.get("rank", "")), _format_gold(float(summary.get("rank_upkeep", 0.0))))
	_add_finance_row(vbox, "Trading Posts (%d)" % int(summary.get("active_posts", 0)), _format_gold(float(summary.get("trading_post_upkeep", 0.0))))

	vbox.add_child(HSeparator.new())
	_add_finance_section_title(vbox, "Today")
	_add_finance_bucket(vbox, summary.get("today", {}))

	vbox.add_child(HSeparator.new())
	_add_finance_section_title(vbox, "Yesterday")
	_add_finance_bucket(vbox, summary.get("yesterday", {}))

func _refresh_finance_panel() -> void:
	if _finance_panel == null or not is_instance_valid(_finance_panel):
		return
	_finance_panel.queue_free()
	_finance_panel = null
	_build_finance_panel()

func _add_finance_section_title(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.94, 0.78, 0.45))
	parent.add_child(label)

func _add_finance_bucket(parent: VBoxContainer, bucket: Variant) -> void:
	var data: Dictionary = bucket if bucket is Dictionary else {}
	var income := float(data.get("income", 0.0))
	var expenses := float(data.get("expenses", 0.0))
	_add_finance_row(parent, "Income", _format_gold(income))
	_add_finance_row(parent, "Expenses", _format_gold(expenses))
	_add_finance_row(parent, "Net", _format_gold(income - expenses))
	_add_finance_row(parent, "Debt paid", _format_gold(float(data.get("debt_paid", 0.0))))
	_add_finance_row(parent, "Upkeep paid", _format_gold(float(data.get("upkeep_paid", 0.0))))
	_add_finance_row(parent, "Unpaid upkeep", _format_gold(float(data.get("upkeep_unpaid", 0.0))))

func _add_finance_row(parent: VBoxContainer, label_text: String, value_text: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)

	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.custom_minimum_size.x = 110
	row.add_child(value)

func _format_gold(value: float) -> String:
	return "%.1fg" % value

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
	travel_elapsed_seconds += delta * float(game_speed)
	_update_player_travel_position()

func _unhandled_input(event: InputEvent) -> void:
	if _active_town_scene != null and is_instance_valid(_active_town_scene):
		return

	var mouse_button := event as InputEventMouseButton
	if mouse_button != null:
		if mouse_button.pressed and _is_in_map_view(mouse_button.position):
			if mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_map(-MAP_ZOOM_STEP, mouse_button.position)
				get_viewport().set_input_as_handled()
				return
			if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_map(MAP_ZOOM_STEP, mouse_button.position)
				get_viewport().set_input_as_handled()
				return
			if mouse_button.button_index == MOUSE_BUTTON_LEFT:
				_is_panning_map = true
				_last_pan_mouse_pos = mouse_button.position
				get_viewport().set_input_as_handled()
				return
		elif mouse_button.button_index == MOUSE_BUTTON_LEFT and not mouse_button.pressed:
			_is_panning_map = false
		return

	var mouse_motion := event as InputEventMouseMotion
	if mouse_motion != null and _is_panning_map:
		_map_pan += (mouse_motion.position - _last_pan_mouse_pos) / _map_scale
		_last_pan_mouse_pos = mouse_motion.position
		_clamp_map_pan()
		_update_map_positions()
		get_viewport().set_input_as_handled()

func _zoom_map(delta_scale: float, focus_screen_pos: Vector2) -> void:
	var old_scale := _map_scale
	var new_scale := clampf(_map_scale + delta_scale, MAP_MIN_VIEW_SCALE, MAP_VIEW_SCALE)
	if is_equal_approx(old_scale, new_scale):
		return

	var focus_map_pos := (focus_screen_pos - _map_view_rect.position) / old_scale - _map_pan
	_map_scale = new_scale
	_map_pan = (focus_screen_pos - _map_view_rect.position) / new_scale - focus_map_pos
	_clamp_map_pan()
	_update_map_positions()

func _update_player_travel_position() -> void:
	var player = get_node_or_null("Player")
	if player == null:
		return
	var duration := maxf(float(travel_total_days) * DAY_INTERVAL, 0.001)
	var t := clampf(travel_elapsed_seconds / duration, 0.0, 1.0)
	player.position = _map_to_screen(travel_start_map_pos.lerp(travel_end_map_pos, t))

func _on_day_tick() -> void:
	_economy.advance_day()
	if is_traveling:
		travel_days_remaining -= 1
		if travel_days_remaining <= 0:
			get_node("Player").position = _map_to_screen(travel_end_map_pos)
			_arrive()
			return
	_update_ui()
	_refresh_buttons()
	_update_rank_panel()
	_update_goal_panel()
	_update_cargo_panel()
	_update_trader_labels()
	_refresh_finance_panel()
	_check_win_condition()

# -----------------------------------------------

func _build_town_buttons() -> void:
	for town_name in _economy.towns:
		var btn := get_node_or_null("TownButtons/%sBtn" % town_name) as Button
		if btn == null:
			continue
		btn.custom_minimum_size = Vector2(140, 42)
		btn.size = Vector2(140, 42)
		btn.pressed.connect(_on_town_pressed.bind(town_name))
		town_buttons[town_name] = btn
	_position_town_buttons()
	_refresh_buttons()

func _position_town_buttons() -> void:
	for town_name in town_buttons:
		var btn: Button = town_buttons[town_name]
		var map_pos: Vector2 = _economy.towns.get(town_name, {}).get("position", Vector2.ZERO)
		var screen_pos := _map_to_screen(map_pos)
		btn.position = screen_pos + Vector2(-70.0, -21.0)
		btn.visible = _is_in_map_view(screen_pos)

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
	travel_start_map_pos  = _economy.towns[_player_data.current_town].get("position", Vector2.ZERO)
	travel_end_map_pos    = _economy.towns[town_name].get("position", Vector2.ZERO)
	travel_start_pos      = _map_to_screen(travel_start_map_pos)
	travel_end_pos        = _map_to_screen(travel_end_map_pos)
	travel_total_days     = _calc_travel_days(town_name)
	travel_days_remaining = travel_total_days
	travel_elapsed_seconds = 0.0

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
	travel_elapsed_seconds = 0.0
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
	_set_map_view_visible(false)
	if _town_view_host != null and is_instance_valid(_town_view_host):
		_town_view_host.queue_free()

	var ui := get_node("UI")
	_town_view_host = Control.new()
	_town_view_host.name = "TownViewHost"
	_town_view_host.mouse_filter = Control.MOUSE_FILTER_STOP
	ui.add_child(_town_view_host)
	_layout_town_view_host()

	var town_scene: Control = preload("res://scenes/TownScene.tscn").instantiate()
	town_scene.set("town_name", town_name)
	town_scene.set("embedded_in_map_view", true)
	_town_view_host.add_child(town_scene)
	town_scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_active_town_scene = town_scene
	town_scene.connect("closed", Callable(self, "_on_town_ui_closed"))

func _on_town_ui_closed() -> void:
	if _town_view_host != null and is_instance_valid(_town_view_host):
		_town_view_host.queue_free()
	_town_view_host = null
	_active_town_scene = null
	_set_map_view_visible(true)
	if game_speed > 0:
		_day_timer.paused = false
	_update_ui()
	_refresh_buttons()
	_update_cargo_panel()

func _set_map_view_visible(visible: bool) -> void:
	var map_content := get_node_or_null("MapContent") as CanvasItem
	if map_content:
		map_content.visible = visible
	var player := get_node_or_null("Player") as CanvasItem
	if player:
		player.visible = visible
	var town_buttons_layer := get_node_or_null("TownButtons") as CanvasLayer
	if town_buttons_layer:
		town_buttons_layer.visible = visible
	var ui := get_node_or_null("UI")
	if ui:
		for child in ui.get_children():
			if child is CanvasItem and str(child.name).begins_with("TraderLabel_"):
				(child as CanvasItem).visible = visible

func _refresh_buttons() -> void:
	_position_town_buttons()
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
	if _active_town_scene != null and is_instance_valid(_active_town_scene):
		var ui := get_node_or_null("UI")
		if ui:
			for child in ui.get_children():
				if child is CanvasItem and str(child.name).begins_with("TraderLabel_"):
					(child as CanvasItem).visible = false
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
