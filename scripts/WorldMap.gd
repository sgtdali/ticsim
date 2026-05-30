extends Node2D

const RoadData := preload("res://scripts/systems/RoadData.gd")

var _player_data: Node
var _economy: Node
var _contracts: Node
var _risk: Node
var _events: Node
var _traders: Node
var _posts: Node
var _masters: Node

# Controllers
var _side_panel: SidePanelController
var _finance: FinancePanelController
var _trader_labels: TraderLabelController
var _event_log: EventLogController

var is_traveling: bool = false
var travel_destination: String = ""
var travel_days_remaining: int = 0
var travel_total_days: int = 0
var travel_start_pos: Vector2
var travel_end_pos: Vector2
var travel_start_map_pos: Vector2
var travel_end_map_pos: Vector2
var travel_elapsed_seconds: float = 0.0

var town_buttons: Dictionary = {}
var top_bar: Control
var _contracts_panel_open := true
var _town_view_host: Control
var _active_town_scene: Control
var _trade_route_panel: Control

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
const DEFAULT_MASTER_HIRE_COST := 120
const DEFAULT_MASTER_DAILY_WAGE := 4.0
const CITY_R: float = 14.0

var _map_scale: float = 1.0
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
	_events      = get_node_or_null("/root/EventManager")
	_traders     = get_node_or_null("/root/TraderManager")
	_posts       = get_node_or_null("/root/TradingPostManager")
	_masters     = get_node_or_null("/root/CaravanMasterManager")

	_side_panel   = SidePanelController.new(self)
	_finance      = FinancePanelController.new(self)
	_trader_labels = TraderLabelController.new(self)
	_event_log    = EventLogController.new(self)

	_player_data.current_town = "Ashford"

	_setup_view()
	get_viewport().size_changed.connect(_on_viewport_resized)
	_bind_top_bar()
	_bind_side_panel()

	if _events:
		_events.connect("event_started", _event_log.on_event_started)
		_events.connect("event_ended", _event_log.on_event_ended)
	if _traders:
		_traders.connect("trader_moved", _trader_labels.on_trader_moved)
		_traders.connect("trader_traded", _trader_labels.on_trader_traded)

	_sync_town_positions_from_anchors()
	_build_roads_from_data()
	_smooth_road_lines()
	_place_player()
	_build_town_buttons()
	_setup_day_timer()
	_update_ui()
	_event_log.update_panel()
	_trader_labels.build()
	_layout_ui()

# -----------------------------------------------
# MAP VIEW
# -----------------------------------------------

func _setup_view() -> void:
	var vp: Vector2 = get_viewport_rect().size
	var top_bar_height := _get_top_bar_height()
	var side_width := _get_side_panel_width()
	_map_view_rect = Rect2(
		Vector2(0.0, top_bar_height),
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

func _get_top_bar_height() -> float:
	var bar := get_node_or_null("UI/TopBar") as Control
	if bar == null or not bar.visible:
		return DEFAULT_TOP_BAR_HEIGHT
	return maxf(
		maxf(bar.size.y, bar.custom_minimum_size.y),
		maxf(bar.get_combined_minimum_size().y, DEFAULT_TOP_BAR_HEIGHT)
	)

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
	_trader_labels.update()
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

# -----------------------------------------------
# LAYOUT
# -----------------------------------------------

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

	_finance.layout(side_left, top_bar_height, vp.x)
	_layout_side_panel(vp, top_bar_height, side_left)
	_layout_event_panel(vp, side_left)
	_layout_trade_route_panel()
	_layout_town_view_host()

func _layout_side_panel(vp: Vector2, top_bar_height: float, side_left: float) -> void:
	var side_panel := get_node_or_null("UI/SidePanel") as Control
	if side_panel == null:
		return
	side_panel.anchor_left = 0.0
	side_panel.anchor_top = 0.0
	side_panel.anchor_right = 0.0
	side_panel.anchor_bottom = 0.0
	side_panel.offset_left = side_left + UI_GAP
	side_panel.offset_top = top_bar_height + UI_GAP
	side_panel.offset_right = vp.x - UI_GAP
	side_panel.offset_bottom = vp.y - UI_GAP

func _layout_event_panel(vp: Vector2, side_left: float) -> void:
	var event_panel := get_node_or_null("UI/EventPanel") as Control
	if event_panel == null:
		return
	event_panel.anchor_left = 0.0
	event_panel.anchor_top = 0.0
	event_panel.anchor_right = 0.0
	event_panel.anchor_bottom = 0.0
	event_panel.offset_left = UI_GAP
	event_panel.offset_top = vp.y - BOTTOM_BAR_HEIGHT + UI_GAP
	event_panel.offset_right = side_left - UI_GAP
	event_panel.offset_bottom = vp.y - UI_GAP

func _layout_trade_route_panel() -> void:
	if _trade_route_panel == null or not is_instance_valid(_trade_route_panel):
		return
	_trade_route_panel.anchor_left = 0.0
	_trade_route_panel.anchor_top = 0.0
	_trade_route_panel.anchor_right = 0.0
	_trade_route_panel.anchor_bottom = 0.0
	_trade_route_panel.offset_left = _map_view_rect.position.x
	_trade_route_panel.offset_top = _map_view_rect.position.y
	_trade_route_panel.offset_right = _map_view_rect.end.x
	_trade_route_panel.offset_bottom = _map_view_rect.end.y

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
	var bg_style := load("res://assets/ui/topbar/topbar_bg_style.tres") as StyleBox

	var right_dock := ui.get_node_or_null("RightDockBackdrop") as PanelContainer
	if right_dock == null:
		right_dock = PanelContainer.new()
		right_dock.name = "RightDockBackdrop"
		right_dock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		right_dock.add_theme_stylebox_override("panel", bg_style)
		ui.add_child(right_dock)
		ui.move_child(right_dock, 0)
	right_dock.visible = false
	right_dock.anchor_left = 0.0; right_dock.anchor_top = 0.0
	right_dock.anchor_right = 0.0; right_dock.anchor_bottom = 0.0
	right_dock.offset_left = side_left; right_dock.offset_top = top_bar_height
	right_dock.offset_right = vp.x; right_dock.offset_bottom = vp.y

	var bottom_bar := ui.get_node_or_null("BottomDockBackdrop") as PanelContainer
	if bottom_bar == null:
		bottom_bar = PanelContainer.new()
		bottom_bar.name = "BottomDockBackdrop"
		bottom_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bottom_bar.add_theme_stylebox_override("panel", bg_style)
		ui.add_child(bottom_bar)
		ui.move_child(bottom_bar, 0)
	bottom_bar.visible = false
	bottom_bar.anchor_left = 0.0; bottom_bar.anchor_top = 0.0
	bottom_bar.anchor_right = 0.0; bottom_bar.anchor_bottom = 0.0
	bottom_bar.offset_left = 0.0; bottom_bar.offset_top = vp.y - BOTTOM_BAR_HEIGHT
	bottom_bar.offset_right = side_left; bottom_bar.offset_bottom = vp.y

# -----------------------------------------------
# ROADS
# -----------------------------------------------

func _build_roads_from_data() -> void:
	var roads_node := get_node_or_null("MapContent/Roads")
	if roads_node == null:
		return
	for child in roads_node.get_children():
		if child is Line2D:
			roads_node.remove_child(child)
			child.queue_free()

	for road_data in RoadData.load_roads():
		var road_id: String = str(road_data.get("id", "Road"))
		var points: PackedVector2Array = road_data.get("points", PackedVector2Array())
		var road_color: Color = road_data.get("color", Color(0.55, 0.40, 0.20, 0.95))

		var shadow := Line2D.new()
		shadow.name = "%sShadow" % road_id
		shadow.points = points
		shadow.width = 7.0
		shadow.default_color = Color(0.105882, 0.0745098, 0.0392157, 0.22)
		shadow.joint_mode = Line2D.LINE_JOINT_ROUND
		shadow.begin_cap_mode = Line2D.LINE_CAP_ROUND
		shadow.end_cap_mode = Line2D.LINE_CAP_ROUND
		shadow.antialiased = true
		roads_node.add_child(shadow)

		var road := Line2D.new()
		road.name = road_id
		road.points = points
		road.width = 3.0
		road.default_color = road_color
		road.joint_mode = Line2D.LINE_JOINT_ROUND
		road.begin_cap_mode = Line2D.LINE_CAP_ROUND
		road.end_cap_mode = Line2D.LINE_CAP_ROUND
		road.antialiased = true
		roads_node.add_child(road)

func _smooth_road_lines() -> void:
	var roads := get_node_or_null("MapContent/Roads")
	if roads == null:
		return
	for child in roads.get_children():
		var line := child as Line2D
		if line == null or line.points.size() < 3:
			continue
		line.points = MapUtils.catmull_rom_points(line.points, 10)

# -----------------------------------------------
# TIMERS & INPUT
# -----------------------------------------------

func _setup_day_timer() -> void:
	_day_timer = Timer.new()
	_day_timer.wait_time = DAY_INTERVAL
	_day_timer.autostart = true
	_day_timer.timeout.connect(_on_day_tick)
	add_child(_day_timer)

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

func _set_speed(speed: int) -> void:
	game_speed = speed
	if speed == 0:
		_day_timer.paused = true
	else:
		_day_timer.paused = false
		_day_timer.wait_time = DAY_INTERVAL / float(speed)
	if top_bar and top_bar.has_method("set_speed"):
		top_bar.call("set_speed", game_speed)

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
	_side_panel.update()
	_trader_labels.update()
	_finance.refresh()
	_check_win_condition()

# -----------------------------------------------
# BINDINGS
# -----------------------------------------------

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
		top_bar.connect("finance_requested", _finance.toggle)

func _bind_side_panel() -> void:
	var old_toggle := get_node_or_null("UI/ContractsToggle") as Control
	if old_toggle:
		old_toggle.visible = false
	var old_panel := get_node_or_null("UI/ContractsPanel") as Control
	if old_panel:
		old_panel.visible = false
	var route_btn := get_node_or_null("UI/SidePanel/PanelMargin/Tabs/Operations/OperationsVBox/OpenTradeRouteButton") as Button
	if route_btn:
		route_btn.pressed.connect(_open_trade_route_panel)
	_side_panel.bind_signals()

# -----------------------------------------------
# TOWN BUTTONS
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

		if _events != null and _events.has_event(town_name):
			var event: Dictionary = _events.get_event(town_name)
			btn.text = "%s %s" % [str(event.get("icon", "?")), btn_text]
			btn.modulate = event.get("color", Color.WHITE)
			continue

		btn.text = btn_text

		var chance: float = 0.0
		if _risk != null:
			chance = _risk.calculate_attack_chance(town_name)

		var trend: String = _economy.get_population_trend(town_name)
		if trend == "down":
			btn.modulate = Color(1.0, 0.5, 0.5)
		elif trend == "up":
			btn.modulate = Color(0.6, 1.0, 0.6)
		elif chance >= 0.30:
			btn.modulate = Color(1.0, 0.65, 0.55)
		elif chance >= 0.20:
			btn.modulate = Color(1.0, 0.85, 0.7)
		else:
			if level == 3:
				btn.modulate = Color(0.4, 1.0, 0.4)
			elif level == 2:
				btn.modulate = Color(1.0, 0.9, 0.4)
			else:
				btn.modulate = Color(1.0, 1.0, 1.0)
	_update_risk_indicators()

func _get_town_label(town_name: String) -> String:
	var pop: int = int(_economy.get_town(town_name).get("population", 0))
	var trend: String = _economy.get_population_trend(town_name)
	var arrow: String = ""
	match trend:
		"up":   arrow = " ↑"
		"down": arrow = " ↓"
		_:      arrow = " →"
	var p := " [P]" if _posts and _posts.has_post(town_name) else ""
	return "%s%s\n👥 %d%s" % [town_name, p, pop, arrow]

# -----------------------------------------------
# TRAVEL
# -----------------------------------------------

func _on_town_pressed(town_name: String) -> void:
	if is_traveling:
		return
	if town_name == _player_data.current_town:
		_open_town(town_name)
		return

	is_traveling = true
	travel_destination   = town_name
	travel_start_map_pos = _economy.towns[_player_data.current_town].get("position", Vector2.ZERO)
	travel_end_map_pos   = _economy.towns[town_name].get("position", Vector2.ZERO)
	travel_start_pos     = _map_to_screen(travel_start_map_pos)
	travel_end_pos       = _map_to_screen(travel_end_map_pos)
	travel_total_days    = _calc_travel_days(town_name)
	travel_days_remaining = travel_total_days
	travel_elapsed_seconds = 0.0
	_refresh_buttons()
	_update_ui()

func _calc_travel_days(town_name: String) -> int:
	var from: Vector2 = _economy.towns[_player_data.current_town].get("position", Vector2.ZERO)
	var to: Vector2   = _economy.towns[town_name].get("position", Vector2.ZERO)
	return max(1, int(from.distance_to(to) / 200.0))

func _update_player_travel_position() -> void:
	var player = get_node_or_null("Player")
	if player == null:
		return
	var duration := maxf(float(travel_total_days) * DAY_INTERVAL, 0.001)
	var t := clampf(travel_elapsed_seconds / duration, 0.0, 1.0)
	player.position = _map_to_screen(travel_start_map_pos.lerp(travel_end_map_pos, t))

func _arrive() -> void:
	is_traveling = false
	var arrived_town: String = travel_destination
	_player_data.current_town = arrived_town
	travel_destination = ""
	travel_days_remaining = 0
	travel_total_days = 0
	travel_elapsed_seconds = 0.0
	_refresh_buttons()

	if _risk.roll_attack(arrived_town) and _player_data.get_total_cargo() > 0:
		var lost: Dictionary = _resolve_attack()
		_show_attack_popup(lost, arrived_town)
		return

	_update_ui()
	_open_town(arrived_town)

# -----------------------------------------------
# TOWN VIEW
# -----------------------------------------------

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
	_side_panel.update()

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

# -----------------------------------------------
# UI UPDATE
# -----------------------------------------------

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
		top_bar.call("set_values",
			_player_data.current_day,
			_player_data.gold,
			_player_data.get_total_cargo(),
			_player_data.caravan_capacity,
			location,
			travel_days
		)
	_side_panel.update()

# -----------------------------------------------
# RISK INDICATORS (tooltip)
# -----------------------------------------------

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

		var expensive: Array = []
		var cheap: Array = []
		for item in _economy.BASE_PRICES:
			var base: float = float(_economy.BASE_PRICES[item])
			if base <= 0.0:
				continue
			var current: float = float(_economy.get_price(town_name, item))
			var ratio: float = (current - base) / base
			if ratio >= 0.20:
				expensive.append({"item": item, "price": current, "ratio": ratio})
			elif ratio <= -0.15:
				cheap.append({"item": item, "price": current, "ratio": ratio})

		expensive.sort_custom(func(a, b): return float(a["ratio"]) > float(b["ratio"]))
		cheap.sort_custom(func(a, b): return float(a["ratio"]) < float(b["ratio"]))

		if not expensive.is_empty():
			lines.append("↑ Sat fırsatı:")
			for i in range(mini(3, expensive.size())):
				var e = expensive[i]
				lines.append("  %s: %.1fg (+%d%%)" % [str(e["item"]).capitalize(), float(e["price"]), int(round(float(e["ratio"]) * 100.0))])

		if not cheap.is_empty():
			lines.append("↓ Al fırsatı:")
			for i in range(mini(3, cheap.size())):
				var c = cheap[i]
				lines.append("  %s: %.1fg (%d%%)" % [str(c["item"]).capitalize(), float(c["price"]), int(round(float(c["ratio"]) * 100.0))])

		if expensive.is_empty() and cheap.is_empty():
			lines.append("Fiyatlar normal.")

		var chance: float = float(_risk.calculate_attack_chance(town_name))
		var risk_pct: int = int(round(chance * 100.0))
		lines.append("─────────────────")
		lines.append("Bandit riski: %s (%d%%)" % [_risk.get_risk_label(chance), risk_pct])

		if _events != null and _events.has_event(town_name):
			var event: Dictionary = _events.get_event(town_name)
			var days_left: int = int(event.get("ends_day", 0)) - int(_economy.current_day)
			lines.append("%s %s — %d gün kaldı" % [
				str(event.get("icon", "")),
				str(event.get("name", "")),
				maxi(days_left, 0)
			])

		btn.tooltip_text = "\n".join(lines)

# -----------------------------------------------
# ATTACK
# -----------------------------------------------

func _resolve_attack() -> Dictionary:
	var lost_items: Dictionary = {}
	var inventory_copy: Dictionary = _player_data.inventory.duplicate()
	for item in inventory_copy:
		var qty: int = int(inventory_copy[item])
		if qty <= 0:
			continue
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

# -----------------------------------------------
# TRADE ROUTE PANEL
# -----------------------------------------------

func _open_trade_route_panel() -> void:
	if _trade_route_panel != null and is_instance_valid(_trade_route_panel):
		return
	var scene := load("res://scenes/ui/TradeRoutePanel.tscn") as PackedScene
	if scene == null:
		return
	_trade_route_panel = scene.instantiate() as Control
	get_node("UI").add_child(_trade_route_panel)
	if _trade_route_panel.has_signal("closed"):
		_trade_route_panel.connect("closed", _on_trade_route_panel_closed)
	_layout_trade_route_panel()

func _on_trade_route_panel_closed() -> void:
	_trade_route_panel = null

# -----------------------------------------------
# WIN CONDITION
# -----------------------------------------------

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

# -----------------------------------------------
# LEGACY — contract tracker (unused, kept for compatibility)
# -----------------------------------------------

func _bind_contract_tracker() -> void:
	var toggle := get_node_or_null("UI/ContractsToggle") as Button
	if toggle:
		toggle.pressed.connect(_toggle_contract_tracker)
	if _contracts and _contracts.has_signal("contracts_changed"):
		_contracts.connect("contracts_changed", _update_contract_tracker)
	_side_panel.update()

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
	title.add_theme_color_override("font_color", MapUtils.contract_status_color(str(contract.get("status", ""))))
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
		return "Completed on day %d. Reward: %dg" % [int(contract.get("completed_day", 0)), int(contract.get("reward_gold", 0))]
	if status == "failed":
		return "Failed on day %d. Target was %s." % [int(contract.get("failed_day", 0)), target]
	var progress := "Ready"
	if _player_data.current_town != target:
		progress = "Travel to %s" % target
	elif held < required:
		progress = "Need %d more %s" % [required - held, item.capitalize()]
	return "%d/%d %s | %s | %d day(s) left | %dg" % [held, required, item.capitalize(), progress, days_left, int(contract.get("reward_gold", 0))]

# -----------------------------------------------
# LEGACY — unused panel builders
# -----------------------------------------------

func _build_rank_panel() -> void:
	var ui := get_node("UI")
	var panel := PanelContainer.new()
	panel.name = "RankPanel"
	panel.add_theme_stylebox_override("panel", load("res://assets/ui/topbar/topbar_section_bg_style.tres"))
	ui.add_child(panel)
	var vbox := VBoxContainer.new()
	vbox.name = "RankVBox"
	panel.add_child(vbox)
	var rm = get_node("/root/RankManager")
	rm.connect("rank_changed", _on_rank_changed_legacy)
	_update_rank_panel()

func _on_rank_changed_legacy(old_rank: String, new_rank: String) -> void:
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
			row.text = "- %s: %d / %d" % [key.replace("_", " ").capitalize(), cur, req]
			row.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4) if cur >= req else Color(1.0, 0.5, 0.4))
			vbox.add_child(row)

func _build_goal_panel() -> void:
	var ui := get_node("UI")
	var panel := PanelContainer.new()
	panel.name = "GoalPanel"
	panel.add_theme_stylebox_override("panel", load("res://assets/ui/topbar/topbar_section_bg_style.tres"))
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
		var filled: int = clampi(int(round(float(prosperity) / float(threshold) * 10.0)), 0, 10)
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

func _build_cargo_panel() -> void:
	var ui := get_node("UI")
	var panel := PanelContainer.new()
	panel.name = "CargoPanel"
	panel.anchor_left = 1.0; panel.anchor_top = 1.0
	panel.anchor_right = 1.0; panel.anchor_bottom = 1.0
	panel.offset_left = -180.0; panel.offset_top = -220.0
	panel.offset_right = -10.0; panel.offset_bottom = -10.0
	panel.add_theme_stylebox_override("panel", load("res://assets/ui/topbar/topbar_section_bg_style.tres"))
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
	title.text = "CARGO  (%d/%d)" % [int(_player_data.get_total_cargo()), int(_player_data.caravan_capacity)]
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
